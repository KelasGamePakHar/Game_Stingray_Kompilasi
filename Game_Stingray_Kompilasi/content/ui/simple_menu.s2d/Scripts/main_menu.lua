-- ============================================================================
-- Stage setup
-- ============================================================================
-- The content has been designed to support arbitrary aspect ratios
-- with appropriate safe zones. Changing scale mode to 'No Border', 
-- as we want the content to scale up and we aren't worried if the
-- the content is chopped on the larger dimension.
scaleform.Stage.set_view_scale_mode(scaleform.ViewScaleModes.NoBorder);


local thisActor = ...
if scaleform.build.platform() == "iOS" then
	local container = scaleform.Actor.container(thisActor)
	local main = scaleform.ContainerComponent.actor_by_name(container, "main")
	local main_container = scaleform.Actor.container(main)
	local quit_button = scaleform.ContainerComponent.actor_by_name(main_container, "quit")
	scaleform.ContainerComponent.remove_actor(main_container, quit_button)
end 
