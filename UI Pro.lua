--==[ UFO HUB X UI Pro | ALL-IN-ONE (Main UI + Adapter API) ]==--
-- 1) สร้าง UI ที่นายชอบ (เหมือนเดิม 100%)
-- 2) เปิด API แบบ Kavo-สไตล์ของเราเอง ผ่านโมดูลชื่อ: UFOPro
-- 3) รองรับทั้งรันตรง ๆ และโหลดผ่าน: local UFOPro = loadstring(game:HttpGet("..."))()

-- เคลียร์เก่าถ้ามี
pcall(function()
    local cg = game:GetService("CoreGui")
    for _,n in ipairs({"UFO_HUB_X_UI","UFO_HUB_X_Toggle"}) do
        local g = cg:FindFirstChild(n)
        if g then g:Destroy() end
    end
end)

--=========== THEME ===========
local GREEN        = Color3.fromRGB(0,255,140)
local MINT         = Color3.fromRGB(120,255,220)
local MINT_SOFT    = Color3.fromRGB(90,210,190)
local BG_WINDOW    = Color3.fromRGB(16,16,16)
local BG_HEADER    = Color3.fromRGB(6,6,6)
local BG_PANEL     = Color3.fromRGB(22,22,22)
local BG_INNER     = Color3.fromRGB(18,18,18)
local TEXT_WHITE   = Color3.fromRGB(235,235,235)
local DANGER_RED   = Color3.fromRGB(200,40,40)

--=========== SIZE ===========
local WIN_W, WIN_H = 640, 360
local GAP_OUTER    = 14
local GAP_BETWEEN  = 12
local LEFT_RATIO   = 0.22
local RIGHT_RATIO  = 0.78

--=========== IMAGES ===========
local IMG_SMALL = "rbxassetid://121069267171370"
local IMG_LARGE = "rbxassetid://108408843188558"
local IMG_UFO   = "rbxassetid://100650447103028"

--=========== HELPERS ===========
local function corner(gui, r)
    local c = Instance.new("UICorner", gui); c.CornerRadius = UDim.new(0, r or 10); return c
end
local function stroke(gui, t, col, trans)
    local s = Instance.new("UIStroke", gui)
    s.Thickness, s.Color, s.Transparency = t or 1, col or MINT, trans or 0.35
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; s.LineJoinMode = Enum.LineJoinMode.Round
    return s
end
local function gradient(gui, c1, c2, rot)
    local g = Instance.new("UIGradient", gui); g.Color = ColorSequence.new(c1, c2); g.Rotation = rot or 0; return g
end

--=========== ROOT ===========
local CoreGui = game:GetService("CoreGui")
local UIS     = game:GetService("UserInputService")
local RunS    = game:GetService("RunService")
local CAS     = game:GetService("ContextActionService")

