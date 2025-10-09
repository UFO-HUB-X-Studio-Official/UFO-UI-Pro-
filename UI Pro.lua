--======================================================
-- UFO HUB X (original look) + solid scroll L/R + green-outline button + active badge
--======================================================

pcall(function()
    local g = game:GetService("CoreGui"):FindFirstChild("UFO_HUB_X_UI")
    if g then g:Destroy() end
    local t = game:GetService("CoreGui"):FindFirstChild("UFO_HUB_X_Toggle")
    if t then t:Destroy() end
end)

-- THEME (เหมือนเดิม)
local GREEN      = Color3.fromRGB(0,255,140)
local MINT       = Color3.fromRGB(120,255,220)
local MINT_SOFT  = Color3.fromRGB(90,210,190)
local BG_WINDOW  = Color3.fromRGB(16,16,16)
local BG_HEADER  = Color3.fromRGB(6,6,6)
local BG_PANEL   = Color3.fromRGB(22,22,22)
local BG_INNER   = Color3.fromRGB(18,18,18)
local TEXT_WHITE = Color3.fromRGB(235,235,235)
local DANGER_RED = Color3.fromRGB(200,40,40)

-- SIZE (เหมือนเดิม)
local WIN_W, WIN_H = 640, 360
local GAP_OUTER    = 14
local GAP_BETWEEN  = 12
local LEFT_RATIO   = 0.22
local RIGHT_RATIO  = 0.78

-- IMAGES
local IMG_UFO   = "rbxassetid://100650447103028"
local IMG_GLOW  = "rbxassetid://5028857084"
local IMG_TOGGLE= "rbxassetid://117052960049460"

-- HELPERS
local function corner(gui, r) local c=Instance.new("UICorner",gui); c.CornerRadius=UDim.new(0,r or 10); return c end
local function stroke(gui,t,col,trans) local s=Instance.new("UIStroke",gui); s.Thickness=t or 1; s.Color=col or MINT; s.Transparency=trans or 0.35; s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; s.LineJoinMode=Enum.LineJoinMode.Round; return s end
local function gradient(gui,c1,c2,rot) local g=Instance.new("UIGradient",gui); g.Color=ColorSequence.new(c1,c2); g.Rotation=rot or 0; return g end

-- ROOT
local CoreGui = game:GetService("CoreGui")
local UIS     = game:GetService("UserInputService")
local RunS    = game:GetService("RunService")
local CAS     = game:GetService("ContextActionService")

-- GUI
local GUI = Instance.new("ScreenGui")
GUI.Name = "UFO_HUB_X_UI"; GUI.IgnoreGuiInset = true; GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
GUI.ResetOnSpawn = false; GUI.Parent = CoreGui

-- WINDOW
local Window = Instance.new("Frame", GUI)
Window.AnchorPoint = Vector2.new(0.5,0.5); Window.Position = UDim2.new(0.5,0,0.5,0)
Window.Size = UDim2.fromOffset(WIN_W, WIN_H); Window.BackgroundColor3 = BG_WINDOW; Window.BorderSizePixel = 0
corner(Window, 12); stroke(Window, 3, GREEN, 0)

-- glow
do local Glow=Instance.new("ImageLabel",Window)
    Glow.BackgroundTransparency=1; Glow.AnchorPoint=Vector2.new(.5,.5); Glow.Position=UDim2.new(.5,0,.5,0)
    Glow.Size=UDim2.new(1.07,0,1.09,0); Glow.Image=IMG_GLOW; Glow.ImageColor3=GREEN; Glow.ImageTransparency=.78
    Glow.ScaleType=Enum.ScaleType.Slice; Glow.SliceCenter=Rect.new(24,24,276,276); Glow.ZIndex=0
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
BtnClose.MouseButton1Click:Connect(function() Window.Visible=false; getgenv().UFO_ISOPEN=false end)

