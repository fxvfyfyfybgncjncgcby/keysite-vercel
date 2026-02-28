-- ============================================
-- TON SCRIPT - Key System Custom
-- Remplace SITE_URL par ton vrai domaine Vercel
-- ============================================

local SITE_URL = "https://TON-SITE.vercel.app" -- ← CHANGE ICI

-- ============================================

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

-- Couleurs identiques à ton script original
local Colors = {
    background   = Color3.fromRGB(13, 17, 23),
    surface      = Color3.fromRGB(22, 27, 34),
    surfaceLight = Color3.fromRGB(30, 36, 44),
    primary      = Color3.fromRGB(88, 166, 255),
    primaryDark  = Color3.fromRGB(58, 136, 225),
    primaryGlow  = Color3.fromRGB(120, 180, 255),
    accent       = Color3.fromRGB(136, 87, 224),
    success      = Color3.fromRGB(47, 183, 117),
    successDark  = Color3.fromRGB(37, 153, 97),
    successGlow  = Color3.fromRGB(67, 203, 137),
    error        = Color3.fromRGB(248, 81, 73),
    textPrimary  = Color3.fromRGB(230, 237, 243),
    textSecondary= Color3.fromRGB(139, 148, 158),
    textMuted    = Color3.fromRGB(110, 118, 129),
    border       = Color3.fromRGB(48, 54, 61),
}

-- ============================================
-- Fonctions utilitaires
-- ============================================

local function hasFS()
    return pcall(function()
        return type(writefile)=="function" and type(readfile)=="function"
    end)
end

local function saveKey(key)
    if not hasFS() then return end
    pcall(function() writefile("script_key.txt", key) end)
end

local function loadKey()
    if not hasFS() then return nil end
    local ok, v = pcall(function() return readfile("script_key.txt") end)
    return (ok and v ~= "") and v or nil
end

local function clearKey()
    if not hasFS() then return end
    pcall(function() delfile("script_key.txt") end)
end

local function getHWID()
    return tostring(game:GetService("RbxAnalyticsService"):GetClientId())
end

-- Vérifie la key sur TON serveur
local function checkKey(key)
    if not key or key == "" then return false end
    local hwid = getHWID()
    local url = SITE_URL .. "/api/checkkey?key=" .. HttpService:UrlEncode(key) .. "&hwid=" .. HttpService:UrlEncode(hwid)

    local ok, res = pcall(function()
        return HttpService:GetAsync(url, true)
    end)

    if not ok then return false end

    local parsed = HttpService:JSONDecode(res)
    return parsed and parsed.valid == true, parsed
end

-- ============================================
-- Interface graphique (identique à l'original)
-- ============================================

getgenv().SCRIPT_KEY = nil
getgenv().UI_CLOSED = false

local gui = Instance.new("ScreenGui")
gui.Name = "KeySystemUI"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset = true

local blur = Instance.new("BlurEffect")
blur.Size = 16
blur.Name = "KeyUIBlur"
blur.Parent = Lighting

local backdrop = Instance.new("Frame")
backdrop.Size = UDim2.new(1,0,1,0)
backdrop.BackgroundColor3 = Color3.fromRGB(0,0,0)
backdrop.BackgroundTransparency = 0.4
backdrop.BorderSizePixel = 0
backdrop.Parent = gui

local container = Instance.new("Frame")
container.Size = UDim2.new(0,560,0,310)
container.Position = UDim2.new(0.5,0,0.5,0)
container.AnchorPoint = Vector2.new(0.5,0.5)
container.BackgroundColor3 = Colors.surface
container.BorderSizePixel = 0
container.Parent = backdrop

Instance.new("UICorner", container).CornerRadius = UDim.new(0,14)

local stroke = Instance.new("UIStroke")
stroke.Color = Colors.border
stroke.Thickness = 1
stroke.Transparency = 0.3
stroke.Parent = container

-- Top bar
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1,0,0,45)
topBar.BackgroundColor3 = Colors.background
topBar.BorderSizePixel = 0
topBar.ZIndex = 10
topBar.Parent = container
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0,14)

