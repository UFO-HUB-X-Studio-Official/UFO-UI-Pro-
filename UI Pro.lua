--[[
UFO UI Pro — STEP 1 (Fixed)
Core: Window + Tabs + Sections + Button (correct parenting)
]]

-------------------------
-- 0) Utilities & State
-------------------------
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local UFOUI = {}
UFOUI.__index = UFOUI
local __REGISTRY = { windows = {} }

function UFOUI.Version() return "0.1.1-step1-fixed" end

-- parent GUI ให้ปลอดภัยบน executor ส่วนใหญ่
local function safeParent(gui)
    local ok = false
    if gethui then
        local s,p = pcall(gethui)
        if s and typeof(p)=="Instance" then gui.Parent = p ok = true end
    end
    if syn and syn.protect_gui then pcall(function() syn.protect_gui(gui) end) end
    if not ok then (game:FindFirstChildOfClass("CoreGui") or game:GetService("CoreGui")).Parent = game
        gui.Parent = game:GetService("CoreGui")
    end
end

local function create(className, props, parent)
    local o = Instance.new(className)
    if props then for k,v in pairs(props) do o[k]=v end end
    if parent then o.Parent = parent end
    return o
end

------------------------------------------------
-- Theme (โทนเรียบเขียว-ดำ คล้ายตัวอย่าง)
------------------------------------------------
local DEFAULT_TOKENS = {
  colors = {
    primary  = Color3.fromRGB(0,255,140),
    bg       = Color3.fromRGB(12,12,12),
    header   = Color3.fromRGB(16,16,16),
    text     = Color3.fromRGB(235,235,235),
    element  = Color3.fromRGB(18,18,18),
    border   = Color3.fromRGB(25,70,50),
    subtle   = Color3.fromRGB(150,150,150),
  },
  radius  = { sm=8, md=10, lg=14 },
  stroke  = { width = 1 },
  spacing = { x=12, y=10 },
  layout  = { leftRatio=0.22, rightRatio=0.78 },
}

local function normalizeTheme(theme)
  if typeof(theme)=="table" then
    local t = table.clone(DEFAULT_TOKENS); local c=theme
    t.colors.primary = c.SchemeColor or t.colors.primary
    t.colors.bg      = c.Background  or t.colors.bg
    t.colors.header  = c.Header      or t.colors.header
    t.colors.text    = c.TextColor   or t.colors.text
    t.colors.element = c.ElementColor or t.colors.element
    return t
  end
  return DEFAULT_TOKENS
end

local function applyCornerStroke(inst, tokens, radius, borderColor, borderWidth)
  local cr = inst:FindFirstChildOfClass("UICorner") or create("UICorner", nil, inst)
  cr.CornerRadius = UDim.new(0, radius or tokens.radius.md)
  local st = inst:FindFirstChildOfClass("UIStroke") or create("UIStroke", nil, inst)
  st.Thickness = borderWidth or tokens.stroke.width
  st.Color = borderColor or tokens.colors.border
  st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
  return cr, st
end

local function computeScale(view)
  local sx = view.X/1280; local sy = view.Y/720
  return math.clamp(math.min(sx,sy), 0.75, 1.5)
end

------------------------------------------------
-- Classes
------------------------------------------------
local Window  = {} ; Window.__index  = Window
local Tab     = {} ; Tab.__index     = Tab
local Section = {} ; Section.__index = Section

-- ========== Window helpers ==========
function Window:ToggleUI() self._gui.Enabled = not self._gui.Enabled end
function Window:IsVisible() return self._gui.Enabled end

function Window:Expose(name) __REGISTRY.windows[name]=self return self end
function UFOUI:Attach(name)
  local w = __REGISTRY.windows[name]
  assert(w, "[UFO UI Pro] Attach failed: "..tostring(name))
  return w
end

-- สลับแท็บด้วยชื่อ (ให้แน่ใจว่ามีแท็บเปิด)
function Window:SwitchTab(name)
  for _,t in ipairs(self._tabs) do
    if t.Name==name then
      for _,u in ipairs(self._tabs) do
        u._frame.Visible=false
        u._btn.BackgroundColor3=self._tokens.colors.header
      end
      t._frame.Visible=true
      t._btn.BackgroundColor3=self._tokens.colors.header:Lerp(self._tokens.colors.bg,0.2)
      self._activeTab=t
      return true
    end
  end
  return false
