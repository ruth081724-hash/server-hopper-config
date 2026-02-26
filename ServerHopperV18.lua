-- ================================
-- SERVER HOPPER V18
-- michaelarsx | Config via GitHub
-- ================================
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local PLACE_ID = game.PlaceId
local ADMIN_ID = 1616055032
local esAdmin = player.UserId == ADMIN_ID

-- ================================
-- GITHUB CONFIG URL
-- ================================
local GITHUB_RAW = "https://raw.githubusercontent.com/ruth081724-hash/server-hopper-config/refs/heads/main/config.json"
local GITHUB_API = "https://api.github.com/repos/ruth081724-hash/server-hopper-config/contents/config.json"

local GITHUB_TOKEN = "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"

-- ================================
-- ARCHIVOS LOCALES
-- ================================
local FILES = {
    config    = "SHConfig.json",
    historial = "SHHistorial.json",
    blacklist = "SHBlacklist.json",
    stats     = "SHStats.json",
    record    = "SHRecord.json",
    log       = "SHLog.json",
}

local function leerJSON(file, default)
    local ok, data = pcall(function()
        if isfile(file) then return HttpService:JSONDecode(readfile(file)) end
    end)
    return (ok and data) or default
end
local function escribirJSON(file, data)
    pcall(function() writefile(file, HttpService:JSONEncode(data)) end)
end

-- ================================
-- LEER CONFIG DESDE GITHUB
-- ================================
local globalConfig = nil

local function leerGitHub()
    local ok, res = pcall(function()
        return game:HttpGet(GITHUB_RAW .. "?t=" .. os.time())
    end)
    if not ok or not res then return nil end
    local ok2, data = pcall(function() return HttpService:JSONDecode(res) end)
    if not ok2 or not data then return nil end
    return data
end

local function escribirGitHub(nuevaConfig)
    if GITHUB_TOKEN == "PON_TU_TOKEN_AQUI" then return false, "No hay token" end
    local sha = ""
    local ok1, res1 = pcall(function() return game:HttpGet(GITHUB_API) end)
    if ok1 and res1 then
        local ok2, data = pcall(function() return HttpService:JSONDecode(res1) end)
        if ok2 and data and data.sha then sha = data.sha end
    end
    local contenido = HttpService:JSONEncode(nuevaConfig)
    local b64chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    local function b64encode(data)
        local result = ""
        local len = #data
        local i = 1
        while i <= len do
            local b1 = string.byte(data, i) or 0
            local b2 = string.byte(data, i+1) or 0
            local b3 = string.byte(data, i+2) or 0
            local n = b1*65536 + b2*256 + b3
            result = result
                .. b64chars:sub(math.floor(n/262144)%64+1, math.floor(n/262144)%64+1)
                .. b64chars:sub(math.floor(n/4096)%64+1, math.floor(n/4096)%64+1)
                .. (i+1<=len and b64chars:sub(math.floor(n/64)%64+1, math.floor(n/64)%64+1) or "=")
                .. (i+2<=len and b64chars:sub(n%64+1, n%64+1) or "=")
            i = i + 3
        end
        return result
    end
    local encoded = b64encode(contenido)
    local body = HttpService:JSONEncode({
        message = "Update config - michaelarsx",
        content = encoded,
        sha = sha,
    })
    local ok3, res3 = pcall(function()
        return syn and syn.request({
            Url = GITHUB_API, Method = "PUT",
            Headers = {["Authorization"]="token "..GITHUB_TOKEN,["Content-Type"]="application/json"},
            Body = body,
        }) or request({
            Url = GITHUB_API, Method = "PUT",
            Headers = {["Authorization"]="token "..GITHUB_TOKEN,["Content-Type"]="application/json"},
            Body = body,
        })
    end)
    return ok3, ok3 and "OK" or tostring(res3)
end

-- ================================
-- LOADING SCREEN
-- ================================
local LoadGui = Instance.new("ScreenGui")
LoadGui.Name = "SHLoading" LoadGui.ResetOnSpawn = false LoadGui.DisplayOrder = 9999
LoadGui.Parent = player:WaitForChild("PlayerGui")
local LoadBg = Instance.new("Frame")
LoadBg.Size = UDim2.new(1,0,1,0) LoadBg.BackgroundColor3 = Color3.fromRGB(0,0,0)
LoadBg.BackgroundTransparency = 0.3 LoadBg.BorderSizePixel = 0 LoadBg.Parent = LoadGui
local LoadCard = Instance.new("Frame")
LoadCard.Size = UDim2.new(0,280,0,130) LoadCard.Position = UDim2.new(0.5,-140,0.5,-65)
LoadCard.BackgroundColor3 = Color3.fromRGB(14,14,20) LoadCard.BorderSizePixel = 0 LoadCard.Parent = LoadGui
Instance.new("UICorner",LoadCard).CornerRadius = UDim.new(0,14)
local LS = Instance.new("UIStroke") LS.Color = Color3.fromRGB(0,140,255) LS.Thickness = 1.5 LS.Parent = LoadCard
local LoadIcon = Instance.new("TextLabel")
LoadIcon.Size = UDim2.new(1,0,0,40) LoadIcon.Position = UDim2.new(0,0,0,10)
LoadIcon.BackgroundTransparency = 1 LoadIcon.Text = "⏳" LoadIcon.TextScaled = true
LoadIcon.Font = Enum.Font.GothamBold LoadIcon.Parent = LoadCard
local LoadTxt = Instance.new("TextLabel")
LoadTxt.Size = UDim2.new(1,-20,0,28) LoadTxt.Position = UDim2.new(0,10,0,54)
LoadTxt.BackgroundTransparency = 1 LoadTxt.TextColor3 = Color3.fromRGB(200,200,255)
LoadTxt.Text = "Conectando con el servidor..." LoadTxt.Font = Enum.Font.GothamBold
LoadTxt.TextSize = 13 LoadTxt.Parent = LoadCard
local LoadSub = Instance.new("TextLabel")
LoadSub.Size = UDim2.new(1,-20,0,20) LoadSub.Position = UDim2.new(0,10,0,84)
LoadSub.BackgroundTransparency = 1 LoadSub.TextColor3 = Color3.fromRGB(120,120,150)
LoadSub.Text = "Server Hopper v18 | michaelarsx" LoadSub.Font = Enum.Font.Gotham
LoadSub.TextSize = 11 LoadSub.Parent = LoadCard
task.spawn(function()
    local dots = 0
    while LoadGui and LoadGui.Parent do
        dots = (dots % 3) + 1
        LoadTxt.Text = "Conectando con el servidor" .. string.rep(".", dots)
        task.wait(0.5)
    end
end)

globalConfig = leerGitHub()
if not globalConfig then
    globalConfig = {
        scriptActivo = true, modoMantenimiento = false,
        mensajeDia = "Bienvenido al Server Hopper!",
        bans = {}, whitelist = {activo=false, usuarios={}}, admins = {},
    }
    LoadTxt.Text = "Sin conexion, modo offline"
    LoadTxt.TextColor3 = Color3.fromRGB(255,180,50)
    task.wait(1.5)
end
LoadGui:Destroy()

-- ================================
-- HELPERS DE CONFIG
-- ================================
local function esAdminSecundario()
    if not globalConfig.admins then return false end
    for _, a in ipairs(globalConfig.admins) do
        if tostring(a.userId) == tostring(player.UserId) then return true end
    end
    return false
end
local function tieneAccesoAdmin() return esAdmin or esAdminSecundario() end

local function estaBaneado(userId)
    if not globalConfig.bans then return false end
    for _, b in ipairs(globalConfig.bans) do
        if tostring(b.userId) == tostring(userId) then return true, b.razon or "Sin razon" end
    end
    return false
end
local function estaEnWhitelist(userId)
    if not globalConfig.whitelist or not globalConfig.whitelist.usuarios then return false end
    for _, v in ipairs(globalConfig.whitelist.usuarios) do
        if tostring(v.userId) == tostring(userId) then return true end
    end
    return false
end

-- ================================
-- VERIFICACIONES AL INICIO
-- ================================
local baneado, razonBan = estaBaneado(player.UserId)

if baneado and not tieneAccesoAdmin() then
    local G = Instance.new("ScreenGui")
    G.Name = "BanScreen" G.ResetOnSpawn=false G.DisplayOrder=9999
    G.Parent = player:WaitForChild("PlayerGui")
    local Bg = Instance.new("Frame")
    Bg.Size=UDim2.new(1,0,1,0) Bg.BackgroundColor3=Color3.fromRGB(0,0,0)
    Bg.BackgroundTransparency=0.2 Bg.BorderSizePixel=0 Bg.Parent=G
    local Card = Instance.new("Frame")
    Card.Size=UDim2.new(0,320,0,250) Card.Position=UDim2.new(0.5,-160,0.5,-125)
    Card.BackgroundColor3=Color3.fromRGB(16,5,5) Card.BorderSizePixel=0 Card.Parent=G
    Instance.new("UICorner",Card).CornerRadius=UDim.new(0,16)
    local S=Instance.new("UIStroke") S.Color=Color3.fromRGB(220,40,40) S.Thickness=2 S.Parent=Card
    local function lbl(txt,posY,size,color,bold)
        local l=Instance.new("TextLabel")
        l.Size=UDim2.new(1,-20,0,size+6) l.Position=UDim2.new(0,10,0,posY)
        l.BackgroundTransparency=1 l.TextColor3=color
        l.Text=txt l.Font=bold and Enum.Font.GothamBold or Enum.Font.Gotham
        l.TextSize=size l.TextWrapped=true l.Parent=Card
    end
    lbl("🚫",8,44,Color3.fromRGB(220,50,50),true)
    lbl("Has sido baneado del script",58,18,Color3.fromRGB(255,80,80),true)
    lbl("Razon: "..(razonBan or "Sin razon"),90,13,Color3.fromRGB(200,150,150),false)
    lbl("Contacta a michaelarsx para apelar",116,12,Color3.fromRGB(160,160,160),false)
    lbl("discord.gg/eY9tPGQXJ2",142,12,Color3.fromRGB(150,130,255),true)
    lbl("Tu UserID: "..tostring(player.UserId),168,11,Color3.fromRGB(100,100,100),false)
    local btn=Instance.new("TextButton")
    btn.Size=UDim2.new(1,-20,0,36) btn.Position=UDim2.new(0,10,0,200)
    btn.BackgroundColor3=Color3.fromRGB(80,80,200) btn.TextColor3=Color3.fromRGB(255,255,255)
    btn.Text="Copiar Discord" btn.Font=Enum.Font.GothamBold btn.TextSize=13
    btn.BorderSizePixel=0 btn.Parent=Card
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,8)
    btn.MouseButton1Click:Connect(function()
        pcall(function() setclipboard("https://discord.gg/eY9tPGQXJ2") end)
        btn.Text="Copiado!" task.wait(2) btn.Text="Copiar Discord"
    end)
    return
end

if globalConfig.whitelist and globalConfig.whitelist.activo and not estaEnWhitelist(player.UserId) and not tieneAccesoAdmin() then
    local G = Instance.new("ScreenGui")
    G.Name="WhitelistScreen" G.ResetOnSpawn=false G.DisplayOrder=9999
    G.Parent=player:WaitForChild("PlayerGui")
    local Bg=Instance.new("Frame") Bg.Size=UDim2.new(1,0,1,0)
    Bg.BackgroundColor3=Color3.fromRGB(0,0,0) Bg.BackgroundTransparency=0.3
    Bg.BorderSizePixel=0 Bg.Parent=G
    local Card=Instance.new("Frame") Card.Size=UDim2.new(0,300,0,210)
    Card.Position=UDim2.new(0.5,-150,0.5,-105) Card.BackgroundColor3=Color3.fromRGB(10,10,20)
    Card.BorderSizePixel=0 Card.Parent=G
    Instance.new("UICorner",Card).CornerRadius=UDim.new(0,16)
    local S=Instance.new("UIStroke") S.Color=Color3.fromRGB(150,100,255) S.Thickness=2 S.Parent=Card
    local rows={
        {"🔒",8,42,Color3.fromRGB(180,120,255),true},
        {"Script en modo privado",58,17,Color3.fromRGB(200,160,255),true},
        {"Solo usuarios aprobados pueden acceder",88,12,Color3.fromRGB(150,150,150),false},
        {"Contacta a michaelarsx",116,12,Color3.fromRGB(160,160,160),false},
        {"discord.gg/eY9tPGQXJ2",140,12,Color3.fromRGB(150,130,255),true},
        {"Tu ID: "..tostring(player.UserId),168,11,Color3.fromRGB(100,100,100),false},
    }
    for _,r in ipairs(rows) do
        local l=Instance.new("TextLabel")
        l.Size=UDim2.new(1,-20,0,r[3]+6) l.Position=UDim2.new(0,10,0,r[2])
        l.BackgroundTransparency=1 l.TextColor3=r[4]
        l.Text=r[1] l.Font=r[5] and Enum.Font.GothamBold or Enum.Font.Gotham
        l.TextSize=r[3] l.TextWrapped=true l.Parent=Card
    end
    return
end

if globalConfig.modoMantenimiento and not tieneAccesoAdmin() then
    local G=Instance.new("ScreenGui") G.Name="Mantenimiento" G.ResetOnSpawn=false G.DisplayOrder=9999
    G.Parent=player:WaitForChild("PlayerGui")
    local Bg=Instance.new("Frame") Bg.Size=UDim2.new(1,0,1,0)
    Bg.BackgroundColor3=Color3.fromRGB(0,0,0) Bg.BackgroundTransparency=0.35
    Bg.BorderSizePixel=0 Bg.Parent=G
    local Card=Instance.new("Frame") Card.Size=UDim2.new(0,300,0,200)
    Card.Position=UDim2.new(0.5,-150,0.5,-100) Card.BackgroundColor3=Color3.fromRGB(12,10,5)
    Card.BorderSizePixel=0 Card.Parent=G
    Instance.new("UICorner",Card).CornerRadius=UDim.new(0,16)
    local S=Instance.new("UIStroke") S.Color=Color3.fromRGB(255,160,0) S.Thickness=2 S.Parent=Card
    task.spawn(function()
        local t=0
        while Card and Card.Parent do t+=0.1 S.Transparency=math.abs(math.sin(t))*0.6 task.wait(0.05) end
    end)
    local rows={
        {"⚙️",8,42,Color3.fromRGB(255,160,0),true},
        {"Modo Mantenimiento",58,17,Color3.fromRGB(255,180,50),true},
        {"Siendo actualizado por michaelarsx",88,12,Color3.fromRGB(180,180,180),false},
        {"Vuelve pronto!",116,12,Color3.fromRGB(160,160,160),false},
        {"discord.gg/eY9tPGQXJ2",144,12,Color3.fromRGB(150,130,255),true},
    }
    for _,r in ipairs(rows) do
        local l=Instance.new("TextLabel")
        l.Size=UDim2.new(1,-20,0,r[3]+6) l.Position=UDim2.new(0,10,0,r[2])
        l.BackgroundTransparency=1 l.TextColor3=r[4]
        l.Text=r[1] l.Font=r[5] and Enum.Font.GothamBold or Enum.Font.Gotham
        l.TextSize=r[3] l.TextWrapped=true l.Parent=Card
    end
    return
end

if not globalConfig.scriptActivo and not tieneAccesoAdmin() then
    local G=Instance.new("ScreenGui") G.Name="ScriptOff" G.ResetOnSpawn=false G.DisplayOrder=9999
    G.Parent=player:WaitForChild("PlayerGui")
    local Bg=Instance.new("Frame") Bg.Size=UDim2.new(1,0,1,0)
    Bg.BackgroundColor3=Color3.fromRGB(0,0,0) Bg.BackgroundTransparency=0.4
    Bg.BorderSizePixel=0 Bg.Parent=G
    local Card=Instance.new("Frame") Card.Size=UDim2.new(0,300,0,185)
    Card.Position=UDim2.new(0.5,-150,0.5,-92) Card.BackgroundColor3=Color3.fromRGB(15,15,20)
    Card.BorderSizePixel=0 Card.Parent=G
    Instance.new("UICorner",Card).CornerRadius=UDim.new(0,16)
    local S=Instance.new("UIStroke") S.Color=Color3.fromRGB(180,140,0) S.Thickness=2 S.Parent=Card
    local rows={
        {"⚙️",8,38,Color3.fromRGB(255,200,50),true},
        {"Script desactivado",54,16,Color3.fromRGB(255,200,50),true},
        {"Por michaelarsx - vuelve mas tarde",80,12,Color3.fromRGB(160,160,160),false},
        {"discord.gg/eY9tPGQXJ2",108,12,Color3.fromRGB(150,130,255),true},
    }
    for _,r in ipairs(rows) do
        local l=Instance.new("TextLabel")
        l.Size=UDim2.new(1,-20,0,r[3]+6) l.Position=UDim2.new(0,10,0,r[2])
        l.BackgroundTransparency=1 l.TextColor3=r[4]
        l.Text=r[1] l.Font=r[5] and Enum.Font.GothamBold or Enum.Font.Gotham
        l.TextSize=r[3] l.TextWrapped=true l.Parent=Card
    end
    return
