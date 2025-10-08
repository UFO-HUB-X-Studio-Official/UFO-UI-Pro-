--======================================================
-- UFO HUB X UI Pro | Stable Build (Big Size + Scroll + Demo)
--======================================================

-- ล้างของเดิม
pcall(function()
    local cg = game:GetService("CoreGui")
    for _,n in ipairs({"UFO_HUB_X_UI","UFO_HUB_X_Toggle"}) do
        local g = cg:FindFirstChild(n)
        if g then g:Destroy() end
    end
end)

-- ---------- CONFIG ----------
local THEME = {
    GREEN        = Color3.fromRGB(0,255,140),
    MINT         = Color3.fromRGB(120,255,220),
    MINT_SOFT    = Color3.fromRGB(90,210,190),
    BG_WINDOW    = Color3.fromRGB(16,16,16),
    BG_HEADER    = Color3.fromRGB(6,6,6),
    BG_PANEL     = Color3.fromRGB(20,20,22),
    BG_INNER     = Color3.fromRGB(14,14,16),
    TEXT_WHITE   = Color3.fromRGB(235,235,235),
    DANGER_RED   = Color3.fromRGB(200,40,40),

    BTN_IDLE     = Color3.fromRGB(24,24,28),
    BTN_HOVER    = Color3.fromRGB(30,30,36),
    BTN_ACTIVE   = Color3.fromRGB(36,36,44),
    CARD_FILL    = Color3.fromRGB(28,28,34),
    CARD_STROKE  = Color3.fromRGB(100,160,140),
    TEXT_DIM     = Color3.fromRGB(180,190,200),
}

-- ขนาด “ใหญ่สวย” + autoscale ไม่บีบเล็กไป
local SIZE = {
    WIN_W = 720, WIN_H = 400,
    GAP_OUTER = 12, GAP_BETWEEN = 10,
    LEFT_RATIO = 0.26, RIGHT_RATIO = 0.74,
    HEADER_H = 46
}

local IMGS = {
    SMALL = "rbxassetid://121069267171370",
    LARGE = "rbxassetid://108408843188558",
    UFO   = "rbxassetid://100650447103028",
    GLOW  = "rbxassetid://5028857084",
    TOGGLE= "rbxassetid://117052960049460",
}

-- ---------- HELPERS ----------
local function corner(gui, r)
    local c = Instance.new("UICorner", gui); c.CornerRadius = UDim.new(0, r or 10); return c
end
local function stroke(gui, t, col, trans)
    local s = Instance.new("UIStroke", gui)
    s.Thickness, s.Color, s.Transparency = t or 1, col or THEME.MINT, trans or 0.35
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; s.LineJoinMode = Enum.LineJoinMode.Round
    return s
end
local function gradient(gui, c1, c2, rot)
    local g = Instance.new("UIGradient", gui); g.Color = ColorSequence.new(c1, c2); g.Rotation = rot or 0; return g
end

-- ---------- Services ----------
local CoreGui = game:GetService("CoreGui")
local UIS     = game:GetService("UserInputService")
local RunS    = game:GetService("RunService")
local CAS     = game:GetService("ContextActionService")

