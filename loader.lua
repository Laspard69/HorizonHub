-- ==================================================
-- Platoboost Helpers
-- ==================================================
local HttpService = game:GetService("HttpService")

-- JSON encode/decode
local lEncode = function(tbl) return HttpService:JSONEncode(tbl) end
local lDecode = function(str) return HttpService:JSONDecode(str) end

-- Hashing
local lDigest = function(str)
    str = tostring(str) -- ✅ ensure always a string
    if syn and syn.crypt and syn.crypt.hash then
        return syn.crypt.hash(str, "sha256")
    elseif crypt and crypt.hash then
        return crypt.hash(str, "sha256")
    else
        -- insecure fallback (testing only!)
        return str
    end
end

-- HTTP request check
local fRequest = request or http_request or (syn and syn.request)
if not fRequest then
    warn("[Platoboost] ERROR: Your executor does not support HTTP requests.")
end

local fSetClipboard = setclipboard or toclipboard
local fOsTime, fMathRandom, fMathFloor, fStringChar, fStringSub, fToString, fGetHwid =
    os.time, math.random, math.floor, string.char, string.sub, tostring,
    gethwid or function() return game:GetService("Players").LocalPlayer.UserId end

-- seed randomness ✅
math.randomseed(tick() * 1000)

-- ==================================================
-- Platoboost Core
-- ==================================================
local service = 2893
local secret  = "6c707778-0f79-4261-aaf8-935dd2ccad7c"
local useNonce = true
local requestSending = false
local cachedLink, cachedTime = "", 0

local host = "https://api.platoboost.com"
if fRequest then
    local hostResponse = fRequest({ Url = host .. "/public/connectivity", Method = "GET" })
    if not hostResponse or (hostResponse.StatusCode ~= 200 and hostResponse.StatusCode ~= 429) then
        host = "https://api.platoboost.net"
    end
end

-- random nonce
local function generateNonce()
    local str = ""
    for _ = 1, 16 do
        str = str .. fStringChar(fMathFloor(fMathRandom() * 26) + 97)
    end
    return str
end

-- cache key link
local function cacheLink()
    if not fRequest then return false, "Executor missing fRequest" end
    if cachedTime + (10*60) < fOsTime() then
        local response = fRequest({
            Url = host .. "/public/start",
            Method = "POST",
            Body = lEncode({ service = service, identifier = lDigest(fGetHwid()) }),
            Headers = { ["Content-Type"] = "application/json" }
        })
        if response and response.StatusCode == 200 then
            local decoded = lDecode(response.Body)
            if decoded.success then
                cachedLink = decoded.data.url
                cachedTime = fOsTime()
                return true, cachedLink
            else
                return false, decoded.message
            end
        end
        return false, "Failed to cache link"
    else
        return true, cachedLink
    end
end

-- copy link
local function copyLink()
    local ok, link = cacheLink()
    if ok and fSetClipboard then
        fSetClipboard(link)
        return true, link
    end
    return false, link or "Clipboard not supported"
end

-- redeem key
local function redeemKey(key)
    if not fRequest then return false end
    local nonce = generateNonce()
    local body = { identifier = lDigest(fGetHwid()), key = key }
    if useNonce then body.nonce = nonce end

    local response = fRequest({
        Url = host .. "/public/redeem/" .. fToString(service),
        Method = "POST",
        Body = lEncode(body),
        Headers = { ["Content-Type"] = "application/json" }
    })
    if response and response.StatusCode == 200 then
        local decoded = lDecode(response.Body)
        if decoded.success and decoded.data.valid then
            if useNonce then
                return decoded.data.hash == lDigest("true" .. "-" .. nonce .. "-" .. secret)
            else
                return true
            end
        end
    end
    return false
end

