--======================================================
-- UFO HUB X UI Pro | Full Core + External API
-- - Build UI (looks like original UFO HUB X)
-- - External API UFOPro: CreateLib -> NewTab -> NewSection -> NewButton/NewLabel
-- - Supports asset-id icons ("12345" or "rbxassetid://12345") or emoji strings
-- - Scrollable left/right, mobile & PC friendly, toggle + drag
--======================================================

-- 0) Clear old
pcall(function()
    local cg = game:GetService("CoreGui")
    for _,n in ipairs({"UFO_HUB_X_UI","UFO_HUB_X_Toggle"}) do
        local g = cg:FindFirstChild(n); if g then g:Destroy() end
    end
end)

-- 1) Theme (exact to your original)
local THEME = {
    GREEN        = Color3.fromRGB(0,255,140),
    MINT         = Color3.fromRGB(120,255,220),
    MINT_SOFT    = Color3.fromRGB(90,210,190),
    BG_WINDOW    = Color3.fromRGB(16,16,16),
    BG_HEADER    = Color3.fromRGB(6,6,6),
    BG_PANEL     = Color3.fromRGB(22,22,22),
    BG_INNER     = Color3.fromRGB(18,18,18),
    TEXT_WHITE   = Color3.fromRGB(235,235,235),
    DANGER_RED   = Color3.fromRGB(200,40,40),
    BTN_IDLE     = Color3.fromRGB(24,24,28),
    BTN_HOVER    = Color3.fromRGB(30,30,36),
    BTN_ACTIVE   = Color3.fromRGB(36,36,44),
    CARD_FILL    = Color3.fromRGB(28,28,34),
    CARD_STROKE  = Color3.fromRGB(100,160,140),
    TEXT_DIM     = Color3.fromRGB(185,190,200),
}

local SIZE = {
    WIN_W = 860, WIN_H = 360,        -- default size (big as original)
    GAP_OUTER = 14, GAP_BETWEEN = 12,
    LEFT_RATIO = 0.22, RIGHT_RATIO = 0.78,
    HEADER_H = 46
}

local IMGS = {
    SMALL = "rbxassetid://121069267171370",
    LARGE = "rbxassetid://108408843188558",
    UFO   = "rbxassetid://100650447103028",
    GLOW  = "rbxassetid://5028857084",
    TOGGLE= "rbxassetid://117052960049460",
}

-- 2) Helpers
local function corner(gui, r) local c=Instance.new("UICorner",gui); c.CornerRadius=UDim.new(0,r or 10); return c end
local function stroke(gui,t,col,trans)
    local s=Instance.new("UIStroke",gui); s.Thickness=t or 1; s.Color=col or THEME.MINT; s.Transparency=trans or 0.35
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; s.LineJoinMode = Enum.LineJoinMode.Round
    return s
end
local function gradient(gui,c1,c2,rot) local g=Instance.new("UIGradient",gui); g.Color=ColorSequence.new(c1,c2); g.Rotation=rot or 0; return g end
local function isAssetId(str) str=tostring(str or "") return str:match("^rbxassetid://%d+$") or str:match("^%d+$") end

-- 3) Services
local CoreGui = game:GetService("CoreGui")
local UIS     = game:GetService("UserInputService")
local RunS    = game:GetService("RunService")
local CAS     = game:GetService("ContextActionService")

