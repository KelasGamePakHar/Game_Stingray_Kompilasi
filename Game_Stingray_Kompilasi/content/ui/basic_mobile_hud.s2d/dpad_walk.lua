local thisActor = ...;
local actorName = scaleform.Actor.name(thisActor);

local function transmitAnalogValues(x, y)
	local evt = {	eventId = scaleform.EventTypes.Custom, 
        		    name = "analog_stick",
            		data = {action = "walk", x = x, y = y} 
    }
    
    --print("walk: " .. x .. " : " .. y)
    
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
	clicked = function()
        -- JUMP
        local evt = {	eventId = scaleform.EventTypes.Custom, 
        		    name = "analog_stick",
            		data = {action = "jump"} 
        }
        
        --print("jump")
        
    	scaleform.Stage.dispatch_event(evt)
	end
}

return handler;