-- drag (block camera)
do
    local dragging, start, startPos
    local function bindBlock(on)
        local name="UFO_BlockLook_Window"
        if on then
            CAS:BindActionAtPriority(name,function() return Enum.ContextActionResult.Sink end,false,9000,
                Enum.UserInputType.MouseMovement,Enum.UserInputType.Touch,Enum.UserInputType.MouseButton1)
        else pcall(function() CAS:UnbindAction(name) end) end
    end
    Header.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            dragging=true; start=i.Position; startPos=Window.Position; bindBlock(true)
            i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then dragging=false; bindBlock(false) end end)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local d=i.Position-start
            Window.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
        end
    end)
end

-- UFO + TITLE
do
    local UFO=Instance.new("ImageLabel",Window)
    UFO.Name="UFO_Top"; UFO.BackgroundTransparency=1; UFO.Image=IMG_UFO
    UFO.Size=UDim2.new(0,168,0,168); UFO.AnchorPoint=Vector2.new(.5,1); UFO.Position=UDim2.new(.5,0,0,84); UFO.ZIndex=60
    local Halo=Instance.new("ImageLabel",Window)
    Halo.BackgroundTransparency=1; Halo.AnchorPoint=Vector2.new(.5,0); Halo.Position=UDim2.new(.5,0,0,0)
    Halo.Size=UDim2.new(0,200,0,60); Halo.Image=IMG_GLOW; Halo.ImageColor3=MINT_SOFT; Halo.ImageTransparency=.72; Halo.ZIndex=50

    local TitleCenter = Instance.new("TextLabel", Header)
    TitleCenter.BackgroundTransparency = 1; TitleCenter.AnchorPoint = Vector2.new(0.5,0)
    TitleCenter.Position = UDim2.new(0.5, 0, 0, 8)
    TitleCenter.Size = UDim2.new(0.8, 0, 0, 36)
    TitleCenter.Font = Enum.Font.GothamBold; TitleCenter.RichText = true; TitleCenter.TextScaled = true
    TitleCenter.Text = '<font color="#FFFFFF">UFO</font> <font color="#00FF8C">HUB X</font>'
    TitleCenter.TextColor3 = TEXT_WHITE
end

-- BODY
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

-- LEFT panel container (มีกรอบเหมือนเดิม) + สกรอลล์ภายใน
local Left = Instance.new("Frame", Columns)
Left.BackgroundColor3 = Color3.fromRGB(16,16,16); Left.Size = UDim2.new(LEFT_RATIO, -GAP_BETWEEN/2, 1, 0)
Left.ClipsDescendants = true; corner(Left, 10); stroke(Left, 1.2, GREEN, 0); stroke(Left, 0.45, MINT, 0.35)

local LeftList = Instance.new("ScrollingFrame", Left)
LeftList.Name="LeftList"; LeftList.BackgroundTransparency=1; LeftList.BorderSizePixel=0
LeftList.Position=UDim2.new(0,8,0,8); LeftList.Size=UDim2.new(1,-16,1,-16); LeftList.ScrollBarThickness=3
local LL=Instance.new("UIListLayout", LeftList); LL.Padding=UDim.new(0,8); LL.SortOrder=Enum.SortOrder.LayoutOrder
LL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    LeftList.CanvasSize=UDim2.new(0,0,0,LL.AbsoluteContentSize.Y+8)
end)

-- RIGHT panel container + สกรอลล์ภายใน (โลโก้เป็นพื้นหลังของพาเนลขวา)
local Right = Instance.new("Frame", Columns)
Right.BackgroundColor3 = Color3.fromRGB(16,16,16)
Right.Position = UDim2.new(LEFT_RATIO, GAP_BETWEEN, 0, 0)
Right.Size = UDim2.new(RIGHT_RATIO, -GAP_BETWEEN/2, 1, 0)
Right.ClipsDescendants = true
corner(Right, 10)
stroke(Right, 1.2, GREEN, 0)
stroke(Right, 0.45, MINT, 0.35)

