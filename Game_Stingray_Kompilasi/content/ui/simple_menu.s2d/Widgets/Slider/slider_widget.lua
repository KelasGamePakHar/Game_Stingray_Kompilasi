--
-- IMPORTANT: This script resource may be attached to all slider widgets created by the Widget Creator panel.
--            If modifications are required, then first copy this file to a unique path and fix all necessary
--            script components' resource paths.
--

-- Local vars
local thisActor = ...;
local isPressed = false;
local lastX = 0;
local maxX = 0;
local lastSliderValue = 0;

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

-- local functions
local setGripBitmap = function(label)
	local container = scaleform.Actor.container(thisActor);
	local grip_normal = scaleform.ContainerComponent.actor_by_name(container, "grip_normal");
	local grip_press = scaleform.ContainerComponent.actor_by_name(container, "grip_press");
	local grip_over = scaleform.ContainerComponent.actor_by_name(container, "grip_over");
	scaleform.Actor.set_visible(grip_normal, label=="normal");
	scaleform.Actor.set_visible(grip_press, label=="press");
	scaleform.Actor.set_visible(grip_over, label=="over");
end

local setGripBitmapPosition = function(ptPosition)
	local container = scaleform.Actor.container(thisActor);
	local grip_normal = scaleform.ContainerComponent.actor_by_name(container, "grip_normal");
	local grip_press = scaleform.ContainerComponent.actor_by_name(container, "grip_press");
	local grip_over = scaleform.ContainerComponent.actor_by_name(container, "grip_over");
	scaleform.Actor.set_local_position(grip_normal, ptPosition);
	scaleform.Actor.set_local_position(grip_press, ptPosition);
	scaleform.Actor.set_local_position(grip_over, ptPosition);
end


-- Disable mouse for children
local container = scaleform.Actor.container(thisActor);
if container ~= nil then
	local background = scaleform.ContainerComponent.actor_by_name(container, "background");
	local grip_normal = scaleform.ContainerComponent.actor_by_name(container, "grip_normal");
	local grip_press = scaleform.ContainerComponent.actor_by_name(container, "grip_press");
	local grip_over = scaleform.ContainerComponent.actor_by_name(container, "grip_over");
	scaleform.Actor.set_mouse_enabled(background, false);
	scaleform.Actor.set_mouse_enabled(grip_normal, false);
	scaleform.Actor.set_mouse_enabled(grip_press, false);
	scaleform.Actor.set_mouse_enabled(grip_over, false);
    scaleform.Actor.set_visible(grip_press, false);
	scaleform.Actor.set_visible(grip_over, false);
end