local topBarFix = Instance.new("Frame")
topBarFix.Size = UDim2.new(1,0,0,10)
topBarFix.Position = UDim2.new(0,0,1,-10)
topBarFix.BackgroundColor3 = Colors.background
topBarFix.BorderSizePixel = 0
topBarFix.Parent = topBar

-- Logo
local brandText = Instance.new("TextLabel")
brandText.Size = UDim2.new(0,200,1,0)
brandText.Position = UDim2.new(0,20,0,0)
brandText.BackgroundTransparency = 1
brandText.Text = "🛡️  Key System"
brandText.TextColor3 = Colors.textPrimary
brandText.TextSize = 15
brandText.Font = Enum.Font.GothamSemibold
brandText.TextXAlignment = Enum.TextXAlignment.Left
brandText.ZIndex = 11
brandText.Parent = topBar

-- Bouton fermer
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0,30,0,30)
closeBtn.Position = UDim2.new(1,-40,0.5,0)
closeBtn.AnchorPoint = Vector2.new(0,0.5)
closeBtn.BackgroundColor3 = Colors.error
closeBtn.BackgroundTransparency = 0.8
closeBtn.BorderSizePixel = 0
closeBtn.Text = "✕"
closeBtn.TextColor3 = Colors.textPrimary
closeBtn.TextSize = 14
closeBtn.Font = Enum.Font.GothamSemibold
closeBtn.AutoButtonColor = false
closeBtn.ZIndex = 11
closeBtn.Parent = topBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,8)

-- Content
local content = Instance.new("Frame")
content.Size = UDim2.new(1,-40,1,-65)
content.Position = UDim2.new(0,20,0,55)
content.BackgroundTransparency = 1
content.Parent = container

-- Icône centrale
local iconFrame = Instance.new("Frame")
iconFrame.Size = UDim2.new(0,52,0,52)
iconFrame.Position = UDim2.new(0.5,-26,0,0)
iconFrame.BackgroundColor3 = Colors.surfaceLight
iconFrame.BorderSizePixel = 0
iconFrame.Parent = content
Instance.new("UICorner", iconFrame).CornerRadius = UDim.new(0,12)

local iconStroke = Instance.new("UIStroke")
iconStroke.Color = Colors.primary
iconStroke.Thickness = 2
iconStroke.Transparency = 0.5
iconStroke.Parent = iconFrame

local iconLabel = Instance.new("TextLabel")
iconLabel.Size = UDim2.new(1,0,1,0)
iconLabel.BackgroundTransparency = 1
iconLabel.Text = "🔑"
iconLabel.TextSize = 24
iconLabel.Font = Enum.Font.GothamBold
iconLabel.Parent = iconFrame

-- Titre
local titleLbl = Instance.new("TextLabel")
titleLbl.Size = UDim2.new(1,0,0,24)
titleLbl.Position = UDim2.new(0,0,0,58)
titleLbl.BackgroundTransparency = 1
titleLbl.Text = "Key Verification"
titleLbl.TextColor3 = Colors.textPrimary
titleLbl.TextSize = 17
titleLbl.Font = Enum.Font.GothamBold
titleLbl.TextXAlignment = Enum.TextXAlignment.Center
titleLbl.Parent = content

local subLbl = Instance.new("TextLabel")
subLbl.Size = UDim2.new(1,0,0,18)
subLbl.Position = UDim2.new(0,0,0,83)
subLbl.BackgroundTransparency = 1
subLbl.Text = "Powered by ton site · Keys 24h"
subLbl.TextColor3 = Colors.textSecondary
subLbl.TextSize = 13
subLbl.Font = Enum.Font.Gotham
subLbl.TextXAlignment = Enum.TextXAlignment.Center
subLbl.Parent = content