end

-- ================================
-- BIENVENIDA ADMIN
-- ================================
if tieneAccesoAdmin() then
    local G=Instance.new("ScreenGui") G.Name="BienvenidaAdmin" G.ResetOnSpawn=false G.DisplayOrder=1000
    G.Parent=player:WaitForChild("PlayerGui")
    local Bg=Instance.new("Frame") Bg.Size=UDim2.new(1,0,1,0)
    Bg.BackgroundColor3=Color3.fromRGB(0,0,0) Bg.BackgroundTransparency=0.3 Bg.BorderSizePixel=0 Bg.Parent=G
    local Card=Instance.new("Frame") Card.Size=UDim2.new(0,330,0,280)
    Card.Position=UDim2.new(0.5,-165,0.5,320) Card.BackgroundColor3=Color3.fromRGB(10,10,20)
    Card.BorderSizePixel=0 Card.Parent=G
    Instance.new("UICorner",Card).CornerRadius=UDim.new(0,16)
    local GS=Instance.new("UIStroke") GS.Color=Color3.fromRGB(255,200,0) GS.Thickness=2.5 GS.Parent=Card
    task.spawn(function()
        local t=0
        while Card and Card.Parent do
            t+=0.05
            GS.Color=Color3.fromRGB(math.floor(200+55*math.abs(math.sin(t))),math.floor(140+60*math.abs(math.sin(t+1))),0)
            task.wait(0.05)
        end
    end)
    local crown=Instance.new("TextLabel") crown.Size=UDim2.new(1,0,0,60)
    crown.Position=UDim2.new(0,0,0,8) crown.BackgroundTransparency=1
    crown.Text=esAdmin and "👑" or "🛡️" crown.TextScaled=true crown.Font=Enum.Font.GothamBold crown.Parent=Card
    local rows={
        {esAdmin and "Bienvenido, Creador" or "Bienvenido, Admin",74,20,Color3.fromRGB(255,220,50),true},
        {esAdmin and "michaelarsx" or player.Name,102,16,Color3.fromRGB(200,180,255),true},
    }
    for _,r in ipairs(rows) do
        local l=Instance.new("TextLabel") l.Size=UDim2.new(1,-20,0,r[3]+6)
        l.Position=UDim2.new(0,10,0,r[2]) l.BackgroundTransparency=1 l.TextColor3=r[4]
        l.Text=r[1] l.Font=r[5] and Enum.Font.GothamBold or Enum.Font.Gotham l.TextSize=r[3] l.Parent=Card
    end
    local sep=Instance.new("Frame") sep.Size=UDim2.new(1,-40,0,1) sep.Position=UDim2.new(0,20,0,132)
    sep.BackgroundColor3=Color3.fromRGB(255,200,0) sep.BackgroundTransparency=0.5 sep.BorderSizePixel=0 sep.Parent=Card
    local info={
        {"Script: "..(globalConfig.scriptActivo and "ACTIVO ✓" or "DESACTIVADO ✗"),globalConfig.scriptActivo and Color3.fromRGB(80,220,80) or Color3.fromRGB(220,80,80),140},
        {"Mantenimiento: "..(globalConfig.modoMantenimiento and "ON" or "OFF"),globalConfig.modoMantenimiento and Color3.fromRGB(255,160,50) or Color3.fromRGB(120,120,120),162},
        {"Baneados: "..(globalConfig.bans and #globalConfig.bans or 0),Color3.fromRGB(200,150,150),184},
        {"Whitelist: "..(globalConfig.whitelist and globalConfig.whitelist.activo and "ACTIVA" or "INACTIVA"),globalConfig.whitelist and globalConfig.whitelist.activo and Color3.fromRGB(100,200,255) or Color3.fromRGB(120,120,120),206},
        {"Config: GitHub (online)",Color3.fromRGB(80,200,80),228},
    }
    for _,r in ipairs(info) do
        local l=Instance.new("TextLabel") l.Size=UDim2.new(1,-20,0,18)
        l.Position=UDim2.new(0,10,0,r[3]) l.BackgroundTransparency=1 l.TextColor3=r[2]
        l.Text=r[1] l.Font=Enum.Font.GothamBold l.TextSize=11 l.TextXAlignment=Enum.TextXAlignment.Left l.Parent=Card
    end
    local btn=Instance.new("TextButton") btn.Size=UDim2.new(1,-20,0,36)
    btn.Position=UDim2.new(0,10,0,238) btn.BackgroundColor3=Color3.fromRGB(200,160,0)
    btn.TextColor3=Color3.fromRGB(0,0,0) btn.Text="Entrar al juego"
    btn.Font=Enum.Font.GothamBold btn.TextSize=14 btn.BorderSizePixel=0 btn.Parent=Card
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,10)
    TweenService:Create(Card,TweenInfo.new(0.6,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Position=UDim2.new(0.5,-165,0.5,-140)}):Play()
    btn.MouseButton1Click:Connect(function()
        TweenService:Create(Card,TweenInfo.new(0.3,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Position=UDim2.new(0.5,-165,1,20)}):Play()
        TweenService:Create(Bg,TweenInfo.new(0.3),{BackgroundTransparency=1}):Play()
        task.wait(0.35) G:Destroy()
    end)
end

-- ================================
-- SPLASH NORMAL
-- ================================
if not _G.MichaelSplashMostrado then
    _G.MichaelSplashMostrado = true
    local SG=Instance.new("ScreenGui") SG.Name="MichaelSplash" SG.ResetOnSpawn=false SG.DisplayOrder=999
    SG.Parent=player:WaitForChild("PlayerGui")
    local Ov=Instance.new("Frame") Ov.Size=UDim2.new(1,0,1,0)
    Ov.BackgroundColor3=Color3.fromRGB(0,0,0) Ov.BackgroundTransparency=0.4 Ov.BorderSizePixel=0 Ov.Parent=SG
    local Card=Instance.new("Frame") Card.Size=UDim2.new(0,300,0,330)
    Card.Position=UDim2.new(0.5,-150,0.5,200) Card.BackgroundColor3=Color3.fromRGB(16,16,22)
    Card.BorderSizePixel=0 Card.Parent=SG
    Instance.new("UICorner",Card).CornerRadius=UDim.new(0,16)
    local CS=Instance.new("UIStroke") CS.Color=Color3.fromRGB(0,140,255) CS.Thickness=2 CS.Parent=Card
    local topD=Instance.new("Frame") topD.Size=UDim2.new(1,0,0,6)
    topD.BackgroundColor3=Color3.fromRGB(0,130,220) topD.BorderSizePixel=0 topD.Parent=Card
    Instance.new("UICorner",topD).CornerRadius=UDim.new(0,16)
    local tdf=Instance.new("Frame") tdf.Size=UDim2.new(1,0,0.5,0) tdf.Position=UDim2.new(0,0,0.5,0)
    tdf.BackgroundColor3=Color3.fromRGB(0,130,220) tdf.BorderSizePixel=0 tdf.Parent=topD
    local function sLbl(txt,posY,size,color,bold)
        local l=Instance.new("TextLabel") l.Size=UDim2.new(1,-20,0,size+4)
        l.Position=UDim2.new(0,10,0,posY) l.BackgroundTransparency=1 l.TextColor3=color
        l.Text=txt l.Font=bold and Enum.Font.GothamBold or Enum.Font.Gotham
        l.TextSize=size l.TextWrapped=true l.Parent=Card
    end
    sLbl("🎮",12,40,Color3.fromRGB(255,255,255),true)
    sLbl("Gracias por usar nuestro Script!",76,15,Color3.fromRGB(255,255,255),true)
    sLbl("Creado por michaelarsx",106,13,Color3.fromRGB(100,180,255),true)
    local s=Instance.new("Frame") s.Size=UDim2.new(1,-30,0,1) s.Position=UDim2.new(0,15,0,136)
    s.BackgroundColor3=Color3.fromRGB(40,40,60) s.BorderSizePixel=0 s.Parent=Card
    local msg = globalConfig.mensajeDia or "Bienvenido al Server Hopper!"
    sLbl('"'..msg..'"',144,12,Color3.fromRGB(180,230,180),false)
    sLbl("Discord: michaelarsx",186,12,Color3.fromRGB(150,130,255),true)
    local LF=Instance.new("Frame") LF.Size=UDim2.new(1,-20,0,32)
    LF.Position=UDim2.new(0,10,0,210) LF.BackgroundColor3=Color3.fromRGB(24,24,40)
    LF.BorderSizePixel=0 LF.Parent=Card
    Instance.new("UICorner",LF).CornerRadius=UDim.new(0,8)
    local LFS=Instance.new("UIStroke") LFS.Color=Color3.fromRGB(80,80,180) LFS.Thickness=1 LFS.Parent=LF
    local LL=Instance.new("TextLabel") LL.Size=UDim2.new(1,-70,1,0) LL.Position=UDim2.new(0,8,0,0)
    LL.BackgroundTransparency=1 LL.TextColor3=Color3.fromRGB(120,120,220) LL.Text="discord.gg/eY9tPGQXJ2"
    LL.Font=Enum.Font.Gotham LL.TextSize=11 LL.TextXAlignment=Enum.TextXAlignment.Left LL.Parent=LF
    local BC=Instance.new("TextButton") BC.Size=UDim2.new(0,56,0,24) BC.Position=UDim2.new(1,-60,0.5,-12)
    BC.BackgroundColor3=Color3.fromRGB(80,80,200) BC.TextColor3=Color3.fromRGB(255,255,255) BC.Text="Copiar"
    BC.Font=Enum.Font.GothamBold BC.TextSize=10 BC.BorderSizePixel=0 BC.Parent=LF
    Instance.new("UICorner",BC).CornerRadius=UDim.new(0,6)
    BC.MouseButton1Click:Connect(function()
        pcall(function() setclipboard("https://discord.gg/eY9tPGQXJ2") end)
        BC.Text="Copiado!" BC.BackgroundColor3=Color3.fromRGB(40,160,80)
        task.wait(2) BC.Text="Copiar" BC.BackgroundColor3=Color3.fromRGB(80,80,200)
    end)
    local BE=Instance.new("TextButton") BE.Size=UDim2.new(1,-20,0,36)
    BE.Position=UDim2.new(0,10,0,254) BE.BackgroundColor3=Color3.fromRGB(0,120,210)
    BE.TextColor3=Color3.fromRGB(255,255,255) BE.Text="Entendido! Jugar"
    BE.Font=Enum.Font.GothamBold BE.TextSize=14 BE.BorderSizePixel=0 BE.Parent=Card
    Instance.new("UICorner",BE).CornerRadius=UDim.new(0,10)
    TweenService:Create(Card,TweenInfo.new(0.5,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Position=UDim2.new(0.5,-150,0.5,-165)}):Play()
    BE.MouseButton1Click:Connect(function()
        TweenService:Create(Card,TweenInfo.new(0.3,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Position=UDim2.new(0.5,-150,1,20)}):Play()
        TweenService:Create(Ov,TweenInfo.new(0.3),{BackgroundTransparency=1}):Play()
        task.wait(0.35) SG:Destroy()
    end)
end

-- ================================
-- GUI FPS
-- ================================
local PerfGui=Instance.new("ScreenGui") PerfGui.Name="PerfMonitor" PerfGui.ResetOnSpawn=false
PerfGui.DisplayOrder=10 PerfGui.Parent=player:WaitForChild("PlayerGui")
local PF=Instance.new("Frame") PF.Size=UDim2.new(0,218,0,28)
PF.Position=UDim2.new(0.5,-109,0,4) PF.BackgroundColor3=Color3.fromRGB(10,10,15)
PF.BackgroundTransparency=0.15 PF.BorderSizePixel=0 PF.Active=true PF.Draggable=true PF.Parent=PerfGui
Instance.new("UICorner",PF).CornerRadius=UDim.new(0,8)
local PFS=Instance.new("UIStroke") PFS.Color=Color3.fromRGB(0,100,180) PFS.Thickness=1 PFS.Parent=PF
local PL=Instance.new("TextLabel") PL.Size=UDim2.new(1,-30,1,0) PL.Position=UDim2.new(0,8,0,0)
PL.BackgroundTransparency=1 PL.TextColor3=Color3.fromRGB(220,220,220) PL.Text="FPS: --  Ping: --  RAM: --"
PL.Font=Enum.Font.GothamBold PL.TextSize=11 PL.TextXAlignment=Enum.TextXAlignment.Left PL.Parent=PF
local PM=Instance.new("TextButton") PM.Size=UDim2.new(0,20,0,20) PM.Position=UDim2.new(1,-24,0.5,-10)
PM.BackgroundColor3=Color3.fromRGB(40,40,60) PM.TextColor3=Color3.fromRGB(180,180,180) PM.Text="-"
PM.Font=Enum.Font.GothamBold PM.TextSize=12 PM.BorderSizePixel=0 PM.Parent=PF
Instance.new("UICorner",PM).CornerRadius=UDim.new(0,4)
local perfMin=false
PM.MouseButton1Click:Connect(function()
    perfMin=not perfMin
    if perfMin then TweenService:Create(PF,TweenInfo.new(0.2),{Size=UDim2.new(0,24,0,24)}):Play() PL.Visible=false PM.Text="+"
    else TweenService:Create(PF,TweenInfo.new(0.2),{Size=UDim2.new(0,218,0,28)}):Play() PL.Visible=true PM.Text="-" end
end)
local fpsCount=0
RunService.Heartbeat:Connect(function() fpsCount+=1 end)
task.spawn(function()
    while task.wait(1) do
        if not perfMin then
            local fps=fpsCount fpsCount=0
            local ping=0 pcall(function() ping=math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
            local ram=0 pcall(function() ram=math.floor(Stats:GetTotalMemoryUsageMb()) end)
            PL.TextColor3=fps>=50 and Color3.fromRGB(80,220,80) or fps>=30 and Color3.fromRGB(220,200,50) or Color3.fromRGB(220,80,80)
            PL.Text="FPS: "..fps.."  Ping: "..ping.."ms  RAM: "..ram.."MB"
        end
    end
end)

-- ================================
-- ESTADO LOCAL
-- ================================
local cfg=leerJSON(FILES.config,{minVal=1,maxVal=Players.MaxPlayers,autoAmpliar=false,modoRapido=false,minPing=0,maxPing=999})
local minVal=cfg.minVal or 1
local maxVal=cfg.maxVal or Players.MaxPlayers
local minPing=cfg.minPing or 0
local maxPing=cfg.maxPing or 999
local autoAmpliar=cfg.autoAmpliar or false
local modoRapido=cfg.modoRapido or false
local hopping=false local soloHopping=false local escaneando=false
local minimized=false local tiempoBusquedaInicio=0
local viendoHistorial=false local viendoBlacklist=false
local viendoEscaner=false local viendoAdmin=false
local recordD=leerJSON(FILES.record,{record=999999,ultimo=0})
local stats=leerJSON(FILES.stats,{totalRevisados=0,totalEncontrados=0,blacklistCount=0})
local blacklist=leerJSON(FILES.blacklist,{})

local function guardarConfig()
    escribirJSON(FILES.config,{minVal=minVal,maxVal=maxVal,autoAmpliar=autoAmpliar,modoRapido=modoRapido,minPing=minPing,maxPing=maxPing})
end
local function estaEnBL(id)
    for _,v in ipairs(blacklist) do if v==id then return true end end
    return false
end
local function agregarBL(id)
    for _,v in ipairs(blacklist) do if v==id then return end end
    table.insert(blacklist,1,id) if #blacklist>50 then table.remove(blacklist,#blacklist) end
    escribirJSON(FILES.blacklist,blacklist)
    stats.blacklistCount=#blacklist escribirJSON(FILES.stats,stats)
end
local function pasaPing(p)
    if maxPing>=999 then return true end
    if p==0 then return true end
    return p>=minPing and p<=maxPing
end
local function pingTxt(p)
    if p==0 then return "sin dato" end
    if p<80 then return p.."ms OK" end
    if p<150 then return p.."ms Regular" end
    return p.."ms Malo"
end

-- ================================
-- GUI PRINCIPAL
-- ================================
local SG=Instance.new("ScreenGui") SG.Name="ServerHopperV18" SG.ResetOnSpawn=false SG.Parent=player:WaitForChild("PlayerGui")
local TOPBAR_H=72 local ALTURA_NORMAL=648 local FRAME_W=350
local Frame=Instance.new("Frame") Frame.Size=UDim2.new(0,FRAME_W,0,ALTURA_NORMAL)
Frame.Position=UDim2.new(0.5,-(FRAME_W/2),0.5,-(ALTURA_NORMAL/2)+20)
Frame.BackgroundColor3=Color3.fromRGB(16,16,22) Frame.BorderSizePixel=0
Frame.Active=true Frame.Draggable=true Frame.ClipsDescendants=true Frame.Parent=SG
Instance.new("UICorner",Frame).CornerRadius=UDim.new(0,14)
local FS=Instance.new("UIStroke") FS.Color=Color3.fromRGB(0,140,255) FS.Thickness=1.5 FS.Parent=Frame
local TB1=Instance.new("Frame") TB1.Size=UDim2.new(1,0,0,36)
TB1.BackgroundColor3=Color3.fromRGB(0,110,210) TB1.BorderSizePixel=0 TB1.Parent=Frame
Instance.new("UICorner",TB1).CornerRadius=UDim.new(0,14)
local TB1F=Instance.new("Frame") TB1F.Size=UDim2.new(1,0,0.5,0) TB1F.Position=UDim2.new(0,0,0.5,0)
TB1F.BackgroundColor3=Color3.fromRGB(0,110,210) TB1F.BorderSizePixel=0 TB1F.Parent=TB1
local TitleLbl=Instance.new("TextLabel") TitleLbl.Size=UDim2.new(1,-16,1,0)
TitleLbl.Position=UDim2.new(0,14,0,0) TitleLbl.BackgroundTransparency=1
TitleLbl.TextColor3=Color3.fromRGB(255,255,255) TitleLbl.Text="Server Hopper v18  |  michaelarsx"
TitleLbl.Font=Enum.Font.GothamBold TitleLbl.TextSize=15 TitleLbl.TextXAlignment=Enum.TextXAlignment.Left TitleLbl.Parent=TB1
local TB2=Instance.new("Frame") TB2.Size=UDim2.new(1,0,0,36)
TB2.Position=UDim2.new(0,0,0,36) TB2.BackgroundColor3=Color3.fromRGB(0,88,175) TB2.BorderSizePixel=0 TB2.Parent=Frame
local function mkBtn(txt,color,x,w)
    local b=Instance.new("TextButton") b.Size=UDim2.new(0,w or 50,0,28)
    b.Position=UDim2.new(0,x,0.5,-14) b.BackgroundColor3=color
    b.TextColor3=Color3.fromRGB(255,255,255) b.Text=txt
    b.Font=Enum.Font.GothamBold b.TextSize=11 b.BorderSizePixel=0 b.Parent=TB2
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,6) return b
end
local BtnScan=mkBtn("Scan",Color3.fromRGB(0,150,100),6,44)
local BtnHist=mkBtn("Hist",Color3.fromRGB(80,80,180),54,42)
local BtnBL=mkBtn("BL",Color3.fromRGB(160,40,40),100,34)
local BtnAdmin=tieneAccesoAdmin() and mkBtn("Admin",Color3.fromRGB(160,110,0),138,52) or nil
local xMin=tieneAccesoAdmin() and 194 or 138
local BtnMin=mkBtn("Min",Color3.fromRGB(140,100,0),xMin,42)
local BtnClose=mkBtn("Cerrar",Color3.fromRGB(200,40,40),xMin+46,56)
local Content=Instance.new("Frame") Content.Size=UDim2.new(1,0,1,-TOPBAR_H)
Content.Position=UDim2.new(0,0,0,TOPBAR_H) Content.BackgroundTransparency=1 Content.Parent=Frame
local function sep(posY)
    local s=Instance.new("Frame") s.Size=UDim2.new(1,-24,0,1) s.Position=UDim2.new(0,12,0,posY)
    s.BackgroundColor3=Color3.fromRGB(45,45,55) s.BorderSizePixel=0 s.Parent=Content
end
local PLbl=Instance.new("TextLabel") PLbl.Size=UDim2.new(1,-24,0,18) PLbl.Position=UDim2.new(0,12,0,8)
PLbl.BackgroundTransparency=1 PLbl.TextColor3=Color3.fromRGB(100,180,255)
PLbl.Text="PlaceID: "..PLACE_ID.."  |  Max: "..Players.MaxPlayers
PLbl.Font=Enum.Font.Gotham PLbl.TextSize=11 PLbl.Parent=Content
local SBar=Instance.new("Frame") SBar.Size=UDim2.new(1,-24,0,24) SBar.Position=UDim2.new(0,12,0,28)
SBar.BackgroundColor3=Color3.fromRGB(22,22,30) SBar.BorderSizePixel=0 SBar.Parent=Content
Instance.new("UICorner",SBar).CornerRadius=UDim.new(0,6)
local SLbl=Instance.new("TextLabel") SLbl.Size=UDim2.new(1,-10,1,0) SLbl.Position=UDim2.new(0,6,0,0)
SLbl.BackgroundTransparency=1 SLbl.TextColor3=Color3.fromRGB(150,200,255) SLbl.Font=Enum.Font.Gotham SLbl.TextSize=10 SLbl.Parent=SBar
local TBar=Instance.new("Frame") TBar.Size=UDim2.new(1,-24,0,30) TBar.Position=UDim2.new(0,12,0,54)
TBar.BackgroundColor3=Color3.fromRGB(16,22,16) TBar.BorderSizePixel=0 TBar.Parent=Content
Instance.new("UICorner",TBar).CornerRadius=UDim.new(0,8)
local TBarS=Instance.new("UIStroke") TBarS.Color=Color3.fromRGB(0,120,60) TBarS.Thickness=1 TBarS.Parent=TBar
local TFill=Instance.new("Frame") TFill.Size=UDim2.new(0,0,1,0)
TFill.BackgroundColor3=Color3.fromRGB(0,160,80) TFill.BackgroundTransparency=0.4 TFill.BorderSizePixel=0 TFill.Parent=TBar
Instance.new("UICorner",TFill).CornerRadius=UDim.new(0,8)
local TLbl=Instance.new("TextLabel") TLbl.Size=UDim2.new(1,-10,1,0) TLbl.Position=UDim2.new(0,10,0,0)
TLbl.BackgroundTransparency=1 TLbl.TextColor3=Color3.fromRGB(180,255,180)
TLbl.Font=Enum.Font.GothamBold TLbl.TextSize=11 TLbl.TextXAlignment=Enum.TextXAlignment.Left TLbl.Parent=TBar
local RBar=Instance.new("Frame") RBar.Size=UDim2.new(1,-24,0,26) RBar.Position=UDim2.new(0,12,0,86)
RBar.BackgroundColor3=Color3.fromRGB(20,16,6) RBar.BorderSizePixel=0 RBar.Parent=Content
Instance.new("UICorner",RBar).CornerRadius=UDim.new(0,8)
local RBarS=Instance.new("UIStroke") RBarS.Color=Color3.fromRGB(180,140,0) RBarS.Thickness=1 RBarS.Parent=RBar
local RLbl=Instance.new("TextLabel") RLbl.Size=UDim2.new(1,-10,1,0) RLbl.Position=UDim2.new(0,10,0,0)
RLbl.BackgroundTransparency=1 RLbl.TextColor3=Color3.fromRGB(255,210,50)
RLbl.Font=Enum.Font.GothamBold RLbl.TextSize=11 RLbl.TextXAlignment=Enum.TextXAlignment.Left RLbl.Parent=RBar
local function actualizarUI()
    local tasa=stats.totalRevisados>0 and math.floor((stats.totalEncontrados/stats.totalRevisados)*100) or 0
    SLbl.Text="Revisados: "..stats.totalRevisados.."  Encontrados: "..stats.totalEncontrados.."  BL: "..stats.blacklistCount
    TLbl.Text="Tasa exito: "..tasa.."%  ("..stats.totalEncontrados.."/"..stats.totalRevisados..")"
    TweenService:Create(TFill,TweenInfo.new(0.5),{Size=UDim2.new(math.clamp(tasa/100,0,1),0,1,0)}):Play()
    if tasa>=60 then TBarS.Color=Color3.fromRGB(0,200,80) TLbl.TextColor3=Color3.fromRGB(100,255,150)
    elseif tasa>=30 then TBarS.Color=Color3.fromRGB(200,160,0) TLbl.TextColor3=Color3.fromRGB(255,220,80)
    else TBarS.Color=Color3.fromRGB(180,50,50) TLbl.TextColor3=Color3.fromRGB(255,120,120) end
    RLbl.Text=recordD.record>=999999 and "Record: sin datos aun" or "Record: "..recordD.record.."s  |  Ultimo: "..recordD.ultimo.."s"
end
actualizarUI()
sep(118)
local function mkRow(labelTxt,valor,posY)
    local lbl=Instance.new("TextLabel") lbl.Size=UDim2.new(0,200,0,32)
    lbl.Position=UDim2.new(0,12,0,posY) lbl.BackgroundTransparency=1
    lbl.TextColor3=Color3.fromRGB(215,215,215) lbl.Text=labelTxt..valor
    lbl.Font=Enum.Font.Gotham lbl.TextSize=13 lbl.TextXAlignment=Enum.TextXAlignment.Left lbl.Parent=Content
    local bM=Instance.new("TextButton") bM.Size=UDim2.new(0,36,0,28) bM.Position=UDim2.new(0,216,0,posY+2)
    bM.BackgroundColor3=Color3.fromRGB(180,50,50) bM.TextColor3=Color3.fromRGB(255,255,255) bM.Text="-"
    bM.Font=Enum.Font.GothamBold bM.TextSize=16 bM.BorderSizePixel=0 bM.Parent=Content
    Instance.new("UICorner",bM).CornerRadius=UDim.new(0,6)
    local bP=Instance.new("TextButton") bP.Size=UDim2.new(0,36,0,28) bP.Position=UDim2.new(0,258,0,posY+2)
    bP.BackgroundColor3=Color3.fromRGB(50,160,50) bP.TextColor3=Color3.fromRGB(255,255,255) bP.Text="+"
    bP.Font=Enum.Font.GothamBold bP.TextSize=16 bP.BorderSizePixel=0 bP.Parent=Content
    Instance.new("UICorner",bP).CornerRadius=UDim.new(0,6)
    return lbl,bM,bP
end
local MinLbl,BMinM,BMinP=mkRow("Min jugadores: ",minVal,124)
local MaxLbl,BMaxM,BMaxP=mkRow("Max jugadores: ",maxVal,160)
sep(198)
local PingTit=Instance.new("TextLabel") PingTit.Size=UDim2.new(1,-24,0,18)
PingTit.Position=UDim2.new(0,12,0,204) PingTit.BackgroundTransparency=1
PingTit.TextColor3=Color3.fromRGB(100,220,180) PingTit.Text="Filtro Ping (999 = sin filtro)"
PingTit.Font=Enum.Font.GothamBold PingTit.TextSize=11 PingTit.TextXAlignment=Enum.TextXAlignment.Left PingTit.Parent=Content
local PMinLbl,BPMinM,BPMinP=mkRow("Ping min: ",minPing,226)
local PMaxLbl,BPMaxM,BPMaxP=mkRow("Ping max: ",maxPing,262)
sep(300)
local function mkToggle(txt,posY)
    local lbl=Instance.new("TextLabel") lbl.Size=UDim2.new(0,230,0,30)
    lbl.Position=UDim2.new(0,12,0,posY) lbl.BackgroundTransparency=1
    lbl.TextColor3=Color3.fromRGB(200,200,200) lbl.Text=txt
    lbl.Font=Enum.Font.Gotham lbl.TextSize=13 lbl.TextXAlignment=Enum.TextXAlignment.Left lbl.Parent=Content
    local bg=Instance.new("Frame") bg.Size=UDim2.new(0,52,0,28) bg.Position=UDim2.new(0,282,0,posY+1)
    bg.BackgroundColor3=Color3.fromRGB(60,60,60) bg.BorderSizePixel=0 bg.Parent=Content
    Instance.new("UICorner",bg).CornerRadius=UDim.new(1,0)
    local circle=Instance.new("Frame") circle.Size=UDim2.new(0,22,0,22) circle.Position=UDim2.new(0,3,0.5,-11)
    circle.BackgroundColor3=Color3.fromRGB(180,180,180) circle.BorderSizePixel=0 circle.Parent=bg
    Instance.new("UICorner",circle).CornerRadius=UDim.new(1,0)
    local btn=Instance.new("TextButton") btn.Size=UDim2.new(1,0,1,0) btn.BackgroundTransparency=1 btn.Text="" btn.Parent=bg
    return lbl,bg,circle,btn
end
local TAmpLbl,TAmpBg,TAmpC,TAmpBtn=mkToggle("Auto-ampliar rango:",306)
local TRapLbl,TRapBg,TRapC,TRapBtn=mkToggle("Modo rapido:",342)
sep(380)
local PrgLbl=Instance.new("TextLabel") PrgLbl.Size=UDim2.new(1,-24,0,18)
PrgLbl.Position=UDim2.new(0,12,0,386) PrgLbl.BackgroundTransparency=1
PrgLbl.TextColor3=Color3.fromRGB(150,150,150) PrgLbl.Text="Progreso: --"
PrgLbl.Font=Enum.Font.Gotham PrgLbl.TextSize=11 PrgLbl.TextXAlignment=Enum.TextXAlignment.Left PrgLbl.Parent=Content
local BarBg=Instance.new("Frame") BarBg.Size=UDim2.new(1,-24,0,14) BarBg.Position=UDim2.new(0,12,0,406)
BarBg.BackgroundColor3=Color3.fromRGB(38,38,38) BarBg.BorderSizePixel=0 BarBg.Parent=Content
Instance.new("UICorner",BarBg).CornerRadius=UDim.new(1,0)
local BarFill=Instance.new("Frame") BarFill.Size=UDim2.new(0,0,1,0)
BarFill.BackgroundColor3=Color3.fromRGB(0,130,220) BarFill.BorderSizePixel=0 BarFill.Parent=BarBg
Instance.new("UICorner",BarFill).CornerRadius=UDim.new(1,0)
local function actualizarBarra(a,t,color)
    local pct=t>0 and math.clamp(a/t,0,1) or 0
    TweenService:Create(BarFill,TweenInfo.new(0.15),{Size=UDim2.new(pct,0,1,0),BackgroundColor3=color or Color3.fromRGB(0,130,220)}):Play()
    PrgLbl.Text="Progreso: "..a.." / "..(t>0 and t or "?").." servers"
end
local function resetBarra()
    BarFill.Size=UDim2.new(0,0,1,0) PrgLbl.Text="Progreso: --" BarFill.BackgroundColor3=Color3.fromRGB(0,130,220)
end
sep(426)
local BtnHop=Instance.new("TextButton") BtnHop.Size=UDim2.new(0,304,0,44)
BtnHop.Position=UDim2.new(0.5,-152,0,434) BtnHop.BackgroundColor3=Color3.fromRGB(0,130,220)
BtnHop.TextColor3=Color3.fromRGB(255,255,255) BtnHop.Text="Buscar Servidor"
BtnHop.Font=Enum.Font.GothamBold BtnHop.TextSize=15 BtnHop.BorderSizePixel=0 BtnHop.Parent=Content
Instance.new("UICorner",BtnHop).CornerRadius=UDim.new(0,10)
sep(488)
local SoloTit=Instance.new("TextLabel") SoloTit.Size=UDim2.new(1,-24,0,22)
SoloTit.Position=UDim2.new(0,12,0,494) SoloTit.BackgroundTransparency=1
SoloTit.TextColor3=Color3.fromRGB(255,200,50) SoloTit.Text="Modo Solo"
SoloTit.Font=Enum.Font.GothamBold SoloTit.TextSize=13 SoloTit.TextXAlignment=Enum.TextXAlignment.Left SoloTit.Parent=Content
local BSolo1=Instance.new("TextButton") BSolo1.Size=UDim2.new(0,154,0,40)
BSolo1.Position=UDim2.new(0,12,0,520) BSolo1.BackgroundColor3=Color3.fromRGB(180,120,0)
BSolo1.TextColor3=Color3.fromRGB(255,255,255) BSolo1.Text="Server vacio"
BSolo1.Font=Enum.Font.GothamBold BSolo1.TextSize=13 BSolo1.BorderSizePixel=0 BSolo1.Parent=Content
Instance.new("UICorner",BSolo1).CornerRadius=UDim.new(0,8)
local BSolo0=Instance.new("TextButton") BSolo0.Size=UDim2.new(0,154,0,40)
BSolo0.Position=UDim2.new(0,174,0,520) BSolo0.BackgroundColor3=Color3.fromRGB(100,0,160)
BSolo0.TextColor3=Color3.fromRGB(255,255,255) BSolo0.Text="0 jugadores"
BSolo0.Font=Enum.Font.GothamBold BSolo0.TextSize=13 BSolo0.BorderSizePixel=0 BSolo0.Parent=Content
Instance.new("UICorner",BSolo0).CornerRadius=UDim.new(0,8)
local StatusSolo=Instance.new("TextLabel") StatusSolo.Size=UDim2.new(1,0,0,20)
StatusSolo.Position=UDim2.new(0,0,0,566) StatusSolo.BackgroundTransparency=1
StatusSolo.TextColor3=Color3.fromRGB(180,180,180) StatusSolo.Text=""
StatusSolo.Font=Enum.Font.Gotham StatusSolo.TextSize=11 StatusSolo.Parent=Content
local StatusLbl=Instance.new("TextLabel") StatusLbl.Size=UDim2.new(1,0,0,20)
StatusLbl.Position=UDim2.new(0,0,0,586) StatusLbl.BackgroundTransparency=1
StatusLbl.TextColor3=Color3.fromRGB(180,180,180) StatusLbl.Text="Estado: Listo"
StatusLbl.Font=Enum.Font.Gotham StatusLbl.TextSize=11 StatusLbl.Parent=Content
local Status2=Instance.new("TextLabel") Status2.Size=UDim2.new(1,0,0,20)
Status2.Position=UDim2.new(0,0,0,606) Status2.BackgroundTransparency=1
Status2.TextColor3=Color3.fromRGB(100,220,100) Status2.Text=""
Status2.Font=Enum.Font.GothamBold Status2.TextSize=11 Status2.Parent=Content

-- ================================
-- NOTIFICACION RECORD
-- ================================
local RNotif=Instance.new("Frame") RNotif.Size=UDim2.new(0,300,0,96)
RNotif.Position=UDim2.new(0.5,-150,1,10) RNotif.BackgroundColor3=Color3.fromRGB(10,16,10)
RNotif.BorderSizePixel=0 RNotif.Parent=SG RNotif.Visible=false
Instance.new("UICorner",RNotif).CornerRadius=UDim.new(0,12)
local RNS=Instance.new("UIStroke") RNS.Color=Color3.fromRGB(255,200,0) RNS.Thickness=2 RNS.Parent=RNotif
local RNIcon=Instance.new("Frame") RNIcon.Size=UDim2.new(0,72,1,0)
RNIcon.BackgroundColor3=Color3.fromRGB(0,0,0) RNIcon.BackgroundTransparency=0.6 RNIcon.BorderSizePixel=0 RNIcon.Parent=RNotif
local RNM=Instance.new("TextLabel") RNM.Size=UDim2.new(1,0,0,46) RNM.Position=UDim2.new(0,0,0,8)
RNM.BackgroundTransparency=1 RNM.TextColor3=Color3.fromRGB(255,200,50) RNM.Text="M"
RNM.Font=Enum.Font.GothamBold RNM.TextSize=36 RNM.Parent=RNIcon
local RNSub=Instance.new("TextLabel") RNSub.Size=UDim2.new(1,0,0,14) RNSub.Position=UDim2.new(0,0,0,56)
RNSub.BackgroundTransparency=1 RNSub.TextColor3=Color3.fromRGB(180,140,50) RNSub.Text="michaelarsx"
RNSub.Font=Enum.Font.GothamBold RNSub.TextSize=7 RNSub.Parent=RNIcon
local RNTxt=Instance.new("TextLabel") RNTxt.Size=UDim2.new(1,-82,1,-10) RNTxt.Position=UDim2.new(0,76,0,5)
RNTxt.BackgroundTransparency=1 RNTxt.TextColor3=Color3.fromRGB(255,230,100) RNTxt.Text=""
RNTxt.Font=Enum.Font.GothamBold RNTxt.TextSize=12 RNTxt.TextWrapped=true
RNTxt.TextXAlignment=Enum.TextXAlignment.Left RNTxt.TextYAlignment=Enum.TextYAlignment.Top RNTxt.Parent=RNotif
local RNCreado=Instance.new("TextLabel") RNCreado.Size=UDim2.new(1,-82,0,14) RNCreado.Position=UDim2.new(0,76,1,-18)
RNCreado.BackgroundTransparency=1 RNCreado.TextColor3=Color3.fromRGB(100,100,100) RNCreado.Text="Creado por michaelarsx"
RNCreado.Font=Enum.Font.Gotham RNCreado.TextSize=9 RNCreado.TextXAlignment=Enum.TextXAlignment.Left RNCreado.Parent=RNotif
local rnActivo=false
local function mostrarRecordNotif(seg,esRecord)
    if rnActivo then return end rnActivo=true
    RNS.Color=esRecord and Color3.fromRGB(255,200,0) or Color3.fromRGB(0,180,255)
    RNM.TextColor3=esRecord and Color3.fromRGB(255,200,50) or Color3.fromRGB(100,200,255)
    RNTxt.TextColor3=esRecord and Color3.fromRGB(255,230,50) or Color3.fromRGB(180,220,255)
    RNTxt.Text="Te uniste en "..seg.."s\n"..(esRecord and "NUEVO RECORD!" or "Record: "..recordD.record.."s").."\nUltimo: "..recordD.ultimo.."s"
    RNotif.Visible=true
    TweenService:Create(RNotif,TweenInfo.new(0.4,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Position=UDim2.new(0.5,-150,1,-106)}):Play()
    task.wait(4)
    TweenService:Create(RNotif,TweenInfo.new(0.3,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Position=UDim2.new(0.5,-150,1,10)}):Play()
    task.wait(0.35) RNotif.Visible=false rnActivo=false
end
local function registrarTiempo(seg)
    recordD.ultimo=seg
    local esRecord=seg<recordD.record
    if esRecord then recordD.record=seg end
    escribirJSON(FILES.record,recordD) actualizarUI()
    task.spawn(function() mostrarRecordNotif(seg,esRecord) end)
end

-- ================================
-- POPUP
-- ================================
local Popup=Instance.new("Frame") Popup.Size=UDim2.new(0,270,0,72)
Popup.Position=UDim2.new(0.5,-135,1,10) Popup.BackgroundColor3=Color3.fromRGB(140,60,0)
Popup.BorderSizePixel=0 Popup.Parent=SG Popup.Visible=false
Instance.new("UICorner",Popup).CornerRadius=UDim.new(0,10)
local PopS=Instance.new("UIStroke") PopS.Color=Color3.fromRGB(255,150,0) PopS.Thickness=2 PopS.Parent=Popup
local PopI=Instance.new("TextLabel") PopI.Size=UDim2.new(0,55,1,0) PopI.BackgroundTransparency=1
PopI.TextColor3=Color3.fromRGB(255,200,0) PopI.Text="!" PopI.Font=Enum.Font.GothamBold PopI.TextSize=32 PopI.Parent=Popup
local PopT=Instance.new("TextLabel") PopT.Size=UDim2.new(1,-65,1,0) PopT.Position=UDim2.new(0,55,0,0)
PopT.BackgroundTransparency=1 PopT.TextColor3=Color3.fromRGB(255,220,100) PopT.Text=""
PopT.Font=Enum.Font.GothamBold PopT.TextSize=11 PopT.TextWrapped=true PopT.TextXAlignment=Enum.TextXAlignment.Left PopT.Parent=Popup
local popActivo=false
local function mostrarPopup(icono,bgC,stC,txtC,msg)
    if popActivo then return end popActivo=true
    Popup.BackgroundColor3=bgC PopS.Color=stC PopI.Text=icono PopT.Text=msg PopT.TextColor3=txtC
    Popup.Visible=true
    TweenService:Create(Popup,TweenInfo.new(0.4,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Position=UDim2.new(0.5,-135,1,-85)}):Play()
    task.wait(3)
    TweenService:Create(Popup,TweenInfo.new(0.3,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Position=UDim2.new(0.5,-135,1,10)}):Play()
    task.wait(0.35) Popup.Visible=false popActivo=false
end
local function notif(t,m)
    pcall(function() StarterGui:SetCore("SendNotification",{Title=t,Text=m,Duration=5}) end)
end

-- ================================
-- PANEL ADMIN
-- ================================
local AdminFrame=Instance.new("Frame") AdminFrame.Size=UDim2.new(1,0,1,-TOPBAR_H)
AdminFrame.Position=UDim2.new(0,0,0,TOPBAR_H) AdminFrame.BackgroundTransparency=1
AdminFrame.Visible=false AdminFrame.Parent=Frame
local AdminScroll=Instance.new("ScrollingFrame") AdminScroll.Size=UDim2.new(1,0,1,0)
AdminScroll.BackgroundTransparency=1 AdminScroll.BorderSizePixel=0
AdminScroll.ScrollBarThickness=4 AdminScroll.ScrollBarImageColor3=Color3.fromRGB(200,150,0)
AdminScroll.CanvasSize=UDim2.new(0,0,0,900) AdminScroll.Parent=AdminFrame
local AdminLL=Instance.new("UIListLayout") AdminLL.SortOrder=Enum.SortOrder.LayoutOrder
AdminLL.Padding=UDim.new(0,6) AdminLL.Parent=AdminScroll
local function mkSec(titulo,altura,order)
    local sec=Instance.new("Frame") sec.Size=UDim2.new(1,-24,0,altura)
    sec.BackgroundColor3=Color3.fromRGB(20,20,30) sec.BorderSizePixel=0
    sec.LayoutOrder=order sec.Parent=AdminScroll
    Instance.new("UICorner",sec).CornerRadius=UDim.new(0,10)
    local s=Instance.new("UIStroke") s.Color=Color3.fromRGB(60,60,80) s.Thickness=1 s.Parent=sec
    if titulo then
        local t=Instance.new("TextLabel") t.Size=UDim2.new(1,-16,0,22)
        t.Position=UDim2.new(0,8,0,4) t.BackgroundTransparency=1
        t.TextColor3=Color3.fromRGB(200,200,255) t.Text=titulo
        t.Font=Enum.Font.GothamBold t.TextSize=12 t.TextXAlignment=Enum.TextXAlignment.Left t.Parent=sec
    end
    return sec
end
local function mkABtn(txt,color,posX,posY,ancho,alto,padre)
    local b=Instance.new("TextButton") b.Size=UDim2.new(0,ancho or 110,0,alto or 28)
    b.Position=UDim2.new(0,posX,0,posY) b.BackgroundColor3=color
    b.TextColor3=Color3.fromRGB(255,255,255) b.Text=txt
    b.Font=Enum.Font.GothamBold b.TextSize=12 b.BorderSizePixel=0 b.Parent=padre
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,7) return b
end
local padTop=Instance.new("Frame") padTop.Size=UDim2.new(1,-24,0,6)
padTop.BackgroundTransparency=1 padTop.LayoutOrder=0 padTop.Parent=AdminScroll
local titSec=Instance.new("Frame") titSec.Size=UDim2.new(1,-24,0,36)
titSec.BackgroundColor3=Color3.fromRGB(160,100,0) titSec.BorderSizePixel=0
titSec.LayoutOrder=1 titSec.Parent=AdminScroll
Instance.new("UICorner",titSec).CornerRadius=UDim.new(0,8)
local titLbl=Instance.new("TextLabel") titLbl.Size=UDim2.new(1,-120,1,0)
titLbl.Position=UDim2.new(0,12,0,0) titLbl.BackgroundTransparency=1
titLbl.TextColor3=Color3.fromRGB(255,255,255) titLbl.Text="Panel Admin  |  michaelarsx  |  GitHub"
titLbl.Font=Enum.Font.GothamBold titLbl.TextSize=13 titLbl.TextXAlignment=Enum.TextXAlignment.Left titLbl.Parent=titSec
local BtnSync=mkABtn("Sync GitHub",Color3.fromRGB(0,130,60),0,0,108,28,titSec)
BtnSync.Position=UDim2.new(1,-116,0.5,-14)
local FeedbackLbl=Instance.new("TextLabel")
FeedbackLbl.Size=UDim2.new(1,-24,0,22) FeedbackLbl.BackgroundTransparency=1
FeedbackLbl.TextColor3=Color3.fromRGB(100,220,100) FeedbackLbl.Text=""
FeedbackLbl.Font=Enum.Font.GothamBold FeedbackLbl.TextSize=11 FeedbackLbl.LayoutOrder=2
FeedbackLbl.Parent=AdminScroll
local function setFeedback(msg,color)
    FeedbackLbl.Text=msg FeedbackLbl.TextColor3=color or Color3.fromRGB(100,220,100)
    task.delay(4,function() FeedbackLbl.Text="" end)