local states = {
    press = function()
        local container = scaleform.Actor.container(thisActor);
    	local background = scaleform.ContainerComponent.actor_by_name(container, "background");
    	local grip_normal = scaleform.ContainerComponent.actor_by_name(container, "grip_normal");
    	isPressed = true;
    	setGripBitmap("press");
    	local dim_bg = scaleform.Actor.dimensions(background);
    	local dim_grip = scaleform.Actor.dimensions(grip_normal);
    	maxX = dim_bg.width - dim_grip.width;
    	emitEvent("gripDown");
    end,
    click = function(target)
	    if isPressed then
		emitEvent("gripUp");
    	end
        isPressed = false;
    	lastX = 0;
    	if target == thisActor or target == nil then
    	    setGripBitmap("over");
    	else
    	    setGripBitmap("normal");
        end
    end,
    over = function()
        if not isPressed then
        	local container = scaleform.Actor.container(thisActor);
        	local background = scaleform.ContainerComponent.actor_by_name(container, "background");
        	setGripBitmap("over");
        end
        emitEvent("over");
	end,
    normal = function()
        if not isPressed then
	        setGripBitmap("normal");
	    end
	end,
	out = function()
	    if not isPressed then
	        setGripBitmap("normal");
	    end
	    emitEvent("out");
    end,
    getValue = function()
        local container = scaleform.Actor.container(thisActor);
    	local background = scaleform.ContainerComponent.actor_by_name(container, "background");
    	local grip_normal = scaleform.ContainerComponent.actor_by_name(container, "grip_normal");

    	local dim_bg = scaleform.Actor.dimensions(background);
    	local dim_grip = scaleform.Actor.dimensions(grip_normal);
    	maxX = dim_bg.width - dim_grip.width;
		
		local container = scaleform.Actor.container(thisActor);
		local grip_normal = scaleform.ContainerComponent.actor_by_name(container, "grip_normal");
		local pt = scaleform.Actor.local_position(grip_normal);
		
		return pt.x/maxX*100;
    end,
    setValue = function(newSliderValue)
        if newSliderValue > 100 or newSliderValue < 0 then
            return
        end
        
		if newSliderValue ~= lastSliderValue then
			lastSliderValue = newSliderValue;
			emitEvent("valueChanged", newSliderValue);
		end
		
		local container = scaleform.Actor.container(thisActor);
    	local background = scaleform.ContainerComponent.actor_by_name(container, "background");
    	local grip_normal = scaleform.ContainerComponent.actor_by_name(container, "grip_normal");

    	local dim_bg = scaleform.Actor.dimensions(background);
    	local position = scaleform.Actor.local_position(background);
    	local dim_grip = scaleform.Actor.dimensions(grip_normal);
    	maxX = dim_bg.width - dim_grip.width;
		
		local container = scaleform.Actor.container(thisActor);
		local grip_normal = scaleform.ContainerComponent.actor_by_name(container, "grip_normal");
		local pt = scaleform.Actor.local_position(grip_normal);
		pt.x = newSliderValue * maxX / 100;
        
		if pt.x > maxX then
			pt.x = maxX;
		end
		if pt.x < 0 then
			pt.x = 0;
		end
		
		setGripBitmapPosition(pt);
    end
}

-- Mouse event listeners
local mouseDownEventListener = scaleform.EventListener.create(mouseDownEventListener, function(e)
	states.press()
end )

local mouseUpEventListener = scaleform.EventListener.create(mouseUpEventListener, function(e)
    states.click(e.target)
end )

local mouseOverEventListener = scaleform.EventListener.create(mouseOverEventListener, function(e)
    states.over()
end )

local mouseOutEventListener = scaleform.EventListener.create(mouseOutEventListener, function(e)
	states.out()
end )

local mouseMoveEventListener = scaleform.EventListener.create(mouseMoveEventListener, function(e)
    if isPressed == true then
		if lastX ~= 0 then
			local container = scaleform.Actor.container(thisActor);
			local grip_normal = scaleform.ContainerComponent.actor_by_name(container, "grip_normal");
			local xScale = scaleform.Actor.local_scale_3d(thisActor).x;
            local pt = scaleform.Actor.local_position(grip_normal);
			pt.x = pt.x + (e.stageX - lastX)/xScale;
			
			if pt.x > maxX then
				pt.x = maxX;
			end
			if pt.x < 0 then
				pt.x = 0;
			end
			setGripBitmapPosition(pt);

			local newSliderValue = math.floor(pt.x/maxX*100);
			if newSliderValue ~= lastSliderValue then
				lastSliderValue = newSliderValue;
				emitEvent("valueChanged", newSliderValue);
			end
        end
        lastX = e.stageX;

    end
end )

scaleform.EventListener.connect(mouseDownEventListener, thisActor, scaleform.EventTypes.MouseDown)
scaleform.EventListener.connect(mouseUpEventListener, scaleform.EventTypes.MouseUp)
scaleform.EventListener.connect(mouseOverEventListener, thisActor, scaleform.EventTypes.MouseOver)
scaleform.EventListener.connect(mouseOutEventListener, thisActor, scaleform.EventTypes.MouseOut)
scaleform.EventListener.connect(mouseMoveEventListener, scaleform.EventTypes.MouseMove)

return states