-- 4) Build UI (core)
local function buildUI()
    if CoreGui:FindFirstChild("UFO_HUB_X_UI") then return CoreGui.UFO_HUB_X_UI end
    local GUI = Instance.new("ScreenGui", CoreGui)
    GUI.Name = "UFO_HUB_X_UI"; GUI.IgnoreGuiInset = true; GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    GUI.ResetOnSpawn = false

    local Window = Instance.new("Frame", GUI)
    Window.Name="Window"; Window.AnchorPoint=Vector2.new(0.5,0.5); Window.Position=UDim2.new(0.5,0,0.5,0)
    Window.Size = UDim2.fromOffset(SIZE.WIN_W, SIZE.WIN_H); Window.BackgroundColor3 = THEME.BG_WINDOW; Window.BorderSizePixel=0
    corner(Window,12); stroke(Window,3,THEME.GREEN,0)

    -- glow
    local Glow = Instance.new("ImageLabel", Window)
    Glow.BackgroundTransparency = 1; Glow.AnchorPoint = Vector2.new(0.5,0.5)
    Glow.Position = UDim2.new(0.5,0,0.5,0); Glow.Size = UDim2.new(1.07,0,1.09,0)
    Glow.Image = IMGS.GLOW; Glow.ImageColor3 = THEME.GREEN; Glow.ImageTransparency = 0.78
    Glow.ScaleType = Enum.ScaleType.Slice; Glow.SliceCenter = Rect.new(24,24,276,276); Glow.ZIndex = 0

    -- autoscale (mobile-friendly)
    local UIScale = Instance.new("UIScale", Window)
    local function fit()
        local v = (workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize) or Vector2.new(1280,720)
        UIScale.Scale = math.clamp(math.min(v.X / 1000, v.Y / 620), 0.64, 1.0) -- tuned so not too small
    end
    fit(); RunS.RenderStepped:Connect(fit)

    -- HEADER
    local Header = Instance.new("Frame", Window)
    Header.Name = "Header"; Header.Size = UDim2.new(1,0,0,SIZE.HEADER_H); Header.BackgroundColor3 = THEME.BG_HEADER; Header.BorderSizePixel=0
    corner(Header,12); gradient(Header, Color3.fromRGB(10,10,10), Color3.fromRGB(0,0,0), 0)

    local HeadAccent = Instance.new("Frame", Header)
    HeadAccent.AnchorPoint = Vector2.new(0.5,1); HeadAccent.Position = UDim2.new(0.5,0,1,0)
    HeadAccent.Size = UDim2.new(1,-20,0,1); HeadAccent.BackgroundColor3 = THEME.MINT; HeadAccent.BackgroundTransparency = 0.35

    local Dot = Instance.new("Frame", Header)
    Dot.Name="Dot"; Dot.BackgroundColor3 = THEME.MINT; Dot.Position = UDim2.new(0,14,0.5,-4); Dot.Size = UDim2.new(0,8,0,8)
    Dot.BorderSizePixel = 0; corner(Dot, 4)

    -- RED NAME BOX (to show active tab name) - small red rounded rect at top-right of header near X
    local ActiveName = Instance.new("Frame", Header)
    ActiveName.Name = "ActiveName"; ActiveName.Size = UDim2.new(0,110,0,24); ActiveName.Position = UDim2.new(1,-160,0.5,-12)
    ActiveName.BackgroundColor3 = Color3.fromRGB(180,40,40); ActiveName.Visible = false; corner(ActiveName,6)
    local activeLbl = Instance.new("TextLabel", ActiveName)
    activeLbl.BackgroundTransparency = 1; activeLbl.Size = UDim2.new(1,0,1,0)
    activeLbl.Font = Enum.Font.GothamBold; activeLbl.TextSize = 14; activeLbl.TextColor3 = Color3.new(1,1,1)
    activeLbl.Text = "TabName"; activeLbl.TextScaled = false; activeLbl.TextXAlignment = Enum.TextXAlignment.Center

    -- Title center
    local TitleCenter = Instance.new("TextLabel", Header)
    TitleCenter.Name = "TitleCenter"; TitleCenter.BackgroundTransparency = 1; TitleCenter.AnchorPoint = Vector2.new(0.5,0)
    TitleCenter.Position = UDim2.new(0.5, 0, 0, 8)
    TitleCenter.Size = UDim2.new(0.8, 0, 0, 36)
    TitleCenter.Font = Enum.Font.GothamBold; TitleCenter.RichText = true; TitleCenter.TextScaled = true
    TitleCenter.Text = '<font color="#FFFFFF">UFO</font> <font color="#00FF8C">HUB X</font>'
    TitleCenter.TextColor3 = THEME.TEXT_WHITE

    local BtnClose = Instance.new("TextButton", Header)
    BtnClose.Name="BtnClose"; BtnClose.Size = UDim2.new(0,24,0,24); BtnClose.Position = UDim2.new(1,-34,0.5,-12)
    BtnClose.BackgroundColor3 = THEME.DANGER_RED; BtnClose.Text = "X"; BtnClose.Font = Enum.Font.GothamBold
    BtnClose.TextSize = 13; BtnClose.TextColor3 = Color3.new(1,1,1); BtnClose.BorderSizePixel = 0
    corner(BtnClose,6); stroke(BtnClose,1,Color3.fromRGB(255,0,0),0.1)
    BtnClose.MouseButton1Click:Connect(function() Window.Visible=false; getgenv().UFO_ISOPEN=false end)

    -- BODY
    local Body = Instance.new("Frame", Window)
    Body.Name = "Body"; Body.BackgroundTransparency = 1; Body.Position = UDim2.new(0,0,0,SIZE.HEADER_H); Body.Size = UDim2.new(1,0,1,-SIZE.HEADER_H)

    local Inner = Instance.new("Frame", Body)
    Inner.Name = "Inner"; Inner.BackgroundColor3 = THEME.BG_INNER; Inner.BorderSizePixel = 0
    Inner.Position = UDim2.new(0,8,0,8); Inner.Size = UDim2.new(1,-16,1,-16); corner(Inner,12)

    local Content = Instance.new("Frame", Body)
    Content.Name = "Content"; Content.BackgroundColor3 = THEME.BG_PANEL;
    Content.Position = UDim2.new(0,SIZE.GAP_OUTER,0,SIZE.GAP_OUTER)
    Content.Size = UDim2.new(1,-SIZE.GAP_OUTER*2,1,-SIZE.GAP_OUTER*2); corner(Content,12); stroke(Content,0.5,THEME.MINT,0.35)

    local Columns = Instance.new("Frame", Content)
    Columns.Name="Columns"; Columns.BackgroundTransparency=1; Columns.Position=UDim2.new(0,8,0,8); Columns.Size=UDim2.new(1,-16,1,-16)

    -- LEFT (Scrolling)
    local Left = Instance.new("ScrollingFrame", Columns)
    Left.Name="Left"; Left.BackgroundColor3 = THEME.BG_INNER
    Left.Size = UDim2.new(SIZE.LEFT_RATIO, -SIZE.GAP_BETWEEN/2, 1, 0)
    Left.ScrollBarThickness = 3; Left.CanvasSize = UDim2.new(0,0,0,0); Left.ClipsDescendants = true
    corner(Left,10); stroke(Left,1.2,THEME.GREEN,0); stroke(Left,0.45,THEME.MINT,0.35)
    local padL = Instance.new("UIPadding", Left)
    padL.PaddingTop = UDim.new(0,8); padL.PaddingLeft = UDim.new(0,8); padL.PaddingRight = UDim.new(0,8); padL.PaddingBottom = UDim.new(0,8)
    local listL = Instance.new("UIListLayout", Left)
    listL.Padding = UDim.new(0,8); listL.SortOrder = Enum.SortOrder.LayoutOrder
    listL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Left.CanvasSize = UDim2.new(0,0,0, listL.AbsoluteContentSize.Y + 12) end)

    -- RIGHT (Pages host) - Scrolling
    local Right = Instance.new("ScrollingFrame", Columns)
    Right.Name="Right"; Right.BackgroundColor3 = THEME.BG_INNER
    Right.Position = UDim2.new(SIZE.LEFT_RATIO, SIZE.GAP_BETWEEN, 0, 0)
    Right.Size = UDim2.new(SIZE.RIGHT_RATIO, -SIZE.GAP_BETWEEN/2, 1, 0)
    Right.ScrollBarThickness = 4; Right.ClipsDescendants = true; Right.CanvasSize = UDim2.new(0,0,0,0)
    corner(Right,10); stroke(Right,1.2,THEME.GREEN,0); stroke(Right,0.45,THEME.MINT,0.35)
    local padR = Instance.new("UIPadding", Right)
    padR.PaddingTop = UDim.new(0,8); padR.PaddingLeft = UDim.new(0,8); padR.PaddingRight = UDim.new(0,8); padR.PaddingBottom = UDim.new(0,8)

    local PageHost = Instance.new("Frame", Right)
    PageHost.Name="PageHost"; PageHost.BackgroundTransparency=1; PageHost.Size=UDim2.new(1,-12,1,-12); PageHost.Position=UDim2.new(0,6,0,6)
    local layPages = Instance.new("UIListLayout", PageHost)
    layPages.Padding = UDim.new(0,0)
    layPages:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Right.CanvasSize = UDim2.new(0,0,0, layPages.AbsoluteContentSize.Y + 12) end)

    -- UFO + halo decoration
    local UFO = Instance.new("ImageLabel", Window)
    UFO.Name="UFO_Top"; UFO.BackgroundTransparency=1; UFO.Image = IMGS.UFO
    UFO.Size = UDim2.new(0,168,0,168); UFO.AnchorPoint = Vector2.new(0.5,1); UFO.Position = UDim2.new(0.5, 0, 0, 84); UFO.ZIndex = 60
    local Halo = Instance.new("ImageLabel", Window)
    Halo.BackgroundTransparency=1; Halo.AnchorPoint=Vector2.new(0.5,0); Halo.Position = UDim2.new(0.5,0,0,0)
    Halo.Size = UDim2.new(0,200,0,60); Halo.Image = IMGS.GLOW; Halo.ImageColor3 = THEME.MINT_SOFT; Halo.ImageTransparency = 0.72; Halo.ZIndex = 50

    return GUI
