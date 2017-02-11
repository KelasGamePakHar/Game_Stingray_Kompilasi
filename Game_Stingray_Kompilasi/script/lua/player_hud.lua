local Util = require 'core/appkit/lua/util'
local SimpleProject= require 'core/appkit/lua/simple_project'
Project.PlayerHud = Project.PlayerHud or {}
local PlayerHud = Project.PlayerHud

local Vector3 = stingray.Vector3
local Vector3Box = stingray.Vector3Box
local Keyboard = stingray.Keyboard

local hud_level = nil

-- Scaleform is an engine plugin and is required for this file.
if scaleform == nil then 
	PlayerHud = { init_hud = function() end,
				  update   = function() end,
				  shutdown = function() end,
				  exit_level = function() end,
				  get_motion_input = function() assert(false) end,
				  check_toggle_camera = function() return false end,
				  check_sprint = function() return false end,
				  check_jump = function() return false end
				}
	return PlayerHud
end

function PlayerHud:on_custom_event(evt)
	if evt.name == "analog_stick" then
		if evt.data.action == "jump" then
			self.input.jump = true
		end
		if evt.data.action == "walk" then
			local move = Vector3(evt.data.x, -evt.data.y,0)
			self.input.move:store(Vector3.normalize(move))
		end
		if evt.data.action == "look"  then
			local pan = Vector3(evt.data.x, evt.data.y, 0)
			self.input.pan:store(4 * Vector3.normalize(pan)) --speed up pan rate a bit for look.
		end
	end

	if evt.name == "button_click" then
		if evt.data.action == "start_sprint" then
			self.input.sprint = true
			local move = Vector3(0, 1, 0)
			self.input.move:store(Vector3.normalize(move))
		end

		if evt.data.action == "stop_sprint" then
			local move = Vector3(0, 0, 0)
			self.input.move:store(Vector3.normalize(move))
			self.input.sprint = false
		end

		if evt.data.action == "toggle_camera" then
			self.input.toggle_camera = true
		end
		if evt.data.action == "return" then
			self.input.exit_level = true
		end
	end
end

function PlayerHud:init_hud()
	--Used for mobile hud controls but it simplifies the logic in player if they're always available.
	self.input = {
		pan = Vector3Box(Vector3(0, 0, 0)),
		move = Vector3Box(Vector3(0, 0, 0)),
		jump = false,
		toggle_camera = false,
		sprint = false,
		exit_level = false
	}

	--On PC show only the dpad hud.
	if  Util.is_pc() then 
		local current_level = SimpleProject.level
		scaleform.Stingray.load_project_and_scene("content/ui/template_hud.s2d/template_hud");
		hud_level = current_level
	end

	--On Touch devices display touch specific hud
	if  Util.use_touch() then
		local current_level = SimpleProject.level
		scaleform.Stingray.load_project_and_scene("content/ui/basic_mobile_hud.s2d/basic_mobile_hud");
		hud_level = current_level

		--Register a custom listener to check for different controls.
		local custom_listener = PlayerHud.custom_listener
		custom_listener = scaleform.EventListener.create(custom_listener, function (e) PlayerHud.on_custom_event(PlayerHud,e) end)
		PlayerHud.custom_listener = custom_listener
		scaleform.EventListener.connect(custom_listener, scaleform.EventTypes.Custom)
	end
end

function PlayerHud:shutdown(level)
	if scaleform then
		scaleform.Stingray.unload_project();
		if Util.use_touch() then
			PlayerHud.custom_listener = nil
		end
		hud_level = nil
	end
end

local function update_pc_hud()
	local event = {
		eventId = scaleform.EventTypes.Custom,
		name = nil,
		data = nil
	}
	--Controlling HUD features through custom messages and key presses.
	if stingray.Keyboard.pressed(stingray.Keyboard.button_id("w"))  then
		event.name = "keypressed"
		event.data = "up"
		scaleform.Stage.dispatch_event(event)
	elseif stingray.Keyboard.released(stingray.Keyboard.button_id("w"))  then
		event.name = "keyreleased"
		event.data = "up"
		scaleform.Stage.dispatch_event(event)
	end
	
	if stingray.Keyboard.pressed(stingray.Keyboard.button_id("a")) then
		event.name = "keypressed"
		event.data = "left"
		scaleform.Stage.dispatch_event(event)
	elseif stingray.Keyboard.released(stingray.Keyboard.button_id("a")) then
		event.name = "keyreleased"
		event.data = "left"
		scaleform.Stage.dispatch_event(event)
	end

	if stingray.Keyboard.pressed(stingray.Keyboard.button_id("s"))  then
		event.name = "keypressed"
		event.data = "down"
		scaleform.Stage.dispatch_event(event)
	elseif stingray.Keyboard.released(stingray.Keyboard.button_id("s"))  then
		event.name = "keyreleased"
		event.data = "down"
		scaleform.Stage.dispatch_event(event)
	end
	
	if stingray.Keyboard.pressed(stingray.Keyboard.button_id("d")) then
		event.name = "keypressed"
		event.data = "right"
		scaleform.Stage.dispatch_event(event)
	elseif stingray.Keyboard.released(stingray.Keyboard.button_id("d")) then
		event.name = "keyreleased"
		event.data = "right"
		scaleform.Stage.dispatch_event(event)
	end
end

function PlayerHud:update(dt)
	if Util.is_pc() then
		update_pc_hud()
	end
end

--Implement handlers for touch controls to override appkit input_mapper and project specific controls.
function PlayerHud:get_motion_input()
	local input = self.input
	return {move = input.move:unbox(), pan = input.pan:unbox()}
end

function PlayerHud:check_toggle_camera()
	local ret = self.input.toggle_camera
	self.input.toggle_camera = false
	return ret
end

function PlayerHud:check_sprint()
	return self.input.sprint
end

function PlayerHud:check_jump()
	local ret = self.input.jump
	self.input.jump = false
	return ret
end

function PlayerHud:exit_level()
	local ret = self.input.exit_level
	self.input.exit_level = false
	return ret
end

return PlayerHud