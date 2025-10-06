script_name("AntiAFK_Action")
script_author("Paxz")
script_version("1.0")

local ENABLED = true
local CHAT_NOTIFY = true
local ACTION_INTERVAL = 30000

local random_messages = { "Hahaha", "Aku?", "Pasti gila lah", "Info lur", "Tolong", "Buset" }

local function random_action()
    if not ENABLED then return end
    local action_type = math.random(1, 4)

    if action_type == 1 then
        -- Maju + kanan
        setVirtualKeyDown(0x57, true) -- W
        setVirtualKeyDown(0x44, true) -- D
        wait(3000)
        setVirtualKeyDown(0x57, false)
        setVirtualKeyDown(0x44, false)
        if CHAT_NOTIFY then sampAddChatMessage("[AntiAFK_Action] Jalan maju dan kanan.", 0xAAAAFF) end

    elseif action_type == 2 then
        -- Lompat
        setVirtualKeyDown(0x20, true) -- Space
        wait(200)
        setVirtualKeyDown(0x20, false)
        if CHAT_NOTIFY then sampAddChatMessage("[AntiAFK_Action] Lompat.", 0xAAAAFF) end

    elseif action_type == 3 then
        -- /anim 123 lalu spasi
        sampSendChat("/anim 123")
        wait(3000)
        setVirtualKeyDown(0x20, true)
        wait(200)
        setVirtualKeyDown(0x20, false)
        if CHAT_NOTIFY then sampAddChatMessage("[AntiAFK_Action] Animasi dan spasi.", 0xAAAAFF) end

    elseif action_type == 4 then
        -- Kirim chat random
        local msg = random_messages[math.random(1, #random_messages)]
        sampSendChat(msg)
        if CHAT_NOTIFY then sampAddChatMessage("[AntiAFK_Action] Kirim chat: \"" .. msg .. "\".", 0xAAAAFF) end
    end
end

function main()
    repeat wait(100) until isSampAvailable()
    sampAddChatMessage("[AntiAFK_Action] Aktif otomatis.", 0x1CD031)

    lua_thread.create(function()
        while true do
            wait(ACTION_INTERVAL)
            if ENABLED then random_action() end
        end
    end)

    while true do wait(1000) end
end
