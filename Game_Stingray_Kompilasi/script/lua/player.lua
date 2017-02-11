require 'core/appkit/lua/class'
require 'core/appkit/lua/app'
local SimpleProject = require 'core/appkit/lua/simple_project'
local ComponentManager = require 'core/appkit/lua/component_manager'
local UnitController = require 'core/appkit/lua/unit_controller'
local UnitLink = require 'core/appkit/lua/unit_link'
local CameraWrapper = require 'core/appkit/lua/camera_wrapper'
local PlayerHud = require 'script/lua/player_hud'
local Util = require 'core/appkit/lua/util'

local Pad1 = stingray.Pad1

-- On touch devices we will override the input_mapper in Appkit to use the Hud Controls.
if scaleform and Util.use_touch() then
	function Appkit.input_mapper:get_motion_input()
		return PlayerHud:get_motion_input()
	end
end

Project.Player = Appkit.class(Project.Player)
local Player = Project.Player -- cache off for readability and speed

-- cache off for readability and speed
local Keyboard = stingray.Keyboard
local Vector3 = stingray.Vector3
local Matrix4x4 = stingray.Matrix4x4
local Matrix4x4Box = stingray.Matrix4x4Box
local Quaternion = stingray.Quaternion
local Unit = stingray.Unit
local World = stingray.World
local Level = stingray.Level

local free_cam_move_speed = stingray.Vector3Box(Vector3(3.8,3.8,3.8))
local free_cam_sprint_speed = stingray.Vector3Box(Vector3(9,9,8))
local free_cam_yaw_speed = 0.085
local free_cam_pitch_speed = 0.075

local character_move_speed = stingray.Vector3Box(Vector3(3.5,3.5,3.5))
local character_sprint_speed = stingray.Vector3Box(Vector3(7,7,7))
local character_cam_yaw_speed = 0.1
local character_cam_pitch_speed = 0.0 -- character model does not pitch

local function play_spawn_sound()
	if stingray.Wwise then
		stingray.Wwise.load_bank("content/audio/default") -- temporarily necessary for autoload mode to work
		local wwise_world = stingray.Wwise.wwise_world(SimpleProject.world)
		stingray.WwiseWorld.trigger_event(wwise_world, "sfx_spawn_sound")
	end
end

local function spawn_freecam_player(self, level, view_position, view_rotation)
	view_position = view_position or Vector3(0, 0, 2)
	view_rotation = view_rotation or Quaternion.identity()

	local world = Level.world(level)
	local unit = SimpleProject.camera_unit

	local player_camera = self.player_camera
	player_camera.unit = unit

	-- Camera
	local camera_wrapper = Appkit.CameraWrapper(player_camera, unit, 1)
	camera_wrapper:set_local_position(view_position)
	camera_wrapper:set_local_rotation(view_rotation)
	camera_wrapper:enable()

	-- Add camera input movement. Starts enabled.
	local controller = UnitController(player_camera, unit, Appkit.input_mapper)
	controller:set_move_speed(free_cam_move_speed:unbox())
	controller:set_yaw_speed(free_cam_yaw_speed)
	controller:set_pitch_speed(free_cam_pitch_speed)

	-- Give free cam ability to attached to character for walking mode. Starts disabled.
	local unit_link = UnitLink(player_camera, level, unit, 1, nil, 1, false)

	self.is_freecam_mode = true
end

-- Main Player Spawn function.
-- Player starts in Free Cam mode, and can toggle to spawning a character and back to Free Cam.
function Player.spawn_player(level, view_position, view_rotation)
	if not level then
		print "ERROR: No current level - cannot spawn"
		return
	end

	local player = Player()

	spawn_freecam_player(player, level, view_position, view_rotation)
	PlayerHud:init_hud()
	play_spawn_sound()

	-- allow appkit to manage update and shutdown
	Appkit.manage_level_object(level, Player, player)
end

function Player:init()
	-- The Basic Project gameplay design is for the player character to spawn, but the 
	-- camera is initially set to freecam and the player character will be stationary.
	self.player_camera = {}
	self.land_character = {}
	self.is_freecam_mode = false
	self.saved_freecam_pose = Matrix4x4Box(Matrix4x4.identity())
end

local function is_character_spawned(self)
	return self.land_character.unit ~= nil
end

local function despawn_character(self)
	local land_character = self.land_character
	if land_character and is_character_spawned(self) then
		ComponentManager.remove_components(land_character)
		World.destroy_unit(SimpleProject.world, land_character.unit)
		land_character.unit = nil
	end
end

local function despawn_freecam(self)
	local player_camera = self.player_camera
	if player_camera then
		local world = SimpleProject.world
		ComponentManager.remove_components(player_camera)
		player_camera.unit = nil
	end
end

function Player.shutdown(self, level)
	despawn_character(self)
	despawn_freecam(self)
	PlayerHud:shutdown()
end

local function enable_free_mode(self)
	local player_camera = self.player_camera

	-- detach camera from character
	local unit_link = UnitLink.manager:get(player_camera)
	unit_link:unlink()

	despawn_character(self)

	-- enable camera movement and yaw
	local freecam_controller = UnitController.manager:get(player_camera)
	freecam_controller:set_move_speed(free_cam_move_speed:unbox())
	freecam_controller:set_yaw_speed(free_cam_yaw_speed)

	-- set freecam to saved off camera position
	local camera_wrapper = CameraWrapper.manager:get(player_camera)
	camera_wrapper:set_local_pose(self.saved_freecam_pose:unbox())

	self.is_freecam_mode = true
