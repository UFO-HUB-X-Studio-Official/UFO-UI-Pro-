--[[
UFO UI Pro — Trial Minimal STEP 1
จุดประสงค์: ทำ UI ทดลองที่หน้าตาเรียบแบบ Kavo และ "ปุ่มขึ้นถูกที่" ทันที
API: CreateLib → NewTab → NewSection → NewButton
ที่แก้ได้: DEFAULT_THEME, SIZE/POS, ratio L/R
]]--

-- ========= Utilities =========
local Players = game:GetService("Players")
local Camera  = workspace.CurrentCamera

local function create(className, props, parent)
  local o = Instance.new(className)
  if props then for k,v in pairs(props) do o[k]=v end end
  if parent then o.Parent = parent end
  return o
end

local function safeParent(gui)
  local ok=false
  if gethui then local s,p=pcall(gethui) if s and typeof(p)=="Instance" then gui.Parent=p ok=true end end
  if syn and syn.protect_gui then pcall(function() syn.protect_gui(gui) end) end
  if not ok then gui.Parent = game:GetService("CoreGui") end
end

-- ========= Theme (ปรับได้) =========
local DEFAULT_THEME = {
  SchemeColor  = Color3.fromRGB(0,255,140), -- เขียวหลัก
  Background   = Color3.fromRGB(15,15,15),
  Header       = Color3.fromRGB(20,20,20),
  TextColor    = Color3.fromRGB(235,235,235),
  ElementColor = Color3.fromRGB(22,22,22),
  Border       = Color3.fromRGB(30,90,60),
}

-- ========= Module =========
local UFOUI = {}
UFOUI.__index = UFOUI

local Window  = {} ; Window.__index  = Window
local Tab     = {} ; Tab.__index     = Tab
local Section = {} ; Section.__index = Section

local function applyCornerStroke(inst, radius, color)
  local c = inst:FindFirstChildOfClass("UICorner") or create("UICorner", nil, inst)
  c.CornerRadius = UDim.new(0, 8)
  local s = inst:FindFirstChildOfClass("UIStroke") or create("UIStroke", nil, inst)
  s.Thickness = 1
  s.Color = color or DEFAULT_THEME.Border
  s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
  return c, s
end

local function scaleFor(view)
  local sx,sy = view.X/1280, view.Y/720
  return math.clamp(math.min(sx,sy), 0.8, 1.4)
end

-- ========= CreateLib =========
function UFOUI.CreateLib(title, theme)
  theme = theme or DEFAULT_THEME
  local gui = create("ScreenGui", {Name="UFO_UI_PRO_TRIAL", ResetOnSpawn=false, IgnoreGuiInset=true})
  safeParent(gui)
  local uiScale = create("UIScale", {Scale = scaleFor(Camera.ViewportSize)}, gui)
  Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    uiScale.Scale = scaleFor(Camera.ViewportSize)
  end)

  -- Root Window
  local root = create("Frame", {
    Size=UDim2.new(0, 860, 0, 520),
    Position=UDim2.new(0.5, -430, 0.5, -260),
    BackgroundColor3 = theme.Background, BorderSizePixel = 0
  }, gui)
  applyCornerStroke(root, 8, theme.Border)

  -- Header
  local header = create("Frame", {
    Size=UDim2.new(1,0,0,36), BackgroundColor3=theme.Header, BorderSizePixel=0
  }, root)
  applyCornerStroke(header, 8, theme.Border)
  local titleLbl = create("TextLabel", {
    BackgroundTransparency=1, Size=UDim2.new(1,-100,1,0), Position=UDim2.new(0,12,0,0),
    Text=(title or "UFO UI Pro (Trial)"), Font=Enum.Font.GothamBold,
    TextColor3=theme.TextColor, TextSize=16, TextXAlignment=Enum.TextXAlignment.Left
  }, header)
  local closeBtn = create("TextButton", {
    Size=UDim2.new(0,70,1,0), Position=UDim2.new(1,-74,0,0), BackgroundColor3=theme.Header,
    Text="Hide", TextColor3=theme.TextColor, AutoButtonColor=false, Font=Enum.Font.Gotham, TextSize=14
  }, header)
  applyCornerStroke(closeBtn, 8, theme.Border)
  closeBtn.MouseButton1Click:Connect(function() gui.Enabled=false end)

  -- TabBar
  local tabBar = create("Frame", {
    Size=UDim2.new(1,-16,0,34), Position=UDim2.new(0,8,0,44),
    BackgroundColor3=theme.Header, BorderSizePixel=0
  }, root)
  applyCornerStroke(tabBar, 8, theme.Border)
  local tabStrip = create("ScrollingFrame", {
    BackgroundTransparency=1, BorderSizePixel=0, ScrollBarThickness=4,
    Size=UDim2.new(1,-16,1,-8), Position=UDim2.new(0,8,0,4),
    AutomaticCanvasSize=Enum.AutomaticSize.X, CanvasSize=UDim2.new()
  }, tabBar)
  local tabLayout = create("UIListLayout", {
    FillDirection=Enum.FillDirection.Horizontal, Padding=UDim.new(0,8),
    SortOrder=Enum.SortOrder.LayoutOrder, VerticalAlignment=Enum.VerticalAlignment.Center
  }, tabStrip)

  -- Content area
  local main = create("Frame", {
    Size=UDim2.new(1,-16,1,-(44+34+8)), Position=UDim2.new(0,8,0,44+34+8),
    BackgroundTransparency=1, BorderSizePixel=0, ClipsDescendants=true
  }, root)

  local win = setmetatable({
    _gui=gui, _root=root, _header=header, _tabBar=tabStrip, _main=main,
    _theme=theme, _tabs={}, _activeTab=nil
  }, Window)

  return win
