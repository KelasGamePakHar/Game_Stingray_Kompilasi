--

-- IMPORTANT: This script resource may be attached to all Button widgets created by the Widget Creator panel.

--            If modifications are required, then first copy this file to a unique path and fix all necessary

--            script components' resource paths.

--



local thisActor = ...;

scaleform.Actor.set_mouse_enabled_for_children(thisActor, false);



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

    	emitEvent("pressed");

    	emitEvent("stateChanged", "press");

    end,

    click = function()

	    local container = scaleform.Actor.container(thisActor);

    	scaleform.AnimationComponent.goto_label(container, "over");

    	scaleform.AnimationComponent.play(container);

    	emitEvent("clicked");

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

    	emitEvent("out");

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

    states.out()

end )



local mouseReleaseOutsideEventListener = scaleform.EventListener.create(mouseReleaseOutsideEventListener, function(e)

	local container = scaleform.Actor.container(thisActor);

	scaleform.AnimationComponent.goto_label(container, "normal");

	scaleform.AnimationComponent.play(container);

	emitEvent("releasedOutside");

	emitEvent("stateChanged", "normal");

end )



scaleform.EventListener.connect(mouseDownEventListener, thisActor, scaleform.EventTypes.MouseDown)

scaleform.EventListener.connect(mouseUpEventListener, thisActor, scaleform.EventTypes.MouseUp)

scaleform.EventListener.connect(mouseOverEventListener, thisActor, scaleform.EventTypes.MouseOver)

scaleform.EventListener.connect(mouseOutEventListener, thisActor, scaleform.EventTypes.MouseOut)

scaleform.EventListener.connect(mouseReleaseOutsideEventListener, thisActor, scaleform.EventTypes.MouseUpOutside)



return states;