end

local function spawn_player_character(self, pose)
	local world = SimpleProject.world
	local land_unit = World.spawn_unit(world, "content/models/character/character", pose)

	local land_character = self.land_character
	land_character.unit = land_unit

	-- Add Character input movement.
	local controller = UnitController(land_character, land_unit, Appkit.input_mapper)
	controller:set_move_speed(character_move_speed:unbox())
	controller:set_yaw_speed(character_cam_yaw_speed)
	controller:set_pitch_speed(character_cam_pitch_speed)
	controller:set_mover("body")
	controller:set_gravity_enabled(true)
end

local function enable_walk_mode(self)
	local player_camera = self.player_camera

	-- save off freecam camera position
	local camera_wrapper = CameraWrapper.manager:get(player_camera)
	self.saved_freecam_pose:store(camera_wrapper:local_pose())

	-- disable movement and yaw on camera
	local freecam_controller = UnitController.manager:get(player_camera)
	freecam_controller:set_move_speed(Vector3(0,0,0))
	freecam_controller:set_yaw_speed(0)

	-- spawn character
	local character_pose = camera_wrapper:local_pose()
	local forward = Matrix4x4.forward(character_pose)
	Vector3.set_z(forward, 0) -- remove pitch
	local rot = Quaternion.look(forward)
	local no_pitch_character_pose = Matrix4x4.from_quaternion(rot)
	Matrix4x4.set_translation(no_pitch_character_pose, Matrix4x4.translation(character_pose))
	spawn_player_character(self, no_pitch_character_pose)

	-- attach camera to character
	local land_unit = self.land_character.unit
	local unit_link = UnitLink.manager:get(player_camera)
	unit_link:set_parent(land_unit, 1)
	unit_link:link()

	-- offset camera to eye height
	local pose_offset = Matrix4x4.identity()
	local camera_node_id = Unit.node(land_unit, "eyeheight")
	local delta = Unit.world_position(land_unit, camera_node_id) - Unit.world_position(land_unit, 1)
	Matrix4x4.set_translation(pose_offset, delta)
	camera_wrapper:set_local_pose(pose_offset)

	self.is_freecam_mode = false
end

local function check_camera_mode(self)
	-- freecam toggle input
	local index = Keyboard.button_id("f2")
	if (index and Keyboard.pressed(index)) or PlayerHud:check_toggle_camera() then
		if self.is_freecam_mode then
			enable_walk_mode(self)
		else
			enable_free_mode(self)
		end
	end
end

local function check_jump(self)
	if not self.is_freecam_mode then
		local is_keyboard_jumping = Keyboard.pressed(Keyboard.button_id("space"))
		local is_pad_jumping = Pad1 and Pad1.active() and Pad1.pressed(Pad1.button_id(Appkit.Util.plat(nil, "a", nil, "cross")))
		if is_keyboard_jumping or is_pad_jumping or PlayerHud:check_jump() then
			local controller = UnitController.manager:get(self.land_character)
			if controller and controller.velocity.z == 0 then
				controller:add_impulse(Vector3(0,0,14))
			end
		end
	end
end

local function check_sprint(self)
	local is_keyboard_sprinting = Keyboard.button(Keyboard.button_id("left shift")) > 0 
									and Keyboard.button(Keyboard.button_id("w")) > 0 
									and Keyboard.button(Keyboard.button_id("a")) == 0 
									and Keyboard.button(Keyboard.button_id("d")) == 0
	local input = Appkit.input_mapper:get_motion_input()
	local is_pad_sprinting = Pad1 and Pad1.active() 
								and Pad1.button(Pad1.button_id(Appkit.Util.plat(nil, "left_thumb", nil, "l3"))) > 0
								and input.move.y > 0.9
	if is_keyboard_sprinting or is_pad_sprinting or PlayerHud:check_sprint() then
		if is_character_spawned(self) then
			local controller = UnitController.manager:get(self.land_character)
			controller:set_move_speed(character_sprint_speed:unbox())
		else
			local controller = UnitController.manager:get(self.player_camera)
			controller:set_move_speed(free_cam_sprint_speed:unbox())
		end
	else
		if is_character_spawned(self) then
			local controller = UnitController.manager:get(self.land_character)
			controller:set_move_speed(character_move_speed:unbox())
		else
			local controller = UnitController.manager:get(self.player_camera)
			controller:set_move_speed(free_cam_move_speed:unbox())
		end
	end
end

local function check_exit_level(self)
	-- level exit input
	if Appkit.is_standalone() then
		local index = Keyboard.button_id("f5")
		local b1_pressed = index and Keyboard.pressed(index) 
		local index = Keyboard.button_id("esc")
		local b2_pressed = index and Keyboard.pressed(index) 
		if b1_pressed or b2_pressed or PlayerHud:exit_level() then
			SimpleProject.change_level(Project.level_names.menu)
		end
	end
end

function Player.update(self, dt)
	PlayerHud:update(dt)
	check_camera_mode(self)
	check_jump(self)
	check_sprint(self)
	check_exit_level(self)
end

return Player