-- ลบ MainLogo เดิมถ้ามี (ทั้งที่อยู่ใต้ Right และ RightList)
for _, ch in ipairs(Right:GetChildren()) do
    if ch.Name == "MainLogo" then ch:Destroy() end
end
-- เผื่อเคยสร้างใน RightList มาก่อน ให้เคลียร์ด้วยเมื่อพบ
local oldRightList = Right:FindFirstChild("RightList")
if oldRightList then
    local oldLogo = oldRightList:FindFirstChild("MainLogo")
    if oldLogo then oldLogo:Destroy() end
end

-- ===== MainLogo = พื้นหลังของพาเนลขวา (ไม่เลื่อนตาม) =====
local MainLogo = Instance.new("ImageLabel")
MainLogo.Name = "MainLogo"
MainLogo.BackgroundTransparency = 1
MainLogo.AnchorPoint = Vector2.new(0.5, 0.5)
MainLogo.Position = UDim2.new(0.5, 0, 0.5, 0)
-- ให้กินพื้นที่เกือบเต็มพาเนล (ไม่ทับเส้นขอบเขียว)
MainLogo.Size = UDim2.new(1, -48, 1, -48)
MainLogo.Image = "rbxassetid://117052960049460"   -- << ไอดีรูปที่ต้องการ
MainLogo.ImageColor3 = Color3.fromRGB(255,255,255)
MainLogo.ScaleType = Enum.ScaleType.Fit
MainLogo.ImageTransparency = 0
MainLogo.ZIndex = 0        -- เป็นพื้นหลัง
MainLogo.Parent = Right    -- สำคัญ: เป็นลูกของ Right

-- ===== RightList = รายการที่เลื่อนอยู่ “เหนือ” โลโก้ =====
local RightList = Instance.new("ScrollingFrame", Right)
RightList.Name = "RightList"
RightList.BackgroundTransparency = 1       -- โปร่งใสเพื่อให้เห็นโลโก้
RightList.BorderSizePixel = 0
RightList.Position = UDim2.new(0,8,0,8)
RightList.Size = UDim2.new(1,-16,1,-16)
RightList.ZIndex = 1                       -- อยู่เหนือ MainLogo
-- ซ่อนสกรอลบาร์ แต่ยังเลื่อนได้เหมือนเดิม
RightList.ScrollBarThickness = 0
RightList.ScrollBarImageTransparency = 1
RightList.TopImage, RightList.MidImage, RightList.BottomImage = "","",""

local RL = Instance.new("UIListLayout", RightList)
RL.Padding = UDim.new(0,8)
RL.SortOrder = Enum.SortOrder.LayoutOrder
RL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    RightList.CanvasSize = UDim2.new(0,0,0, RL.AbsoluteContentSize.Y + 8)
end)