--=========== BUILD UI (เหมือนเดิม 100%) ===========
local function buildUIMain()
    if CoreGui:FindFirstChild("UFO_HUB_X_UI") then return CoreGui.UFO_HUB_X_UI end

    local GUI = Instance.new("ScreenGui")
    GUI.Name = "UFO_HUB_X_UI"; GUI.IgnoreGuiInset = true; GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    GUI.ResetOnSpawn = false; GUI.Parent = CoreGui

    -- WINDOW
    local Window = Instance.new("Frame", GUI)
    Window.Name = "Window"
    Window.AnchorPoint = Vector2.new(0.5,0.5); Window.Position = UDim2.new(0.5,0,0.5,0)
    Window.Size = UDim2.fromOffset(WIN_W, WIN_H); Window.BackgroundColor3 = BG_WINDOW; Window.BorderSizePixel = 0
    corner(Window, 12); stroke(Window, 3, GREEN, 0)

    -- glow
    do
        local Glow = Instance.new("ImageLabel", Window)
        Glow.BackgroundTransparency = 1; Glow.AnchorPoint = Vector2.new(0.5,0.5)
        Glow.Position = UDim2.new(0.5,0,0.5,0); Glow.Size = UDim2.new(1.07,0,1.09,0)
        Glow.Image = "rbxassetid://5028857084"; Glow.ImageColor3 = GREEN; Glow.ImageTransparency = 0.78
        Glow.ScaleType = Enum.ScaleType.Slice; Glow.SliceCenter = Rect.new(24,24,276,276); Glow.ZIndex = 0
    end

    -- autoscale
    local UIScale = Instance.new("UIScale", Window)
    local function fit()
        local v = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280,720)
        UIScale.Scale = math.clamp(math.min(v.X/860, v.Y/540), 0.72, 1.0)
    end
    fit(); RunS.RenderStepped:Connect(fit)

    -- HEADER
    local Header = Instance.new("Frame", Window)
    Header.Name = "Header"
    Header.Size = UDim2.new(1,0,0,46); Header.BackgroundColor3 = BG_HEADER; Header.BorderSizePixel = 0
    corner(Header, 12); gradient(Header, Color3.fromRGB(10,10,10), Color3.fromRGB(0,0,0), 0)

    local HeadAccent = Instance.new("Frame", Header)
    HeadAccent.AnchorPoint = Vector2.new(0.5,1); HeadAccent.Position = UDim2.new(0.5,0,1,0)
    HeadAccent.Size = UDim2.new(1,-20,0,1); HeadAccent.BackgroundColor3 = MINT; HeadAccent.BackgroundTransparency = 0.35
    HeadAccent.BorderSizePixel = 0

    local Dot = Instance.new("Frame", Header)
    Dot.BackgroundColor3 = MINT; Dot.Position = UDim2.new(0,14,0.5,-4); Dot.Size = UDim2.new(0,8,0,8)
    Dot.BorderSizePixel = 0; corner(Dot, 4)

    local BtnClose = Instance.new("TextButton", Header)
    BtnClose.Name = "BtnClose"
    BtnClose.Size = UDim2.new(0,24,0,24); BtnClose.Position = UDim2.new(1,-34,0.5,-12)
    BtnClose.BackgroundColor3 = DANGER_RED; BtnClose.Text = "X"; BtnClose.Font = Enum.Font.GothamBold
    BtnClose.TextSize = 13; BtnClose.TextColor3 = Color3.new(1,1,1); BtnClose.BorderSizePixel = 0
    corner(BtnClose, 6); stroke(BtnClose, 1, Color3.fromRGB(255,0,0), 0.1)

    -- ปุ่ม X ซ่อนเฉพาะ Window + sync flag
    BtnClose.MouseButton1Click:Connect(function()
        Window.Visible = false
        getgenv().UFO_ISOPEN = false
    end)

    -- drag (block camera look)
    do
        local dragging, start, startPos
        local function bindBlock(on)
            local name="UFO_BlockLook_Window"
            if on then
                local fn=function() return Enum.ContextActionResult.Sink end
                CAS:BindActionAtPriority(name, fn, false, 9000,
                    Enum.UserInputType.MouseMovement,
                    Enum.UserInputType.Touch,
                    Enum.UserInputType.MouseButton1)
            else
                pcall(function() CAS:UnbindAction(name) end)
            end
        end
        Header.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                dragging=true; start=i.Position; startPos=Window.Position
                bindBlock(true)
                i.Changed:Connect(function()
                    if i.UserInputState==Enum.UserInputState.End then
                        dragging=false; bindBlock(false)
                    end
                end)
            end
        end)
        UIS.InputChanged:Connect(function(i)
            if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
                local d=i.Position-start
                Window.Position=UDim2.new(
                    startPos.X.Scale, startPos.X.Offset+d.X,
                    startPos.Y.Scale, startPos.Y.Offset+d.Y
                )
            end
        end)
    end

    -- ===== UFO + TITLE =====
    do
        local UFO_Y_OFFSET   = 84
        local TITLE_Y_OFFSET = 8

        local UFO = Instance.new("ImageLabel", Window)
        UFO.Name = "UFO_Top"; UFO.BackgroundTransparency = 1; UFO.Image = IMG_UFO
        UFO.Size = UDim2.new(0,168,0,168)
        UFO.AnchorPoint = Vector2.new(0.5,1)
        UFO.Position = UDim2.new(0.5, 0, 0, UFO_Y_OFFSET)
        UFO.ZIndex = 60

        local Halo = Instance.new("ImageLabel", Window)
        Halo.BackgroundTransparency = 1; Halo.AnchorPoint = Vector2.new(0.5,0)
        Halo.Position = UDim2.new(0.5,0,0,0); Halo.Size = UDim2.new(0, 200, 0, 60)
        Halo.Image = "rbxassetid://5028857084"; Halo.ImageColor3 = MINT_SOFT; Halo.ImageTransparency = 0.72
        Halo.ZIndex = 50

        local TitleCenter = Instance.new("TextLabel", Header)
        TitleCenter.Name = "TitleCenter"
        TitleCenter.BackgroundTransparency = 1; TitleCenter.AnchorPoint = Vector2.new(0.5,0)
        TitleCenter.Position = UDim2.new(0.5, 0, 0, TITLE_Y_OFFSET)
        TitleCenter.Size = UDim2.new(0.8, 0, 0, 36)
        TitleCenter.Font = Enum.Font.GothamBold; TitleCenter.RichText = true; TitleCenter.TextScaled = true
        TitleCenter.Text = '<font color="#FFFFFF">UFO</font> <font color="#00FF8C">HUB X</font>'
        TitleCenter.TextColor3 = TEXT_WHITE; TitleCenter.ZIndex = 61
    end

    -- BODY
    local Body = Instance.new("Frame", Window)
    Body.Name = "Body"
    Body.BackgroundTransparency = 1; Body.Position = UDim2.new(0,0,0,46); Body.Size = UDim2.new(1,0,1,-46)

    local Inner = Instance.new("Frame", Body)
    Inner.Name = "Inner"
    Inner.BackgroundColor3 = BG_INNER; Inner.BorderSizePixel = 0
    Inner.Position = UDim2.new(0,8,0,8); Inner.Size = UDim2.new(1,-16,1,-16); corner(Inner, 12)

    local Content = Instance.new("Frame", Body)
    Content.Name = "Content"
    Content.BackgroundColor3 = BG_PANEL; Content.Position = UDim2.new(0,GAP_OUTER,0,GAP_OUTER)
    -- แก้บั๊ก: ใช้ GAP_OUTER*2 แทน GAP_OUTER2
    Content.Size = UDim2.new(1,-GAP_OUTER*2,1,-GAP_OUTER*2); corner(Content, 12); stroke(Content, 0.5, MINT, 0.35)

    local Columns = Instance.new("Frame", Content)
    Columns.Name = "Columns"
    Columns.BackgroundTransparency = 1; Columns.Position = UDim2.new(0,8,0,8); Columns.Size = UDim2.new(1,-16,1,-16)

    local Left = Instance.new("Frame", Columns)
    Left.Name = "Left"
    Left.BackgroundColor3 = Color3.fromRGB(16,16,16); Left.Size = UDim2.new(LEFT_RATIO, -GAP_BETWEEN/2, 1, 0)
    Left.ClipsDescendants = true; corner(Left, 10); stroke(Left, 1.2, GREEN, 0); stroke(Left, 0.45, MINT, 0.35)

    local Right = Instance.new("Frame", Columns)
    Right.Name = "Right"
    Right.BackgroundColor3 = Color3.fromRGB(16,16,16)
    Right.Position = UDim2.new(LEFT_RATIO, GAP_BETWEEN, 0, 0)
    Right.Size = UDim2.new(RIGHT_RATIO, -GAP_BETWEEN/2, 1, 0)
    Right.ClipsDescendants = true; corner(Right, 10); stroke(Right, 1.2, GREEN, 0); stroke(Right, 0.45, MINT, 0.35)

    local imgL = Instance.new("ImageLabel", Left)
    imgL.Name = "PreviewL"
    imgL.BackgroundTransparency = 1; imgL.Size = UDim2.new(1,0,1,0); imgL.Image = IMG_SMALL; imgL.ScaleType = Enum.ScaleType.Crop

    local imgR = Instance.new("ImageLabel", Right)
    imgR.Name = "PreviewR"
    imgR.BackgroundTransparency = 1; imgR.Size = UDim2.new(1,0,1,0); imgR.Image = IMG_LARGE; imgR.ScaleType = Enum.ScaleType.Crop

    -- RECOVERY / TOGGLE
    do
        local function findMain()
            local gui = CoreGui:FindFirstChild("UFO_HUB_X_UI")
            local win
            if gui then win = gui:FindFirstChildWhichIsA("Frame") end
            return gui, win
        end
        local function showUI()
            local gui, win = findMain()
            if gui then gui.Enabled = true end
            if win then win.Visible = true end
            getgenv().UFO_ISOPEN = true
        end
        local function hideUI()
            local gui, win = findMain()
            if win then win.Visible = false end
            getgenv().UFO_ISOPEN = false
        end
        do
            local _, win = findMain()
            getgenv().UFO_ISOPEN = (win and win.Visible) and true or false
        end
        for _,o in ipairs(CoreGui:GetDescendants()) do
            if o:IsA("TextButton") and o.Text and o.Text:upper()=="X" then
                o.MouseButton1Click:Connect(function() hideUI() end)
            end
        end
        local toggleGui = CoreGui:FindFirstChild("UFO_HUB_X_Toggle")
        if toggleGui then toggleGui:Destroy() end
        local ToggleGui = Instance.new("ScreenGui", CoreGui)
        ToggleGui.Name = "UFO_HUB_X_Toggle"; ToggleGui.IgnoreGuiInset = true

        local ToggleBtn = Instance.new("ImageButton", ToggleGui)
        ToggleBtn.Name = "ToggleBtn"
        ToggleBtn.Size = UDim2.fromOffset(64,64); ToggleBtn.Position = UDim2.fromOffset(80,200)
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(0,0,0)
        ToggleBtn.BorderSizePixel = 0
        ToggleBtn.Image = "rbxassetid://117052960049460"
        local c = Instance.new("UICorner", ToggleBtn); c.CornerRadius = UDim.new(0,8)
        local s = Instance.new("UIStroke", ToggleBtn); s.Thickness=2; s.Color=GREEN

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
                        Enum.UserInputType.MouseMovement,
                        Enum.UserInputType.Touch,
                        Enum.UserInputType.MouseButton1)
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
                        if i.UserInputState==Enum.UserInputState.End then
                            dragging=false; bindBlock(false)
                        end
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

