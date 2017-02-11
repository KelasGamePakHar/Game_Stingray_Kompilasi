-- NOTE: This handler object is auto-generated. Feel free to modify the contents of this file.
--
-- IMPORTANT: This script resource must be attached to a script component named WidgetHandler to work
--            with the Button widget's base script.
-- 

local thisActor = ...;
local actorName = scaleform.Actor.name(thisActor);

-- The handler object expected by the base widget script
-- If any of the handler methods are not defined, then the base widget will not attempt to invoke them.

local handler = {

	clicked = function()
      local evt = {   eventId = scaleform.EventTypes.Custom, 
                        name = "action",
                        data = { message = "start" } 
                    }
            scaleform.Stage.dispatch_event(evt)
	end
}

return handler;