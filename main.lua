--[[
    Discord Notifier for AzerothCore & ElunaEngine
    Created by: 0xCiBeR(https://github.com/0xCiBeR)
]]--

--[[

    Config Flags Section -> EDIT TO YOUR LIKING!!

]]--

Config = {}
Config.hooks = {}
Config.eventOn = {}
-- By default, users are notified if any of the events are sent to Discord. Do you really want to disable this?
Config.privacyWarning = true 

-- This is the global Discord Webhook to use if other specific Webhooks are not defined. IMPORTANT: Must always be defined since its used as fallback
Config.hooks.globalWebook = "https://discord.com/api/webhooks/1287259836928757900/5aj-SelfNZUapUGc1gkSoIYSt_P3hsuuzEU7-qXuB7Jl6tKD_hFbr1ME4XtZ7YvO1wPH"
-- Webhook to send OnChat events
Config.hooks.PLAYER_EVENT_ON_CHAT = nil
-- Webhook to send OnWhisperChat events
Config.hooks.PLAYER_EVENT_ON_WHISPER = nil
-- Webhook to send OnGroupChat events
Config.hooks.PLAYER_EVENT_ON_GROUP_CHAT = nil
-- Webhook to send OnGuildChat events
Config.hooks.PLAYER_EVENT_ON_GUILD_CHAT = nil

-- Webhook to send Login and Logout events
Config.hooks.PLAYER_EVENT_ON_LOGIN = nil
Config.hooks.PLAYER_EVENT_ON_LOGOUT = nil

-- Feature Flag for enabiling each event
Config.eventOn.PLAYER_EVENT_ON_CHAT = true
Config.eventOn.PLAYER_EVENT_ON_WHISPER = true
Config.eventOn.PLAYER_EVENT_ON_GROUP_CHAT = true
Config.eventOn.PLAYER_EVENT_ON_GUILD_CHAT = true
Config.eventOn.PLAYER_EVENT_ON_LOGIN = true
Config.eventOn.PLAYER_EVENT_ON_LOGOUT = true

--[[

    Event Mappings Section -- DO NOT TOUCH!!

]]--

local PLAYER_EVENT_ON_CHAT = 18
local PLAYER_EVENT_ON_WHISPER = 19
local PLAYER_EVENT_ON_GROUP_CHAT = 20
local PLAYER_EVENT_ON_GUILD_CHAT = 21

-- Misc
local PLAYER_EVENT_ON_LOGIN = 3
local PLAYER_EVENT_ON_LOGOUT = 4

--[[

    Utility Function Section -- DO NOT TOUCH!!

]]--

local function sendToDiscord(event, msg)
    if msg and event then
        local webhook = Config.hooks[event] or Config.hooks.globalWebook
        
        -- Properly escape the message content
        msg = msg:gsub([[\]], [[\\]])  -- Escape backslashes
                 :gsub('"', '\\"')      -- Escape double quotes
                 :gsub("\n", "\\n")     -- Escape newlines

        -- Construct the JSON payload
        local payload = '{"content": "' .. msg .. '"}'
        
        -- Send the request
        HttpRequest("POST", webhook, payload, "application/json", 
        function(status, body, headers)
            -- Treat both 200 OK and 204 No Content as success
            if status ~= 200 and status ~= 204 then
                print("Error when sending webhook to Discord. Status: " .. status .. ". Response body: " .. (body or "No response body"))
            end
        end)
    end
end

--[[

    Events Section -- DO NOT TOUCH!!

]]--

-- OnLogin
local function OnLogin(event, player)
    if Config.eventOn.PLAYER_EVENT_ON_LOGIN then
        local accountid = player:GetAccountId()
        local accountname = player:GetAccountName()
        local name = player:GetName()
        local guid = player:GetGUIDLow()
        sendToDiscord("PLAYER_EVENT_ON_LOGIN", '__Logged on__ -> **['..accountid..'] '..accountname..' - ['..guid..'] '..name..'**')
    end
end

-- OnLogout
local function OnLogout(event, player)
    if Config.eventOn.PLAYER_EVENT_ON_LOGOUT then
        local name = player:GetName()
        local guid = player:GetGUIDLow()
        local accountid = player:GetAccountId()
        local accountname = player:GetAccountName()
        sendToDiscord("PLAYER_EVENT_ON_LOGOUT", '__Logged out__ -> **['..accountid..'] '..accountname..' - ['..guid..'] '..name..'**')
    end
end

-- OnChat
local function OnChat(event, player, msg, Type, lang)
    if Config.eventOn.PLAYER_EVENT_ON_CHAT then
        local name = player:GetName()

        local chatMessage = '[C] - [**'.. name ..'**]: ' .. msg
        sendToDiscord("PLAYER_EVENT_ON_CHAT", chatMessage)
    end
end

-- OnWhisperChat
local function OnWhisperChat(event, player, msg, Type, lang, receiver)
    if Config.eventOn.PLAYER_EVENT_ON_WHISPER then
        local sName = player:GetName()
        local rName = receiver:GetName()

        local whisperMessage = '[W] - [**'.. sName ..'**] -> [**'..rName..'**]: ' .. msg
        sendToDiscord("PLAYER_EVENT_ON_WHISPER", whisperMessage)
    end
end

-- OnGroupChat
local function OnGroupChat(event, player, msg, Type, lang, group)
    local name = player:GetName()

    local groupMessage = '[P] - [**'.. name ..'**]: ' .. msg
    sendToDiscord("PLAYER_EVENT_ON_GROUP_CHAT", groupMessage)
end


-- OnGuildChat
local function OnGuildChat(event, player, msg, Type, lang, guild)
    if Config.eventOn.PLAYER_EVENT_ON_GUILD_CHAT then
        local name = player:GetName()
        local gName = guild:GetName()

        local guildMessage = '[G] - [**' .. gName .. '**] [**'.. name ..'**]: ' .. msg
        sendToDiscord("PLAYER_EVENT_ON_GUILD_CHAT", guildMessage)
    end
end

--[[

    Register Events Section -- DO NOT TOUCH!!

]]--
-- OnChat
RegisterPlayerEvent(PLAYER_EVENT_ON_CHAT, OnChat)
-- OnWhisperChat
RegisterPlayerEvent(PLAYER_EVENT_ON_WHISPER, OnWhisperChat)
-- OnGroupChat
RegisterPlayerEvent(PLAYER_EVENT_ON_GROUP_CHAT, OnGroupChat)
-- OnGuildChat
RegisterPlayerEvent(PLAYER_EVENT_ON_GUILD_CHAT, OnGuildChat)
-- OnLogin
RegisterPlayerEvent(PLAYER_EVENT_ON_LOGIN, OnLogin)
-- OnLogout
RegisterPlayerEvent(PLAYER_EVENT_ON_LOGOUT, OnLogout)


--[[

    MISC -- DO NOT TOUCH!!

]]--

local function privacyAlert(event, player)
    if Config.privacyWarning then
        for i, v in pairs(Config.eventOn) do
            if v == true then
                player:SendBroadcastMessage("|cff00ff00[PRIVACY NOTICE] |cffff0000THIS SERVER IS CURRENTLY MONITORING AND FORWARDING TEXT MESSAGES SENT WITHIN THE SERVER TO DISCORD.")
                break
            end
        end
    end
end
RegisterPlayerEvent(PLAYER_EVENT_ON_LOGIN, privacyAlert)
