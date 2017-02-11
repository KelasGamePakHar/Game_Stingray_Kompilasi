local thisActor = ...
local container = scaleform.Actor.container(thisActor)

-- Control quadrants
local top_left = scaleform.ContainerComponent.actor_by_name(container, "top_left")
local top_right = scaleform.ContainerComponent.actor_by_name(container, "top_right")
local bottom_left = scaleform.ContainerComponent.actor_by_name(container, "bottom_left")
local bottom_right = scaleform.ContainerComponent.actor_by_name(container, "bottom_right")

local function updateViewport()
    -- Get the new viewport size
    local stageSz = scaleform.Stage.dimensions()
	local viewFrame = scaleform.Stage.visible_frame_rect()
	-- Affix background on right edge
	local xshift = (stageSz.width - (viewFrame.x2 - viewFrame.x1)) * 0.5
	local yshift = (stageSz.height - (viewFrame.y2 - viewFrame.y1)) * 0.5

	scaleform.Actor.set_local_position(top_left, {x = 0 + xshift, y = 0 - yshift})
    scaleform.Actor.set_local_position(top_right, {x = 2731 - xshift, y = 0 - yshift})
    scaleform.Actor.set_local_position(bottom_left, {x = 0 + xshift, y = 1536 - yshift})
 	scaleform.Actor.set_local_position(bottom_right, {x = 2731 - xshift, y = 1536 - yshift})
end

-- ============================================================================
-- Event Handlers
-- ============================================================================
-- On viewport resize, we resposition the controls
local viewportResizeEventListener = scaleform.EventListener.create(viewportResizeEventListener, function(e)
	updateViewport()
end )
scaleform.EventListener.connect(viewportResizeEventListener, thisActor, scaleform.EventTypes.ViewportResize)
updateViewport()