end

-- ========= Tabs =========
function Window:NewTab(name)
  local theme = self._theme
  local btn = create("TextButton", {
    AutomaticSize=Enum.AutomaticSize.X, Size=UDim2.new(0,0,1,0),
    BackgroundColor3=theme.Header, Text="  "..name.."  ",
    TextColor3=theme.TextColor, AutoButtonColor=false, Font=Enum.Font.GothamBold, TextSize=14
  }, self._tabBar)
  applyCornerStroke(btn, 8, theme.Border)

  local frame = create("Frame", {
    BackgroundTransparency=1, Size=UDim2.new(1,0,1,-0), Visible=false
  }, self._main)

  -- Left/Right columns (โปร่ง)
  local LEFT_RATIO, RIGHT_RATIO = 0.22, 0.78
  local left = create("ScrollingFrame", {
    BackgroundTransparency=1, BorderSizePixel=0, ScrollBarThickness=4,
    Size=UDim2.new(LEFT_RATIO, -8, 1, 0), Position=UDim2.new(0,0,0,0),
    AutomaticCanvasSize=Enum.AutomaticSize.Y, CanvasSize=UDim2.new()
  }, frame)
  local right = create("ScrollingFrame", {
    BackgroundTransparency=1, BorderSizePixel=0, ScrollBarThickness=4,
    Size=UDim2.new(RIGHT_RATIO, -0, 1, 0), Position=UDim2.new(LEFT_RATIO, 8, 0, 0),
    AutomaticCanvasSize=Enum.AutomaticSize.Y, CanvasSize=UDim2.new()
  }, frame)
  for _,col in ipairs({left,right}) do
    create("UIListLayout", {Padding=UDim.new(0,10), SortOrder=Enum.SortOrder.LayoutOrder}, col)
    create("UIPadding", {PaddingTop=UDim.new(0,10), PaddingLeft=UDim.new(0,10), PaddingRight=UDim.new(0,10), PaddingBottom=UDim.new(0,10)}, col)
  end

  local tab = setmetatable({
    _win=self, _theme=theme, _btn=btn, _frame=frame, _left=left, _right=right, _sections={},
    Name=name
  }, Tab)

  btn.MouseButton1Click:Connect(function()
    for _,t in ipairs(self._tabs) do
      t._frame.Visible=false
      t._btn.BackgroundColor3=theme.Header
    end
    frame.Visible=true
    btn.BackgroundColor3 = theme.Header:Lerp(theme.Background, 0.20)
    self._activeTab = tab
  end)

  table.insert(self._tabs, tab)
  if not self._activeTab then btn:Activate() btn.MouseButton1Click:Fire() end
  return tab
end

