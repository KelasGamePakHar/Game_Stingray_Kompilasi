local thisActor = ...
local container = scaleform.Actor.container(thisActor)
local grip = scaleform.ContainerComponent.actor_by_name(container, "grip")
local pad = scaleform.ContainerComponent.actor_by_name(container, "pad")
local handler = scaleform.Actor.component_by_name(thisActor, "handler");
local handlerObject = scaleform.ScriptComponent.script_results(handler);

scaleform.Actor.set_mouse_enabled_for_children(thisActor, false)

local gripDrag = false
local gripDragged = false
local gripReleaseHandled = false
local gripOffsetX = 0
local gripOffsetY = 0
local gripExtent = 128
local gripNormalizeX = 0
local gripNormalizeY = 0
local EPSILON=0.0000001

local emitEvent = function(func, param)
	if handlerObject[func] ~= nil then
	    if (param) then
		    handlerObject[func](param);
		else
		    handlerObject[func]();
		end
	end
end

local gripPressListener = scaleform.EventListener.create(gripPressListener, function(e)
	gripOffsetX = e.localX
	gripOffsetY = e.localY
	gripDrag = true
	gripDragged = false
	gripReleaseHandled = false
end )

local gripDragListener = scaleform.EventListener.create(gripDragListener, function(e)
	if gripDrag then
	    gripReleaseHandled = false
	    gripDragged = true
	    
	    local x = e.localX - gripOffsetX
	    local y = e.localY - gripOffsetY
	    local dist = math.sqrt(x*x + y*y)
	   
	    if(dist > EPSILON) then
	        x = x / dist
	        y = y / dist
	    
	        dist = math.max(-gripExtent, math.min(gripExtent, dist))
	    else
	        x = 0
	        y = 0
	        dist = 0
	    end    
	    
	    local coords = { x = x * dist, y = y * dist }
	    
		scaleform.Actor.set_local_position(grip, coords)

		gripNormalizeX = x
		gripNormalizeY = y
		emitEvent("dragged", coords)
	end
end )

local gripReleaseListener = scaleform.EventListener.create(gripReleaseListener, function(e)
	if not gripDrag then
		return
	end
	
    if not gripReleaseHandled and not gripDragged then
        emitEvent("clicked")
        gripDrag = false
	    gripReleaseHandled = true
        return
    end
    
    gripDrag = false
	gripReleaseHandled = true
    
	scaleform.Actor.set_local_position(grip, { x = 0, y = 0 })

	enterFrameListenerHandle = nil
    emitEvent("released")
end )

-- We inject our own press event handler to the fire
scaleform.EventListener.connect(gripPressListener, thisActor, scaleform.EventTypes.MouseDown)
scaleform.EventListener.connect(gripReleaseListener, thisActor, scaleform.EventTypes.MouseUp)
scaleform.EventListener.connect(gripReleaseListener, thisActor, scaleform.EventTypes.MouseUpOutside)
scaleform.EventListener.connect(gripDragListener, thisActor, scaleform.EventTypes.MouseMove)