end

local _GUI = buildUI()

--======================================================
-- 5) UFOPro External API
--======================================================
local UFOPro = { _version = "2.0-pro" }
UFOPro.__index = UFOPro
getgenv().UFOPro = UFOPro

-- helpers to access containers
local function findContainers()
    local gui = CoreGui:FindFirstChild("UFO_HUB_X_UI")
    if not gui then return end
    local win   = gui:FindFirstChild("Window")
    local left  = win and win:FindFirstChild("Body") and win.Body:FindFirstChild("Content") and win.Body.Content:FindFirstChild("Columns") and win.Body.Content.Columns:FindFirstChild("Left")
    local host  = win and win:FindFirstChild("Body") and win.Body:FindFirstChild("Content") and win.Body.Content:FindFirstChild("Columns") and win.Body.Content.Columns:FindFirstChild("Right") and win.Body.Content.Columns.Right:FindFirstChild("PageHost")
    local header = win and win:FindFirstChild("Header")
    return gui, win, header, left, host
end

-- Create side tab button (rectangle + green stroke + optional icon/emoji)
local function makeSideButton(parent, labelText, iconOrEmoji, active)
    local b = Instance.new("TextButton")
    b.Name = "Tab_"..labelText; b.AutoButtonColor = false
    b.Size = UDim2.new(1,0,0,36)
    b.BackgroundColor3 = active and THEME.BTN_ACTIVE or THEME.BTN_IDLE
    b.Text = ""  -- we'll build manual text layout (icon + label)
    b.Font = Enum.Font.GothamSemibold; b.TextSize = 14; b.TextColor3 = THEME.TEXT_WHITE
    b.Parent = parent; corner(b,10); stroke(b,1,THEME.GREEN,0.22)

    -- container inside for icon + text
    local inner = Instance.new("Frame", b); inner.BackgroundTransparency = 1; inner.Size = UDim2.new(1,0,1,0)
    local iconSize = 28
    if iconOrEmoji then
        if isAssetId(iconOrEmoji) then
            local img = Instance.new("ImageLabel", inner); img.BackgroundTransparency = 1
            img.Size = UDim2.new(0,iconSize,0,iconSize); img.Position = UDim2.new(0,6,0.5,-iconSize/2)
            img.Image = (iconOrEmoji:match("^rbxassetid://") and iconOrEmoji) or ("rbxassetid://"..iconOrEmoji)
            img.ScaleType = Enum.ScaleType.Crop
            local txt = Instance.new("TextLabel", inner); txt.BackgroundTransparency = 1; txt.Position = UDim2.new(0,iconSize+14,0,0)
            txt.Size = UDim2.new(1,-iconSize-14,1,0); txt.Font=Enum.Font.GothamSemibold; txt.TextSize=14; txt.TextColor3 = THEME.TEXT_DIM
            txt.Text = "· "..labelText; txt.TextXAlignment = Enum.TextXAlignment.Left
        else
            local em = Instance.new("TextLabel", inner); em.BackgroundTransparency = 1
            em.Position = UDim2.new(0,6,0,0); em.Size = UDim2.new(0,iconSize,1,0); em.Font = Enum.Font.GothamBold; em.TextScaled = true
            em.Text = tostring(iconOrEmoji); em.TextColor3 = THEME.TEXT_WHITE
            local txt = Instance.new("TextLabel", inner); txt.BackgroundTransparency = 1; txt.Position = UDim2.new(0,iconSize+14,0,0)
            txt.Size = UDim2.new(1,-iconSize-14,1,0); txt.Font=Enum.Font.GothamSemibold; txt.TextSize=14; txt.TextColor3 = THEME.TEXT_DIM
            txt.Text = "· "..labelText; txt.TextXAlignment = Enum.TextXAlignment.Left
        end
    else
        local txt = Instance.new("TextLabel", inner); txt.BackgroundTransparency = 1; txt.Position = UDim2.new(0,8,0,0)
        txt.Size = UDim2.new(1,-8,1,0); txt.Font=Enum.Font.GothamSemibold; txt.TextSize=14; txt.TextColor3 = THEME.TEXT_DIM
        txt.Text = "· "..labelText; txt.TextXAlignment = Enum.TextXAlignment.Left
    end

    b.MouseEnter:Connect(function() if not active then b.BackgroundColor3 = THEME.BTN_HOVER end end)
    b.MouseLeave:Connect(function() if not active then b.BackgroundColor3 = THEME.BTN_IDLE end end)
    return b
