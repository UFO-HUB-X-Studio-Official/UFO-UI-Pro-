--======================================================
-- UFO HUB X UI Pro | Scrollable Edition (All-in-One)
-- - UI เหมือนเดิม 100% + เลื่อนซ้าย/ขวาได้
-- - ปรับง่าย: สี/ขนาด/สัดส่วน อยู่ด้านบน
-- - API สไตล์ Kavo: CreateLib -> NewTab -> NewSection -> NewButton/Label
-- - ใช้ได้ทั้งรันตรง ๆ และ loadstring(game:HttpGet("..."))()
--======================================================

-- 0) ล้างของเดิม
pcall(function()
    local cg = game:GetService("CoreGui")
    for _,n in ipairs({"UFO_HUB_X_UI","UFO_HUB_X_Toggle"}) do
        local g = cg:FindFirstChild(n)
        if g then g:Destroy() end
    end
end)

-- 1) CONFIG ง่าย ๆ (แก้แค่ตรงนี้ได้ 90%)
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
}

-- ขนาดและสัดส่วน (ถ้าดูใหญ่/เล็กไป ปรับ WIN_W, WIN_H หรือสัดส่วนซ้าย/ขวา)
local SIZE = {
    WIN_W = 560, WIN_H = 320,      -- ขนาดหน้าต่างพื้นฐาน
    GAP_OUTER = 12, GAP_BETWEEN = 10,
    LEFT_RATIO = 0.24, RIGHT_RATIO = 0.76,
    HEADER_H = 46
}

-- รูปภาพตกแต่ง (เปลี่ยนได้)
local IMGS = {
    SMALL = "rbxassetid://121069267171370",
    LARGE = "rbxassetid://108408843188558",
    UFO   = "rbxassetid://100650447103028",
    GLOW  = "rbxassetid://5028857084",
    TOGGLE= "rbxassetid://117052960049460",
}

-- 2) HELPERS
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

-- 3) Services
local CoreGui = game:GetService("CoreGui")
local UIS     = game:GetService("UserInputService")
local RunS    = game:GetService("RunService")
local CAS     = game:GetService("ContextActionService")

--======================================================
-- 4) สร้าง UI หลัก (เหมือนดีไซน์เดิม 100%) + Scroll ทั้งสองฝั่ง
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

    -- Autoscale (รองรับมือถือ/PC ทุกจอ)
    local UIScale = Instance.new("UIScale", Window)
    local function fit()
        local v = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280,720)
        UIScale.Scale = math.clamp(math.min(v.X/920, v.Y/580), 0.64, 1.0)
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

    -- LEFT: แท็บ (Scrolling)
    local Left = Instance.new("ScrollingFrame", Columns)
    Left.Name = "Left"
    Left.BackgroundColor3 = THEME.BG_INNER
    Left.Size = UDim2.new(SIZE.LEFT_RATIO, -SIZE.GAP_BETWEEN/2, 1, 0)
    Left.ScrollBarThickness = 3; Left.CanvasSize = UDim2.new()
    Left.AutomaticCanvasSize = Enum.AutomaticSize.None -- เราจะคุมเองด้วย Layout
    Left.ClipsDescendants = true
    corner(Left, 10); stroke(Left, 1.1, THEME.GREEN, 0.08); stroke(Left, 0.6, THEME.MINT, 0.28)
    local padL = Instance.new("UIPadding", Left)
    padL.PaddingTop = UDim.new(0,8); padL.PaddingLeft = UDim.new(0,8); padL.PaddingRight = UDim.new(0,8); padL.PaddingBottom = UDim.new(0,8)
    local listL = Instance.new("UIListLayout", Left)
    listL.Padding = UDim.new(0,8); listL.SortOrder = Enum.SortOrder.LayoutOrder
    listL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Left.CanvasSize = UDim2.new(0,0,0, listL.AbsoluteContentSize.Y + 12)
    end)

    -- RIGHT: เนื้อหา (Scrolling)
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

    -- โฮสต์เพจจริง (ขวาด้านใน) -> จะสลับ Page ให้โชว์แค่หน้าเดียว
    local PageHost = Instance.new("Frame", Right)
    PageHost.Name = "PageHost"; PageHost.BackgroundTransparency = 1; PageHost.Size = UDim2.new(1, -12, 1, -12)
    PageHost.Position = UDim2.new(0,6,0,6)
    local layPages = Instance.new("UIListLayout", PageHost) -- ใช้เพื่อคำนวณ CanvasSize
    layPages.Padding = UDim.new(0,0)
    layPages:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Right.CanvasSize = UDim2.new(0,0,0, layPages.AbsoluteContentSize.Y + 12)
    end)

    -- พรีวิวรูป (ถ้าไม่ชอบ ลบ 5 บรรทัดนี้ได้)
    local imgR = Instance.new("ImageLabel", PageHost)
    imgR.BackgroundTransparency = 1; imgR.Size = UDim2.new(1,0,0,1); imgR.Visible = false

    -- UFO + Halo ตกแต่งหัว
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

    -- RECOVERY / TOGGLE ปุ่มเปิด-ปิด + ลากได้
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
        corner(ToggleBtn, 8); local s = stroke(ToggleBtn, 2, THEME.GREEN, 0)

        local function toggleUI() if getgenv().UFO_ISOPEN then hideUI() else showUI() end end
        ToggleBtn.MouseButton1Click:Connect(toggleUI)
        UIS.InputBegan:Connect(function(i,gp) if gp then return end if i.KeyCode==Enum.KeyCode.RightShift then toggleUI() end end)

        -- Drag ToggleBtn
        do
            local dragging=false; local start; local startPos
            local function bindBlock(on)
                local name="UFO_BlockLook_Toggle"
                if on then
                    local fn=function() return Enum.ContextActionResult.Sink end
                    CAS:BindActionAtPriority(name, fn, false, 9000,
                        Enum.UserInputType.MouseMovement, Enum.UserInputType.Touch, Enum.UserInputType.MouseButton1)
                else
                    pcall(function() CAS:UnbindAction(name) end)
                end
            end
            ToggleBtn.InputBegan:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                    dragging=true; start=i.Position
                    startPos=Vector2.new(ToggleBtn.Position.X.Offset, ToggleBtn.Position.Y.Offset)
                    bindBlock(true)
                    i.Changed:Connect(function()
                        if i.UserInputState==Enum.UserInputState.End then dragging=false; bindBlock(false) end
                    end)
                end
            end)
            UIS.InputChanged:Connect(function(i)
                if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
                    local d=i.Position-start
                    ToggleBtn.Position=UDim2.fromOffset(startPos.X+d.X,startPos.Y+d.Y)
                end
            end)
        end
    end

    return GUI