-- สร้าง UI ทันที (ให้เห็นเลย แม้ยังไม่เรียก API)
local _GUI = buildUIMain()

--=========== ADAPTER API (เหมือน Kavo-สไตล์ | ของเราเอง) ===========
local UFOPro = { _version = "1.0-main" }
UFOPro.__index = UFOPro

local function findContainers()
    local gui = CoreGui:FindFirstChild("UFO_HUB_X_UI")
    if not gui then return end
    local win   = gui:FindFirstChild("Window")
    local body  = win and win:FindFirstChild("Body")
    local cont  = body and body:FindFirstChild("Content")
    local cols  = cont and cont:FindFirstChild("Columns")
    local left  = cols and cols:FindFirstChild("Left")
    local right = cols and cols:FindFirstChild("Right")
    return gui, win, left, right
end

local function assureTabList(left)
    local list = left:FindFirstChild("TabList")
    if not list then
        list = Instance.new("ScrollingFrame", left)
        list.Name = "TabList"; list.BackgroundTransparency = 1
        list.Size = UDim2.new(1,0,1,0); list.ScrollBarThickness = 3
        local layout = Instance.new("UIListLayout", list)
        layout.Padding = UDim.new(0,8); layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            list.CanvasSize = UDim2.new(0,0,0, layout.AbsoluteContentSize.Y + 12)
        end)
        local pad = Instance.new("UIPadding", list)
        pad.PaddingTop = UDim.new(0,10); pad.PaddingLeft = UDim.new(0,10)
        pad.PaddingRight = UDim.new(0,10); pad.PaddingBottom = UDim.new(0,10)
    end
    return list
