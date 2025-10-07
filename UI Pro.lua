pcall(function()
    local g = game:GetService("CoreGui"):FindFirstChild("UFO_HUB_X_UI")
    if g then g:Destroy() end
    local t = game:GetService("CoreGui"):FindFirstChild("UFO_HUB_X_Toggle")
    if t then t:Destroy() end
end)

-- THEME
local GREEN        = Color3.fromRGB(0,255,140)
local MINT         = Color3.fromRGB(120,255,220)
local MINT_SOFT    = Color3.fromRGB(90,210,190)
local BG_WINDOW    = Color3.fromRGB(16,16,16)
local BG_HEADER    = Color3.fromRGB(6,6,6)
local BG_PANEL     = Color3.fromRGB(22,22,22)
local BG_INNER     = Color3.fromRGB(18,18,18)
local TEXT_WHITE   = Color3.fromRGB(235,235,235)
local DANGER_RED   = Color3.fromRGB(200,40,40)

-- SIZE
local WIN_W, WIN_H = 640, 360
local GAP_OUTER    = 14
local GAP_BETWEEN  = 12
local LEFT_RATIO   = 0.22
local RIGHT_RATIO  = 0.78

-- IMAGES
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
HeadAccent.BorderSizePixel = 0

local Dot = Instance.new("Frame", Header)
Dot.BackgroundColor3 = MINT; Dot.Position = UDim2.new(0,14,0.5,-4); Dot.Size = UDim2.new(0,8,0,8)
Dot.BorderSizePixel = 0; corner(Dot, 4)

local BtnClose = Instance.new("TextButton", Header)
BtnClose.Size = UDim2.new(0,24,0,24); BtnClose.Position = UDim2.new(1,-34,0.5,-12)
BtnClose.BackgroundColor3 = DANGER_RED; BtnClose.Text = "X"; BtnClose.Font = Enum.Font.GothamBold
BtnClose.TextSize = 13; BtnClose.TextColor3 = Color3.new(1,1,1); BtnClose.BorderSizePixel = 0
corner(BtnClose, 6); stroke(BtnClose, 1, Color3.fromRGB(255,0,0), 0.1)

-- ✅ ปุ่ม X ซ่อนเฉพาะ Window + sync flag
BtnClose.MouseButton1Click:Connect(function()
    Window.Visible = false
    getgenv().UFO_ISOPEN = false
end)

-- drag (fix: block camera input while dragging)
do
    local dragging, start, startPos
    local CAS = game:GetService("ContextActionService")

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
                    dragging=false
                    bindBlock(false)
                end
            end)
        end
    end)

    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local d=i.Position-start
            Window.Position=UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset+d.X,
                startPos.Y.Scale,
                startPos.Y.Offset+d.Y
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
    TitleCenter.BackgroundTransparency = 1; TitleCenter.AnchorPoint = Vector2.new(0.5,0)
    TitleCenter.Position = UDim2.new(0.5, 0, 0, TITLE_Y_OFFSET)
    TitleCenter.Size = UDim2.new(0.8, 0, 0, 36)
    TitleCenter.Font = Enum.Font.GothamBold; TitleCenter.RichText = true; TitleCenter.TextScaled = true
    TitleCenter.Text = '<font color="#FFFFFF">UFO</font> <font color="#00FF8C">HUB X</font>'
    TitleCenter.TextColor3 = TEXT_WHITE; TitleCenter.ZIndex = 61
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

local Left = Instance.new("Frame", Columns)
Left.BackgroundColor3 = Color3.fromRGB(16,16,16); Left.Size = UDim2.new(LEFT_RATIO, -GAP_BETWEEN/2, 1, 0)
Left.ClipsDescendants = true; corner(Left, 10); stroke(Left, 1.2, GREEN, 0); stroke(Left, 0.45, MINT, 0.35)