--======================================================
-- สร้าง UI หลัก (ดีไซน์เดิม 100%) + Scroll ซ้าย/ขวา
--======================================================
local function buildUIMain()
    if CoreGui:FindFirstChild("UFO_HUB_X_UI") then return CoreGui.UFO_HUB_X_UI end

    local GUI = Instance.new("ScreenGui")
    GUI.Name = "UFO_HUB_X_UI"; GUI.IgnoreGuiInset = true; GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    GUI.ResetOnSpawn = false; GUI.Parent = CoreGui

    -- WINDOW
    local Window = Instance.new("Frame", GUI)
    Window.Name = "Window"
    Window.AnchorPoint = Vector2.new(0.5,0.5); Window.Position = UDim2.new(0.5,0,0.5,0)
    Window.Size = UDim2.fromOffset(SIZE.WIN_W, SIZE.WIN_H); Window.BackgroundColor3 = THEME.BG_WINDOW; Window.BorderSizePixel = 0
    corner(Window, 12); stroke(Window, 3, THEME.GREEN, 0)

    -- Glow
    local Glow = Instance.new("ImageLabel", Window)
    Glow.BackgroundTransparency = 1; Glow.AnchorPoint = Vector2.new(0.5,0.5)
    Glow.Position = UDim2.new(0.5,0,0.5,0); Glow.Size = UDim2.new(1.07,0,1.09,0)
    Glow.Image = IMGS.GLOW; Glow.ImageColor3 = THEME.GREEN; Glow.ImageTransparency = 0.78
    Glow.ScaleType = Enum.ScaleType.Slice; Glow.SliceCenter = Rect.new(24,24,276,276); Glow.ZIndex = 0

    -- Autoscale (ไม่ย่อเล็กเกินไป)
    local UIScale = Instance.new("UIScale", Window)
    local function fit()
        local v = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280,720)
        UIScale.Scale = math.clamp(math.min(v.X/960, v.Y/600), 0.80, 1.05)
    end
    fit(); RunS.RenderStepped:Connect(fit)

    -- HEADER
    local Header = Instance.new("Frame", Window)
    Header.Name = "Header"
    Header.Size = UDim2.new(1,0,0,SIZE.HEADER_H); Header.BackgroundColor3 = THEME.BG_HEADER; Header.BorderSizePixel = 0
    corner(Header, 12); gradient(Header, Color3.fromRGB(10,10,10), Color3.fromRGB(0,0,0), 0)

    local HeadAccent = Instance.new("Frame", Header)
    HeadAccent.AnchorPoint = Vector2.new(0.5,1); HeadAccent.Position = UDim2.new(0.5,0,1,0)
    HeadAccent.Size = UDim2.new(1,-20,0,1); HeadAccent.BackgroundColor3 = THEME.MINT; HeadAccent.BackgroundTransparency = 0.35
    HeadAccent.BorderSizePixel = 0

    local Dot = Instance.new("Frame", Header)
    Dot.BackgroundColor3 = THEME.MINT; Dot.Position = UDim2.new(0,14,0.5,-4); Dot.Size = UDim2.new(0,8,0,8)
    Dot.BorderSizePixel = 0; corner(Dot, 4)

    local TitleCenter = Instance.new("TextLabel", Header)
    TitleCenter.Name = "TitleCenter"
    TitleCenter.BackgroundTransparency = 1; TitleCenter.AnchorPoint = Vector2.new(0.5,0)
    TitleCenter.Position = UDim2.new(0.5, 0, 0, 8)
    TitleCenter.Size = UDim2.new(0.8, 0, 0, 36)
    TitleCenter.Font = Enum.Font.GothamBold; TitleCenter.RichText = true; TitleCenter.TextScaled = true
    TitleCenter.Text = '<font color="#FFFFFF">UFO</font> <font color="#00FF8C">HUB X</font>'
    TitleCenter.TextColor3 = THEME.TEXT_WHITE

    local BtnClose = Instance.new("TextButton", Header)
    BtnClose.Name = "BtnClose"
    BtnClose.Size = UDim2.new(0,24,0,24); BtnClose.Position = UDim2.new(1,-34,0.5,-12)
    BtnClose.BackgroundColor3 = THEME.DANGER_RED; BtnClose.Text = "X"; BtnClose.Font = Enum.Font.GothamBold
    BtnClose.TextSize = 13; BtnClose.TextColor3 = Color3.new(1,1,1); BtnClose.BorderSizePixel = 0
    corner(BtnClose, 6); stroke(BtnClose, 1, Color3.fromRGB(255,0,0), 0.1)
    BtnClose.MouseButton1Click:Connect(function() Window.Visible = false; getgenv().UFO_ISOPEN = false end)

    -- Drag Window (บล็อกกล้องระหว่างลาก)
    do
        local dragging, start, startPos
        local function bindBlock(on)
            local name="UFO_BlockLook_Window"
            if on then
                local fn=function() return Enum.ContextActionResult.Sink end
                CAS:BindActionAtPriority(name, fn, false, 9000,
                    Enum.UserInputType.MouseMovement, Enum.UserInputType.Touch, Enum.UserInputType.MouseButton1)
            else
                pcall(function() CAS:UnbindAction(name) end)
            end
        end
        Header.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                dragging=true; start=i.Position; startPos=Window.Position; bindBlock(true)
                i.Changed:Connect(function()
                    if i.UserInputState==Enum.UserInputState.End then dragging=false; bindBlock(false) end
                end)
            end
        end)
        UIS.InputChanged:Connect(function(i)
            if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
                local d=i.Position-start
                Window.Position=UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X, startPos.Y.Scale, startPos.Y.Offset+d.Y)
            end
        end)
    end

    -- BODY
    local Body = Instance.new("Frame", Window)
    Body.Name = "Body"
    Body.BackgroundTransparency = 1; Body.Position = UDim2.new(0,0,0,SIZE.HEADER_H); Body.Size = UDim2.new(1,0,1,-SIZE.HEADER_H)

    local Inner = Instance.new("Frame", Body)
    Inner.Name = "Inner"
    Inner.BackgroundColor3 = THEME.BG_INNER; Inner.BorderSizePixel = 0
    Inner.Position = UDim2.new(0,8,0,8); Inner.Size = UDim2.new(1,-16,1,-16); corner(Inner, 12)

    local Content = Instance.new("Frame", Body)
    Content.Name = "Content"
    Content.BackgroundColor3 = THEME.BG_PANEL; Content.Position = UDim2.new(0,SIZE.GAP_OUTER,0,SIZE.GAP_OUTER)
    Content.Size = UDim2.new(1,-SIZE.GAP_OUTER*2,1,-SIZE.GAP_OUTER*2); corner(Content, 12); stroke(Content, 0.8, THEME.MINT, 0.28)
    local padC = Instance.new("UIPadding", Content)
    padC.PaddingTop = UDim.new(0,8); padC.PaddingLeft = UDim.new(0,8); padC.PaddingRight = UDim.new(0,8); padC.PaddingBottom = UDim.new(0,8)

    local Columns = Instance.new("Frame", Content)
    Columns.Name = "Columns"; Columns.BackgroundTransparency = 1
    Columns.Position = UDim2.new(0,8,0,8); Columns.Size = UDim2.new(1,-16,1,-16)

    -- LEFT (แท็บ) - Scrolling
    local Left = Instance.new("ScrollingFrame", Columns)
    Left.Name = "Left"
    Left.BackgroundColor3 = THEME.BG_INNER
    Left.Size = UDim2.new(SIZE.LEFT_RATIO, -SIZE.GAP_BETWEEN/2, 1, 0)
    Left.ScrollBarThickness = 3; Left.CanvasSize = UDim2.new()
    Left.ClipsDescendants = true
    corner(Left, 10); stroke(Left, 1.1, THEME.GREEN, 0.08); stroke(Left, 0.6, THEME.MINT, 0.28)
    local padL = Instance.new("UIPadding", Left)
    padL.PaddingTop = UDim.new(0,8); padL.PaddingLeft = UDim.new(0,8); padL.PaddingRight = UDim.new(0,8); padL.PaddingBottom = UDim.new(0,8)
    local listL = Instance.new("UIListLayout", Left)
    listL.Padding = UDim.new(0,8); listL.SortOrder = Enum.SortOrder.LayoutOrder
    listL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Left.CanvasSize = UDim2.new(0,0,0, listL.AbsoluteContentSize.Y + 12)
    end)

    -- RIGHT (เนื้อหา) - Scrolling
    local Right = Instance.new("ScrollingFrame", Columns)
    Right.Name = "Right"
    Right.BackgroundColor3 = THEME.BG_INNER
    Right.Position = UDim2.new(SIZE.LEFT_RATIO, SIZE.GAP_BETWEEN, 0, 0)
    Right.Size = UDim2.new(SIZE.RIGHT_RATIO, -SIZE.GAP_BETWEEN/2, 1, 0)
    Right.ScrollBarThickness = 4; Right.ClipsDescendants = true
    Right.CanvasSize = UDim2.new()
    corner(Right, 10); stroke(Right, 1.1, THEME.GREEN, 0.08); stroke(Right, 0.6, THEME.MINT, 0.28)
    local padR = Instance.new("UIPadding", Right)
    padR.PaddingTop = UDim.new(0,8); padR.PaddingLeft = UDim.new(0,8); padR.PaddingRight = UDim.new(0,8); padR.PaddingBottom = UDim.new(0,8)

    local PageHost = Instance.new("Frame", Right)
    PageHost.Name = "PageHost"; PageHost.BackgroundTransparency = 1; PageHost.Size = UDim2.new(1, -12, 1, -12)
    PageHost.Position = UDim2.new(0,6,0,6)
    local layPages = Instance.new("UIListLayout", PageHost)
    layPages.Padding = UDim.new(0,0)
    layPages:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Right.CanvasSize = UDim2.new(0,0,0, layPages.AbsoluteContentSize.Y + 12)
    end)

    -- UFO + Halo ที่หัว
    do
        local UFO = Instance.new("ImageLabel", Window)
        UFO.Name = "UFO_Top"; UFO.BackgroundTransparency = 1; UFO.Image = IMGS.UFO
        UFO.Size = UDim2.new(0,168,0,168); UFO.AnchorPoint = Vector2.new(0.5,1)
        UFO.Position = UDim2.new(0.5, 0, 0, 84); UFO.ZIndex = 60

        local Halo = Instance.new("ImageLabel", Window)
        Halo.BackgroundTransparency = 1; Halo.AnchorPoint = Vector2.new(0.5,0)
        Halo.Position = UDim2.new(0.5,0,0,0); Halo.Size = UDim2.new(0, 200, 0, 60)
        Halo.Image = IMGS.GLOW; Halo.ImageColor3 = THEME.MINT_SOFT; Halo.ImageTransparency = 0.72; Halo.ZIndex = 50
    end

    -- ปุ่ม Toggle เปิด/ปิด + ลากได้ + RightShift
    do
        local function findMain()
            local gui = CoreGui:FindFirstChild("UFO_HUB_X_UI")
            local win
            if gui then win = gui:FindFirstChild("Window") end
            return gui, win
        end
        local function showUI() local gui, win = findMain(); if gui then gui.Enabled = true end; if win then win.Visible = true end; getgenv().UFO_ISOPEN = true end
        local function hideUI() local gui, win = findMain(); if win then win.Visible = false end; getgenv().UFO_ISOPEN = false end
        do local _, win = findMain(); getgenv().UFO_ISOPEN = (win and win.Visible) and true or false end

        local toggleGui = CoreGui:FindFirstChild("UFO_HUB_X_Toggle"); if toggleGui then toggleGui:Destroy() end
        local ToggleGui = Instance.new("ScreenGui", CoreGui)
        ToggleGui.Name = "UFO_HUB_X_Toggle"; ToggleGui.IgnoreGuiInset = true

        local ToggleBtn = Instance.new("ImageButton", ToggleGui)
        ToggleBtn.Name = "ToggleBtn"
        ToggleBtn.Size = UDim2.fromOffset(64,64); ToggleBtn.Position = UDim2.fromOffset(80,200)
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(0,0,0); ToggleBtn.BorderSizePixel = 0; ToggleBtn.Image = IMGS.TOGGLE
        corner(ToggleBtn, 8); stroke(ToggleBtn, 2, THEME.GREEN, 0)

        local function toggleUI() if getgenv().UFO_ISOPEN then hideUI() else showUI() end end
        ToggleBtn.MouseButton1Click:Connect(toggleUI)
        UIS.InputBegan:Connect(function(i,gp) if gp then return end if i.KeyCode==Enum.KeyCode.RightShift then toggleUI() end end)

        local dragging=false; local start; local startPos
        local function bindBlock(on)
            local name="UFO_BlockLook_Toggle"
            if on then
                local fn=function() return Enum.ContextActionResult.Sink end
                CAS:BindActionAtPriority(name, fn, false, 9000,
                    Enum.UserInputType.MouseMovement, Enum.UserInputType.Touch, Enum.UserInputType.MouseButton1)
            else pcall(function() CAS:UnbindAction(name) end) end
        end
        ToggleBtn.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                dragging=true; start=i.Position
                startPos=Vector2.new(ToggleBtn.Position.X.Offset, ToggleBtn.Position.Y.Offset)
                bindBlock(true)
                i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then dragging=false; bindBlock(false) end end)
            end
        end)
        UIS.InputChanged:Connect(function(i)
            if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
                local d=i.Position-start
                ToggleBtn.Position=UDim2.fromOffset(startPos.X+d.X,startPos.Y+d.Y)
            end
        end)
    end

    return GUI
