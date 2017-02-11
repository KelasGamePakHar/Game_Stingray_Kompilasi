thisActor = ...

local prevButtonIdx = 0
local buttonIdx = 1

local widgetCount = 2

local main_menu_buttons = {}
local main_menu_scripts = {}

local keyDownListener = scaleform.EventListener.create(keyDownListener, function(e, thisListener)
    if e.key == "Down" then
        buttonIdx = buttonIdx + 1
    elseif e.key == "Up" then
        buttonIdx = buttonIdx - 1
    elseif e.key == "Return" then
        main_menu_scripts[buttonIdx].click()
    elseif e.key == "Escape" then
    end

    if buttonIdx > widgetCount then
        buttonIdx = 1
    elseif buttonIdx < 1 then
        buttonIdx = widgetCount
    end
end )

local mainButtonOverEventListener = scaleform.EventListener.create(mainButtonOverEventListener, function(e, thisListener)
    local name = scaleform.Actor.name(e.target)
    if name == "start" then
        buttonIdx = 1
    elseif name == "quit" then
        buttonIdx = 2
    end
end )

local enterFrameListener = scaleform.EventListener.create(enterFrameListener, function(e, thisListener)
    if buttonIdx ~= prevButtonIdx then
        if prevButtonIdx > 0 and prevButtonIdx < widgetCount + 1 then
                main_menu_scripts[prevButtonIdx].normal()
        end
        main_menu_scripts[buttonIdx].over()

        prevButtonIdx = buttonIdx
    end
end )

local addedListener = scaleform.EventListener.create(addedListener, function(e, thisListener)
    local button_cnt = 1
    main_menu_buttons[1] = scaleform.Stage.actor_by_name_path("main_menu.main.start")
    if scaleform.build.platform() ~= "iOS" then
        main_menu_buttons[2] = scaleform.Stage.actor_by_name_path("main_menu.main.quit")
        button_cnt = 2
    end

    for idx = 1, button_cnt do
        local comp = scaleform.Actor.component_by_name(main_menu_buttons[idx], "WidgetBase")
        scaleform.EventListener.connect(mainButtonOverEventListener, main_menu_buttons[idx], scaleform.EventTypes.MouseOver)
        main_menu_scripts[idx] = scaleform.ScriptComponent.script_results(comp)
    end
end )
scaleform.EventListener.connect(addedListener, thisActor, scaleform.EventTypes.Added)
scaleform.EventListener.connect(keyDownListener, scaleform.EventTypes.KeyDown)
scaleform.EventListener.connect(enterFrameListener, thisActor, scaleform.EventTypes.EnterFrame)