-- Input key
local inputFrame = Instance.new("Frame")
inputFrame.Size = UDim2.new(1,0,0,46)
inputFrame.Position = UDim2.new(0,0,0,115)
inputFrame.BackgroundColor3 = Colors.surfaceLight
inputFrame.BorderSizePixel = 0
inputFrame.Parent = content
Instance.new("UICorner", inputFrame).CornerRadius = UDim.new(0,10)

local inputStroke = Instance.new("UIStroke")
inputStroke.Color = Colors.border
inputStroke.Thickness = 1
inputStroke.Transparency = 0.5
inputStroke.Parent = inputFrame

local keyInput = Instance.new("TextBox")
keyInput.Size = UDim2.new(1,-20,1,0)
keyInput.Position = UDim2.new(0,14,0,0)
keyInput.BackgroundTransparency = 1
keyInput.PlaceholderText = "XXXX-XXXX-XXXX-XXXX"
keyInput.PlaceholderColor3 = Colors.textMuted
keyInput.Text = ""
keyInput.TextColor3 = Colors.textPrimary
keyInput.TextSize = 14
keyInput.Font = Enum.Font.Gotham
keyInput.ClearTextOnFocus = false
keyInput.Parent = inputFrame

-- Boutons
local btnSection = Instance.new("Frame")
btnSection.Size = UDim2.new(1,0,0,40)
btnSection.Position = UDim2.new(0,0,0,175)
btnSection.BackgroundTransparency = 1
btnSection.Parent = content

-- Bouton Get Key (ouvre le site)
local getLinkBtn = Instance.new("TextButton")
getLinkBtn.Size = UDim2.new(0.48,0,1,0)
getLinkBtn.BackgroundColor3 = Colors.primary
getLinkBtn.BorderSizePixel = 0
getLinkBtn.Text = "🔗  Get Key"
getLinkBtn.TextColor3 = Color3.fromRGB(255,255,255)
getLinkBtn.TextSize = 14
getLinkBtn.Font = Enum.Font.GothamSemibold
getLinkBtn.AutoButtonColor = false
getLinkBtn.Parent = btnSection
Instance.new("UICorner", getLinkBtn).CornerRadius = UDim.new(0,10)

-- Bouton Verify
local verifyBtn = Instance.new("TextButton")
verifyBtn.Size = UDim2.new(0.48,0,1,0)
verifyBtn.Position = UDim2.new(0.52,0,0,0)
verifyBtn.BackgroundColor3 = Colors.success
verifyBtn.BorderSizePixel = 0
verifyBtn.Text = "✓  Verify Key"
verifyBtn.TextColor3 = Color3.fromRGB(255,255,255)
verifyBtn.TextSize = 14
verifyBtn.Font = Enum.Font.GothamSemibold
verifyBtn.AutoButtonColor = false
verifyBtn.Parent = btnSection
Instance.new("UICorner", verifyBtn).CornerRadius = UDim.new(0,10)

-- Status
local statusLbl = Instance.new("TextLabel")
statusLbl.Size = UDim2.new(1,-40,0,20)
statusLbl.Position = UDim2.new(0.5,0,1,-36)
statusLbl.AnchorPoint = Vector2.new(0.5,0)
statusLbl.BackgroundTransparency = 1
statusLbl.Text = ""
statusLbl.TextColor3 = Colors.textSecondary
statusLbl.Font = Enum.Font.Gotham
statusLbl.TextSize = 12
statusLbl.TextXAlignment = Enum.TextXAlignment.Center
statusLbl.Visible = false
statusLbl.Parent = container

local function setStatus(msg, color, duration)
    statusLbl.Text = msg
    statusLbl.TextColor3 = color or Colors.textSecondary
    statusLbl.Visible = true
    if duration then
        task.delay(duration, function()
            if statusLbl.Text == msg then statusLbl.Visible = false end
        end)
    end
end