end

-- ========== Window:NewTab ==========
function Window:NewTab(name)
  assert(type(name)=="string" and #name>0, "Tab name invalid")
  local tokens = self._tokens

  local tabBtn = create("TextButton", {
    AutomaticSize = Enum.AutomaticSize.X,
    Size = UDim2.new(0,0,1,0),
    BackgroundColor3 = tokens.colors.header,
    TextColor3 = tokens.colors.text,
    Text = "  "..name.."  ",
    Font = Enum.Font.GothamBold, TextSize = 14, AutoButtonColor=false
  }, self._tabBar)
  applyCornerStroke(tabBtn, tokens, tokens.radius.sm, tokens.colors.border, tokens.stroke.width)

  local tabFrame = create("Frame", {
    BackgroundTransparency=1, Size=UDim2.new(1,0,1,-54), Position=UDim2.new(0,0,0,54),
    Visible=false
  }, self._main)

  -- Left/Right panels (โปร่งเพื่อให้เห็นการ์ดชัด)
  local left = create("ScrollingFrame", {
    BackgroundTransparency=1, BorderSizePixel=0, ScrollBarThickness=6,
    Size = UDim2.new(tokens.layout.leftRatio, -8, 1, 0), Position = UDim2.new(0,8,0,0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new()
  }, tabFrame)

  local right = create("ScrollingFrame", {
    BackgroundTransparency=1, BorderSizePixel=0, ScrollBarThickness=6,
    Size = UDim2.new(tokens.layout.rightRatio, -16, 1, 0),
    Position = UDim2.new(tokens.layout.leftRatio,16,0,0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new()
  }, tabFrame)

  local function addList(container)
    create("UIListLayout", {Padding=UDim.new(0,tokens.spacing.y), SortOrder=Enum.SortOrder.LayoutOrder}, container)
    create("UIPadding", {PaddingTop=UDim.new(0,10),PaddingLeft=UDim.new(0,10),PaddingRight=UDim.new(0,10),PaddingBottom=UDim.new(0,10)}, container)
  end
  addList(left); addList(right)

  local tabObj = setmetatable({
    _win=self,_tokens=tokens,_frame=tabFrame,_left=left,_right=right,_btn=tabBtn,_sections={},Name=name
  }, Tab)

  tabBtn.MouseEnter:Connect(function()
    if self._activeTab ~= tabObj then tabBtn.BackgroundColor3=tokens.colors.header:Lerp(tokens.colors.bg,0.1) end
  end)
  tabBtn.MouseLeave:Connect(function()
    if self._activeTab ~= tabObj then tabBtn.BackgroundColor3=tokens.colors.header end
  end)
  tabBtn.MouseButton1Click:Connect(function()
    self:SwitchTab(name)
  end)

  table.insert(self._tabs, tabObj)

  -- เปิดแท็บแรกทันที (จุดที่ทำให้ปุ่มไม่ขึ้นถูกแก้ตรงนี้)
  if not self._activeTab then
    self:SwitchTab(name)
  end

  return tabObj
end

-- ========== Tab:NewSection ==========
function Tab:NewSection(name, side)
  side = side or "Left"
  local container = (string.lower(side)=="right") and self._right or self._left
  local tokens = self._tokens

  -- การ์ด Section
  local sec = create("Frame", {
    BackgroundColor3=tokens.colors.element, BorderSizePixel=0,
    Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y
  }, container)
  local _, stroke = applyCornerStroke(sec, tokens, tokens.radius.lg, tokens.colors.primary, 1)
  stroke.Transparency = 0.25

  local title = create("TextLabel", {
    BackgroundTransparency=1, Text=name or "Section",
    Font=Enum.Font.GothamBold, TextColor3=tokens.colors.text, TextSize=15,
    Size=UDim2.new(1,-20,0,26), Position=UDim2.new(0,10,0,8),
    TextXAlignment=Enum.TextXAlignment.Left
  }, sec)
  create("Frame", {
    BackgroundColor3=tokens.colors.primary, BackgroundTransparency=0.88,
    Size=UDim2.new(1,-20,0,1), Position=UDim2.new(0,10,0,36), BorderSizePixel=0
  }, sec)

  -- พื้นที่เนื้อหาคอนโทรลของ Section (สำคัญ: ปุ่มจะเข้า container นี้)
  local content = create("Frame", {
    BackgroundTransparency=1, Size=UDim2.new(1,-20,0,0), Position=UDim2.new(0,10,0,44),
    AutomaticSize=Enum.AutomaticSize.Y
  }, sec)
  create("UIListLayout", {Padding=UDim.new(0,self._tokens.spacing.y), SortOrder=Enum.SortOrder.LayoutOrder}, content)

  local sectionObj = setmetatable({
    _tab=self, _tokens=tokens, _frame=sec, _title=title, _content=content,
    _controls={}, Name=name or "Section", Side=side
  }, Section)

  function sectionObj:UpdateSection(newTitle) self._title.Text = newTitle end
  table.insert(self._sections, sectionObj)
  return sectionObj
end

-- ========== Section:NewButton ==========
local function buildButton(parent, tokens)
  local btn = create("TextButton", {
    Size=UDim2.new(1,0,0,36), BackgroundColor3=tokens.colors.element:Lerp(tokens.colors.bg,0.06),
    TextColor3=tokens.colors.text, Text="Button", Font=Enum.Font.Gotham, TextSize=14,
    AutoButtonColor=false, ClipsDescendants=true
  }, parent)
  local _, st = applyCornerStroke(btn, tokens, tokens.radius.md, tokens.colors.border, 1)
  st.Transparency = 0.4

  local icon = create("ImageLabel", {
    Name="Icon", BackgroundTransparency=1, Size=UDim2.new(0,18,0,18),
    Position=UDim2.new(0,12,0.5,-9), ImageTransparency=0, ImageColor3=Color3.new(1,1,1),
    Visible=false, ZIndex=2
  }, btn)
  local padding = create("UIPadding", {PaddingLeft=UDim.new(0,14),PaddingRight=UDim.new(0,14)}, btn)

  btn.MouseEnter:Connect(function()
    btn.BackgroundColor3=tokens.colors.element:Lerp(tokens.colors.bg,0.14); st.Transparency=0.25
  end)
  btn.MouseLeave:Connect(function()
    btn.BackgroundColor3=tokens.colors.element:Lerp(tokens.colors.bg,0.06); st.Transparency=0.4
  end)

  return btn, icon, padding
end

function Section:NewButton(text, info, callback)
  local tokens = self._tokens
  -- ใส่ปุ่มลงใน "self._content" (นี่แหละจุดแก้หลัก)
  local btn, icon, padding = buildButton(self._content, tokens)
  btn.Text = text or "Button"

  local handle = { _btn=btn, _icon=icon, _tokens=tokens, _stateStyles={} }

  btn.MouseButton1Click:Connect(function()
    if typeof(callback)=="function" then callback() end
  end)

  function handle:UpdateButton(newText) btn.Text = newText or btn.Text end
  function handle:SetStyle(st)
    if not st then return end
    if st.bg then btn.BackgroundColor3 = st.bg end
    if st.text then btn.TextColor3 = st.text end
    if st.padding then padding.PaddingLeft=UDim.new(0,st.padding); padding.PaddingRight=UDim.new(0,st.padding) end
    applyCornerStroke(btn, tokens, st.radius or tokens.radius.md,
      (st.border and st.border.color) or tokens.colors.border,
      (st.border and st.border.width) or 1
    )
    if st.bgImage and st.bgImage.id then
      local bg = btn:FindFirstChild("BGImage") or create("ImageLabel", {
        Name="BGImage", BackgroundTransparency=1, Size=UDim2.fromScale(1,1), ZIndex=0
      }, btn)
      bg.Image = st.bgImage.id
      bg.ImageTransparency = st.bgImage.transparency or 0.1
      bg.ScaleType = (st.bgImage.fit=="cover") and Enum.ScaleType.Crop or Enum.ScaleType.Fit
    end
  end
  function handle:SetIcon(opt)
    if not opt or not opt.id then icon.Visible=false return end
    icon.Visible=true; icon.Image=opt.id; if opt.size then icon.Size=opt.size end
    if opt.colorize then icon.ImageColor3=tokens.colors.primary end
    local p=(opt.placement or "left"):lower()
    if p=="left" then
      icon.Position=UDim2.new(0,12,0.5,-9); padding.PaddingLeft=UDim.new(0,(opt.padding or 8)+28)
    elseif p=="right" then
      icon.Position=UDim2.new(1,-((opt.padding or 8)+18+10),0.5,-9); padding.PaddingRight=UDim.new(0,(opt.padding or 8)+28)
    elseif p=="background" then
      icon.Size=UDim2.new(1,0,1,0); icon.ImageTransparency=0.85
    end
  end
  function handle:Show() btn.Visible=true end
  function handle:Hide() btn.Visible=false end
  function handle:Destroy() btn:Destroy() end

  table.insert(self._controls, handle)
  return handle
end

--------------------------------------
-- สร้างหน้าต่างหลัก
--------------------------------------
function UFOUI.CreateLib(title, theme)
  local gui = create("ScreenGui", {Name="UFO_UI_PRO", ResetOnSpawn=false, IgnoreGuiInset=true, Enabled=true})
  safeParent(gui)

  local scale = create("UIScale", {Scale=computeScale(Camera.ViewportSize)}, gui)
  Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    scale.Scale = computeScale(Camera.ViewportSize)
  end)

  local tokens = normalizeTheme(theme)

  local root = create("Frame", {
    Name="Root", Size=UDim2.new(0,900,0,560), Position=UDim2.new(0.5,-450,0.5,-280),
    BackgroundColor3=tokens.colors.bg, BorderSizePixel=0
  }, gui)
  applyCornerStroke(root, tokens, tokens.radius.lg, tokens.colors.border, 1)

  local header = create("Frame", {
    Name="Header", Size=UDim2.new(1,0,0,34), BackgroundColor3=tokens.colors.header, BorderSizePixel=0
  }, root)
  applyCornerStroke(header, tokens, tokens.radius.sm, tokens.colors.border, 1)

  local titleLbl = create("TextLabel", {
    BackgroundTransparency=1, Size=UDim2.new(1,-120,1,0), Position=UDim2.new(0,60,0,0),
    TextXAlignment=Enum.TextXAlignment.Center, RichText=true,
    Text = title or "<b>UFO <font color='#00FF8C'>HUB X</font></b>",
    Font=Enum.Font.GothamBold, TextColor3=tokens.colors.text, TextSize=16
  }, header)

  local closeBtn = create("TextButton", {
    Size=UDim2.new(0,28,0,28), Position=UDim2.new(1,-36,0,3),
    BackgroundColor3=Color3.fromRGB(160,30,30), Text="x",
    TextColor3=Color3.new(1,1,1), Font=Enum.Font.Gotham, TextSize=14, AutoButtonColor=false
  }, header)
  applyCornerStroke(closeBtn, tokens, tokens.radius.sm, tokens.colors.border, 1)
  closeBtn.MouseButton1Click:Connect(function() gui.Enabled=false end)

  local tabBar = create("Frame", {
    Name="TabBar", Size=UDim2.new(1,-16,0,34), Position=UDim2.new(0,8,0,42),
    BackgroundColor3=tokens.colors.header, BorderSizePixel=0
  }, root)
  applyCornerStroke(tabBar, tokens, tokens.radius.sm, tokens.colors.border, 1)

  local tabList = create("ScrollingFrame", {
    Size=UDim2.new(1,-16,1,-8), Position=UDim2.new(0,8,0,4),
    BackgroundTransparency=1, BorderSizePixel=0, ScrollBarThickness=4,
    AutomaticCanvasSize=Enum.AutomaticSize.X, CanvasSize=UDim2.new()
  }, tabBar)
  create("UIListLayout", {
    FillDirection=Enum.FillDirection.Horizontal, Padding=UDim.new(0,8),
    SortOrder=Enum.SortOrder.LayoutOrder, VerticalAlignment=Enum.VerticalAlignment.Center
  }, tabList)

  local main = create("Frame", {
    Name="Main", Size=UDim2.new(1,-16,1,-(42+34+8)), Position=UDim2.new(0,8,0,42+34+8),
    BackgroundTransparency=1, BorderSizePixel=0, ClipsDescendants=true
  }, root)

  local win = setmetatable({
    _gui=gui, _root=root, _header=header, _tabBar=tabList, _main=main,
    _tokens=tokens, _tabs={}, _activeTab=nil
  }, Window)

  return win
end

UFOUI.CreateLib = UFOUI.CreateLib
return UFOUI