-- ========= Sections =========
function Tab:NewSection(name, side)
  local theme = self._theme
  local parent = (string.lower(side or "Left")=="right") and self._right or self._left

  local card = create("Frame", {
    BackgroundColor3=theme.ElementColor, BorderSizePixel=0,
    Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y
  }, parent)
  local _, st = applyCornerStroke(card, 10, theme.Border)
  st.Color = theme.SchemeColor
  st.Transparency = 0.25

  local title = create("TextLabel", {
    BackgroundTransparency=1, Text=(name or "Section"), Font=Enum.Font.GothamBold,
    TextColor3=theme.TextColor, TextSize=15, Size=UDim2.new(1,-20,0,26),
    Position=UDim2.new(0,10,0,8), TextXAlignment=Enum.TextXAlignment.Left
  }, card)
  create("Frame", {BackgroundColor3=theme.SchemeColor, BackgroundTransparency=0.88,
    Size=UDim2.new(1,-20,0,1), Position=UDim2.new(0,10,0,36), BorderSizePixel=0}, card)

  local content = create("Frame", {
    BackgroundTransparency=1, Size=UDim2.new(1,-20,0,0), Position=UDim2.new(0,10,0,44),
    AutomaticSize=Enum.AutomaticSize.Y
  }, card)
  create("UIListLayout", {Padding=UDim.new(0,10), SortOrder=Enum.SortOrder.LayoutOrder}, content)

  local sec = setmetatable({
    _tab=self, _theme=theme, _card=card, _content=content, _controls={}
  }, Section)

  function sec:UpdateSection(newTitle) title.Text = newTitle or title.Text end
  return sec
end

-- ========= Buttons =========
local function buildButton(parent, theme)
  local b = create("TextButton", {
    Size=UDim2.new(1,0,0,36), BackgroundColor3=theme.ElementColor:Lerp(theme.Background,0.06),
    Text="Button", TextColor3=theme.TextColor, Font=Enum.Font.Gotham, TextSize=14,
    AutoButtonColor=false, ClipsDescendants=true
  }, parent)
  local _, st = applyCornerStroke(b, 8, theme.Border); st.Transparency=0.4

  b.MouseEnter:Connect(function()
    b.BackgroundColor3 = theme.ElementColor:Lerp(theme.Background,0.14); st.Transparency=0.25
  end)
  b.MouseLeave:Connect(function()
    b.BackgroundColor3 = theme.ElementColor:Lerp(theme.Background,0.06); st.Transparency=0.4
  end)

  local icon = create("ImageLabel", {
    Name="Icon", BackgroundTransparency=1, Size=UDim2.new(0,18,0,18),
    Position=UDim2.new(0,12,0.5,-9), Visible=false, ZIndex=2
  }, b)
  local pad = create("UIPadding", {PaddingLeft=UDim.new(0,14), PaddingRight=UDim.new(0,14)}, b)
  return b, icon, pad
end

function Section:NewButton(text, info, callback)
  local b, icon, pad = buildButton(self._content, self._theme)
  b.Text = text or "Button"
  if typeof(callback)=="function" then
    b.MouseButton1Click:Connect(callback)
  end

  local handle = {}
  function handle:UpdateButton(newText) b.Text = newText or b.Text end
  function handle:SetStyle(st)
    if not st then return end
    if st.bg then b.BackgroundColor3 = st.bg end
    if st.text then b.TextColor3 = st.text end
    if st.padding then pad.PaddingLeft=UDim.new(0,st.padding); pad.PaddingRight=UDim.new(0,st.padding) end
  end
  function handle:SetIcon(opt)
    if not opt or not opt.id then icon.Visible=false return end
    icon.Visible=true; icon.Image = opt.id
    if opt.size then icon.Size = opt.size end
    local p = (opt.placement or "left"):lower()
    if p=="left" then
      icon.Position = UDim2.new(0,12,0.5,-9); pad.PaddingLeft = UDim.new(0,(opt.padding or 8)+28)
    elseif p=="right" then
      icon.Position = UDim2.new(1,-((opt.padding or 8)+28),0.5,-9); pad.PaddingRight = UDim.new(0,(opt.padding or 8)+28)
    elseif p=="background" then
      icon.Size = UDim2.new(1,0,1,0); icon.ImageTransparency=0.85
    end
  end
  function handle:Show() b.Visible=true end
  function handle:Hide() b.Visible=false end
  function handle:Destroy() b:Destroy() end
  return handle
end

return UFOUI
