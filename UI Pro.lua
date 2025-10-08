pcall(function()
    local g = game:GetService("CoreGui"):FindFirstChild("UFO_HUB_X_UI")
    if g then g:Destroy() end
    local t = game:GetService("CoreGui"):FindFirstChild("UFO_HUB_X_Toggle")
    if t then t:Destroy() end
end)

-- THEME (เหมือนเดิม)
local GREEN        = Color3.fromRGB(0,255,140)
local MINT         = Color3.fromRGB(120,255,220)
local MINT_SOFT    = Color3.fromRGB(90,210,190)
local BG_WINDOW    = Color3.fromRGB(16,16,16)
local BG_HEADER    = Color3.fromRGB(6,6,6)
local BG_PANEL     = Color3.fromRGB(22,22,22)
local BG_INNER     = Color3.fromRGB(18,18,18)
local TEXT_WHITE   = Color3.fromRGB(235,235,235)
local DANGER_RED   = Color3.fromRGB(200,40,40)

-- SIZE (เหมือนเดิม)
local WIN_W, WIN_H = 640, 360
local GAP_OUTER    = 14
local GAP_BETWEEN  = 12
local LEFT_RATIO   = 0.22
local RIGHT_RATIO  = 0.78

-- IMAGES (เหมือนเดิม)
local IMG_SMALL = "rbxassetid://121069267171370"
local IMG_LARGE = "rbxassetid://108408843188558"
local IMG_UFO   = "rbxassetid://100650447103028"

-- HELPERS
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

-- ROOT
local CoreGui = game:GetService("CoreGui")
local UIS     = game:GetService("UserInputService")
local RunS    = game:GetService("RunService")

local GUI = Instance.new("ScreenGui")
GUI.Name = "UFO_HUB_X_UI"; GUI.IgnoreGuiInset = true; GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
GUI.ResetOnSpawn = false; GUI.Parent = CoreGui

-- WINDOW
local Window = Instance.new("Frame", GUI)
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
Header.Size = UDim2.new(1,0,0,46); Header.BackgroundColor3 = BG_HEADER; Header.BorderSizePixel = 0
corner(Header, 12); gradient(Header, Color3.fromRGB(10,10,10), Color3.fromRGB(0,0,0), 0)

local HeadAccent = Instance.new("Frame", Header)
HeadAccent.AnchorPoint = Vector2.new(0.5,1); HeadAccent.Position = UDim2.new(0.5,0,1,0)
HeadAccent.Size = UDim2.new(1,-20,0,1); HeadAccent.BackgroundColor3 = MINT; HeadAccent.BackgroundTransparency = 0.35

local Dot = Instance.new("Frame", Header)
Dot.BackgroundColor3 = MINT; Dot.Position = UDim2.new(0,14,0.5,-4); Dot.Size = UDim2.new(0,8,0,8)
Dot.BorderSizePixel = 0; corner(Dot, 4)

local BtnClose = Instance.new("TextButton", Header)
BtnClose.Size = UDim2.new(0,24,0,24); BtnClose.Position = UDim2.new(1,-34,0.5,-12)
BtnClose.BackgroundColor3 = DANGER_RED; BtnClose.Text = "X"; BtnClose.Font = Enum.Font.GothamBold
BtnClose.TextSize = 13; BtnClose.TextColor3 = Color3.new(1,1,1); BtnClose.BorderSizePixel = 0
corner(BtnClose, 6); stroke(BtnClose, 1, Color3.fromRGB(255,0,0), 0.1)

BtnClose.MouseButton1Click:Connect(function()
    Window.Visible = false
    getgenv().UFO_ISOPEN = false
end)

-- drag (block camera while dragging)
do
    local dragging, start, startPos
    local CAS = game:GetService("ContextActionService")
    local function bindBlock(on)
        local name="UFO_BlockLook_Window"
        if on then
            CAS:BindActionAtPriority(name, function() return Enum.ContextActionResult.Sink end, false, 9000,
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
            Window.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
        end
    end)
end