-- verify key
local function verifyKey(key)
    if not fRequest then return false end
    if requestSending then return false end
    requestSending = true

    local nonce = generateNonce()
    local endpoint = host .. "/public/whitelist/" .. fToString(service) ..
        "?identifier=" .. lDigest(fGetHwid()) .. "&key=" .. key
    if useNonce then endpoint = endpoint .. "&nonce=" .. nonce end

    local response = fRequest({ Url = endpoint, Method = "GET" })
    requestSending = false

    if response and response.StatusCode == 200 then
        local decoded = lDecode(response.Body)
        if decoded.success and decoded.data.valid then
            if useNonce then
                return decoded.data.hash == lDigest("true" .. "-" .. nonce .. "-" .. secret)
            else
                return true
            end
        else
            if fStringSub(key, 1, 4) == "KEY_" then
                return redeemKey(key)
            end
        end
    end
    return false
end

-- ==================================================
-- Key Save/Load
-- ==================================================
local keyFile = "HorizonHubV3/key.txt"
local function loadKey() if isfile and isfile(keyFile) then return readfile(keyFile) end return "" end
local function saveKey(k) if writefile then writefile(keyFile, k) end end

-- ==================================================
-- Main Hub Loader
-- ==================================================
local function loadMainUI()
    -- 🔥 Load your big hub script here
    if game.PlaceId == 79546208627805 then
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Laspard69/HorizonHub/refs/heads/main/scripts/99nightsintheforest.lua", true))()
    elseif game.PlaceId == 89567611558207 then
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Laspard69/HorizonHub/refs/heads/main/scripts/ThePeeGame.lua", true))()
    elseif game.PlaceId == 3956818381 then
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Laspard69/HorizonHub/refs/heads/main/scripts/ninjalegends.lua", true))()
    elseif game.PlaceId == 81440632616906 then
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Laspard69/HorizonHub/refs/heads/main/scripts/Digtotheearthscore.lua", true))()
    elseif game.PlaceId == 2753915549 or 4442272183 or 7449423635 then 
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Laspard69/HorizonHub/refs/heads/main/scripts/bloxfruits.lua", true))()
    end
end

-- ==================================================
-- Boot: Try Saved Key First
-- ==================================================
local currentKey = loadKey()
if currentKey ~= "" and verifyKey(currentKey) then
    print("[Platoboost] Auto-verified saved key, loading UI...")
    loadMainUI()
else
    -- Show Key System UI
    local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
    local Window = WindUI:CreateWindow({
        Title = "Horizon Hub | Key System",
        Icon  = "lock",
        Author = "Laspard",
        Folder = "HorizonHubV3/"
    })
    WindUI:SetTheme("Sky")
    local KeyTab = Window:Tab({ Title = "Key", Icon = "lock" })

    -- Input for key
    KeyTab:Input({
        Title = "Enter Key",
        Desc  = "Paste your Platoboost key",
        Default = "",
        Placeholder = "KEY_xxxxx",
        Callback = function(v) currentKey = v end
    })

    -- Get Key Link Button
    KeyTab:Button({
        Title = "Get Key Link",
        Icon  = "link",
        Callback = function()
            local ok, msg = copyLink()
            if ok then
                WindUI:Notify({ Title = "Platoboost", Content = "Link copied to clipboard!", Duration = 5, Icon = "check" })
            else
                WindUI:Notify({ Title = "Platoboost", Content = msg or "Failed to copy link", Duration = 5, Icon = "x" })
            end
        end
    })

    -- Verify Key Button
    KeyTab:Button({
        Title = "Verify Key",
        Icon  = "check",
        Callback = function()
            if currentKey == "" then
                WindUI:Notify({
                    Title = "Platoboost",
                    Content = "Enter a key first.",
                    Duration = 5,
                    Icon = "x"
                })
                return
            end

            local ok = verifyKey(currentKey)
            if ok then
                saveKey(currentKey)
                WindUI:Notify({
                    Title = "Platoboost",
                    Content = "Key verified! Loading UI...",
                    Duration = 5,
                    Icon = "check"
                })

                task.delay(1, function()
                    pcall(function()
                        Window:Close() -- ✅ proper cleanup
                    end)
                    task.wait(0.2)
                    loadMainUI()
                end)
            else
                WindUI:Notify({
                    Title = "Platoboost",
                    Content = "Invalid or expired key.",
                    Duration = 5,
                    Icon = "x"
                })
            end
        end
    })
end
