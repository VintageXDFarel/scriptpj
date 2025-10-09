script_name("Anti AFK JGRP - Leave AFK")
script_author("Paxz")
script_version("1.0")

local sampev = require 'samp.events'
local encoding = require 'encoding'
encoding.default = 'CP1251'
local u8 = encoding.UTF8

ENABLED = true
local CHAT_NOTIFY = true
local PATTERNS = { "you are now afk", "server: you are now afk", "use '/afk" }
local AFTER_EXIT_COOLDOWN = 5000
local WAIT_DELAY = 5000
local lastActionTime = 0

local function safe_lower(str)
    if type(str) ~= "string" then return "" end
    local ok, res = pcall(string.lower, str)
    return (ok and res) and res or ""
end

local function contains_afk_keyword(text)
    local t = safe_lower(text)
    for _, pattern in ipairs(PATTERNS) do
        if string.find(t, pattern, 1, true) then
            return true
        end
    end
    return false
end

local function extract_afk_code(text)
    if type(text) ~= "string" then return nil end
    local code = string.match(text, "/[aA][fF][kK]%s*(%d+)")
    if code then return code end
    code = string.match(text, "['\"]/?[aA][fF][kK]%s*(%d+)['\"]")
    return code
end

local function do_exit_afk(code)
    if not ENABLED then return end
    local now = os.clock() * 1000
    if now - lastActionTime < AFTER_EXIT_COOLDOWN then return end
    lastActionTime = now
    local cmd = "/afk"
    if code then cmd = cmd .. " " .. tostring(code) end

    lua_thread.create(function()
        if CHAT_NOTIFY then
            sampAddChatMessage(string.format("[AntiAFK] Menunggu %d detik...", WAIT_DELAY / 1000), 0xFFA500)
        end
        wait(WAIT_DELAY)
        if ENABLED then
            sampSendChat(cmd)
            sampAddChatMessage("[AntiAFK] Keluar dari AFK.", 0x1CD031)
        end
    end)
end

function sampev.onServerMessage(color, text)
    if ENABLED and contains_afk_keyword(text) then
        do_exit_afk(extract_afk_code(text))
    end
end

function sampev.onChatMessage(playerId, color, text)
    if ENABLED and contains_afk_keyword(text) then
        do_exit_afk(extract_afk_code(text))
    end
end

function stop()
    ENABLED = false
    -- sampAddChatMessage("[AntiAFK] Dinonaktifkan oleh Loader.", 0xFF3333)
end

function main()
    repeat wait(100) until isSampAvailable()
    -- sampAddChatMessage("[AntiAFK] Aktif otomatis.", 0x1CD031)
    while ENABLED do wait(1000) end
end