-- ป้ายชื่อ (มุมซ้ายบนแผงขวา) แสดงไอคอน+ชื่อปุ่มที่เลือก
local ActiveBadge = Instance.new("Frame", Right)
ActiveBadge.Name="ActiveBadge"; ActiveBadge.Position=UDim2.new(0,14,0,12); ActiveBadge.Size=UDim2.new(0,150,0,28)
ActiveBadge.BackgroundColor3 = Color3.fromRGB(28,28,34); ActiveBadge.BorderSizePixel=0; ActiveBadge.Visible=false; corner(ActiveBadge,8)
local abStroke=Instance.new("UIStroke", ActiveBadge); abStroke.Color = GREEN; abStroke.Thickness=1.2
local ABIcon=Instance.new("ImageLabel",ActiveBadge); ABIcon.Name="Icon"; ABIcon.BackgroundTransparency=1; ABIcon.Size=UDim2.new(0,20,0,20); ABIcon.Position=UDim2.new(0,6,0.5,-10)
local ABText=Instance.new("TextLabel",ActiveBadge); ABText.Name="Text"; ABText.BackgroundTransparency=1; ABText.Position=UDim2.new(0,32,0,0); ABText.Size=UDim2.new(1,-36,1,0)
ABText.Font=Enum.Font.GothamSemibold; ABText.TextSize=14; ABText.TextColor3=TEXT_WHITE; ABText.TextXAlignment=Enum.TextXAlignment.Left
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

    -- ตั้งค่า flag เริ่มตามสถานะจริงของหน้าต่าง (กันกดครั้งแรกไม่ขึ้น)
    do
        local _, win = findMain()
        getgenv().UFO_ISOPEN = (win and win.Visible) and true or false
    end

    -- ปุ่ม X ทั้งระบบ -> ซ่อน + sync flag (กันกดเปิดต้องกดสองครั้ง)
    for _,o in ipairs(CoreGui:GetDescendants()) do
        if o:IsA("TextButton") and o.Text and o.Text:upper()=="X" then
            o.MouseButton1Click:Connect(function() hideUI() end)
        end
    end

    -- ปุ่ม Toggle (ImageButton) + กรอบเขียว + ลากได้ + บล็อกกล้องขณะลาก
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

    -- Drag ปุ่มสี่เหลี่ยม + block camera
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
-- ===== Hide scrollbars on both sides (Left & Right) but keep scrolling =====
local function hideScrollbar(sf)
    if not (sf and sf:IsA("ScrollingFrame")) then return end
    -- ซ่อนทั้งแท่งและราง
    sf.ScrollBarThickness = 0                 -- ซ่อนทันทีแบบชัวร์
    sf.ScrollBarImageTransparency = 1         -- กันเผื่อบางเกม
    sf.TopImage, sf.MidImage, sf.BottomImage = "", "", ""  -- ลบรางขาว
end

hideScrollbar(LeftList)
hideScrollbar(RightList)
-- ========================================================================
-- ========================================================================
-- ปุ่มซ้าย: ขอบเขียว + เอฟเฟกต์กดค้าง + สลับ active ถูกต้อง + เริ่มต้นไม่ active
-- ========================================================================
if MainLogo then MainLogo.Visible = false end
local activeButton = nil
local LeftButtons = {}

local function setActive(btn)
    for _, it in ipairs(LeftButtons) do
        if it.btn == btn then
            it.btn.BackgroundColor3 = it.bgActive
            it.stroke.Color = it.strokeActive
        else
            it.btn.BackgroundColor3 = it.bgDefault
            it.stroke.Color = it.strokeDefault
        end
    end
    activeButton = btn
end

local function CreateLeftButton(name, assetId)
    local H = 28
    local btn = Instance.new("TextButton", LeftList)
    btn.Name = "Btn_" .. name
    btn.AutoButtonColor = false
    btn.Size = UDim2.new(1, 0, 0, H)
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    btn.Text = ""
    btn.BorderSizePixel = 0
    corner(btn, 8)

    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = GREEN
    stroke.Thickness = 1.2

    local iconSize = H - 8
    local ic = Instance.new("ImageLabel", btn)
    ic.BackgroundTransparency = 1
    ic.Size = UDim2.new(0, iconSize, 0, iconSize)
    ic.Position = UDim2.new(0, 6, 0.5, -iconSize / 2)
    ic.Image = "rbxassetid://" .. tostring(assetId)

    local lab = Instance.new("TextLabel", btn)
    lab.BackgroundTransparency = 1
    lab.Position = UDim2.new(0, iconSize + 12, 0, 0)
    lab.Size = UDim2.new(1, -(iconSize + 14), 1, 0)
    lab.Font = Enum.Font.GothamSemibold
    lab.TextSize = 14
    lab.TextColor3 = TEXT_WHITE
    lab.TextXAlignment = Enum.TextXAlignment.Left
    lab.Text = name

    -- ธีมพื้นฐาน
    local theme = {
        bgDefault = Color3.fromRGB(20,20,20),
        bgHover = Color3.fromRGB(26,26,26),
        bgActive = Color3.fromRGB(12,50,20),
        strokeDefault = GREEN,
        strokeActive = Color3.fromRGB(0,255,120)
    }
    table.insert(LeftButtons, {
        btn = btn,
        stroke = stroke,
        bgDefault = theme.bgDefault,
        bgActive = theme.bgActive,
        strokeDefault = theme.strokeDefault,
        strokeActive = theme.strokeActive
    })

    -- Hover
    btn.MouseEnter:Connect(function()
        if activeButton ~= btn then btn.BackgroundColor3 = theme.bgHover end
    end)
    btn.MouseLeave:Connect(function()
        if activeButton ~= btn then btn.BackgroundColor3 = theme.bgDefault end
    end)

    -- คลิกเพื่อ set active
    btn.MouseButton1Click:Connect(function()
        setActive(btn)
        ABIcon.Image = ic.Image
        ABText.Text = name
        ActiveBadge.Visible = true
    end)

    return btn
