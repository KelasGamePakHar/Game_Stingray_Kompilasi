--This script is executed on object creation
local thisActor = ...

local children    = scaleform.Actor.container(thisActor);
local arrows      = scaleform.ContainerComponent.actor_by_name(children,"direction_arrows");
local up_arrow    = scaleform.ContainerComponent.actor_by_name(scaleform.Actor.container(arrows), "up");
local down_arrow  = scaleform.ContainerComponent.actor_by_name(scaleform.Actor.container(arrows), "down");
local left_arrow  = scaleform.ContainerComponent.actor_by_name(scaleform.Actor.container(arrows), "left");
local right_arrow = scaleform.ContainerComponent.actor_by_name(scaleform.Actor.container(arrows), "right");

local unpressed_alpha = .25
local pressed_alpha = .75

scaleform.Stage.set_fps(30);
scaleform.Stage.set_view_scale_mode(scaleform.ViewScaleModes.ExactFit);

local customListener = scaleform.EventListener.create(customListener, function(e)
    local buttonActors = {
        up    = up_arrow,
        down  = down_arrow,
        right = right_arrow,
        left  = left_arrow
    }

	if e.name == "keypressed" then
	    local button = buttonActors[e.data]
	    if button then
	        scaleform.Actor.set_alpha_scale(button, pressed_alpha)
        end
 	end
 	
 	if e.name == "keyreleased" then
	    local button = buttonActors[e.data]
	    if button then
	        scaleform.Actor.set_alpha_scale(button, unpressed_alpha)
        end
 	end
end )
scaleform.EventListener.connect(customListener, thisActor, scaleform.EventTypes.Custom)