end
local function guardarEnGitHub(razon)
    BtnSync.Text="Guardando..." BtnSync.BackgroundColor3=Color3.fromRGB(80,80,0)
    local ok,msg=escribirGitHub(globalConfig)
    if ok then
        BtnSync.Text="Sync GitHub" BtnSync.BackgroundColor3=Color3.fromRGB(0,130,60)
        setFeedback("✓ Guardado en GitHub: "..(razon or ""),Color3.fromRGB(100,220,100))
    else
        BtnSync.Text="Sync GitHub" BtnSync.BackgroundColor3=Color3.fromRGB(0,130,60)
        setFeedback("⚠ Error: Necesitas configurar el TOKEN de GitHub",Color3.fromRGB(255,160,50))
    end
end
BtnSync.MouseButton1Click:Connect(function() task.spawn(function() guardarEnGitHub("manual") end) end)

-- TOKEN
local sec0=mkSec("Token de GitHub (necesario para guardar)",68,3)
local TokenF=Instance.new("Frame") TokenF.Size=UDim2.new(1,-16,0,28)
TokenF.Position=UDim2.new(0,8,0,26) TokenF.BackgroundColor3=Color3.fromRGB(10,10,18)
TokenF.BorderSizePixel=0 TokenF.Parent=sec0
Instance.new("UICorner",TokenF).CornerRadius=UDim.new(0,6)
local TFS=Instance.new("UIStroke") TFS.Color=Color3.fromRGB(100,80,40) TFS.Thickness=1 TFS.Parent=TokenF
local TokenTB=Instance.new("TextBox") TokenTB.Size=UDim2.new(1,-90,1,0)
TokenTB.Position=UDim2.new(0,6,0,0) TokenTB.BackgroundTransparency=1
TokenTB.TextColor3=Color3.fromRGB(220,180,100) TokenTB.PlaceholderText="Pega tu GitHub Token aqui..."
TokenTB.PlaceholderColor3=Color3.fromRGB(100,80,40) TokenTB.Text=GITHUB_TOKEN~="PON_TU_TOKEN_AQUI" and GITHUB_TOKEN or ""
TokenTB.Font=Enum.Font.Gotham TokenTB.TextSize=10
TokenTB.TextXAlignment=Enum.TextXAlignment.Left TokenTB.ClearTextOnFocus=false TokenTB.Parent=TokenF
local BtnGuardToken=mkABtn("Guardar",Color3.fromRGB(160,100,0),0,0,76,24,TokenF)
BtnGuardToken.Position=UDim2.new(1,-82,0.5,-12)
BtnGuardToken.MouseButton1Click:Connect(function()
    GITHUB_TOKEN=TokenTB.Text
    BtnGuardToken.Text="Listo!" BtnGuardToken.BackgroundColor3=Color3.fromRGB(0,150,60)
    task.wait(2) BtnGuardToken.Text="Guardar" BtnGuardToken.BackgroundColor3=Color3.fromRGB(160,100,0)
end)
local TokenHint=Instance.new("TextLabel") TokenHint.Size=UDim2.new(1,-16,0,14)
TokenHint.Position=UDim2.new(0,8,0,56) TokenHint.BackgroundTransparency=1
TokenHint.TextColor3=Color3.fromRGB(120,100,60)
TokenHint.Text="GitHub > Settings > Developer Settings > Tokens (classic) > repo"
TokenHint.Font=Enum.Font.Gotham TokenHint.TextSize=9
TokenHint.TextXAlignment=Enum.TextXAlignment.Left TokenHint.Parent=sec0