-- ===== UFO + TITLE =====
do
    local UFO_Y_OFFSET   = 84
    local TITLE_Y_OFFSET = 8

    local UFO = Instance.new("ImageLabel", Window)
    UFO.Name = "UFO_Top"; UFO.BackgroundTransparency = 1; UFO.Image = IMG_UFO
    UFO.Size = UDim2.new(0,168,0,168); UFO.AnchorPoint = Vector2.new(0.5,1)
    UFO.Position = UDim2.new(0.5, 0, 0, UFO_Y_OFFSET); UFO.ZIndex = 60

    local Halo = Instance.new("ImageLabel", Window)
    Halo.BackgroundTransparency = 1; Halo.AnchorPoint = Vector2.new(0.5,0)
    Halo.Position = UDim2.new(0.5,0,0,0); Halo.Size = UDim2.new(0,200,0,60)
    Halo.Image = "rbxassetid://5028857084"; Halo.ImageColor3 = MINT_SOFT; Halo.ImageTransparency = 0.72; Halo.ZIndex = 50

    local TitleCenter = Instance.new("TextLabel", Header)
    TitleCenter.BackgroundTransparency = 1; TitleCenter.AnchorPoint = Vector2.new(0.5,0)
    TitleCenter.Position = UDim2.new(0.5, 0, 0, TITLE_Y_OFFSET)
    TitleCenter.Size = UDim2.new(0.8, 0, 0, 36)
    TitleCenter.Font = Enum.Font.GothamBold; TitleCenter.RichText = true; TitleCenter.TextScaled = true
    TitleCenter.Text = '<font color="#FFFFFF">UFO</font> <font color="#00FF8C">HUB X</font>'
    TitleCenter.TextColor3 = TEXT_WHITE; TitleCenter.ZIndex = 61
end

-- ================= BODY =================
local Body = Instance.new("Frame", Window)
Body.BackgroundTransparency = 1; Body.Position = UDim2.new(0,0,0,46); Body.Size = UDim2.new(1,0,1,-46)

local Inner = Instance.new("Frame", Body)
Inner.BackgroundColor3 = BG_INNER; Inner.BorderSizePixel = 0
Inner.Position = UDim2.new(0,8,0,8); Inner.Size = UDim2.new(1,-16,1,-16); corner(Inner, 12)

local Content = Instance.new("Frame", Body)
Content.BackgroundColor3 = BG_PANEL; Content.Position = UDim2.new(0,GAP_OUTER,0,GAP_OUTER)
Content.Size = UDim2.new(1,-GAP_OUTER*2,1,-GAP_OUTER*2); corner(Content, 12); stroke(Content, 0.5, MINT, 0.35)

local Columns = Instance.new("Frame", Content)
Columns.BackgroundTransparency = 1; Columns.Position = UDim2.new(0,8,0,8); Columns.Size = UDim2.new(1,-16,1,-16)

-- ********** LEFT: ScrollingFrame (เสถียร) **********
local Left = Instance.new("ScrollingFrame", Columns)
Left.Name = "Left"
Left.BackgroundColor3 = Color3.fromRGB(16,16,16)
Left.Size = UDim2.new(LEFT_RATIO, -GAP_BETWEEN/2, 1, 0)
Left.ScrollBarThickness = 3
Left.ScrollingDirection = Enum.ScrollingDirection.Y
Left.CanvasSize = UDim2.new(0,0,0,0)
Left.ClipsDescendants = true
corner(Left, 10); stroke(Left, 1.2, GREEN, 0); stroke(Left, 0.45, MINT, 0.35)

local padL = Instance.new("UIPadding", Left)
padL.PaddingTop = UDim.new(0,8); padL.PaddingLeft = UDim.new(0,8)
padL.PaddingRight = UDim.new(0,8); padL.PaddingBottom = UDim.new(0,8)

local listL = Instance.new("UIListLayout", Left)
listL.Padding = UDim.new(0,8); listL.SortOrder = Enum.SortOrder.LayoutOrder
listL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Left.CanvasSize = UDim2.new(0,0,0, listL.AbsoluteContentSize.Y + 10)
end)

-- ********** RIGHT: ScrollingFrame (เสถียร) **********
local Right = Instance.new("ScrollingFrame", Columns)
Right.Name = "Right"
Right.BackgroundColor3 = Color3.fromRGB(16,16,16)
Right.Position = UDim2.new(LEFT_RATIO, GAP_BETWEEN, 0, 0)
Right.Size = UDim2.new(RIGHT_RATIO, -GAP_BETWEEN/2, 1, 0)
Right.ScrollBarThickness = 4
Right.ScrollingDirection = Enum.ScrollingDirection.Y
Right.CanvasSize = UDim2.new(0,0,0,0)
Right.ClipsDescendants = true
corner(Right, 10); stroke(Right, 1.2, GREEN, 0); stroke(Right, 0.45, MINT, 0.35)