end

-- create page (frame) with inner scrolling area (for right side)
local function makePage(host, name)
    local page = Instance.new("Frame", host); page.Name = "Page_"..name; page.BackgroundTransparency = 1; page.Size = UDim2.new(1,0,0,0); page.Visible = false
    -- we want page to size by its content; use a ScrollingFrame to allow internal scroll if needed
    local sf = Instance.new("Frame", page); sf.Name="Content"; sf.BackgroundTransparency=1; sf.Size=UDim2.new(1,0,0,0)
    local lay = Instance.new("UIListLayout", sf); lay.Padding = UDim.new(0,10); lay.SortOrder = Enum.SortOrder.LayoutOrder
    -- auto-size page height to content
    lay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.Size = UDim2.new(1,0,0, lay.AbsoluteContentSize.Y + 12)
    end)
    return page, sf
end

-- make section card (header + content holder)
local function makeSectionCard(parent, title)
    local holder = Instance.new("Frame", parent); holder.Size = UDim2.new(1,0,0,56); holder.BackgroundColor3 = THEME.CARD_FILL; holder.BorderSizePixel=0
    corner(holder,10); stroke(holder,1,THEME.CARD_STROKE,0.18)
    local inner = Instance.new("Frame", holder); inner.BackgroundTransparency = 1; inner.Size = UDim2.new(1,-22,1,-14); inner.Position = UDim2.new(0,11,0,7)
    local h = Instance.new("UIListLayout", inner); h.FillDirection = Enum.FillDirection.Horizontal; h.VerticalAlignment = Enum.VerticalAlignment.Center; h.Padding = UDim.new(0,10)
    local dot = Instance.new("Frame", inner); dot.Size = UDim2.fromOffset(8,8); dot.BackgroundColor3 = Color3.fromRGB(86,168,255); dot.BorderSizePixel=0; corner(dot,8)
    local lab = Instance.new("TextLabel", inner); lab.BackgroundTransparency = 1; lab.Size = UDim2.new(1,-18,1,0); lab.Font = Enum.Font.GothamSemibold; lab.TextSize = 16; lab.TextXAlignment = Enum.TextXAlignment.Left; lab.TextColor3 = THEME.TEXT_WHITE; lab.Text = title or "Section"
    -- content frame below
    local content = Instance.new("Frame", parent); content.BackgroundTransparency=1; content.Size = UDim2.new(1,0,0,0)
    local v = Instance.new("UIListLayout", content); v.Padding = UDim.new(0,6); v.SortOrder = Enum.SortOrder.LayoutOrder
    holder.LayoutOrder = 0; content.LayoutOrder = 1

    -- sync content height
    local function sync()
        local total = 0
        for _,o in ipairs(content:GetChildren()) do
            if o:IsA("GuiObject") then total = total + o.AbsoluteSize.Y + 6 end
        end
        content.Size = UDim2.new(1,0,0,total)
    end
    content.ChildAdded:Connect(sync); content.ChildRemoved:Connect(sync)

    -- API to create buttons/items inside section
    local api = {}

    function api:NewButton(opts, callback)
        -- opts: {text=, icon= (asset id or emoji), height=}
        opts = opts or {}
        local hgt = tonumber(opts.height) or 34
        local btn = Instance.new("TextButton", content)
        btn.AutoButtonColor = false; btn.Size = UDim2.new(1,0,0,hgt); btn.BackgroundColor3 = THEME.BTN_IDLE
        btn.Font = Enum.Font.GothamSemibold; btn.TextSize = 14; btn.TextColor3 = THEME.TEXT_WHITE; btn.Text = ""
        corner(btn,8); stroke(btn,1,THEME.MINT,0.20)

        -- layout inside button for icon and label (icon left)
        local inner = Instance.new("Frame", btn); inner.BackgroundTransparency = 1; inner.Size = UDim2.new(1,0,1,0)
        local iconSize = hgt - 8
        local leftPad = 8
        if opts.icon then
            if isAssetId(opts.icon) then
                local img = Instance.new("ImageLabel", inner); img.BackgroundTransparency = 1
                img.Size = UDim2.new(0,iconSize,0,iconSize); img.Position = UDim2.new(0,leftPad,0.5,-iconSize/2)
                img.Image = (opts.icon:match("^rbxassetid://") and opts.icon) or ("rbxassetid://"..opts.icon)
                leftPad = leftPad + iconSize + 8
            else
                local em = Instance.new("TextLabel", inner); em.BackgroundTransparency = 1
                em.Size = UDim2.new(0,iconSize,1,0); em.Position = UDim2.new(0,leftPad,0,0); em.Font = Enum.Font.GothamBold; em.TextScaled = true
                em.Text = tostring(opts.icon); em.TextColor3 = THEME.TEXT_WHITE
                leftPad = leftPad + iconSize + 8
            end
        end
        local lbl = Instance.new("TextLabel", inner); lbl.BackgroundTransparency = 1; lbl.Size = UDim2.new(1,-leftPad,1,0); lbl.Position = UDim2.new(0,leftPad,0,0)
        lbl.Font = Enum.Font.GothamSemibold; lbl.TextSize = 14; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.TextColor3 = THEME.TEXT_WHITE
        lbl.Text = opts.text or "Button"

        btn.MouseEnter:Connect(function() btn.BackgroundColor3 = THEME.BTN_HOVER end)
        btn.MouseLeave:Connect(function() btn.BackgroundColor3 = THEME.BTN_IDLE end)
        btn.MouseButton1Click:Connect(function() pcall(callback or function() end) end)
        return btn
    end

    function api:NewLabel(text)
        local l = Instance.new("TextLabel", content)
        l.BackgroundTransparency = 1; l.Size = UDim2.new(1,0,0,24)
        l.Font = Enum.Font.Gotham; l.TextSize = 14; l.TextXAlignment = Enum.TextXAlignment.Left
        l.TextColor3 = THEME.TEXT_WHITE; l.Text = tostring(text or "Label")
        function l:UpdateLabel(newText) l.Text = tostring(newText) end
        return l
    end

    function api:NewItem(opts)
        -- generic item frame (like label but with bg)
        opts = opts or {}
        local hgt = tonumber(opts.height) or 34
        local item = Instance.new("Frame", content); item.BackgroundColor3 = THEME.BTN_IDLE; item.Size = UDim2.new(1,0,0,hgt); corner(item,8); stroke(item,1,THEME.MINT,0.2)
        local leftPad = 8
        if opts.icon then
            if isAssetId(opts.icon) then
                local img = Instance.new("ImageLabel", item); img.BackgroundTransparency = 1; img.Size = UDim2.new(0,hgt-8,0,hgt-8); img.Position = UDim2
                img.Image = (opts.icon:match("^rbxassetid://") and opts.icon) or ("rbxassetid://"..opts.icon)
                leftPad = leftPad + (hgt-8) + 6
            else
                local em = Instance.new("TextLabel", item)
                em.BackgroundTransparency = 1
                em.Size = UDim2.new(0, hgt-6, 1, 0)
                em.Position = UDim2.new(0, 6, 0, 0)
                em.Font = Enum.Font.GothamBold
                em.TextScaled = true
                em.Text = tostring(opts.icon)
                em.TextColor3 = THEME.TEXT_WHITE
                leftPad = leftPad + (hgt-6) + 6
            end
        end

        if opts.text then
            local t = Instance.new("TextLabel", item)
            t.BackgroundTransparency = 1
            t.Position = UDim2.new(0, leftPad, 0, 0)
            t.Size = UDim2.new(1, -leftPad, 1, 0)
            t.Font = Enum.Font.Gotham
            t.TextSize = 14
            t.TextColor3 = THEME.TEXT_WHITE
            t.TextXAlignment = Enum.TextXAlignment.Left
            t.Text = tostring(opts.text)
        end
        return item
    end

    return api
