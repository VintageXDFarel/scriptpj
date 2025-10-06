-- AutoLeaveAFK.lua (v2.4)
script_name("AutoLeaveAFK")
script_author("ChatGPT + Farel")
script_version("2.4")

local sampev = require 'samp.events'
local encoding = require 'encoding'
encoding.default = 'CP1251'
local u8 = encoding.UTF8

-- ===== Konfigurasi =====
local ENABLED = true
local CHAT_NOTIFY = true
local PATTERNS = {
    "you are now afk",
    "server: you are now afk",
    "use '/afk",
}
local AFTER_EXIT_COOLDOWN = 5000 -- ms
local WAIT_DELAY = 5000 -- delay 5 detik sebelum kirim /afk
local ACTION_INTERVAL = 30000 -- 30 detik sekali
local lastActionTime = 0

-- ===== Utility =====
local function safe_format(fmt, ...)
    if type(fmt) ~= "string" then fmt = tostring(fmt or "") end
    local ok, res = pcall(string.format, fmt, ...)
    if ok and type(res) == "string" then return res end
    local parts = { tostring(fmt) }
    local args = { ... }
    for i = 1, #args do parts[#parts + 1] = tostring(args[i]) end
    return table.concat(parts, " ")
end

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

-- ===== Fitur Keluar AFK =====
local function do_exit_afk(code)
    local now = os.clock() * 1000
    if now - lastActionTime < AFTER_EXIT_COOLDOWN then return end
    lastActionTime = now

    local cmd = "/afk"
    if code then cmd = cmd .. " " .. tostring(code) end

    lua_thread.create(function()
        if CHAT_NOTIFY then
            sampAddChatMessage(safe_format("[AutoLeaveAFK] Menunggu %d detik sebelum keluar dari AFK...", WAIT_DELAY / 1000), 0xFFA500)
        end
        wait(WAIT_DELAY)
        sampSendChat(cmd)
        if CHAT_NOTIFY then
            sampAddChatMessage(safe_format("[AutoLeaveAFK] Mengirim: %s", cmd), 0x1CD031)
        end
    end)
end

-- ===== Random Action System =====
local random_messages = { "Uyy", "Masih aktif", "Gas", "Tes afk?", "Ngopi dulu", "On fire 🔥" }

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
        if CHAT_NOTIFY then sampAddChatMessage("[AutoLeaveAFK] Aksi: Jalan maju dan kanan.", 0xAAAAFF) end

    elseif action_type == 2 then
        -- Lompat
        setVirtualKeyDown(0x20, true) -- Space
        wait(200)
        setVirtualKeyDown(0x20, false)
        if CHAT_NOTIFY then sampAddChatMessage("[AutoLeaveAFK] Aksi: Lompat.", 0xAAAAFF) end

    elseif action_type == 3 then
        -- /anim 123 lalu spasi
        sampSendChat("/anim 123")
        wait(3000)
        setVirtualKeyDown(0x20, true)
        wait(200)
        setVirtualKeyDown(0x20, false)
        if CHAT_NOTIFY then sampAddChatMessage("[AutoLeaveAFK] Aksi: Animasi dan spasi.", 0xAAAAFF) end

    elseif action_type == 4 then
        -- Kirim chat random
        local msg = random_messages[math.random(1, #random_messages)]
        sampSendChat(msg)
        if CHAT_NOTIFY then sampAddChatMessage("[AutoLeaveAFK] Aksi: Kirim chat \"" .. msg .. "\".", 0xAAAAFF) end
    end
end

-- ===== Event handlers =====
function sampev.onServerMessage(color, text)
    if not ENABLED then return end
    if contains_afk_keyword(text) then
        do_exit_afk(extract_afk_code(text))
    end
end

function sampev.onChatMessage(playerId, color, text)
    if not ENABLED then return end
    if contains_afk_keyword(text) then
        do_exit_afk(extract_afk_code(text))
    end
end

-- ===== Main =====
function main()
    repeat wait(100) until isSampAvailable()
    sampAddChatMessage("[AutoLeaveAFK] Aktif. Ketik /autoleaveafk untuk toggle.", 0x1CD031)

    sampRegisterChatCommand("autoleaveafk", function()
        ENABLED = not ENABLED
        sampAddChatMessage(
            safe_format("[AutoLeaveAFK] %s", ENABLED and "Dinyalakan" or "Dimatikan"),
            ENABLED and 0x00FF00 or 0xFF3333
        )
    end)

    lua_thread.create(function()
        while true do
            wait(ACTION_INTERVAL)
            if ENABLED then
                random_action()
            end
        end
    end)

    while true do wait(1000) end
end
