script_name("Anti AFK JGRP - Random Action")
script_author("Paxz")
script_version("1.2")

ENABLED = true
local CHAT_NOTIFY = true
local ACTION_INTERVAL = 30000
local random_messages = { "Halo", "Aku?", "Pasti gila lah", "Info", "Tolong", "Buset" }

local function random_action()
    if not ENABLED then return end
    local action_type = math.random(1, 4)
    if action_type == 1 then
        setVirtualKeyDown(0x57, true)
        setVirtualKeyDown(0x44, true)
        wait(3000)
        setVirtualKeyDown(0x57, false)
        setVirtualKeyDown(0x44, false)
        wait(3000)
        setVirtualKeyDown(0x57, true)
        setVirtualKeyDown(0x44, true)
        wait(3000)
        setVirtualKeyDown(0x57, false)
        setVirtualKeyDown(0x44, false)
    elseif action_type == 2 then
        setVirtualKeyDown(0x10, true)
        wait(200)
        setVirtualKeyDown(0x10, false)
    elseif action_type == 3 then
        sampSendChat("/anim 123")
        wait(3000)
        setVirtualKeyDown(0x20, true)
        wait(200)
        setVirtualKeyDown(0x20, false)
    elseif action_type == 4 then
        local msg = random_messages[math.random(1, #random_messages)]
        sampSendChat(msg)
    end
    if CHAT_NOTIFY then sampAddChatMessage("[AntiAFK] Aksi acak dijalankan.", 0xAAAAFF) end
end

function stop()
    ENABLED = false
    -- sampAddChatMessage("[AntiAFK] Dinonaktifkan oleh Loader.", 0xFF3333)
end

function main()
    repeat wait(100) until isSampAvailable()
    -- sampAddChatMessage("[AntiAFK] Aktif otomatis.", 0x1CD031)
    while ENABLED do
        wait(ACTION_INTERVAL)
        random_action()
    end
end