end

-- แสดง UI เลย
local _GUI = buildUIMain()

--======================================================
-- UFOPro API (แท็บ/เซคชัน/ปุ่ม/เลเบล)
--======================================================
local UFOPro = { _version = "1.0-stable" }
UFOPro.__index = UFOPro
getgenv().UFOPro = UFOPro -- เผื่ออยากเรียกจากสคริปต์อื่น

local function findContainers()
    local gui = CoreGui:FindFirstChild("UFO_HUB_X_UI")
    if not gui then return end
    local win   = gui:FindFirstChild("Window")
    local body  = win and win:FindFirstChild("Body")
    local cont  = body and body:FindFirstChild("Content")
    local cols  = cont and cont:FindFirstChild("Columns")
    local left  = cols and cols:FindFirstChild("Left")   -- ScrollingFrame
    local right = cols and cols:FindFirstChild("Right")  -- ScrollingFrame
    local host  = right and right:FindFirstChild("PageHost")
    return gui, win, left, right, host
end

-- ปุ่มแท็บซ้าย
local function makeSideButton(parent, text, active)
    local b = Instance.new("TextButton")
    b.Name = "Tab_"..text; b.AutoButtonColor = false
    b.Size = UDim2.new(1,0,0,30)
    b.BackgroundColor3 = active and THEME.BTN_ACTIVE or THEME.BTN_IDLE
    b.Text = "· "..text; b.Font = Enum.Font.GothamSemibold; b.TextSize = 14
    b.TextColor3 = active and Color3.fromRGB(230,255,240) or THEME.TEXT_DIM
    b.Parent = parent; corner(b, 10); stroke(b, 1, THEME.MINT, 0.22)
    b.MouseEnter:Connect(function() if not active then b.BackgroundColor3 = THEME.BTN_HOVER end end)
    b.MouseLeave:Connect(function() if not active then b.BackgroundColor3 = THEME.BTN_IDLE end end)
    return b