end

-- UFOPro.CreateLib: entry for external scripts
function UFOPro.CreateLib(title)
    local gui, win, header, left, host = findContainers()
    if not gui then
        gui = buildUI()
        gui, win, header, left, host = findContainers()
    end

    -- set title "UFO HUB X"
    local titleLabel = header and header:FindFirstChild("TitleCenter")
    if titleLabel then
        titleLabel.Text = string.format('<font color="#FFFFFF">%s</font> <font color="#00FF8C">HUB X</font>', tostring(title or "UFO"))
    end

    local api = { _gui = gui, _win = win, _left = left, _host = host, _tabs = {}, _active = nil }

    function api:ToggleUI()
        if self._win then
            self._win.Visible = not self._win.Visible
            getgenv().UFO_ISOPEN = self._win.Visible
        end
    end

    function api:NewTab(opts)
        opts = opts or {}
        local name = tostring(opts.text or ("Tab"..tostring(#(self._tabs)+1)))
        local icon = opts.icon
        local isFirst = (#(self._tabs) == 0)

        -- left button
        local btn = makeSideButton(self._left, name, icon, isFirst)
        -- right page
        local page, contentRoot = makePage(self._host, name)

        local pageset = { name = name, btn = btn, page = page, content = contentRoot, sections = {} }

        local function activate()
            -- hide all pages + dim all buttons
            for _,t in pairs(self._tabs) do
                if t.page then t.page.Visible = false end
                if t.btn then
                    t.btn.BackgroundColor3 = THEME.BTN_IDLE
                    for _,c in ipairs(t.btn:GetDescendants()) do
                        if c:IsA("TextLabel") then c.TextColor3 = THEME.TEXT_DIM end
                    end
                end
            end
            -- show this page + highlight button
            page.Visible = true
            btn.BackgroundColor3 = THEME.BTN_ACTIVE
            for _,c in ipairs(btn:GetDescendants()) do
                if c:IsA("TextLabel") then c.TextColor3 = Color3.fromRGB(230,255,240) end
            end

            -- update red name box (top-right)
            local an = header and header:FindFirstChild("ActiveName")
            if an then
                an.Visible = true
                local lab = an:FindFirstChildWhichIsA("TextLabel")
                if lab then lab.Text = name end
            end

            self._active = name
        end
        btn.MouseButton1Click:Connect(activate)
        if isFirst then activate() end

        -- Tab API to add sections from outside
        local tabAPI = {}
        function tabAPI:NewSection(titleText)
            local secAPI = makeSectionCard(contentRoot, titleText or "Section")
            table.insert(pageset.sections, secAPI)
            return secAPI
        end

        tabAPI._btn = btn
        tabAPI._page = page
        tabAPI._name = name

        self._tabs[name] = pageset
        table.insert(self._tabs, pageset)
        return tabAPI
    end

    function api:GetTabs()
        local out = {}
        for k,_ in pairs(self._tabs) do
            if type(k) == "string" then table.insert(out, k) end
        end
        table.sort(out)
        return out
    end

    function api:SetActive(name)
        local t = self._tabs[name]
        if t and t.btn then
            -- simulate click to reuse activate logic
            t.btn:MouseButton1Click()
        end
    end

    return api
end

-- expose
getgenv().UFOPro = UFOPro
