-- NOTE: This handler object is auto-generated. Feel free to modify the contents of this file.
--
-- IMPORTANT: This script resource must be attached to a script component named WidgetHandler to work
--            with the Button widget's base script.
-- 

local thisActor = ...;
local actorName = scaleform.Actor.name(thisActor);

local isFreeCam = false;

-- The handler object expected by the base widget script
-- If any of the handler methods are not defined, then the base widget will not attempt to invoke them.
local handler = {
    
	-- Invoked when the button is pressed
	--[[
	pressed = function()
		print(actorName .. " button pressed")
	end
	--]]
	
	-- Invoked when the button is pressed
	pressed = function()
		local evt = {	eventId = scaleform.EventTypes.Custom, 
        		    name = "button_click",
            		data = {action = "toggle_camera"} 
        }
        
        --print("toggle_camera")
        local icon = scaleform.Stage.actor_by_name_path("hud.ingame.controls.bottom_left.toggle_camera.icon.icon");
        local bitmap = scaleform.Actor.component_by_name(icon, "bitmap");
        
        if isFreeCam then
            scaleform.BitmapComponent.load(bitmap, "icon_cam_walk.png");
        else
            scaleform.BitmapComponent.load(bitmap, "icon_cam_free.png");
        end
        
        isFreeCam = not isFreeCam;
        
    	scaleform.Stage.dispatch_event(evt)
	end
	
	-- Invoked when the button state changes
	-- Param newState : String
	--[[
	stateChanged = function(newState)
		print(actorName .. " state changed to " .. newState)
	end
	--]]
}

return handler;