-- CONTROL SCRIPT
local sec1=mkSec("Control del Script",106,4)
local ScriptEstLbl=Instance.new("TextLabel") ScriptEstLbl.Size=UDim2.new(1,-130,0,22)
ScriptEstLbl.Position=UDim2.new(0,8,0,28) ScriptEstLbl.BackgroundTransparency=1
ScriptEstLbl.TextColor3=globalConfig.scriptActivo and Color3.fromRGB(80,220,80) or Color3.fromRGB(220,80,80)
ScriptEstLbl.Text="Script: "..(globalConfig.scriptActivo and "ACTIVO ✓" or "DESACTIVADO ✗")
ScriptEstLbl.Font=Enum.Font.GothamBold ScriptEstLbl.TextSize=13
ScriptEstLbl.TextXAlignment=Enum.TextXAlignment.Left ScriptEstLbl.Parent=sec1
local BtnToggleScript=mkABtn(globalConfig.scriptActivo and "Desactivar" or "Activar",
    globalConfig.scriptActivo and Color3.fromRGB(180,40,40) or Color3.fromRGB(0,150,60),0,26,110,26,sec1)
BtnToggleScript.Position=UDim2.new(1,-118,0,28)
local MantenLbl=Instance.new("TextLabel") MantenLbl.Size=UDim2.new(1,-130,0,22)
MantenLbl.Position=UDim2.new(0,8,0,62) MantenLbl.BackgroundTransparency=1
MantenLbl.TextColor3=globalConfig.modoMantenimiento and Color3.fromRGB(255,160,50) or Color3.fromRGB(120,120,120)
MantenLbl.Text="Mantenimiento: "..(globalConfig.modoMantenimiento and "ON" or "OFF")
MantenLbl.Font=Enum.Font.GothamBold MantenLbl.TextSize=13
MantenLbl.TextXAlignment=Enum.TextXAlignment.Left MantenLbl.Parent=sec1
local BtnToggleManten=mkABtn(globalConfig.modoMantenimiento and "Desactivar" or "Activar",
    globalConfig.modoMantenimiento and Color3.fromRGB(160,120,0) or Color3.fromRGB(0,120,140),0,62,110,26,sec1)