end

local function assurePageHost(right)
    local host = right:FindFirstChild("PageHost")
    if not host then
        host = Instance.new("Frame", right)
        host.Name = "PageHost"; host.BackgroundTransparency = 1; host.Size = UDim2.new(1,0,1,0)
    end
    return host
end

local function makeSideButton(parent, text, active)
    local b = Instance.new("TextButton")
    b.Name = "Tab_"..text; b.AutoButtonColor = false
    b.Size = UDim2.new(1,0,0,32)
    b.BackgroundColor3 = active and Color3.fromRGB(28,28,28) or Color3.fromRGB(20,20,20)
    b.Text = "· "..text; b.Font = Enum.Font.GothamSemibold; b.TextSize = 15
    b.TextColor3 = active and Color3.fromRGB(240,240,250) or Color3.fromRGB(180,185,200)
    b.Parent = parent; corner(b, 10); stroke(b, 1, MINT, 0.25)
    b.MouseEnter:Connect(function() if not active then b.BackgroundColor3 = Color3.fromRGB(26,26,26) end end)
    b.MouseLeave:Connect(function() if not active then b.BackgroundColor3 = Color3.fromRGB(20,20,20) end end)
    return b
end

local function makePage(parent)
    local page = Instance.new("ScrollingFrame", parent)
    page.Name = "Page"; page.Visible = false; page.BackgroundTransparency = 1
    page.Size = UDim2.new(1,-12,1,-12); page.Position = UDim2.new(0,6,0,6)
    page.ScrollBarThickness = 4
    local lay = Instance.new("UIListLayout", page); lay.Padding = UDim.new(0,10)
    lay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0,0,0, lay.AbsoluteContentSize.Y + 12)
    end)
    return page