local padR = Instance.new("UIPadding", Right)
padR.PaddingTop = UDim.new(0,8); padR.PaddingLeft = UDim.new(0,8)
padR.PaddingRight = UDim.new(0,8); padR.PaddingBottom = UDim.new(0,8)

-- Host ของคอนเทนต์ด้านขวา (จัดสูงตามเนื้อหา แล้ว Right จะเลื่อนเอง)
local PageHost = Instance.new("Frame", Right)
PageHost.Name = "PageHost"; PageHost.BackgroundTransparency = 1
PageHost.Size = UDim2.new(1, -12, 0, 0); PageHost.Position = UDim2.new(0,6,0,6)

local layPages = Instance.new("UIListLayout", PageHost)
layPages.Padding = UDim.new(0,10); layPages.SortOrder = Enum.SortOrder.LayoutOrder
layPages:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    PageHost.Size = UDim2.new(1, -12, 0, layPages.AbsoluteContentSize.Y)
    Right.CanvasSize = UDim2.new(0,0,0, layPages.AbsoluteContentSize.Y + 12)
end)

-- ปิดรูปพรีวิวเดิม (กันบังพื้นที่เลื่อน)
local imgL = Instance.new("ImageLabel", Left)
imgL.BackgroundTransparency = 1; imgL.Size = UDim2.new(1,0,0,0); imgL.Image = IMG_SMALL; imgL.ScaleType = Enum.ScaleType.Crop; imgL.Visible = false

local imgR = Instance.new("ImageLabel", Right)
imgR.BackgroundTransparency = 1; imgR.Size = UDim2.new(1,0,0,0); imgR.Image = IMG_LARGE; imgR.ScaleType = Enum.ScaleType.Crop; imgR.Visible = false