end

-- เพจเนื้อหาขวา + สกรอลล์ภายในเพจ
local function makePage(parent, name)
    local page = Instance.new("Frame", parent)
    page.Name = "Page_"..name
    page.BackgroundTransparency = 1
    page.Size = UDim2.new(1,0,1,0)
    page.Visible = false

    local sf = Instance.new("ScrollingFrame", page)
    sf.Name = "Scroll"; sf.BackgroundTransparency = 1
    sf.Size = UDim2.new(1,0,1,0)
    sf.ScrollBarThickness = 4; sf.CanvasSize = UDim2.new()

    local lay = Instance.new("UIListLayout", sf)
    lay.Padding = UDim.new(0,10); lay.SortOrder = Enum.SortOrder.LayoutOrder
    lay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        sf.CanvasSize = UDim2.new(0,0,0, lay.AbsoluteContentSize.Y + 12)
    end)

    return page, sf
end

-- สร้างการ์ด Section
local function makeSectionCard(parent, title)
    local holder = Instance.new("Frame", parent)
    holder.Size = UDim2.new(1,0,0,56)
    holder.BackgroundColor3 = THEME.CARD_FILL
    holder.BorderSizePixel = 0
    corner(holder, 10); stroke(holder, 1, THEME.CARD_STROKE, 0.18)

    local inner = Instance.new("Frame", holder)
    inner.BackgroundTransparency = 1
    inner.Size = UDim2.new(1,-20,1,-14)
    inner.Position = UDim2.new(0,10,0,7)

    local h = Instance.new("UIListLayout", inner)
    h.FillDirection = Enum.FillDirection.Horizontal
    h.VerticalAlignment = Enum.VerticalAlignment.Center
    h.Padding = UDim.new(0,10)

    local dot = Instance.new("Frame", inner)
    dot.Size = UDim2.fromOffset(8,8)
    dot.BackgroundColor3 = Color3.fromRGB(86,168,255)
    dot.BorderSizePixel = 0
    corner(dot, 8)

    local lab = Instance.new("TextLabel", inner)
    lab.BackgroundTransparency = 1
    lab.Size = UDim2.new(1, -18, 1, 0)
    lab.Font = Enum.Font.GothamSemibold
    lab.TextSize = 16
    lab.TextXAlignment = Enum.TextXAlignment.Left
    lab.TextColor3 = THEME.TEXT_WHITE
    lab.Text = title or "Section"

    -- คอนเทนต์จริงของ section (เรียงเป็นคอลัมน์)
    local content = Instance.new("Frame", parent)
    content.BackgroundTransparency = 1
    content.Size = UDim2.new(1,0,0,0)

    local v = Instance.new("UIListLayout", content)
    v.Padding = UDim.new(0,6); v.SortOrder = Enum.SortOrder.LayoutOrder

    -- ทำให้กรุ๊ป (หัว+คอนเทนต์) เกาะกัน
    holder.LayoutOrder = 0
    content.LayoutOrder = 1

    -- ตัวช่วยสร้างปุ่ม/เลเบล
    local api = {}

    function api:NewButton(text, info, callback)
        local btn = Instance.new("TextButton", content)
        btn.AutoButtonColor = false
        btn.Size = UDim2.new(1,0,0,30)
        btn.BackgroundColor3 = THEME.BTN_IDLE
        btn.Text = text or "Button"
        btn.Font = Enum.Font.GothamSemibold
        btn.TextSize = 14
        btn.TextColor3 = THEME.TEXT_WHITE
        corner(btn, 8); stroke(btn, 1, THEME.MINT, 0.20)

        btn.MouseEnter:Connect(function() btn.BackgroundColor3 = THEME.BTN_HOVER end)
        btn.MouseLeave:Connect(function() btn.BackgroundColor3 = THEME.BTN_IDLE end)
        btn.MouseButton1Click:Connect(function()
            pcall(callback or function() end)
        end)
        return btn
    end

    function api:NewLabel(text)
        local l = Instance.new("TextLabel", content)
        l.BackgroundTransparency = 1
        l.Size = UDim2.new(1,0,0,24)
        l.Font = Enum.Font.Gotham
        l.TextSize = 14
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.TextColor3 = THEME.TEXT_WHITE
        l.Text = text or "Label"
        function l:UpdateLabel(newText) l.Text = tostring(newText) end
        return l
    end

    -- resize ให้ content มีความสูงพอดีกับลูก ๆ
    local function syncHeight()
        local total = 0
        for _,o in ipairs(content:GetChildren()) do
            if o:IsA("GuiObject") then total = total + o.AbsoluteSize.Y + 6 end
        end
        content.Size = UDim2.new(1,0,0,total)
    end
    content.ChildAdded:Connect(syncHeight)
    content.ChildRemoved:Connect(syncHeight)

    return api
