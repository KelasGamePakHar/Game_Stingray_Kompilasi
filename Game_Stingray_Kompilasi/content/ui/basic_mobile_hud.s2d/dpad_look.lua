local thisActor = ...;
local actorName = scaleform.Actor.name(thisActor);

local function transmitAnalogValues(x, y)
	local evt = {	eventId = scaleform.EventTypes.Custom, 
        		    name = "analog_stick",
            		data = {action = "look", x = x, y = y} 
    }
    
    --print("look: " .. x .. " : " .. y)
    
	scaleform.Stage.dispatch_event(evt)
end

local handler = {
    dragged = function(coords)
        -- Send analog movement event
        transmitAnalogValues(coords.x, coords.y)
    end,
    released = function()
        -- Analog back at (0,0)
        transmitAnalogValues(0, 0)
    end,
	pressed = function()
        -- Camera switch
        local evt = {	eventId = scaleform.EventTypes.Custom, 
        		    name = "analog_stick",
            		data = {action = "switch_camera_mode"} 
        }
        
        --print("camera switch")
        
    	scaleform.Stage.dispatch_event(evt)
	end
}

return handler;