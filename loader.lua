-- ================= MAIN HUB LOADER =================
local function loadMainUI()
    if game.PlaceId == 79546208627805 then
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Laspard69/HorizonHub/refs/heads/main/scripts/99nightsintheforest.lua", true))() -- 99NIF
    elseif game.PlaceId == 89567611558207 then
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Laspard69/HorizonHub/refs/heads/main/scripts/ThePeeGame.lua", true))() -- TPE
    elseif game.PlaceId == 3956818381 then
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Laspard69/HorizonHub/refs/heads/main/scripts/ninjalegends.lua", true))() -- NJ
    elseif game.PlaceId == 81440632616906 then
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Laspard69/HorizonHub/refs/heads/main/scripts/Digtotheearthscore.lua", true))() -- DTTEC
    elseif game.PlaceId == 2753915549 or game.PlaceId == 4442272183 or game.PlaceId == 7449423635 then
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Laspard69/HorizonHub/refs/heads/main/scripts/bloxfruits.lua", true))() -- BF
    elseif game.PlaceId == 13772394625 then
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Laspard69/HorizonHub/refs/heads/main/scripts/bladeball.lua", true))() -- BB
    elseif game.PlaceId == 16794833014 then
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Laspard69/HorizonHub/refs/heads/main/scripts/ThatsNotMyRobloxian.lua", true))() -- TNMR
    end
end

loadMainUI()
