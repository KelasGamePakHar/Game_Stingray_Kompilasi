-- ============================================================================
--Globals
-- ============================================================================
_G.touchMode = _G.touchMode or false

-- Add all custom event listeners here for cleanup
-- Each element must be 
-- { 
--	  actor = <actorRef>, 
--	  eventName = <string for event name, e.g.: "Custom">, 
--	  listenerId = <listener ID from addEventListener> 
-- }
local thisActor = ...
-- ============================================================================
-- Stage setup
-- ============================================================================
-- There no vector graphics in this project. Disable EdgeAA
scaleform.Stage.set_edge_aa_mode(scaleform.EdgeAAModes.Off)
--
-- The content has been designed to support arbitrary aspect ratios
-- with appropriate safe zones. Changing scale mode to 'No Border', 
-- as we want the content to scale up and we aren't worried if the
-- the content is chopped on the larger dimension.
scaleform.Stage.set_view_scale_mode(scaleform.ViewScaleModes.NoBorder);
local function switchToScene(scenePath) -- Path relative to s2d project

	scaleform.Stage.remove_all_scenes()

	local newScene = scaleform.Actor.load(scenePath)
	scaleform.Stage.set_scene(newScene)
end

-- ============================================================================
-- Globals
-- ============================================================================
_G.touchMode = _G.touchMode or false

local customEventListener = scaleform.EventListener.create(customEventListener, function(e)
	local msg_handled = false

	local t = {}
	for w in string.gmatch(e.name, '([^:]+)') do
		table.insert(t,w)
	end

	if t[1] == "set_touch_mode" then
		_G.touchMode = (t[2] == "true")
	end
	
	if t[1] == "switch_to_scene" then
		switchToScene(t[2])
	end
end )
scaleform.EventListener.connect(customEventListener,thisActor,scaleform.EventTypes.Custom)

-- DEBUG
_G.touchMode = true