local Right = Instance.new("Frame", Columns)
Right.BackgroundColor3 = Color3.fromRGB(16,16,16)
Right.Position = UDim2.new(LEFT_RATIO, GAP_BETWEEN, 0, 0)
Right.Size = UDim2.new(RIGHT_RATIO, -GAP_BETWEEN/2, 1, 0)
Right.ClipsDescendants = true; corner(Right, 10); stroke(Right, 1.2, GREEN, 0); stroke(Right, 0.45, MINT, 0.35)

local imgL = Instance.new("ImageLabel", Left)
imgL.BackgroundTransparency = 1; imgL.Size = UDim2.new(1,0,1,0); imgL.Image = IMG_SMALL; imgL.ScaleType = Enum.ScaleType.Crop

local imgR = Instance.new("ImageLabel", Right)
imgR.BackgroundTransparency = 1; imgR.Size = UDim2.new(1,0,1,0); imgR.Image = IMG_LARGE; imgR.ScaleType = Enum.ScaleType.Crop
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
--// Module: UFOHubX
--// External-friendly UI API for UFO HUB X
--// Works with the existing Window you already made.

local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local UFOHubX = {}
UFOHubX.__index = UFOHubX

-- ===== Utilities =====
local function assure(obj, msg)
	if not obj then error("[UFOHubX] "..(msg or "missing object"), 2) end
	return obj
end

local function new(text, props, parent)
	local t = Instance.new(text)
	for k,v in pairs(props or {}) do t[k]=v end
	if parent then t.Parent = parent end
	return t
end

local function round(gui, r)
	local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 10); c.Parent = gui; return c
end

local function stroke(gui, thick, col, tr)
	local s = Instance.new("UIStroke"); s.Thickness = thick or 1; s.Color = col or Color3.fromRGB(90,210,190)
	s.Transparency = tr or 0.5; s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; s.LineJoinMode = Enum.LineJoinMode.Round
	s.Parent = gui; return s
end

-- ===== Mount existing UFO HUB X UI =====
local function pickContainers()
	local gui   = CoreGui:FindFirstChild("UFO_HUB_X_UI")
	local win   = gui and gui:FindFirstChildWhichIsA("Frame")
	local body  = win and win:FindFirstChild("Body")
	local cont  = body and body:FindFirstChild("Content")
	local cols  = cont and cont:FindFirstChild("Columns")
	local left  = cols and cols:FindFirstChild("Left")
	local right = cols and cols:FindFirstChild("Right")

	-- create scrolls if not exists
	if left and not left:FindFirstChild("TabList") then
		local sf = new("ScrollingFrame", {
			Name="TabList", BackgroundTransparency=1, Size=UDim2.new(1,0,1,0),
			ScrollBarThickness=3, CanvasSize=UDim2.new(0,0,0,0), ClipsDescendants=true
		}, left)
		local lay = Instance.new("UIListLayout", sf)
		lay.SortOrder = Enum.SortOrder.LayoutOrder
		lay.Padding = UDim.new(0,8)
		lay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			sf.CanvasSize = UDim2.new(0,0,0,lay.AbsoluteContentSize.Y+12)
		end)
		new("UIPadding", {PaddingTop=UDim.new(0,10),PaddingLeft=UDim.new(0,10),PaddingRight=UDim.new(0,10),PaddingBottom=UDim.new(0,10)}, sf)
	end

	if right and not right:FindFirstChild("PageHost") then
		local ph = new("Frame", {Name="PageHost", BackgroundTransparency=1, Size=UDim2.new(1,0,1,0)}, right)
		local pages = new("Folder", {Name="Pages"}, ph)
	end

	return gui, win, left, right, left and left.TabList, right and right.PageHost
end