end

-- สร้าง UI ให้แสดงทันที
local _GUI = buildUIMain()

--======================================================
-- 5) UFOPro API (สไตล์ Kavo)
--======================================================
local UFOPro = { _version = "1.0-scroll" }
UFOPro.__index = UFOPro

-- จับ containers (ซ้าย/ขวา)
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
    b.TextColor3 = active and Color3.fromRGB(230,255,240) or Color3.fromRGB(180,190,200)
    b.Parent = parent; corner(b, 10); stroke(b, 1, THEME.MINT, 0.22)
    b.MouseEnter:Connect(function() if not active then b.BackgroundColor3 = THEME.BTN_HOVER end end)
    b.MouseLeave:Connect(function() if not active then b.BackgroundColor3 = THEME.BTN_IDLE end end)
    return b
end

-- เพจเนื้อหา (ด้านขวา) แต่จะจัดการโชว์/ซ่อนไว้เอง
local function makePage(parent, name)
    local page = Instance.new("Frame", parent)
    page.Name = "Page_"..name
    page.BackgroundTransparency = 1
    page.Size = UDim2.new(1,0,1,0)
    page.Visible = false

    -- คุมรายการภายในด้วย ScrollingFrame ย่อย (จะทำให้ส่วนขวาเลื่อนรวม + ภายในจัดแนวสวย)
    local sf = Instance.new("ScrollingFrame", page)
    sf.Name = "Scroll"; sf.BackgroundTransparency = 1
    sf.Size = UDim2.new(1,0,1,0); sf.Position = UDim2.new(0,0,0,0)
    sf.ScrollBarThickness = 4; sf.CanvasSize = UDim2.new()
    local lay = Instance.new("UIListLayout", sf)
    lay.Padding = UDim.new(0,10); lay.SortOrder = Enum.SortOrder.LayoutOrder
    lay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        sf.CanvasSize = UDim2.new(0,0,0, lay.AbsoluteContentSize.Y + 12)
    end)

    return page, sf
end