-- Animations hover
closeBtn.MouseEnter:Connect(function() TweenService:Create(closeBtn,TweenInfo.new(.2),{BackgroundTransparency=0.2}):Play() end)
closeBtn.MouseLeave:Connect(function() TweenService:Create(closeBtn,TweenInfo.new(.2),{BackgroundTransparency=0.8}):Play() end)
keyInput.Focused:Connect(function() TweenService:Create(inputStroke,TweenInfo.new(.2),{Color=Colors.primary,Thickness=2,Transparency=0}):Play() end)
keyInput.FocusLost:Connect(function() TweenService:Create(inputStroke,TweenInfo.new(.2),{Color=Colors.border,Thickness=1,Transparency=0.5}):Play() end)

local function closeUI()
    getgenv().UI_CLOSED = true
    blur:Destroy()
    TweenService:Create(container,TweenInfo.new(.2),{BackgroundTransparency=1}):Play()
    TweenService:Create(backdrop,TweenInfo.new(.2),{BackgroundTransparency=1}):Play()
    task.wait(.2)
    gui:Destroy()
end

closeBtn.MouseButton1Click:Connect(closeUI)

-- ============================================
-- Bouton Get Key → ouvre le site
-- ============================================
getLinkBtn.MouseButton1Click:Connect(function()
    local link = SITE_URL
    if setclipboard then
        setclipboard(link)
        setStatus("Lien copié ! Ouvre-le dans ton navigateur.", Colors.primary, 4)
    else
        setStatus("Va sur : " .. link, Colors.primary, 8)
    end
end)

-- ============================================
-- Bouton Verify Key → vérifie sur ton API
-- ============================================
verifyBtn.MouseButton1Click:Connect(function()
    local key = keyInput.Text:gsub("%s+", "")
    if key == "" then
        setStatus("Entre ta key !", Colors.error, 3)
        return
    end

    verifyBtn.Text = "⏳  Vérification..."
    verifyBtn.Interactable = false
    setStatus("Vérification en cours...", Colors.primary, 0)

    local valid, data = checkKey(key)

    if valid then
        saveKey(key)
        setStatus("✓ Key valide ! " .. (data and ("Expire dans " .. data.hours_left .. "h") or ""), Colors.success, 0)
        TweenService:Create(iconFrame,TweenInfo.new(.2,Enum.EasingStyle.Back),{Size=UDim2.new(0,62,0,62),Position=UDim2.new(0.5,-31,0,-5)}):Play()
        task.wait(.2)
        TweenService:Create(iconFrame,TweenInfo.new(.2),{Size=UDim2.new(0,52,0,52),Position=UDim2.new(0.5,-26,0,0)}):Play()
        task.wait(1.2)
        getgenv().SCRIPT_KEY = key
        closeUI()
    else
        setStatus("❌ Key invalide ou expirée.", Colors.error, 4)
        verifyBtn.Text = "✓  Verify Key"
        verifyBtn.Interactable = true
    end
end)

keyInput.FocusLost:Connect(function(enter)
    if enter then verifyBtn:activate() end
end)

-- ============================================
-- Auto-check si une key est sauvegardée
-- ============================================
gui.Parent = game:GetService("CoreGui")

task.spawn(function()
    local saved = loadKey()
    if saved then
        setStatus("Vérification de la key sauvegardée...", Colors.primary, 0)
        keyInput.Text = saved
        local valid, data = checkKey(saved)
        if valid then
            setStatus("✓ Key sauvegardée valide !", Colors.success, 0)
            task.wait(1)
            getgenv().SCRIPT_KEY = saved
            closeUI()
            return
        else
            clearKey()
            setStatus("Key expirée, obtiens-en une nouvelle.", Colors.error, 4)
            keyInput.Text = ""
        end
    end
end)

-- Attend que l'UI soit fermée
while not getgenv().UI_CLOSED do
    task.wait(0.1)
end

-- ============================================
-- ✅ TON SCRIPT COMMENCE ICI
-- getgenv().SCRIPT_KEY contient la key validée
-- ============================================

print("Key validée : " .. tostring(getgenv().SCRIPT_KEY))
-- Mets ton script ici v
