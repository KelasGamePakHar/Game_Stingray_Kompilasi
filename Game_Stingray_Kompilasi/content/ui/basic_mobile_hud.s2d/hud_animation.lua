local thisActor = ...
local container = scaleform.Actor.container(thisActor)
local controls = scaleform.ContainerComponent.actor_by_name(container, "controls")

scaleform.Actor.set_visible(controls, _G.touchMode)

-- ============================================================================
-- Event Handlers
-- ============================================================================
local timelineTriggerListener = scaleform.EventListener.create(timelineTriggerListener, function(e)
	if (e.name == "hudClosed") then
		if (_G.hudCloseCommand == "returnToMenu") then
			local evt = {	eventId = scaleform.EventTypes.Custom, 
				name = "return_to_menu",
				data = {} 
			}
			scaleform.Stage.dispatch_event(evt)
		end
	end
end )

scaleform.EventListener.connect(timelineTriggerListener, thisActor, scaleform.EventTypes.TimelineTrigger)