BtnToggleManten.Position=UDim2.new(1,-118,0,62)
BtnToggleScript.MouseButton1Click:Connect(function()
    globalConfig.scriptActivo=not globalConfig.scriptActivo
    local a=globalConfig.scriptActivo
    ScriptEstLbl.Text="Script: "..(a and "ACTIVO ✓" or "DESACTIVADO ✗")
    ScriptEstLbl.TextColor3=a and Color3.fromRGB(80,220,80) or Color3.fromRGB(220,80,80)
    BtnToggleScript.Text=a and "Desactivar" or "Activar"
    BtnToggleScript.BackgroundColor3=a and Color3.fromRGB(180,40,40) or Color3.fromRGB(0,150,60)
    task.spawn(function() guardarEnGitHub("script "..(a and "activado" or "desactivado")) end)
end)
BtnToggleManten.MouseButton1Click:Connect(function()
    globalConfig.modoMantenimiento=not globalConfig.modoMantenimiento
    local m=globalConfig.modoMantenimiento
    MantenLbl.Text="Mantenimiento: "..(m and "ON" or "OFF")
    MantenLbl.TextColor3=m and Color3.fromRGB(255,160,50) or Color3.fromRGB(120,120,120)
    BtnToggleManten.Text=m and "Desactivar" or "Activar"
    BtnToggleManten.BackgroundColor3=m and Color3.fromRGB(160,120,0) or Color3.fromRGB(0,120,140)
    task.spawn(function() guardarEnGitHub("mantenimiento "..(m and "ON" or "OFF")) end)
end)

-- MENSAJE DEL DIA
local sec2=mkSec("Mensaje del dia (splash de todos)",74,5)
local MsgIF=Instance.new("Frame") MsgIF.Size=UDim2.new(1,-16,0,28) MsgIF.Position=UDim2.new(0,8,0,28)
MsgIF.BackgroundColor3=Color3.fromRGB(12,12,20) MsgIF.BorderSizePixel=0 MsgIF.Parent=sec2
Instance.new("UICorner",MsgIF).CornerRadius=UDim.new(0,6)
local MIFS=Instance.new("UIStroke") MIFS.Color=Color3.fromRGB(80,80,120) MIFS.Thickness=1 MIFS.Parent=MsgIF
local MsgTB=Instance.new("TextBox") MsgTB.Size=UDim2.new(1,-88,1,0) MsgTB.Position=UDim2.new(0,6,0,0)
MsgTB.BackgroundTransparency=1 MsgTB.TextColor3=Color3.fromRGB(220,220,220)
MsgTB.PlaceholderText="Escribe el mensaje del dia..."
MsgTB.PlaceholderColor3=Color3.fromRGB(100,100,100) MsgTB.Text=globalConfig.mensajeDia or ""
MsgTB.Font=Enum.Font.Gotham MsgTB.TextSize=11 MsgTB.TextXAlignment=Enum.TextXAlignment.Left
MsgTB.ClearTextOnFocus=false MsgTB.Parent=MsgIF
local BtnGuardarMsg=mkABtn("Guardar",Color3.fromRGB(0,130,80),0,0,76,24,MsgIF)
BtnGuardarMsg.Position=UDim2.new(1,-80,0.5,-12)
BtnGuardarMsg.MouseButton1Click:Connect(function()
    globalConfig.mensajeDia=MsgTB.Text
    task.spawn(function() guardarEnGitHub("mensaje del dia") end)
    BtnGuardarMsg.Text="Guardado!" BtnGuardarMsg.BackgroundColor3=Color3.fromRGB(0,160,60)
    task.wait(2) BtnGuardarMsg.Text="Guardar" BtnGuardarMsg.BackgroundColor3=Color3.fromRGB(0,130,80)
end)

-- BANEAR
local sec3=mkSec("Banear usuario",64,6)
local BanIF=Instance.new("Frame") BanIF.Size=UDim2.new(1,-16,0,26) BanIF.Position=UDim2.new(0,8,0,28)
BanIF.BackgroundColor3=Color3.fromRGB(10,10,18) BanIF.BorderSizePixel=0 BanIF.Parent=sec3
Instance.new("UICorner",BanIF).CornerRadius=UDim.new(0,6)
local BIFS=Instance.new("UIStroke") BIFS.Color=Color3.fromRGB(120,40,40) BIFS.Thickness=1 BIFS.Parent=BanIF
local BanTB=Instance.new("TextBox") BanTB.Size=UDim2.new(0.45,0,1,0) BanTB.Position=UDim2.new(0,5,0,0)
BanTB.BackgroundTransparency=1 BanTB.TextColor3=Color3.fromRGB(220,150,150)
BanTB.PlaceholderText="UserID/Username" BanTB.PlaceholderColor3=Color3.fromRGB(100,80,80)
BanTB.Text="" BanTB.Font=Enum.Font.Gotham BanTB.TextSize=10
BanTB.TextXAlignment=Enum.TextXAlignment.Left BanTB.ClearTextOnFocus=false BanTB.Parent=BanIF
local RazonTB=Instance.new("TextBox") RazonTB.Size=UDim2.new(0.35,0,1,0) RazonTB.Position=UDim2.new(0.46,0,0,0)
RazonTB.BackgroundTransparency=1 RazonTB.TextColor3=Color3.fromRGB(180,180,180)
RazonTB.PlaceholderText="Razon..." RazonTB.PlaceholderColor3=Color3.fromRGB(100,100,100)
RazonTB.Text="" RazonTB.Font=Enum.Font.Gotham RazonTB.TextSize=10
RazonTB.TextXAlignment=Enum.TextXAlignment.Left RazonTB.ClearTextOnFocus=false RazonTB.Parent=BanIF
local BtnBanear=mkABtn("Banear",Color3.fromRGB(180,40,40),0,0,70,22,BanIF)
BtnBanear.Position=UDim2.new(1,-76,0.5,-11)
BtnBanear.MouseButton1Click:Connect(function()
    local input=BanTB.Text:gsub("%s","")
    if input=="" then return end
    local uid=tonumber(input) local nombre=input
    if not uid then pcall(function() uid=Players:GetUserIdFromNameAsync(input) end) end
    if not uid then setFeedback("Usuario no encontrado",Color3.fromRGB(255,100,100)) return end
    if uid==ADMIN_ID then setFeedback("No puedes banearte a ti mismo",Color3.fromRGB(255,100,100)) return end
    pcall(function() nombre=Players:GetNameFromUserIdAsync(uid) end)
    if not globalConfig.bans then globalConfig.bans={} end
    for _,b in ipairs(globalConfig.bans) do
        if tostring(b.userId)==tostring(uid) then setFeedback("Ya esta baneado",Color3.fromRGB(255,180,50)) return end
    end
    table.insert(globalConfig.bans,1,{userId=uid,nombre=nombre,razon=RazonTB.Text,fecha=os.date("%d/%m %H:%M")})
    BanTB.Text="" RazonTB.Text=""
    task.spawn(function() guardarEnGitHub("ban: "..nombre) end)
    actualizarBanListUI()
end)