-- ===== Core: CreateLib =====
function UFOHubX.CreateLib(title, theme)
	-- title/theme are placeholders for future theming; title set on header if found
	local gui, win, left, right, tabList, pageHost = pickContainers()
	assure(win, "UFO HUB X Window not found. Run your UI script first.")

	-- title (center label in your header)
	local header = win:FindFirstChild("TopBar") or win:FindFirstChildOfClass("Frame")
	local titleLbl = header and header:FindFirstChildWhichIsA("TextLabel", true)
	if titleLbl then titleLbl.Text = ("<font color=\"#FFFFFF\">%s</font> <font color=\"#00FF8C\">HUB X</font>"):format(title or "UFO") end

	local lib = setmetatable({
		_gui = gui, _win = win,
		_left = left, _right = right,
		_tabList = tabList, _pageHost = pageHost.Pages,
		_tabs = {}, _activeTab = nil
	}, UFOHubX)

	return lib
end

-- ===== Tabs =====
function UFOHubX:NewTab(name)
	assure(self._tabList, "TabList missing"); assure(self._pageHost, "PageHost missing")
	local tabBtn = new("TextButton", {
		Name = "Tab_"..name, AutoButtonColor=false,
		Size=UDim2.new(1,0,0,34), BackgroundColor3=Color3.fromRGB(34,34,34),
		Text = "· "..name, Font = Enum.Font.GothamSemibold, TextSize = 15,
		TextColor3 = Color3.fromRGB(200,200,210)
	}, self._tabList); round(tabBtn, 10); stroke(tabBtn, 1, Color3.fromRGB(90,210,190), 0.35)

	tabBtn.MouseEnter:Connect(function()
		tabBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
	end)
	tabBtn.MouseLeave:Connect(function()
		if self._activeTab ~= tabBtn then tabBtn.BackgroundColor3 = Color3.fromRGB(34,34,34) end
	end)

	local page = new("ScrollingFrame", {
		Name = "Page_"..name, Visible=false, BackgroundTransparency=1,
		Size=UDim2.new(1, -12, 1, -12), Position=UDim2.new(0,6,0,6),
		ScrollBarThickness=4, CanvasSize=UDim2.new(0,0,0,0)
	}, self._pageHost); local lay = Instance.new("UIListLayout", page); lay.Padding = UDim.new(0,10)
	lay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		page.CanvasSize = UDim2.new(0,0,0,lay.AbsoluteContentSize.Y+12)
	end)

	local api = {
		__page = page,
		NewSection = function(_, title)
			local holder = new("Frame", {
				BackgroundColor3 = Color3.fromRGB(28,28,28),
				Size = UDim2.new(1,0,0,56)
			}, page); round(holder, 12)
			local grad = Instance.new("UIGradient", holder); grad.Rotation = 90
			grad.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(60,60,80)),
				ColorSequenceKeypoint.new(0.55, Color3.fromRGB(44,44,62)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(30,30,46)),
			})
			stroke(holder, 1.2, Color3.fromRGB(120,180,255), 0.15)

			local inner = new("Frame", {BackgroundTransparency=1, Size=UDim2.new(1,-22,1,-16), Position=UDim2.new(0,11,0,8)}, holder)
			local h = Instance.new("UIListLayout", inner); h.FillDirection = Enum.FillDirection.Horizontal; h.VerticalAlignment = Enum.VerticalAlignment.Center; h.Padding = UDim.new(0,10)
			local dot = new("Frame",{Size=UDim2.fromOffset(8,8),BackgroundColor3=Color3.fromRGB(86,168,255)}, inner); round(dot, 8)
			local lab = new("TextLabel", {BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left,Font=Enum.Font.GothamMedium,TextSize=16,TextColor3=Color3.fromRGB(240,240,250),Text=title,Size=UDim2.new(1,-80,1,0)}, inner)

			-- control host
			local ctrlHost = new("Frame", {BackgroundTransparency=1, Size=UDim2.new(1, -12, 0, 0)}, page)

			local secAPI = {}

			function secAPI:UpdateSection(newTitle) lab.Text = newTitle end

			function secAPI:NewLabel(text)
				local tl = new("TextLabel", {Parent=ctrlHost, BackgroundTransparency=1, Size=UDim2.new(1,0,0,22), Font=Enum.Font.Gotham, TextSize=14, TextColor3=Color3.fromRGB(210,214,230), TextXAlignment=Enum.TextXAlignment.Left, Text = text})
				return {
					UpdateLabel = function(_, t) tl.Text = t end
				}
			end

			function secAPI:NewButton(text, info, callback)
				local b = new("TextButton", {Parent=ctrlHost, AutoButtonColor=false, Size=UDim2.new(1,0,0,34), BackgroundColor3=Color3.fromRGB(40,40,50),
					Text = text, Font=Enum.Font.GothamSemibold, TextSize=14, TextColor3=Color3.fromRGB(235,235,245)})
				round(b, 10); stroke(b, 1, Color3.fromRGB(90,210,190), 0.35)
				b.MouseEnter:Connect(function() b.BackgroundColor3=Color3.fromRGB(48,48,60) end)
				b.MouseLeave:Connect(function() b.BackgroundColor3=Color3.fromRGB(40,40,50) end)
				b.MouseButton1Click:Connect(function() if callback then pcall(callback) end end)
				return {
					UpdateButton = function(_, t) b.Text = t end
				}
			end

			function secAPI:NewToggle(text, info, callback)
				local cont = new("Frame", {Parent=ctrlHost, BackgroundColor3=Color3.fromRGB(40,40,50), Size=UDim2.new(1,0,0,38)}, nil); round(cont, 10); stroke(cont, 1, Color3.fromRGB(120,200,255), 0.28)
				local t = new("TextLabel", {Parent=cont, BackgroundTransparency=1, Position=UDim2.new(0,12,0,0), Size=UDim2.new(1,-70,1,0), TextXAlignment=Enum.TextXAlignment.Left, Font=Enum.Font.Gotham, TextSize=14, TextColor3=Color3.fromRGB(235,235,245), Text=text})
				local sw = new("TextButton", {Parent=cont, AutoButtonColor=false, Size=UDim2.fromOffset(44,20), Position=UDim2.new(1,-56,0.5,-10), BackgroundColor3=Color3.fromRGB(90,90,110), Text=""})
				round(sw, 10)
				local knob = new("Frame",{Parent=sw, Size=UDim2.fromOffset(18,18), Position=UDim2.new(0,1,0.5,-9), BackgroundColor3=Color3.fromRGB(230,230,240)}, nil); round(knob, 9)
				local state=false
				local function set(v)
					state = v and true or false
					sw.BackgroundColor3 = state and Color3.fromRGB(0,205,140) or Color3.fromRGB(90,90,110)
					knob.Position = state and UDim2.new(1,-19,0.5,-9) or UDim2.new(0,1,0.5,-9)
					if callback then pcall(callback, state) end
				end
				sw.MouseButton1Click:Connect(function() set(not state) end)
				set(false)
				return {
					UpdateToggle = function(_, txt) t.Text = txt end,
					Set = function(_, v) set(v) end,
					Get = function() return state end
				}
			end

			function secAPI:NewSlider(text, info, max, min, callback)
				max, min = max or 100, min or 0
				local cont = new("Frame", {Parent=ctrlHost, BackgroundColor3=Color3.fromRGB(40,40,50), Size=UDim2.new(1,0,0,44)}, nil); round(cont, 10); stroke(cont, 1, Color3.fromRGB(120,200,255), 0.28)
				local lab = new("TextLabel", {Parent=cont, BackgroundTransparency=1, Position=UDim2.new(0,12,0,0), Size=UDim2.new(1,-100,0,20), TextXAlignment=Enum.TextXAlignment.Left, Font=Enum.Font.Gotham, TextSize=14, TextColor3=Color3.fromRGB(235,235,245), Text=text})
				local val = new("TextLabel", {Parent=cont, BackgroundTransparency=1, AnchorPoint=Vector2.new(1,0), Position=UDim2.new(1,-12,0,0), Size=UDim2.new(0,80,0,20), TextXAlignment=Enum.TextXAlignment.Right, Font=Enum.Font.Gotham, TextSize=14, TextColor3=Color3.fromRGB(200,255,230), Text=tostring(min)})
				local bar = new("Frame", {Parent=cont, BackgroundColor3=Color3.fromRGB(60,60,76), Size=UDim2.new(1,-24,0,6), Position=UDim2.new(0,12,0,28)}, nil); round(bar, 3)
				local fill = new("Frame", {Parent=bar, BackgroundColor3=Color3.fromRGB(0,205,140), Size=UDim2.new(0,0,1,0)}, nil); round(fill, 3)
				local dragging=false
				local function setFromX(x)
					local abs = bar.AbsoluteSize.X
					local rel = math.clamp((x - bar.AbsolutePosition.X)/abs, 0, 1)
					local v = math.floor(min + (max-min)*rel + 0.5)
					fill.Size = UDim2.new(rel, 0, 1, 0)
					val.Text = tostring(v)
					if callback then pcall(callback, v) end
				end
				bar.InputBegan:Connect(function(i)
					if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging=true; setFromX(i.Position.X) end
				end)
				UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
				UIS.InputChanged:Connect(function(i) if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then setFromX(i.Position.X) end end)
				setFromX(bar.AbsolutePosition.X) -- init
				return { Set = function(_,v) local r=(v-min)/(max-min); fill.Size=UDim2.new(math.clamp(r,0,1),0,1,0); val.Text=tostring(v) end }
			end

			function secAPI:NewTextbox(text, info, callback)
				local cont = new("Frame", {Parent=ctrlHost, BackgroundColor3=Color3.fromRGB(40,40,50), Size=UDim2.new(1,0,0,36)}, nil); round(cont, 10); stroke(cont, 1, Color3.fromRGB(120,200,255), 0.28)
				local lab = new("TextLabel", {Parent=cont, BackgroundTransparency=1, Position=UDim2.new(0,12,0,0), Size=UDim2.new(0.35,0,1,0), TextXAlignment=Enum.TextXAlignment.Left, Font=Enum.Font.Gotham, TextSize=14, TextColor3=Color3.fromRGB(235,235,245), Text=text})
				local box = new("TextBox", {Parent=cont, ClearTextOnFocus=false, Size=UDim2.new(1,-(lab.AbsoluteSize.X+32),1,-10), Position=UDim2.new(0,lab.AbsoluteSize.X+18,0,5), BackgroundColor3=Color3.fromRGB(24,24,32), Font=Enum.Font.Gotham, TextSize=14, TextColor3=Color3.fromRGB(220,240,235), Text=""})
				round(box, 8)
				box.FocusLost:Connect(function(enter) if enter and callback then pcall(callback, box.Text) end end)
				return { Set = function(_,txt) box.Text = txt end, Get=function() return box.Text end }
			end

			function secAPI:NewDropdown(text, info, list, callback)
				list = list or {}
				local cont = new("Frame", {Parent=ctrlHost, BackgroundColor3=Color3.fromRGB(40,40,50), Size=UDim2.new(1,0,0,36)}, nil); round(cont, 10); stroke(cont, 1, Color3.fromRGB(120,200,255), 0.28)
				local lab = new("TextLabel", {Parent=cont, BackgroundTransparency=1, Position=UDim2.new(0,12,0,0), Size=UDim2.new(0.35,0,1,0), TextXAlignment=Enum.TextXAlignment.Left, Font=Enum.Font.Gotham, TextSize=14, TextColor3=Color3.fromRGB(235,235,245), Text=text})
				local dd = new("TextButton", {Parent=cont, AutoButtonColor=false, Size=UDim2.new(1,-(lab.AbsoluteSize.X+24),1,-10), Position=UDim2.new(0,lab.AbsoluteSize.X+18,0,5), BackgroundColor3=Color3.fromRGB(24,24,32), Text="Select", Font=Enum.Font.Gotham, TextSize=14, TextColor3=Color3.fromRGB(220,240,235)})
				round(dd, 8)
				local options = list
				local function pick(opt) dd.Text = tostring(opt); if callback then pcall(callback, opt) end end
				dd.MouseButton1Click:Connect(function()
					-- simple quick menu
					local m = new("Frame", {Parent=cont, Size=UDim2.new(1,0,0,#options*26+8), Position=UDim2.new(0,0,1,4), BackgroundColor3=Color3.fromRGB(26,26,36)})
					round(m, 8); stroke(m,1,Color3.fromRGB(90,210,190),0.35)
					new("UIPadding", {Parent=m, PaddingTop=UDim.new(0,4),PaddingLeft=UDim.new(0,6),PaddingRight=UDim.new(0,6),PaddingBottom=UDim.new(0,4)})
					for i,opt in ipairs(options) do
						local it = new("TextButton",{Parent=m, AutoButtonColor=false, Size=UDim2.new(1,0,0,24), BackgroundTransparency=1, Text=tostring(opt), Font=Enum.Font.Gotham, TextSize=14, TextColor3=Color3.fromRGB(230,230,240)})
						it.MouseButton1Click:Connect(function() pick(opt); m:Destroy() end)
					end
					-- click-away
					task.spawn(function()
						local con; con = UIS.InputBegan:Connect(function(i)
							if i.UserInputType==Enum.UserInputType.MouseButton1 then m:Destroy(); con:Disconnect() end
						end)
					end)
				end)
				return {
					Refresh = function(_, newList) options = newList or options end
				}
			end

			function secAPI:NewKeybind(text, info, defaultKey, callback)
				defaultKey = defaultKey or Enum.KeyCode.F
				local cont = new("Frame", {Parent=ctrlHost, BackgroundColor3=Color3.fromRGB(40,40,50), Size=UDim2.new(1,0,0,36)}, nil); round(cont, 10); stroke(cont, 1, Color3.fromRGB(120,200,255), 0.28)
				local lab = new("TextLabel", {Parent=cont, BackgroundTransparency=1, Position=UDim2.new(0,12,0,0), Size=UDim2.new(1,-120,1,0), TextXAlignment=Enum.TextXAlignment.Left, Font=Enum.Font.Gotham, TextSize=14, TextColor3=Color3.fromRGB(235,235,245), Text=text.." ["..defaultKey.Name.."]"})
				local key = defaultKey
				UIS.InputBegan:Connect(function(i,gp)
					if not gp and i.KeyCode == key then if callback then pcall(callback) end end
				end)
				return {
					SetKey = function(_, kc) key = kc; lab.Text = text.." ["..(kc and kc.Name or "?").."]" end
				}
			end

			return secAPI
		end
	}

	-- tab switching
	local function activate()
		if self._activeTab and self._activeTab ~= tabBtn then
			self._activeTab.BackgroundColor3 = Color3.fromRGB(34,34,34)
			local prevPage = self._pageHost:FindFirstChild("Page_"..self._activeTab.Name:sub(5))
			if prevPage then prevPage.Visible = false end
		end
		self._activeTab = tabBtn
		tabBtn.BackgroundColor3 = Color3.fromRGB(48,48,60)
		for _,p in ipairs(self._pageHost:GetChildren()) do p.Visible = (p == page) end
	end
	tabBtn.MouseButton1Click:Connect(activate)
	if not self._activeTab then activate() end

	return api
end

-- convenience: toggle UI from code
function UFOHubX:ToggleUI()
	local win = self._win
	if not win then return end
	win.Visible = not win.Visible
	getgenv().UFO_ISOPEN = win.Visible
end

return UFOHubX