end

--============= PUBLIC API =============
function UFOPro.CreateLib(title, theme)
    -- สร้าง UI ถ้ายังไม่มี
    if not CoreGui:FindFirstChild("UFO_HUB_X_UI") then buildUIMain() end

    local gui, win, left, right = findContainers()
    assert(gui and win and left and right, "[UFOPro] ไม่พบโครง UI — ตรวจชื่อโหนด")

    local tabList  = assureTabList(left)
    local pageHost = assurePageHost(right)

    local api = { _gui = gui, _win = win, _tabList = tabList, _pageHost = pageHost, _activeTabBtn = nil, _pages = {} }

    function api:ToggleUI()
        local vis = self._win.Visible
        self._win.Visible = not vis
        getgenv().UFO_ISOPEN = self._win.Visible
    end

    function api:SetTitle(txt)
        local header = self._win:FindFirstChild("Header") or self._win:FindFirstChild("TopBar")
        local label = header and header:FindFirstChild("TitleCenter")
        if label then
            label.Text = string.format('<font color="#FFFFFF">%s</font> <font color="#00FF8C">HUB X</font>', txt or "UFO")
        end
    end

    function api:NewTab(name)
        name = tostring(name or "Tab")
        local isFirst = (self._activeTabBtn == nil)

        local btn = makeSideButton(self._tabList, name, isFirst)
        local page = makePage(self._pageHost); page.Name = "Page_"..name
        self._pages[name] = page

        local function activate()
            for _,pg in pairs(self._pages) do pg.Visible = false end
            for _,o in ipairs(self._tabList:GetChildren()) do
                if o:IsA("TextButton") then
                    o.BackgroundColor3 = Color3.fromRGB(20,20,20)
                    o.TextColor3 = Color3.fromRGB(180,185,200)
                end
            end
            page.Visible = true
            btn.BackgroundColor3 = Color3.fromRGB(28,28,28)
            btn.TextColor3 = Color3.fromRGB(240,240,250)
            self._activeTabBtn = btn
        end
        btn.MouseButton1Click:Connect(activate)
        if isFirst then activate() end

        --===== Section API =====
        local tabAPI = {}
        function tabAPI:NewSection(title)
            title = tostring(title or "Section")

            local holder = Instance.new("Frame", page)
            holder.Size = UDim2.new(1,0,0,56)
            holder.BackgroundColor3 = Color3.fromRGB(28,28,28)
            holder.BorderSizePixel = 0
            corner(holder, 12); stroke(holder, 1.1, Color3.fromRGB(120,180,255), 0.15)

            do
                local inner = Instance.new("Frame", holder)
                inner.BackgroundTransparency = 1
                inner.Size = UDim2.new(1,-22,1,-16)
                inner.Position = UDim2.new(0,11,0,8)

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
                lab.Font = Enum.Font.GothamMedium
                lab.TextSize = 16
                lab.TextXAlignment = Enum.TextXAlignment.Left
                lab.TextColor3 = Color3.fromRGB(240,240,250)
                lab.Text = title
                lab.Size = UDim2.new(1,-80,1,0)

                function tabAPI:UpdateSection(newTitle)
                    lab.Text = tostring(newTitle or "")
                end
            end

            -- โฮสต์สำหรับคอนโทรลของเซกชันนี้
            local ctrlHost = Instance.new("Frame", page)
            ctrlHost.BackgroundTransparency = 1
            ctrlHost.Size = UDim2.new(1,0,0,0)
            local v = Instance.new("UIListLayout", ctrlHost)
            v.Padding = UDim.new(0,8)
            v.FillDirection = Enum.FillDirection.Vertical
            v.HorizontalAlignment = Enum.HorizontalAlignment.Stretch

            -- ===== Controls API (เริ่มด้วย Label / Button) =====
            local secAPI = {}

            function secAPI:NewLabel(text)
                local tl = Instance.new("TextLabel", ctrlHost)
                tl.BackgroundTransparency = 1
                tl.Size = UDim2.new(1,0,0,22)
                tl.Font = Enum.Font.Gotham
                tl.TextSize = 14
                tl.TextXAlignment = Enum.TextXAlignment.Left
                tl.TextColor3 = Color3.fromRGB(210,214,230)
                tl.Text = tostring(text or "")
                return {
                    UpdateLabel = function(_, t)
                        tl.Text = tostring(t or "")
                    end
                }
            end

            function secAPI:NewButton(text, info, callback)
                local b = Instance.new("TextButton", ctrlHost)
                b.AutoButtonColor = false
                b.Size = UDim2.new(1,0,0,34)
                b.BackgroundColor3 = Color3.fromRGB(40,40,50)
                b.Text = tostring(text or "Button")
                b.Font = Enum.Font.GothamSemibold
                b.TextSize = 14
                b.TextColor3 = Color3.fromRGB(235,235,245)
                corner(b,10); stroke(b,1, MINT, 0.28)

                b.MouseEnter:Connect(function()
                    b.BackgroundColor3 = Color3.fromRGB(48,48,60)
                end)
                b.MouseLeave:Connect(function()
                    b.BackgroundColor3 = Color3.fromRGB(40,40,50)
                end)
                b.MouseButton1Click:Connect(function()
                    if callback then pcall(callback) end
                end)

                return {
                    UpdateButton = function(_, t)
                        b.Text = tostring(t or "")
                    end
                }
            end

            -- (ขั้นถัดไปจะเติม: Toggle/Slider/TextBox/Keybind/Dropdown/ColorPicker)
            return secAPI
        end

        return tabAPI
    end

    return api
end

-- ถ้าไฟล์นี้ถูกโหลดผ่าน loadstring(... )() → คืนโมดูล
return UFOPro
  