end

-- ---------- PUBLIC ----------
function UFOPro.CreateLib(title)
    if not CoreGui:FindFirstChild("UFO_HUB_X_UI") then buildUIMain() end
    local gui = CoreGui:FindFirstChild("UFO_HUB_X_UI")
    local win   = gui.Window
    local left  = gui.Window.Body.Content.Columns.Left
    local host  = gui.Window.Body.Content.Columns.Right:FindFirstChild("PageHost")

    assert(win and left and host, "[UFOPro] UI containers not found")

    -- ตั้งหัว
    local label = win.Header:FindFirstChild("TitleCenter")
    if label then
        label.Text = string.format('<font color="#FFFFFF">%s</font> <font color="#00FF8C">HUB X</font>', title or "UFO")
    end

    local api = { _gui=gui, _win=win, _left=left, _host=host, _pages={}, _activeBtn=nil }

    function api:ToggleUI()
        self._win.Visible = not self._win.Visible
        getgenv().UFO_ISOPEN = self._win.Visible
    end

    function api:NewTab(name)
        name = tostring(name or "Tab")
        local isFirst = (self._activeBtn == nil)

        -- ปุ่มแท็บซ้าย + เพจขวา
        local btn = makeSideButton(self._left, name, isFirst)
        local page, scroll = makePage(self._host, name)
        self._pages[name] = {root=page, scroll=scroll, btn=btn}

        -- สลับหน้า
        local function activate()
            for _,t in pairs(self._pages) do
                t.root.Visible = false
                t.btn.BackgroundColor3 = THEME.BTN_IDLE
                t.btn.TextColor3 = THEME.TEXT_DIM
            end
            page.Visible = true
            btn.BackgroundColor3 = THEME.BTN_ACTIVE
            btn.TextColor3 = Color3.fromRGB(230,255,240)
            self._activeBtn = btn
        end
        btn.MouseButton1Click:Connect(activate)
        if isFirst then activate() end

        -- API ในแท็บ: Section
        local tabAPI = {}
        function tabAPI:NewSection(title)
            return makeSectionCard(scroll, title or "Section")
        end
        return tabAPI
    end

    return api