-- PUBLIC
function UFOPro.CreateLib(title, theme)
    if not CoreGui:FindFirstChild("UFO_HUB_X_UI") then buildUIMain() end
    local gui, win, left, right, host = findContainers()
    assert(gui and win and left and right and host, "[UFOPro] UI containers not found")

    -- ตั้งชื่อหัว
    do
        local header = win:FindFirstChild("Header")
        local label = header and header:FindFirstChild("TitleCenter")
        if label then
            label.Text = string.format('<font color="#FFFFFF">%s</font> <font color="#00FF8C">HUB X</font>', title or "UFO")
        end
    end

    local api = { _gui=gui, _win=win, _left=left, _host=host, _pages={}, _activeBtn=nil }

    function api:ToggleUI()
        self._win.Visible = not self._win.Visible
        getgenv().UFO_ISOPEN = self._win.Visible
    end

    function api:NewTab(name)
        name = tostring(name or "Tab")
        local isFirst = (self._activeBtn == nil)

        local btn = makeSideButton(self._left, name, isFirst)
        local page, scroll = makePage(self._host, name)
        self._pages[name] = {root=page, scroll=scroll, btn=btn}

        local function activate()
            for _,t in pairs(self._pages) do
                t.root.Visible = false
                t.btn.BackgroundColor3 = THEME.BTN_IDLE
                t.btn.TextColor3 = Color3.fromRGB(180,190,200)
            end
            page.Visible = true
            btn.BackgroundColor3 = THEME.BTN_ACTIVE
            btn.TextColor3 = Color3.fromRGB(230,255,240)
            self._activeBtn = btn
        end
        btn.MouseButton1Click:Connect(activate)
        if isFirst then activate() end

        -- Section API
        local tabAPI = {}

        function tabAPI:NewSection(title)
            title = tostring(title or "Section")
            local holder = Instance.new("Frame", scroll)
            holder.Size = UDim2.new(1,0,0,52)
            holder.BackgroundColor3 = THEME.CARD_FILL
            holder.BorderSizePixel = 0
            corner(holder, 10); stroke(holder, 1, THEME.CARD_STROKE, 0.18)

            -- header line
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
            lab.Size = UDim2.new(1, -28, 1, 0)
            lab.Font = Enum.Font.GothamSemibold
            lab.TextSize = 15
            lab.TextXAlignment = Enum.TextXAlignment.Left
            lab.TextColor3 = Color3.fromRGB(220,230,235)
            lab.RichText = true
            lab.Text = tostring(title)

            -- ====== Section API ======
            local secAPI = {}

            function secAPI:UpdateSection(newTitle)
                lab.Text = tostring(newTitle or title)
            end

            function secAPI:NewLabel(text)
                local k = Instance.new("TextLabel", holder)
                k.BackgroundColor3 = THEME.BTN_IDLE
                k.TextColor3 = Color3.fromRGB(208,220,215)
                k.Text = tostring(text or "Label")
                k.Font = Enum.Font.Gotham
                k.TextSize = 14
                k.Size = UDim2.new(1,-20,0,30)
                k.Position = UDim2.new(0,10,0,holder.AbsoluteSize.Y + 8)
                k.TextXAlignment = Enum.TextXAlignment.Center
                corner(k,8)
                stroke(k,1,THEME.MINT,0.18)

                return {
                    UpdateLabel = function(_, newText)
                        k.Text = tostring(newText or "")
                    end
                }
            end

            function secAPI:NewButton(text, info, callback)
                local b = Instance.new("TextButton", holder)
                b.AutoButtonColor = false
                b.BackgroundColor3 = THEME.BTN_IDLE
                b.TextColor3 = Color3.fromRGB(232,242,238)
                b.Text = tostring(text or "Button")
                b.Font = Enum.Font.GothamSemibold
                b.TextSize = 14
                b.Size = UDim2.new(1,-20,0,30)
                b.Position = UDim2.new(0,10,0,holder.AbsoluteSize.Y + 8)
                corner(b,10)
                stroke(b,1,THEME.MINT,0.22)

                b.MouseEnter:Connect(function()
                    b.BackgroundColor3 = THEME.BTN_HOVER
                end)
                b.MouseLeave:Connect(function()
                    b.BackgroundColor3 = THEME.BTN_IDLE
                end)
                b.MouseButton1Click:Connect(function()
                    if typeof(callback) == "function" then
                        pcall(callback)
                    end
                end)

                return {
                    UpdateButton = function(_, newText)
                        b.Text = tostring(newText or "")
                    end
                }
            end

            return secAPI
        end -- /NewSection

        return tabAPI
    end -- /NewTab

    return api
end -- /CreateLib