end

-- ====== ตัวอย่างปุ่ม ======
CreateLeftButton("Player", 116976545042904)
-- ========================================================================
-- ปุ่มซ้าย: ขอบเขียว + เอฟเฟกต์กดค้าง + สลับ active ถูกต้อง + เริ่มต้นไม่ active
-- ========================================================================
local activeButton = nil
local LeftButtons = {}

local function setActive(btn)
    for _, it in ipairs(LeftButtons) do
        if it.btn == btn then
            it.btn.BackgroundColor3 = it.bgActive
            it.stroke.Color = it.strokeActive
        else
            it.btn.BackgroundColor3 = it.bgDefault
            it.stroke.Color = it.strokeDefault
        end
    end
    activeButton = btn
end

local function CreateLeftButton(name, assetId)
    local H = 28
    local btn = Instance.new("TextButton", LeftList)
    btn.Name = "Btn_" .. name
    btn.AutoButtonColor = false
    btn.Size = UDim2.new(1, 0, 0, H)
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    btn.Text = ""
    btn.BorderSizePixel = 0
    corner(btn, 8)

    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = GREEN
    stroke.Thickness = 1.2

    local iconSize = H - 8
    local ic = Instance.new("ImageLabel", btn)
    ic.BackgroundTransparency = 1
    ic.Size = UDim2.new(0, iconSize, 0, iconSize)
    ic.Position = UDim2.new(0, 6, 0.5, -iconSize / 2)
    ic.Image = "rbxassetid://" .. tostring(assetId)

    local lab = Instance.new("TextLabel", btn)
    lab.BackgroundTransparency = 1
    lab.Position = UDim2.new(0, iconSize + 12, 0, 0)
    lab.Size = UDim2.new(1, -(iconSize + 14), 1, 0)
    lab.Font = Enum.Font.GothamSemibold
    lab.TextSize = 14
    lab.TextColor3 = TEXT_WHITE
    lab.TextXAlignment = Enum.TextXAlignment.Left
    lab.Text = name

    -- ธีมพื้นฐาน
    local theme = {
        bgDefault = Color3.fromRGB(20,20,20),
        bgHover = Color3.fromRGB(26,26,26),
        bgActive = Color3.fromRGB(12,50,20),
        strokeDefault = GREEN,
        strokeActive = Color3.fromRGB(0,255,120)
    }
    table.insert(LeftButtons, {
        btn = btn,
        stroke = stroke,
        bgDefault = theme.bgDefault,
        bgActive = theme.bgActive,
        strokeDefault = theme.strokeDefault,
        strokeActive = theme.strokeActive
    })

    -- Hover
    btn.MouseEnter:Connect(function()
        if activeButton ~= btn then btn.BackgroundColor3 = theme.bgHover end
    end)
    btn.MouseLeave:Connect(function()
        if activeButton ~= btn then btn.BackgroundColor3 = theme.bgDefault end
    end)

    -- คลิกเพื่อ set active
    btn.MouseButton1Click:Connect(function()
        setActive(btn)
        ABIcon.Image = ic.Image
        ABText.Text = name
        ActiveBadge.Visible = true
    end)

    return btn
end

-- ====== ตัวอย่างปุ่ม ======
CreateLeftButton("Player", 116976545042904)