end

--======================================================
-- DEMO: ทำให้เห็นปุ่มขึ้นทันที (ลบส่วนนี้ได้ถ้าไม่ต้องการ)
--======================================================
local UI = UFOPro.CreateLib("UFO")
local mainTab = UI:NewTab("Main")
local mainTab = UI:NewTab("Main")
local mainTab = UI:NewTab("Main")
local mainTab = UI:NewTab("Main")
local mainTab = UI:NewTab("Main")
local mainTab = UI:NewTab("Main")
local mainTab = UI:NewTab("Main")
local mainTab = UI:NewTab("Main")
local mainTab = UI:NewTab("Main")
local mainTab = UI:NewTab("Main")
local mainTab = UI:NewTab("Main")
local sec = mainTab:NewSection("Actions")
local sec = mainTab:NewSection("Actio8ns")
local sec = mainTab:NewSection("Actio4ns")
local sec = mainTab:NewSection("Acti3ons")
local sec = mainTab:NewSection("Action00s")
local sec = mainTab:NewSection("Acti2ons")
local sec = mainTab:NewSection("Actio88ns")
local sec = mainTab:NewSection("Acti55ons")
local sec = mainTab:NewSection("Acti66ons")
local sec = mainTab:NewSection("Action66s")
local sec = mainTab:NewSection("Actio665ns")
local sec = mainTab:NewSection("Act566ions")
sec:NewLabel("Status: Ready")
sec:NewButton("Say Hello", "Print to console", function() print("[UFO HUB X] Hello!") end)
sec:NewButton("Toggle UI (RightShift)", "Show/Hide", function() UI:ToggleUI() end)

print("[UFO HUB X UI Pro] Loaded OK.")