--==========================================================
-- UFO RECOVERY PATCH (Final Fix v3: sync flag + block camera drag)
--==========================================================
do
    local CoreGui = game:GetService("CoreGui")
    local UIS     = game:GetService("UserInputService")
    local CAS     = game:GetService("ContextActionService")

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
    ToggleBtn.Size = UDim2.fromOffset(64,64); ToggleBtn.Position = UDim2.fromOffset(80,200)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(0,0,0)
    ToggleBtn.BorderSizePixel = 0
    ToggleBtn.Image = "rbxassetid://117052960049460"
    local c = Instance.new("UICorner", ToggleBtn); c.CornerRadius = UDim.new(0,8)
    local s = Instance.new("UIStroke", ToggleBtn); s.Thickness=2; s.Color=GREEN

    local function toggleUI()
        if getgenv().UFO_ISOPEN then hideUI() else showUI() end
    end
    ToggleBtn.MouseButton1Click:Connect(toggleUI)

    UIS.InputBegan:Connect(function(i,gp)
        if gp then return end
        if i.KeyCode==Enum.KeyCode.RightShift then toggleUI() end
    end)

    -- draggable toggle (block camera while drag)
    do
        local dragging=false; local start; local startPos
        local function bindBlock(on)
            local name="UFO_BlockLook_Toggle"
            if on then
                CAS:BindActionAtPriority(name, function() return Enum.ContextActionResult.Sink end, false, 9000,
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
-- ========= ADD: Left button (player) + Active badge on Right =========

-- ช่วยเช็ก container
local function _getContainers()
    local gui   = game:GetService("CoreGui"):FindFirstChild("UFO_HUB_X_UI")
    local win   = gui and gui:FindFirstChild("Window")
    local body  = win and win:FindFirstChild("Body")
    local cont  = body and body:FindFirstChild("Content")
    local cols  = cont and cont:FindFirstChild("Columns")
    local Left  = cols and cols:FindFirstChild("Left")
    local Right = cols and cols:FindFirstChild("Right")
    return Left, Right
end

-- ป้ายชื่อแอคทีฟ (ตรงตำแหน่งกล่องแดงในรูป)
-- ถ้าต้องขยับนิดหน่อย ปรับ 4 ตัวเลขนี้ได้ (ค่าเริ่มให้พอดีกับดีไซน์)
local ACTIVE_X, ACTIVE_Y = 8, 8     -- ระยะห่างจากขอบในของฝั่ง Right
local ACTIVE_W, ACTIVE_H = 130, 28  -- ขนาดป้ายชื่อ (กว้าง x สูง)

local function _ensureActiveBadge(Right)
    local badge = Right:FindFirstChild("ActiveBadge")
    if not badge then
        badge = Instance.new("Frame", Right)
        badge.Name = "ActiveBadge"
        badge.Position = UDim2.new(0, ACTIVE_X, 0, ACTIVE_Y)
        badge.Size = UDim2.new(0, ACTIVE_W, 0, ACTIVE_H)
        badge.BackgroundColor3 = Color3.fromRGB(28,28,34) -- กลืนกับ UI
        badge.BorderSizePixel  = 0
        corner(badge, 8)
        stroke(badge, 1.2, GREEN, 0)

        local ic = Instance.new("ImageLabel", badge)
        ic.Name = "Icon"; ic.BackgroundTransparency = 1
        ic.Size = UDim2.new(0, ACTIVE_H-8, 0, ACTIVE_H-8)
        ic.Position = UDim2.new(0, 6, 0.5, -(ACTIVE_H-8)/2)

        local txt = Instance.new("TextLabel", badge)
        txt.Name = "Text"; txt.BackgroundTransparency = 1
        txt.Position = UDim2.new(0, ACTIVE_H+10, 0, 0)
        txt.Size = UDim2.new(1, -(ACTIVE_H+12), 1, 0)
        txt.Font = Enum.Font.GothamSemibold
        txt.TextSize = 14
        txt.TextXAlignment = Enum.TextXAlignment.Left
        txt.TextColor3 = TEXT_WHITE
    end
    return badge
end

-- ฟังก์ชันสร้างปุ่มสี่เหลี่ยมฝั่งซ้าย (เต็มความกว้าง, สูง 28px ตามรูป)
local function CreateLeftButton(opts)
    local Left, Right = _getContainers()
    assert(Left and Right, "Containers not found")

    local H = 28  -- ความสูงปุ่มให้เท่ากับแถบสีขาวในรูป
    local btn = Instance.new("TextButton", Left)
    btn.Name = "Btn_"..tostring(opts.name or "btn")
    btn.AutoButtonColor = false
    btn.Size = UDim2.new(1, 0, 0, H)
    btn.BackgroundColor3 = Color3.fromRGB(20,20,20)
    btn.BorderSizePixel = 0
    btn.Text = "" -- เราจัด layout เอง
    corner(btn, 8)
    stroke(btn, 1.2, GREEN, 0)

    -- ไอคอนซ้าย (รองรับ asset id)
    local iconSize = H - 8
    local ic = Instance.new("ImageLabel", btn)
    ic.BackgroundTransparency = 1
    ic.Size = UDim2.new(0, iconSize, 0, iconSize)
    ic.Position = UDim2.new(0, 6, 0.5, -iconSize/2)
    ic.Image = ("rbxassetid://%s"):format(tostring(opts.assetId or ""))

    -- ข้อความ
    local lab = Instance.new("TextLabel", btn)
    lab.BackgroundTransparency = 1
    lab.Position = UDim2.new(0, iconSize + 12, 0, 0)
    lab.Size = UDim2.new(1, -(iconSize + 14), 1, 0)
    lab.Font = Enum.Font.GothamSemibold
    lab.TextSize = 14
    lab.TextXAlignment = Enum.TextXAlignment.Left
    lab.TextColor3 = TEXT_WHITE
    lab.Text = tostring(opts.name or "button")

    -- อัปเดตป้ายแดง (Active badge) ฝั่งขวา ทุกครั้งที่คลิก
    local function updateActive()
        local badge = _ensureActiveBadge(Right)
        badge.Icon.Image = ic.Image
        badge.Text.Text  = lab.Text
        badge.Visible = true
    end
    btn.MouseButton1Click:Connect(updateActive)

    -- แสดงค่าแรกทันที (ให้ขึ้นตรงจุดสีแดงตั้งแต่แรก)
    updateActive()

    -- hover เล็กน้อย
    btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(26,26,26) end)
    btn.MouseLeave:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(20,20,20) end)

    return btn
end

-- === สร้างปุ่มตามที่ขอ ===
CreateLeftButton({
    name    = "Player",
    assetId = 116976545042904,  -- รูปจาก Roblox
})