-- LISTA BANEADOS
local sec4=mkSec("Usuarios baneados",190,7)
local BanCountLbl2=Instance.new("TextLabel") BanCountLbl2.Size=UDim2.new(1,-130,0,18)
BanCountLbl2.Position=UDim2.new(0,8,0,26) BanCountLbl2.BackgroundTransparency=1
BanCountLbl2.TextColor3=Color3.fromRGB(220,150,150)
BanCountLbl2.Text="Baneados: "..(globalConfig.bans and #globalConfig.bans or 0)
BanCountLbl2.Font=Enum.Font.GothamBold BanCountLbl2.TextSize=11
BanCountLbl2.TextXAlignment=Enum.TextXAlignment.Left BanCountLbl2.Parent=sec4
local BtnLimpiarBans=mkABtn("Limpiar todo",Color3.fromRGB(120,30,30),0,24,110,22,sec4)
BtnLimpiarBans.Position=UDim2.new(1,-118,0,24)
local BanScroll=Instance.new("ScrollingFrame") BanScroll.Size=UDim2.new(1,-16,0,132)
BanScroll.Position=UDim2.new(0,8,0,50) BanScroll.BackgroundTransparency=1
BanScroll.BorderSizePixel=0 BanScroll.ScrollBarThickness=3
BanScroll.ScrollBarImageColor3=Color3.fromRGB(180,50,50) BanScroll.CanvasSize=UDim2.new(0,0,0,0)
BanScroll.Parent=sec4
local BanLL=Instance.new("UIListLayout") BanLL.SortOrder=Enum.SortOrder.LayoutOrder
BanLL.Padding=UDim.new(0,3) BanLL.Parent=BanScroll
local function actualizarBanListUI()
    for _,v in pairs(BanScroll:GetChildren()) do if v:IsA("Frame") or v:IsA("TextLabel") then v:Destroy() end end
    local bans=globalConfig.bans or {}
    BanCountLbl2.Text="Baneados: "..#bans
    if #bans==0 then
        local v=Instance.new("TextLabel") v.Size=UDim2.new(1,0,0,30) v.BackgroundTransparency=1
        v.TextColor3=Color3.fromRGB(100,100,100) v.Text="Sin usuarios baneados"
        v.Font=Enum.Font.Gotham v.TextSize=11 v.Parent=BanScroll
        BanScroll.CanvasSize=UDim2.new(0,0,0,34) return
    end
    for i,ban in ipairs(bans) do
        local item=Instance.new("Frame") item.Size=UDim2.new(1,0,0,46)
        item.BackgroundColor3=Color3.fromRGB(26,12,12) item.BorderSizePixel=0
        item.LayoutOrder=i item.Parent=BanScroll
        Instance.new("UICorner",item).CornerRadius=UDim.new(0,6)
        local iS=Instance.new("UIStroke") iS.Color=Color3.fromRGB(120,40,40) iS.Thickness=1 iS.Parent=item
        local lN=Instance.new("TextLabel") lN.Size=UDim2.new(1,-82,0,18)
        lN.Position=UDim2.new(0,8,0,3) lN.BackgroundTransparency=1
        lN.TextColor3=Color3.fromRGB(220,130,130) lN.Text=(ban.nombre or "??").." | "..tostring(ban.userId)
        lN.Font=Enum.Font.GothamBold lN.TextSize=10 lN.TextXAlignment=Enum.TextXAlignment.Left lN.Parent=item
        local lR=Instance.new("TextLabel") lR.Size=UDim2.new(1,-82,0,16)
        lR.Position=UDim2.new(0,8,0,24) lR.BackgroundTransparency=1
        lR.TextColor3=Color3.fromRGB(160,100,100)
        lR.Text="Razon: "..(ban.razon~="" and ban.razon or "Sin razon")
        lR.Font=Enum.Font.Gotham lR.TextSize=10 lR.TextXAlignment=Enum.TextXAlignment.Left lR.Parent=item
        local bD=mkABtn("Desban",Color3.fromRGB(0,120,60),0,0,68,28,item)
        bD.Position=UDim2.new(1,-76,0.5,-14)
        local savedBan=ban
        bD.MouseButton1Click:Connect(function()
            local bans2=globalConfig.bans or {}
            for j,b in ipairs(bans2) do
                if tostring(b.userId)==tostring(savedBan.userId) then table.remove(bans2,j) break end
            end
            globalConfig.bans=bans2
            task.spawn(function() guardarEnGitHub("desban: "..(savedBan.nombre or "??")) end)
            actualizarBanListUI()
        end)
    end
    BanScroll.CanvasSize=UDim2.new(0,0,0,#bans*49)
end
BtnLimpiarBans.MouseButton1Click:Connect(function()
    globalConfig.bans={}
    task.spawn(function() guardarEnGitHub("limpiar bans") end)
    actualizarBanListUI()
end)

-- WHITELIST
local sec5=mkSec("Whitelist (solo usuarios aprobados)",160,8)
local WLEstLbl=Instance.new("TextLabel") WLEstLbl.Size=UDim2.new(1,-130,0,20)
WLEstLbl.Position=UDim2.new(0,8,0,28) WLEstLbl.BackgroundTransparency=1
local wlActivo=globalConfig.whitelist and globalConfig.whitelist.activo or false
WLEstLbl.TextColor3=wlActivo and Color3.fromRGB(100,200,255) or Color3.fromRGB(120,120,120)
WLEstLbl.Text="Whitelist: "..(wlActivo and "ACTIVA" or "INACTIVA")
WLEstLbl.Font=Enum.Font.GothamBold WLEstLbl.TextSize=12
WLEstLbl.TextXAlignment=Enum.TextXAlignment.Left WLEstLbl.Parent=sec5
local BtnToggleWL=mkABtn(wlActivo and "Desactivar" or "Activar",
    wlActivo and Color3.fromRGB(160,40,40) or Color3.fromRGB(0,130,160),0,26,110,22,sec5)
BtnToggleWL.Position=UDim2.new(1,-118,0,26)
local WLIF=Instance.new("Frame") WLIF.Size=UDim2.new(1,-110,0,24) WLIF.Position=UDim2.new(0,8,0,54)
WLIF.BackgroundColor3=Color3.fromRGB(10,10,18) WLIF.BorderSizePixel=0 WLIF.Parent=sec5
Instance.new("UICorner",WLIF).CornerRadius=UDim.new(0,5)
local WLIS=Instance.new("UIStroke") WLIS.Color=Color3.fromRGB(60,80,120) WLIS.Thickness=1 WLIS.Parent=WLIF
local WLTB=Instance.new("TextBox") WLTB.Size=UDim2.new(1,-8,1,0) WLTB.Position=UDim2.new(0,5,0,0)
WLTB.BackgroundTransparency=1 WLTB.TextColor3=Color3.fromRGB(200,220,255)
WLTB.PlaceholderText="UserID o Username..." WLTB.PlaceholderColor3=Color3.fromRGB(80,80,100)
WLTB.Text="" WLTB.Font=Enum.Font.Gotham WLTB.TextSize=10
WLTB.TextXAlignment=Enum.TextXAlignment.Left WLTB.ClearTextOnFocus=false WLTB.Parent=WLIF
local BtnAddWL=mkABtn("Agregar",Color3.fromRGB(0,120,180),0,0,92,22,sec5)
BtnAddWL.Position=UDim2.new(1,-100,0,54)
local WLScroll=Instance.new("ScrollingFrame") WLScroll.Size=UDim2.new(1,-16,0,68)
WLScroll.Position=UDim2.new(0,8,0,82) WLScroll.BackgroundTransparency=1 WLScroll.BorderSizePixel=0
WLScroll.ScrollBarThickness=3 WLScroll.ScrollBarImageColor3=Color3.fromRGB(0,130,180)
WLScroll.CanvasSize=UDim2.new(0,0,0,0) WLScroll.Parent=sec5
local WLLL=Instance.new("UIListLayout") WLLL.SortOrder=Enum.SortOrder.LayoutOrder
WLLL.Padding=UDim.new(0,3) WLLL.Parent=WLScroll
local WLCountLbl=Instance.new("TextLabel") WLCountLbl.Size=UDim2.new(1,-16,0,14)
WLCountLbl.Position=UDim2.new(0,8,0,152) WLCountLbl.BackgroundTransparency=1
WLCountLbl.TextColor3=Color3.fromRGB(100,150,200)
WLCountLbl.Text="En whitelist: "..(globalConfig.whitelist and #globalConfig.whitelist.usuarios or 0)
WLCountLbl.Font=Enum.Font.Gotham WLCountLbl.TextSize=10
WLCountLbl.TextXAlignment=Enum.TextXAlignment.Left WLCountLbl.Parent=sec5
local function actualizarWLUI()
    for _,v in pairs(WLScroll:GetChildren()) do if v:IsA("Frame") or v:IsA("TextLabel") then v:Destroy() end end
    local wl=globalConfig.whitelist and globalConfig.whitelist.usuarios or {}
    WLCountLbl.Text="En whitelist: "..#wl
    if #wl==0 then
        local v=Instance.new("TextLabel") v.Size=UDim2.new(1,0,0,22) v.BackgroundTransparency=1
        v.TextColor3=Color3.fromRGB(100,100,100) v.Text="Whitelist vacia"
        v.Font=Enum.Font.Gotham v.TextSize=10 v.Parent=WLScroll
        WLScroll.CanvasSize=UDim2.new(0,0,0,26) return
    end
    for i,u in ipairs(wl) do
        local item=Instance.new("Frame") item.Size=UDim2.new(1,0,0,26)
        item.BackgroundColor3=Color3.fromRGB(10,18,28) item.BorderSizePixel=0
        item.LayoutOrder=i item.Parent=WLScroll
        Instance.new("UICorner",item).CornerRadius=UDim.new(0,5)
        local l=Instance.new("TextLabel") l.Size=UDim2.new(1,-74,1,0) l.Position=UDim2.new(0,8,0,0)
        l.BackgroundTransparency=1 l.TextColor3=Color3.fromRGB(130,190,255)
        l.Text=(u.nombre or "??").." | "..tostring(u.userId)
        l.Font=Enum.Font.Gotham l.TextSize=10 l.TextXAlignment=Enum.TextXAlignment.Left l.Parent=item
        local bR=mkABtn("Quitar",Color3.fromRGB(140,40,40),0,0,60,20,item)
        bR.Position=UDim2.new(1,-66,0.5,-10)
        local sU=u
        bR.MouseButton1Click:Connect(function()
            local wl2=globalConfig.whitelist.usuarios or {}
            for j,x in ipairs(wl2) do
                if tostring(x.userId)==tostring(sU.userId) then table.remove(wl2,j) break end
            end
            globalConfig.whitelist.usuarios=wl2
            task.spawn(function() guardarEnGitHub("whitelist quitar") end)
            actualizarWLUI()
        end)
    end
    WLScroll.CanvasSize=UDim2.new(0,0,0,#wl*29)
end
BtnToggleWL.MouseButton1Click:Connect(function()
    if not globalConfig.whitelist then globalConfig.whitelist={activo=false,usuarios={}} end
    globalConfig.whitelist.activo=not globalConfig.whitelist.activo
    local a=globalConfig.whitelist.activo
    WLEstLbl.Text="Whitelist: "..(a and "ACTIVA" or "INACTIVA")
    WLEstLbl.TextColor3=a and Color3.fromRGB(100,200,255) or Color3.fromRGB(120,120,120)
    BtnToggleWL.Text=a and "Desactivar" or "Activar"
    BtnToggleWL.BackgroundColor3=a and Color3.fromRGB(160,40,40) or Color3.fromRGB(0,130,160)
    task.spawn(function() guardarEnGitHub("whitelist "..(a and "activada" or "desactivada")) end)
end)
BtnAddWL.MouseButton1Click:Connect(function()
    local input=WLTB.Text:gsub("%s","")
    if input=="" then return end
    local uid=tonumber(input) local nombre=input
    if not uid then pcall(function() uid=Players:GetUserIdFromNameAsync(input) end) end
    if not uid then setFeedback("Usuario no encontrado",Color3.fromRGB(255,100,100)) return end
    pcall(function() nombre=Players:GetNameFromUserIdAsync(uid) end)
    if not globalConfig.whitelist then globalConfig.whitelist={activo=false,usuarios={}} end
    if not globalConfig.whitelist.usuarios then globalConfig.whitelist.usuarios={} end
    for _,x in ipairs(globalConfig.whitelist.usuarios) do
        if tostring(x.userId)==tostring(uid) then setFeedback("Ya esta en whitelist",Color3.fromRGB(255,180,50)) return end
    end
    table.insert(globalConfig.whitelist.usuarios,{userId=uid,nombre=nombre})
    WLTB.Text=""
    task.spawn(function() guardarEnGitHub("whitelist agregar: "..nombre) end)
    actualizarWLUI()
end)

-- ADMINS SECUNDARIOS
local sec6=mkSec("Admins secundarios",140,9)
local AdminIF=Instance.new("Frame") AdminIF.Size=UDim2.new(1,-110,0,24)
AdminIF.Position=UDim2.new(0,8,0,28) AdminIF.BackgroundColor3=Color3.fromRGB(10,10,18)
AdminIF.BorderSizePixel=0 AdminIF.Parent=sec6
Instance.new("UICorner",AdminIF).CornerRadius=UDim.new(0,5)
local AIIS=Instance.new("UIStroke") AIIS.Color=Color3.fromRGB(120,80,40) AIIS.Thickness=1 AIIS.Parent=AdminIF
local AdminITB=Instance.new("TextBox") AdminITB.Size=UDim2.new(1,-8,1,0) AdminITB.Position=UDim2.new(0,5,0,0)
AdminITB.BackgroundTransparency=1 AdminITB.TextColor3=Color3.fromRGB(255,200,150)
AdminITB.PlaceholderText="UserID o Username..." AdminITB.PlaceholderColor3=Color3.fromRGB(100,80,60)
AdminITB.Text="" AdminITB.Font=Enum.Font.Gotham AdminITB.TextSize=10
AdminITB.TextXAlignment=Enum.TextXAlignment.Left AdminITB.ClearTextOnFocus=false AdminITB.Parent=AdminIF
local BtnAddAdmin2=mkABtn("Dar Admin",Color3.fromRGB(160,100,0),0,0,90,22,sec6)
BtnAddAdmin2.Position=UDim2.new(1,-98,0,28)
local AdminSecScroll=Instance.new("ScrollingFrame") AdminSecScroll.Size=UDim2.new(1,-16,0,76)
AdminSecScroll.Position=UDim2.new(0,8,0,56) AdminSecScroll.BackgroundTransparency=1
AdminSecScroll.BorderSizePixel=0 AdminSecScroll.ScrollBarThickness=3
AdminSecScroll.ScrollBarImageColor3=Color3.fromRGB(180,120,0) AdminSecScroll.CanvasSize=UDim2.new(0,0,0,0)
AdminSecScroll.Parent=sec6
local ASLL=Instance.new("UIListLayout") ASLL.SortOrder=Enum.SortOrder.LayoutOrder
ASLL.Padding=UDim.new(0,3) ASLL.Parent=AdminSecScroll
local function actualizarAdminSecUI()
    for _,v in pairs(AdminSecScroll:GetChildren()) do if v:IsA("Frame") or v:IsA("TextLabel") then v:Destroy() end end
    local admins=globalConfig.admins or {}
    if #admins==0 then
        local v=Instance.new("TextLabel") v.Size=UDim2.new(1,0,0,22) v.BackgroundTransparency=1
        v.TextColor3=Color3.fromRGB(100,100,100) v.Text="Sin admins secundarios"
        v.Font=Enum.Font.Gotham v.TextSize=10 v.Parent=AdminSecScroll
        AdminSecScroll.CanvasSize=UDim2.new(0,0,0,26) return
    end
    for i,a in ipairs(admins) do
        local item=Instance.new("Frame") item.Size=UDim2.new(1,0,0,26)
        item.BackgroundColor3=Color3.fromRGB(20,16,8) item.BorderSizePixel=0
        item.LayoutOrder=i item.Parent=AdminSecScroll
        Instance.new("UICorner",item).CornerRadius=UDim.new(0,5)
        local l=Instance.new("TextLabel") l.Size=UDim2.new(1,-74,1,0) l.Position=UDim2.new(0,8,0,0)
        l.BackgroundTransparency=1 l.TextColor3=Color3.fromRGB(255,200,100)
        l.Text=(a.nombre or "??").." | "..tostring(a.userId)
        l.Font=Enum.Font.GothamBold l.TextSize=10 l.TextXAlignment=Enum.TextXAlignment.Left l.Parent=item
        local bR=mkABtn("Quitar",Color3.fromRGB(140,80,0),0,0,60,20,item)
        bR.Position=UDim2.new(1,-66,0.5,-10)
        local sA=a
        bR.MouseButton1Click:Connect(function()
            local ad2=globalConfig.admins or {}
            for j,x in ipairs(ad2) do
                if tostring(x.userId)==tostring(sA.userId) then table.remove(ad2,j) break end
            end
            globalConfig.admins=ad2
            task.spawn(function() guardarEnGitHub("quitar admin: "..(sA.nombre or "??")) end)
            actualizarAdminSecUI()
        end)
    end
    AdminSecScroll.CanvasSize=UDim2.new(0,0,0,#admins*29)
end
BtnAddAdmin2.MouseButton1Click:Connect(function()
    local input=AdminITB.Text:gsub("%s","")
    if input=="" then return end
    local uid=tonumber(input) local nombre=input
    if not uid then pcall(function() uid=Players:GetUserIdFromNameAsync(input) end) end
    if not uid then setFeedback("No encontrado",Color3.fromRGB(255,100,100)) return end
    if uid==ADMIN_ID then setFeedback("Ya es admin principal",Color3.fromRGB(255,180,50)) return end
    pcall(function() nombre=Players:GetNameFromUserIdAsync(uid) end)
    if not globalConfig.admins then globalConfig.admins={} end
    for _,x in ipairs(globalConfig.admins) do
        if tostring(x.userId)==tostring(uid) then setFeedback("Ya tiene admin",Color3.fromRGB(255,180,50)) return end
    end
    table.insert(globalConfig.admins,{userId=uid,nombre=nombre})
    AdminITB.Text=""
    task.spawn(function() guardarEnGitHub("dar admin: "..nombre) end)
    actualizarAdminSecUI()
end)
local padBot=Instance.new("Frame") padBot.Size=UDim2.new(1,-24,0,10)
padBot.BackgroundTransparency=1 padBot.LayoutOrder=10 padBot.Parent=AdminScroll

-- ================================
-- HISTORIAL
-- ================================
local HistorialFrame=Instance.new("Frame") HistorialFrame.Size=UDim2.new(1,0,1,-TOPBAR_H)
HistorialFrame.Position=UDim2.new(0,0,0,TOPBAR_H) HistorialFrame.BackgroundTransparency=1
HistorialFrame.Visible=false HistorialFrame.Parent=Frame
local HTit=Instance.new("TextLabel") HTit.Size=UDim2.new(1,-24,0,28) HTit.Position=UDim2.new(0,12,0,8)
HTit.BackgroundTransparency=1 HTit.TextColor3=Color3.fromRGB(180,180,255) HTit.Text="Ultimos 10 servidores"
HTit.Font=Enum.Font.GothamBold HTit.TextSize=14 HTit.TextXAlignment=Enum.TextXAlignment.Left HTit.Parent=HistorialFrame
local HScroll=Instance.new("ScrollingFrame") HScroll.Size=UDim2.new(1,-20,1,-92)
HScroll.Position=UDim2.new(0,10,0,42) HScroll.BackgroundTransparency=1 HScroll.BorderSizePixel=0
HScroll.ScrollBarThickness=4 HScroll.ScrollBarImageColor3=Color3.fromRGB(0,130,220)
HScroll.CanvasSize=UDim2.new(0,0,0,0) HScroll.Parent=HistorialFrame
local HLL=Instance.new("UIListLayout") HLL.SortOrder=Enum.SortOrder.LayoutOrder HLL.Padding=UDim.new(0,4) HLL.Parent=HScroll
local BtnBorrarH=Instance.new("TextButton") BtnBorrarH.Size=UDim2.new(1,-24,0,34)
BtnBorrarH.Position=UDim2.new(0,12,1,-44) BtnBorrarH.BackgroundColor3=Color3.fromRGB(160,40,40)
BtnBorrarH.TextColor3=Color3.fromRGB(255,255,255) BtnBorrarH.Text="Borrar historial"
BtnBorrarH.Font=Enum.Font.GothamBold BtnBorrarH.TextSize=13 BtnBorrarH.BorderSizePixel=0
BtnBorrarH.Visible=false BtnBorrarH.Parent=HistorialFrame
Instance.new("UICorner",BtnBorrarH).CornerRadius=UDim.new(0,8)
local function actualizarHistorialUI()
    for _,v in pairs(HScroll:GetChildren()) do if v:IsA("Frame") or v:IsA("TextLabel") then v:Destroy() end end
    local h=leerJSON(FILES.historial,{})
    if #h==0 then
        local v=Instance.new("TextLabel") v.Size=UDim2.new(1,0,0,40) v.BackgroundTransparency=1
        v.TextColor3=Color3.fromRGB(120,120,120) v.Text="Sin historial aun"
        v.Font=Enum.Font.Gotham v.TextSize=13 v.Parent=HScroll HScroll.CanvasSize=UDim2.new(0,0,0,44) return
    end
    for i,e in ipairs(h) do
        local item=Instance.new("Frame") item.Size=UDim2.new(1,0,0,74)
        item.BackgroundColor3=Color3.fromRGB(24,24,36) item.BorderSizePixel=0 item.LayoutOrder=i item.Parent=HScroll
        Instance.new("UICorner",item).CornerRadius=UDim.new(0,8)
        local iS=Instance.new("UIStroke") iS.Color=Color3.fromRGB(50,80,150) iS.Thickness=1 iS.Parent=item
        local rows={
            {(e.fecha or "??").."  Jug: "..(e.jugadores or "?"),Color3.fromRGB(100,180,255),true,4},
            {"Ping: "..(e.ping==0 and "sin dato" or e.ping.."ms"),e.ping<80 and Color3.fromRGB(80,220,80) or e.ping<150 and Color3.fromRGB(220,200,50) or Color3.fromRGB(220,80,80),false,24},
            {"Tiempo: "..(e.segundos>0 and e.segundos.."s" or "sin dato"),Color3.fromRGB(255,200,50),false,42},
        }
        for _,r in ipairs(rows) do
            local l=Instance.new("TextLabel") l.Size=UDim2.new(1,-90,0,18) l.Position=UDim2.new(0,10,0,r[4])
            l.BackgroundTransparency=1 l.TextColor3=r[2] l.Text=r[1]
            l.Font=r[3] and Enum.Font.GothamBold or Enum.Font.Gotham l.TextSize=r[3] and 12 or 11
            l.TextXAlignment=Enum.TextXAlignment.Left l.Parent=item
        end
        local badge=Instance.new("TextLabel") badge.Size=UDim2.new(0,64,0,16) badge.Position=UDim2.new(0,10,0,56)
        badge.BackgroundColor3=e.tipo=="Solo" and Color3.fromRGB(180,120,0) or e.tipo=="Vacio" and Color3.fromRGB(100,0,160) or Color3.fromRGB(0,100,180)
        badge.TextColor3=Color3.fromRGB(255,255,255) badge.Text=e.tipo or "Normal"
        badge.Font=Enum.Font.GothamBold badge.TextSize=10 badge.BorderSizePixel=0 badge.Parent=item
        Instance.new("UICorner",badge).CornerRadius=UDim.new(0,4)
        local bRJ=Instance.new("TextButton") bRJ.Size=UDim2.new(0,72,0,34) bRJ.Position=UDim2.new(1,-82,0.5,-17)
        bRJ.BackgroundColor3=Color3.fromRGB(0,110,200) bRJ.TextColor3=Color3.fromRGB(255,255,255) bRJ.Text="Rejoin"
        bRJ.Font=Enum.Font.GothamBold bRJ.TextSize=12 bRJ.BorderSizePixel=0 bRJ.Parent=item
        Instance.new("UICorner",bRJ).CornerRadius=UDim.new(0,6)
        local sE=e
        bRJ.MouseButton1Click:Connect(function()
            bRJ.Text="..." pcall(function() TeleportService:TeleportToPlaceInstance(sE.placeId,sE.id,player) end)
            task.wait(3) bRJ.Text="Rejoin"
        end)
    end
    HScroll.CanvasSize=UDim2.new(0,0,0,#h*78)
end
BtnBorrarH.MouseButton1Click:Connect(function() escribirJSON(FILES.historial,{}) actualizarHistorialUI() end)

-- BLACKLIST
local BlacklistFrame=Instance.new("Frame") BlacklistFrame.Size=UDim2.new(1,0,1,-TOPBAR_H)
BlacklistFrame.Position=UDim2.new(0,0,0,TOPBAR_H) BlacklistFrame.BackgroundTransparency=1
BlacklistFrame.Visible=false BlacklistFrame.Parent=Frame
local BLTit=Instance.new("TextLabel") BLTit.Size=UDim2.new(1,-24,0,28) BLTit.Position=UDim2.new(0,12,0,8)
BLTit.BackgroundTransparency=1 BLTit.TextColor3=Color3.fromRGB(255,120,120) BLTit.Text="Servers ignorados"
BLTit.Font=Enum.Font.GothamBold BLTit.TextSize=14 BLTit.TextXAlignment=Enum.TextXAlignment.Left BLTit.Parent=BlacklistFrame
local BLScroll=Instance.new("ScrollingFrame") BLScroll.Size=UDim2.new(1,-20,1,-92)
BLScroll.Position=UDim2.new(0,10,0,42) BLScroll.BackgroundTransparency=1 BLScroll.BorderSizePixel=0
BLScroll.ScrollBarThickness=4 BLScroll.ScrollBarImageColor3=Color3.fromRGB(220,50,50)
BLScroll.CanvasSize=UDim2.new(0,0,0,0) BLScroll.Parent=BlacklistFrame
local BLLL=Instance.new("UIListLayout") BLLL.SortOrder=Enum.SortOrder.LayoutOrder BLLL.Padding=UDim.new(0,4) BLLL.Parent=BLScroll
local BtnBorrarBL=Instance.new("TextButton") BtnBorrarBL.Size=UDim2.new(1,-24,0,34)
BtnBorrarBL.Position=UDim2.new(0,12,1,-44) BtnBorrarBL.BackgroundColor3=Color3.fromRGB(160,40,40)
BtnBorrarBL.TextColor3=Color3.fromRGB(255,255,255) BtnBorrarBL.Text="Limpiar blacklist"
BtnBorrarBL.Font=Enum.Font.GothamBold BtnBorrarBL.TextSize=13 BtnBorrarBL.BorderSizePixel=0
BtnBorrarBL.Visible=false BtnBorrarBL.Parent=BlacklistFrame
Instance.new("UICorner",BtnBorrarBL).CornerRadius=UDim.new(0,8)
local function actualizarBLUI()
    for _,v in pairs(BLScroll:GetChildren()) do if v:IsA("Frame") or v:IsA("TextLabel") then v:Destroy() end end
    blacklist=leerJSON(FILES.blacklist,{})
    if #blacklist==0 then
        local v=Instance.new("TextLabel") v.Size=UDim2.new(1,0,0,40) v.BackgroundTransparency=1
        v.TextColor3=Color3.fromRGB(120,120,120) v.Text="Blacklist vacia"
        v.Font=Enum.Font.Gotham v.TextSize=13 v.Parent=BLScroll BLScroll.CanvasSize=UDim2.new(0,0,0,44) return
    end
    for i,sID in ipairs(blacklist) do
        local item=Instance.new("Frame") item.Size=UDim2.new(1,0,0,42)
        item.BackgroundColor3=Color3.fromRGB(30,16,16) item.BorderSizePixel=0 item.LayoutOrder=i item.Parent=BLScroll
        Instance.new("UICorner",item).CornerRadius=UDim.new(0,8)
        local iS=Instance.new("UIStroke") iS.Color=Color3.fromRGB(120,40,40) iS.Thickness=1 iS.Parent=item
        local l=Instance.new("TextLabel") l.Size=UDim2.new(1,-84,1,0) l.Position=UDim2.new(0,10,0,0)
        l.BackgroundTransparency=1 l.TextColor3=Color3.fromRGB(200,120,120) l.Text=tostring(sID):sub(1,28).."..."
        l.Font=Enum.Font.Gotham l.TextSize=10 l.TextXAlignment=Enum.TextXAlignment.Left l.Parent=item
        local bQ=Instance.new("TextButton") bQ.Size=UDim2.new(0,66,0,28) bQ.Position=UDim2.new(1,-74,0.5,-14)
        bQ.BackgroundColor3=Color3.fromRGB(160,40,40) bQ.TextColor3=Color3.fromRGB(255,255,255) bQ.Text="Quitar"
        bQ.Font=Enum.Font.GothamBold bQ.TextSize=12 bQ.BorderSizePixel=0 bQ.Parent=item
        Instance.new("UICorner",bQ).CornerRadius=UDim.new(0,6)
        local savedID=sID
        bQ.MouseButton1Click:Connect(function()
            for j,id in ipairs(blacklist) do if id==savedID then table.remove(blacklist,j) break end end
            escribirJSON(FILES.blacklist,blacklist)
            stats.blacklistCount=#blacklist escribirJSON(FILES.stats,stats) actualizarUI() actualizarBLUI()
        end)
    end
    BLScroll.CanvasSize=UDim2.new(0,0,0,#blacklist*46)
end
BtnBorrarBL.MouseButton1Click:Connect(function()
    blacklist={} escribirJSON(FILES.blacklist,blacklist)
    stats.blacklistCount=0 escribirJSON(FILES.stats,stats) actualizarUI() actualizarBLUI()
end)

-- ESCANER
local EscanerFrame=Instance.new("Frame") EscanerFrame.Size=UDim2.new(1,0,1,-TOPBAR_H)
EscanerFrame.Position=UDim2.new(0,0,0,TOPBAR_H) EscanerFrame.BackgroundTransparency=1
EscanerFrame.Visible=false EscanerFrame.Parent=Frame
local ETit=Instance.new("TextLabel") ETit.Size=UDim2.new(1,-24,0,22) ETit.Position=UDim2.new(0,12,0,6)
ETit.BackgroundTransparency=1 ETit.TextColor3=Color3.fromRGB(80,220,160) ETit.Text="Escaner de Servers"
ETit.Font=Enum.Font.GothamBold ETit.TextSize=14 ETit.TextXAlignment=Enum.TextXAlignment.Left ETit.Parent=EscanerFrame
local EMinLbl=Instance.new("TextLabel") EMinLbl.Size=UDim2.new(0,130,0,22) EMinLbl.Position=UDim2.new(0,12,0,34)
EMinLbl.BackgroundTransparency=1 EMinLbl.TextColor3=Color3.fromRGB(180,180,180) EMinLbl.Text="Min: 0"
EMinLbl.Font=Enum.Font.Gotham EMinLbl.TextSize=12 EMinLbl.TextXAlignment=Enum.TextXAlignment.Left EMinLbl.Parent=EscanerFrame
local EMaxLbl=Instance.new("TextLabel") EMaxLbl.Size=UDim2.new(0,130,0,22) EMaxLbl.Position=UDim2.new(0,180,0,34)
EMaxLbl.BackgroundTransparency=1 EMaxLbl.TextColor3=Color3.fromRGB(180,180,180) EMaxLbl.Text="Max: "..Players.MaxPlayers
EMaxLbl.Font=Enum.Font.Gotham EMaxLbl.TextSize=12 EMaxLbl.TextXAlignment=Enum.TextXAlignment.Left EMaxLbl.Parent=EscanerFrame
local escanerMin=0 local escanerMax=Players.MaxPlayers
local function mkBE(txt,color,x,y)
    local b=Instance.new("TextButton") b.Size=UDim2.new(0,26,0,22) b.Position=UDim2.new(0,x,0,y)
    b.BackgroundColor3=color b.TextColor3=Color3.fromRGB(255,255,255) b.Text=txt
    b.Font=Enum.Font.GothamBold b.TextSize=13 b.BorderSizePixel=0 b.Parent=EscanerFrame
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,5) return b
end
local BEMM=mkBE("-",Color3.fromRGB(160,40,40),142,35)
local BEMP=mkBE("+",Color3.fromRGB(40,140,40),170,35)
local BEXrM=mkBE("-",Color3.fromRGB(160,40,40),310,35)
local BEXrP=mkBE("+",Color3.fromRGB(40,140,40),338,35)
BEMM.MouseButton1Click:Connect(function() if escanerMin>0 then escanerMin-=1 end EMinLbl.Text="Min: "..escanerMin end)
BEMP.MouseButton1Click:Connect(function() if escanerMin<escanerMax then escanerMin+=1 end EMinLbl.Text="Min: "..escanerMin end)
BEXrM.MouseButton1Click:Connect(function() if escanerMax>escanerMin then escanerMax-=1 end EMaxLbl.Text="Max: "..escanerMax end)
BEXrP.MouseButton1Click:Connect(function() if escanerMax<Players.MaxPlayers then escanerMax+=1 end EMaxLbl.Text="Max: "..escanerMax end)
local BtnEscanear=Instance.new("TextButton") BtnEscanear.Size=UDim2.new(1,-24,0,34)
BtnEscanear.Position=UDim2.new(0,12,0,62) BtnEscanear.BackgroundColor3=Color3.fromRGB(0,150,100)
BtnEscanear.TextColor3=Color3.fromRGB(255,255,255) BtnEscanear.Text="Escanear Servers"
BtnEscanear.Font=Enum.Font.GothamBold BtnEscanear.TextSize=13 BtnEscanear.BorderSizePixel=0 BtnEscanear.Parent=EscanerFrame
Instance.new("UICorner",BtnEscanear).CornerRadius=UDim.new(0,8)
local EStatus=Instance.new("TextLabel") EStatus.Size=UDim2.new(1,-24,0,18) EStatus.Position=UDim2.new(0,12,0,100)
EStatus.BackgroundTransparency=1 EStatus.TextColor3=Color3.fromRGB(150,150,150) EStatus.Text="Pulsa escanear"
EStatus.Font=Enum.Font.Gotham EStatus.TextSize=10 EStatus.TextXAlignment=Enum.TextXAlignment.Left EStatus.Parent=EscanerFrame
local ListaScroll=Instance.new("ScrollingFrame") ListaScroll.Size=UDim2.new(1,-20,1,-124)
ListaScroll.Position=UDim2.new(0,10,0,120) ListaScroll.BackgroundTransparency=1 ListaScroll.BorderSizePixel=0
ListaScroll.ScrollBarThickness=4 ListaScroll.ScrollBarImageColor3=Color3.fromRGB(0,150,100)
ListaScroll.CanvasSize=UDim2.new(0,0,0,0) ListaScroll.Parent=EscanerFrame
local ListaLL=Instance.new("UIListLayout") ListaLL.SortOrder=Enum.SortOrder.LayoutOrder ListaLL.Padding=UDim.new(0,4) ListaLL.Parent=ListaScroll

-- ================================
-- NAVEGACION
-- ================================
local function ocultarTodo()
    Content.Visible=false HistorialFrame.Visible=false BlacklistFrame.Visible=false
    EscanerFrame.Visible=false AdminFrame.Visible=false
    BtnBorrarH.Visible=false BtnBorrarBL.Visible=false
end
local function mostrarContent()
    ocultarTodo() Content.Visible=true
    viendoHistorial=false viendoBlacklist=false viendoEscaner=false viendoAdmin=false
    BtnHist.BackgroundColor3=Color3.fromRGB(80,80,180) BtnBL.BackgroundColor3=Color3.fromRGB(160,40,40)
    BtnScan.BackgroundColor3=Color3.fromRGB(0,150,100)
    if BtnAdmin then BtnAdmin.BackgroundColor3=Color3.fromRGB(160,110,0) end
end
BtnScan.MouseButton1Click:Connect(function()
    viendoEscaner=not viendoEscaner
    if viendoEscaner then
        ocultarTodo() EscanerFrame.Visible=true viendoHistorial=false viendoBlacklist=false viendoAdmin=false
        BtnScan.BackgroundColor3=Color3.fromRGB(0,220,130)
    else mostrarContent() end
end)
BtnHist.MouseButton1Click:Connect(function()
    viendoHistorial=not viendoHistorial
    if viendoHistorial then
        ocultarTodo() HistorialFrame.Visible=true BtnBorrarH.Visible=true
        viendoBlacklist=false viendoEscaner=false viendoAdmin=false
        BtnHist.BackgroundColor3=Color3.fromRGB(0,130,220) actualizarHistorialUI()
    else mostrarContent() end
end)
BtnBL.MouseButton1Click:Connect(function()
    viendoBlacklist=not viendoBlacklist
    if viendoBlacklist then
        ocultarTodo() BlacklistFrame.Visible=true BtnBorrarBL.Visible=true
        viendoHistorial=false viendoEscaner=false viendoAdmin=false
        BtnBL.BackgroundColor3=Color3.fromRGB(220,80,80) actualizarBLUI()
    else mostrarContent() end
end)
if BtnAdmin then
    BtnAdmin.MouseButton1Click:Connect(function()
        viendoAdmin=not viendoAdmin
        if viendoAdmin then
            ocultarTodo() AdminFrame.Visible=true
            viendoHistorial=false viendoBlacklist=false viendoEscaner=false
            BtnAdmin.BackgroundColor3=Color3.fromRGB(255,180,0)
            actualizarBanListUI() actualizarWLUI() actualizarAdminSecUI()
        else mostrarContent() end
    end)
end
BtnMin.MouseButton1Click:Connect(function()
    minimized=not minimized
    if minimized then
        ocultarTodo()
        TweenService:Create(Frame,TweenInfo.new(0.25,Enum.EasingStyle.Quad),{Size=UDim2.new(0,FRAME_W,0,TOPBAR_H)}):Play()
        BtnMin.Text="Max"
    else
        TweenService:Create(Frame,TweenInfo.new(0.25,Enum.EasingStyle.Quad),{Size=UDim2.new(0,FRAME_W,0,ALTURA_NORMAL)}):Play()
        task.wait(0.25)
        if viendoHistorial then HistorialFrame.Visible=true BtnBorrarH.Visible=true
        elseif viendoBlacklist then BlacklistFrame.Visible=true BtnBorrarBL.Visible=true
        elseif viendoEscaner then EscanerFrame.Visible=true
        elseif viendoAdmin then AdminFrame.Visible=true
        else Content.Visible=true end
        BtnMin.Text="Min"
    end
end)
BtnClose.MouseButton1Click:Connect(function()
    hopping=false soloHopping=false escaneando=false SG:Destroy() PerfGui:Destroy()
end)

-- TOGGLES
local function setToggle(estado,bg,circle,lbl,on,off)
    if estado then
        TweenService:Create(bg,TweenInfo.new(0.2),{BackgroundColor3=Color3.fromRGB(50,160,50)}):Play()
        TweenService:Create(circle,TweenInfo.new(0.2),{Position=UDim2.new(0,28,0.5,-11)}):Play()
        lbl.TextColor3=Color3.fromRGB(100,220,100) lbl.Text=on
    else
        TweenService:Create(bg,TweenInfo.new(0.2),{BackgroundColor3=Color3.fromRGB(60,60,60)}):Play()
        TweenService:Create(circle,TweenInfo.new(0.2),{Position=UDim2.new(0,3,0.5,-11)}):Play()
        lbl.TextColor3=Color3.fromRGB(200,200,200) lbl.Text=off
    end
end
setToggle(autoAmpliar,TAmpBg,TAmpC,TAmpLbl,"Auto-ampliar: ON","Auto-ampliar: OFF")
setToggle(modoRapido,TRapBg,TRapC,TRapLbl,"Modo rapido: ON","Modo rapido: OFF")
TAmpBtn.MouseButton1Click:Connect(function()
    autoAmpliar=not autoAmpliar setToggle(autoAmpliar,TAmpBg,TAmpC,TAmpLbl,"Auto-ampliar: ON","Auto-ampliar: OFF") guardarConfig()
end)
TRapBtn.MouseButton1Click:Connect(function()
    modoRapido=not modoRapido setToggle(modoRapido,TRapBg,TRapC,TRapLbl,"Modo rapido: ON","Modo rapido: OFF") guardarConfig()
end)
BMinM.MouseButton1Click:Connect(function() if minVal>1 then minVal-=1 end MinLbl.Text="Min jugadores: "..minVal guardarConfig() end)
BMinP.MouseButton1Click:Connect(function() if minVal<maxVal then minVal+=1 end MinLbl.Text="Min jugadores: "..minVal guardarConfig() end)
BMaxM.MouseButton1Click:Connect(function() if maxVal>minVal then maxVal-=1 end MaxLbl.Text="Max jugadores: "..maxVal guardarConfig() end)
BMaxP.MouseButton1Click:Connect(function() if maxVal<Players.MaxPlayers then maxVal+=1 end MaxLbl.Text="Max jugadores: "..maxVal guardarConfig() end)
BPMinM.MouseButton1Click:Connect(function() if minPing>0 then minPing-=10 end PMinLbl.Text="Ping min: "..minPing guardarConfig() end)
BPMinP.MouseButton1Click:Connect(function() if minPing<maxPing-10 then minPing+=10 end PMinLbl.Text="Ping min: "..minPing guardarConfig() end)
BPMaxM.MouseButton1Click:Connect(function() if maxPing>minPing+10 then maxPing-=10 end PMaxLbl.Text="Ping max: "..maxPing guardarConfig() end)
BPMaxP.MouseButton1Click:Connect(function() if maxPing<999 then maxPing+=10 end PMaxLbl.Text="Ping max: "..maxPing guardarConfig() end)

-- ================================
-- LOGICA HOPPER
-- ================================
local function getServers(cursor)
    local url="https://games.roblox.com/v1/games/"..PLACE_ID.."/servers/Public?sortOrder=Asc&limit=100"
    if cursor~="" then url=url.."&cursor="..cursor end
    local ok,res=pcall(function() return game:HttpGet(url) end)
    if not ok then return nil end
    local ok2,data=pcall(function() return HttpService:JSONDecode(res) end)
    if not ok2 then return nil end
    return data
end

local function buscarServer()
    hopping=true tiempoBusquedaInicio=os.clock()
    BtnHop.Text="Detener busqueda" BtnHop.BackgroundColor3=Color3.fromRGB(180,50,50)
    resetBarra()
    local cursor="" local pagina=0 local totalE=0 local totalR=0 local totalS=0
    while hopping do
        pagina+=1 StatusLbl.Text="Pagina "..pagina.."..." StatusLbl.TextColor3=Color3.fromRGB(180,180,180) Status2.Text=""
        local data=getServers(cursor)
        if not data or not data.data then StatusLbl.Text="Error, reintentando..." task.wait(2) cursor="" pagina=0 resetBarra() continue end
        totalS+=#data.data
        for _,server in pairs(data.data) do
            if not hopping then break end
            local jug=server.playing or 0 local ping=server.ping or 0
            totalR+=1 stats.totalRevisados+=1 escribirJSON(FILES.stats,stats) actualizarUI()
            actualizarBarra(totalR,totalS,jug>=minVal and jug<=maxVal and pasaPing(ping) and Color3.fromRGB(50,200,80) or Color3.fromRGB(0,130,220))
            if jug>=minVal and jug<=maxVal and pasaPing(ping) then
                if estaEnBL(server.id) then continue end
                totalE+=1 stats.totalEncontrados+=1 escribirJSON(FILES.stats,stats) actualizarUI()
                local seg=math.floor(os.clock()-tiempoBusquedaInicio)
                StatusLbl.Text="Servidor encontrado!" StatusLbl.TextColor3=Color3.fromRGB(100,220,100)
                Status2.Text="Jug: "..jug.."  Ping: "..pingTxt(ping).."  Tiempo: "..seg.."s"
                actualizarBarra(totalS,totalS,Color3.fromRGB(50,200,80))
                notif("Server Hopper","Encontrado! "..jug.." jug en "..seg.."s")
                if not modoRapido then task.wait(2) end
                local ok=pcall(function() TeleportService:TeleportToPlaceInstance(PLACE_ID,server.id,player) end)
                if not ok then
                    agregarBL(server.id)
                    task.spawn(function() mostrarPopup("!",Color3.fromRGB(140,60,0),Color3.fromRGB(255,150,0),Color3.fromRGB(255,220,100),"No disponible\nBlacklist") end)
                    StatusLbl.Text="No disponible -> Blacklist" task.wait(1)
                else
                    local hist=leerJSON(FILES.historial,{})
                    table.insert(hist,1,{id=server.id,jugadores=jug,placeId=PLACE_ID,tipo="Normal",fecha=os.date("%d/%m %H:%M"),ping=ping,segundos=seg})
                    if #hist>10 then table.remove(hist,#hist) end
                    escribirJSON(FILES.historial,hist) registrarTiempo(seg) task.wait(6)
                end
            end
        end
        if data.nextPageCursor and data.nextPageCursor~="" then
            cursor=data.nextPageCursor task.wait(0.3)
        else
            if totalR>0 and totalE==0 then
                if autoAmpliar then
                    local rA=maxVal maxVal=math.min(maxVal+3,Players.MaxPlayers)
                    MaxLbl.Text="Max jugadores: "..maxVal guardarConfig()
                    task.spawn(function() mostrarPopup("^",Color3.fromRGB(60,0,120),Color3.fromRGB(180,80,255),Color3.fromRGB(200,150,255),"Ampliado a "..minVal.."-"..maxVal) end)
                else
                    task.spawn(function() mostrarPopup("?",Color3.fromRGB(60,0,120),Color3.fromRGB(180,80,255),Color3.fromRGB(200,150,255),"Sin servers en ese rango") end)
                end
            end
            cursor="" pagina=0 totalE=0 totalR=0 totalS=0 resetBarra() Status2.Text="Reiniciando..." task.wait(1)
        end
    end
    BtnHop.Text="Buscar Servidor" BtnHop.BackgroundColor3=Color3.fromRGB(0,130,220)
    StatusLbl.Text="Busqueda detenida" Status2.Text="" resetBarra()
end

local function buscarSolo(obj,tipo)
    soloHopping=true tiempoBusquedaInicio=os.clock()
    local cursor=""
    while soloHopping do
        StatusSolo.Text="Buscando "..obj.." jug..." StatusSolo.TextColor3=Color3.fromRGB(255,200,50)
        local data=getServers(cursor)
        if not data or not data.data then task.wait(2) cursor="" continue end
        for _,server in pairs(data.data) do
            if not soloHopping then break end
            local jug=server.playing or 0 local ping=server.ping or 0
            stats.totalRevisados+=1 escribirJSON(FILES.stats,stats) actualizarUI()
            if jug==obj and not estaEnBL(server.id) and pasaPing(ping) then
                local seg=math.floor(os.clock()-tiempoBusquedaInicio)
                StatusSolo.Text="Encontrado en "..seg.."s!"
                notif("Modo Solo","Server con "..jug.." jug en "..seg.."s!")
                local ok=pcall(function() TeleportService:TeleportToPlaceInstance(PLACE_ID,server.id,player) end)
                if ok then
                    local hist=leerJSON(FILES.historial,{})
                    table.insert(hist,1,{id=server.id,jugadores=jug,placeId=PLACE_ID,tipo=tipo,fecha=os.date("%d/%m %H:%M"),ping=ping,segundos=seg})
                    if #hist>10 then table.remove(hist,#hist) end
                    escribirJSON(FILES.historial,hist) registrarTiempo(seg)
                    stats.totalEncontrados+=1 escribirJSON(FILES.stats,stats) actualizarUI()
                    soloHopping=false return
                else agregarBL(server.id) StatusSolo.Text="No disponible -> Blacklist" task.wait(0.5) end
            end
        end
        if data.nextPageCursor and data.nextPageCursor~="" then cursor=data.nextPageCursor task.wait(0.3)
        else cursor="" StatusSolo.Text="Reiniciando..." end
    end
end

BtnEscanear.MouseButton1Click:Connect(function()
    if escaneando then
        escaneando=false BtnEscanear.Text="Escanear Servers" BtnEscanear.BackgroundColor3=Color3.fromRGB(0,150,100) EStatus.Text="Detenido" return
    end
    for _,v in pairs(ListaScroll:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end
    ListaScroll.CanvasSize=UDim2.new(0,0,0,0) escaneando=true BtnEscanear.Text="Detener" BtnEscanear.BackgroundColor3=Color3.fromRGB(180,50,50)
    task.spawn(function()
        local cursor="" local pagina=0 local encontrados={}
        while escaneando do
            pagina+=1 EStatus.Text="Pagina "..pagina.."..."
            local data=getServers(cursor)
            if not data or not data.data then EStatus.Text="Error" task.wait(2) break end
            for _,server in pairs(data.data) do
                if not escaneando then break end
                local jug=server.playing or 0 local ping=server.ping or 0
                if jug>=escanerMin and jug<=escanerMax and not estaEnBL(server.id) then
                    table.insert(encontrados,{id=server.id,jugadores=jug,ping=ping})
                    local item=Instance.new("Frame") item.Size=UDim2.new(1,0,0,54)
                    item.BackgroundColor3=Color3.fromRGB(18,28,18) item.BorderSizePixel=0
                    item.LayoutOrder=#encontrados item.Parent=ListaScroll
                    Instance.new("UICorner",item).CornerRadius=UDim.new(0,8)
                    local iS=Instance.new("UIStroke")
                    iS.Color=jug==0 and Color3.fromRGB(100,0,160) or jug<=2 and Color3.fromRGB(0,180,80) or Color3.fromRGB(0,100,180)
                    iS.Thickness=1 iS.Parent=item
                    local badge=Instance.new("TextLabel") badge.Size=UDim2.new(0,38,0,38)
                    badge.Position=UDim2.new(0,8,0.5,-19)
                    badge.BackgroundColor3=jug==0 and Color3.fromRGB(100,0,160) or jug<=2 and Color3.fromRGB(0,160,70) or Color3.fromRGB(0,100,180)
                    badge.TextColor3=Color3.fromRGB(255,255,255) badge.Text=tostring(jug)
                    badge.Font=Enum.Font.GothamBold badge.TextSize=15 badge.BorderSizePixel=0 badge.Parent=item
                    Instance.new("UICorner",badge).CornerRadius=UDim.new(0,8)
                    local lJ=Instance.new("TextLabel") lJ.Size=UDim2.new(1,-120,0,22) lJ.Position=UDim2.new(0,54,0,6)
                    lJ.BackgroundTransparency=1 lJ.TextColor3=Color3.fromRGB(200,220,200)
                    lJ.Text=jug==0 and "Vacio" or jug==1 and "1 jugador" or jug.." jugadores"
                    lJ.Font=Enum.Font.GothamBold lJ.TextSize=13 lJ.TextXAlignment=Enum.TextXAlignment.Left lJ.Parent=item
                    local lP=Instance.new("TextLabel") lP.Size=UDim2.new(1,-120,0,18) lP.Position=UDim2.new(0,54,0,28)
                    lP.BackgroundTransparency=1
                    lP.TextColor3=ping<80 and Color3.fromRGB(80,220,80) or ping<150 and Color3.fromRGB(220,200,50) or Color3.fromRGB(220,80,80)
                    lP.Text="Ping: "..pingTxt(ping)
                    lP.Font=Enum.Font.Gotham lP.TextSize=11 lP.TextXAlignment=Enum.TextXAlignment.Left lP.Parent=item
                    local bU=Instance.new("TextButton") bU.Size=UDim2.new(0,66,0,36) bU.Position=UDim2.new(1,-74,0.5,-18)
                    bU.BackgroundColor3=Color3.fromRGB(0,130,60) bU.TextColor3=Color3.fromRGB(255,255,255) bU.Text="Unirse"
                    bU.Font=Enum.Font.GothamBold bU.TextSize=12 bU.BorderSizePixel=0 bU.Parent=item
                    Instance.new("UICorner",bU).CornerRadius=UDim.new(0,6)
                    local sS=server
                    bU.MouseButton1Click:Connect(function()
                        bU.Text="..." bU.BackgroundColor3=Color3.fromRGB(80,80,80)
                        local ok=pcall(function() TeleportService:TeleportToPlaceInstance(PLACE_ID,sS.id,player) end)
                        if not ok then
                            bU.Text="Error" bU.BackgroundColor3=Color3.fromRGB(160,40,40)
                            agregarBL(sS.id)
                            task.spawn(function() mostrarPopup("!",Color3.fromRGB(140,60,0),Color3.fromRGB(255,150,0),Color3.fromRGB(255,220,100),"No disponible") end)
                            task.wait(2) bU.Text="Unirse" bU.BackgroundColor3=Color3.fromRGB(0,130,60)
                        end
                    end)
                    ListaScroll.CanvasSize=UDim2.new(0,0,0,#encontrados*58)
                end
            end
            if data.nextPageCursor and data.nextPageCursor~="" then cursor=data.nextPageCursor task.wait(0.3)
            else
                escaneando=false EStatus.Text="Listo: "..#encontrados.." servers" EStatus.TextColor3=Color3.fromRGB(100,220,100)
                notif("Escaner","Encontre "..#encontrados.." servers") break
            end
        end
        escaneando=false BtnEscanear.Text="Escanear Servers" BtnEscanear.BackgroundColor3=Color3.fromRGB(0,150,100)
    end)
end)

BSolo1.MouseButton1Click:Connect(function()
    if soloHopping then soloHopping=false BSolo1.Text="Server vacio" BSolo1.BackgroundColor3=Color3.fromRGB(180,120,0) StatusSolo.Text="" return end
    BSolo1.Text="Detener" BSolo1.BackgroundColor3=Color3.fromRGB(180,50,50)
    task.spawn(function() buscarSolo(1,"Solo") BSolo1.Text="Server vacio" BSolo1.BackgroundColor3=Color3.fromRGB(180,120,0) end)
end)
BSolo0.MouseButton1Click:Connect(function()
    if soloHopping then soloHopping=false BSolo0.Text="0 jugadores" BSolo0.BackgroundColor3=Color3.fromRGB(100,0,160) StatusSolo.Text="" return end
    BSolo0.Text="Detener" BSolo0.BackgroundColor3=Color3.fromRGB(180,50,50)
    task.spawn(function() buscarSolo(0,"Vacio") BSolo0.Text="0 jugadores" BSolo0.BackgroundColor3=Color3.fromRGB(100,0,160) end)
end)
BtnHop.MouseButton1Click:Connect(function()
    if not hopping then task.spawn(buscarServer) else hopping=false end
end)

print("[Server Hopper V18 | michaelarsx] GitHub: "..GITHUB_RAW)
