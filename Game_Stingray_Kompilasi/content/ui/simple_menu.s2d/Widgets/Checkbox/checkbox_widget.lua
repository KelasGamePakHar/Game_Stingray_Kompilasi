--
-- IMPORTANT: This script resource may be attached to all checkbox widgets created by the Widget Creator panel.
--            If modifications are required, then first copy this file to a unique path and fix all necessary
--            script components' resource paths.
--

local thisActor = ...;
scaleform.Actor.set_mouse_enabled_for_children(thisActor, false);
local container = scaleform.Actor.container(thisActor);
if container ~= nil then
	local background_checked = scaleform.ContainerComponent.actor_by_name(container, "background_checked");
	local content_checked = scaleform.ContainerComponent.actor_by_name(container, "content_checked");
	scaleform.Actor.set_visible(background_checked, false);
	scaleform.Actor.set_visible(content_checked, false);
end

local emitEvent = function(func, param)
	local comp = scaleform.Actor.component_by_name(thisActor, "WidgetHandler");
	if comp ~= nil then
		local handlerObject = scaleform.ScriptComponent.script_results(comp);
		if handlerObject ~= nil then
			if handlerObject[func] ~= nil then
			    if (param) then
				    handlerObject[func](param);
				else
				    handlerObject[func]();
				end
			end
		end
	end	
end

local states = {
    press = function()
        local container = scaleform.Actor.container(thisActor);
    	scaleform.AnimationComponent.goto_label(container, "press");
    	scaleform.AnimationComponent.play(container);
    	emitEvent("stateChanged", "press");
    end,
    click = function()
        local container = scaleform.Actor.container(thisActor);
    	local background_normal = scaleform.ContainerComponent.actor_by_name(container, "background_normal");
        local content_normal = scaleform.ContainerComponent.actor_by_name(container, "content_normal");
    	local background_checked = scaleform.ContainerComponent.actor_by_name(container, "background_checked");
    	local content_checked = scaleform.ContainerComponent.actor_by_name(container, "content_checked");
    	local isVisible = scaleform.Actor.visible(background_normal);
    	scaleform.Actor.set_visible(background_normal, not isVisible);
    	scaleform.Actor.set_visible(content_normal, not isVisible);
    	scaleform.Actor.set_visible(background_checked, isVisible);
    	scaleform.Actor.set_visible(content_checked, isVisible);
    
    	scaleform.AnimationComponent.goto_label(container, "over");
    	scaleform.AnimationComponent.play(container);
    	emitEvent("clicked", isVisible);
    	emitEvent("stateChanged", "over");
    end,
    over = function()
        local container = scaleform.Actor.container(thisActor);
    	scaleform.AnimationComponent.goto_label(container, "over");
    	scaleform.AnimationComponent.play(container);
    	emitEvent("stateChanged", "over");
	end,
    normal = function()
        local container = scaleform.Actor.container(thisActor);
    	scaleform.AnimationComponent.goto_label(container, "normal");
    	scaleform.AnimationComponent.play(container);
    	emitEvent("stateChanged", "normal");
	end,
	out = function()
	    local container = scaleform.Actor.container(thisActor);
    	scaleform.AnimationComponent.goto_label(container, "normal");
    	scaleform.AnimationComponent.play(container);
    	emitEvent("stateChanged", "normal");
    end
}

local mouseDownEventListener = scaleform.EventListener.create(mouseDownEventListener, function(e)
	states.press()
end )

local mouseUpEventListener = scaleform.EventListener.create(mouseUpEventListener, function(e)
	states.click()
end )

local mouseOverEventListener = scaleform.EventListener.create(mouseOverEventListener, function(e)
	states.over()
end )

local mouseOutEventListener = scaleform.EventListener.create(mouseOutEventListener, function(e)
	states.normal()
end )

scaleform.EventListener.connect(mouseDownEventListener, thisActor, scaleform.EventTypes.MouseDown)
scaleform.EventListener.connect(mouseUpEventListener, thisActor, scaleform.EventTypes.MouseUp)
scaleform.EventListener.connect(mouseOverEventListener, thisActor, scaleform.EventTypes.MouseOver)
scaleform.EventListener.connect(mouseOutEventListener, thisActor, scaleform.EventTypes.MouseOut)

return states