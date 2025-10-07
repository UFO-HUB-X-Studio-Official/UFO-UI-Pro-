--[[
UFO UI Pro — STEP 1 (Sidebar Clean Starter)
Style ใกล้ภาพตัวอย่าง #2: Sidebar ซ้าย + Content ขวา + ปุ่มสี่เหลี่ยมข้อความกลาง
API: 
  local win = UFOUI.CreateLib("TITLE", theme?)
  local tab = win:NewTab("Main")
  local sec = tab:NewSection("Group")
  local btn = sec:NewButton("Run", "", function() print("Run") end)
]]

-- ===== Utilities =====
local Camera = workspace.CurrentCamera
local function create(c,p,parent) local o=Instance.new(c) if p then for k,v in pairs(p) do o[k]=v end end if parent then o.Parent=parent end return o end
local function safeParent(gui)
  local ok=false
  if gethui then local s,p=pcall(gethui) if s and typeof(p)=="Instance" then gui.Parent=p ok=true end end
  if syn and syn.protect_gui then pcall(function() syn.protect_gui(gui) end) end
  if not ok then gui.Parent = game:GetService("CoreGui") end
end
local function corner(inst,r) local u=inst:FindFirstChildOfClass("UICorner") or create("UICorner",nil,inst) u.CornerRadius=UDim.new(0,r or 10) return u end
local function stroke(inst,c,w,t) local s=inst:FindFirstChildOfClass("UIStroke") or create("UIStroke",nil,inst) s.Color=c s.Thickness=w or 1 s.Transparency=t or 0.5 s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border return s end
local function scaleFor(v) local sx,sy=v.X/1280,v.Y/720 return math.clamp(math.min(sx,sy),0.85,1.35) end

-- ===== Theme (เรียบ โปร) =====
local THEME = {
  bg        = Color3.fromRGB(18,18,20),
  panel     = Color3.fromRGB(24,24,26),
  header    = Color3.fromRGB(26,26,28),
  text      = Color3.fromRGB(235,235,235),
  subtext   = Color3.fromRGB(170,170,175),
  primary   = Color3.fromRGB(0,255,140),
  border    = Color3.fromRGB(60,60,70)
}

-- ===== Module =====
local UFOUI = {} ; UFOUI.__index = UFOUI
local Window = {} ; Window.__index = Window
local Tab    = {} ; Tab.__index    = Tab
local Section= {} ; Section.__index= Section

function UFOUI.CreateLib(title, theme)
  theme = theme or THEME
  local gui = create("ScreenGui", {Name="UFO_UI_PRO", ResetOnSpawn=false, IgnoreGuiInset=true})
  safeParent(gui)
  local scale = create("UIScale", {Scale=scaleFor(Camera.ViewportSize)}, gui)
  Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function() scale.Scale=scaleFor(Camera.ViewportSize) end)

  -- Root
  local root = create("Frame", {Size=UDim2.new(0, 880, 0, 520), Position=UDim2.new(0.5,-440,0.5,-260),
    BackgroundColor3=theme.bg, BorderSizePixel=0}, gui)
  corner(root,14); stroke(root, theme.border, 1, 0.6)

  -- Header
  local header = create("Frame", {Size=UDim2.new(1,0,0,38), BackgroundColor3=theme.header, BorderSizePixel=0}, root)
  corner(header,14); stroke(header, theme.border, 1, 0.6)
  create("TextLabel", {BackgroundTransparency=1, Text=(title or "UFO HUB X — Starter UI"),
    Font=Enum.Font.GothamBold, TextColor3=theme.text, TextSize=16,
    Size=UDim2.new(1,-100,1,0), Position=UDim2.new(0,16,0,0), TextXAlignment=Enum.TextXAlignment.Left}, header)
  local hide = create("TextButton",{Size=UDim2.new(0,58,1,-10), Position=UDim2.new(1,-66,0,5),
    BackgroundColor3=theme.panel, Text="Hide", TextColor3=theme.text, Font=Enum.Font.Gotham, TextSize=14, AutoButtonColor=false}, header)
  corner(hide,10); stroke(hide, theme.border, 1, 0.6); hide.MouseButton1Click:Connect(function() gui.Enabled=false end)

  -- Body split: Sidebar + Content
  local body = create("Frame",{Size=UDim2.new(1,-16,1,-(38+12)), Position=UDim2.new(0,8,0,38+8),
    BackgroundTransparency=1}, root)

  -- Sidebar (แท็บแนวตั้ง)
  local sidebar = create("Frame",{Size=UDim2.new(0,220,1,0), BackgroundColor3=theme.panel, BorderSizePixel=0}, body)
  corner(sidebar,12); stroke(sidebar, theme.border, 1, 0.6)
  local sideList = create("ScrollingFrame",{BackgroundTransparency=1, BorderSizePixel=0, ScrollBarThickness=4,
    Size=UDim2.new(1,-16,1,-16), Position=UDim2.new(0,8,0,8), AutomaticCanvasSize=Enum.AutomaticSize.Y, CanvasSize=UDim2.new()}, sidebar)
  create("UIListLayout",{Padding=UDim.new(0,8), SortOrder=Enum.SortOrder.LayoutOrder}, sideList)

  -- Content (พื้นที่ของแท็บ)
  local content = create("Frame",{Size=UDim2.new(1,-(220+12),1,0), Position=UDim2.new(0,220+12,0,0),
    BackgroundColor3=theme.panel, BorderSizePixel=0}, body)
  corner(content,12); stroke(content, theme.border, 1, 0.6)

  local win = setmetatable({
    _gui=gui, _theme=theme, _sidebar=sideList, _content=content,
    _tabs={}, _active=nil
  }, Window)

  return win
end

-- ===== Tabs (รายการเมนูซ้าย + หน้าเนื้อหา) =====
function Window:NewTab(name)
  local theme=self._theme
  -- ปุ่มแท็บใน sidebar (สี่เหลี่ยม ข้อความกลาง)
  local tabBtn = create("TextButton", {
    Size=UDim2.new(1,0,0,36), BackgroundColor3=theme.panel, Text=name,
    TextColor3=theme.text, Font=Enum.Font.Gotham, TextSize=14, AutoButtonColor=false
  }, self._sidebar)
  corner(tabBtn,10); stroke(tabBtn, theme.border, 1, 0.7)
  tabBtn.MouseEnter:Connect(function() tabBtn.BackgroundColor3 = theme.panel:lerp(theme.bg,0.1) end)
  tabBtn.MouseLeave:Connect(function() if self._active and self._active._btn~=tabBtn then tabBtn.BackgroundColor3=theme.panel end end)

  -- หน้าของแท็บนี้
  local page = create("ScrollingFrame", {
    BackgroundTransparency=1, BorderSizePixel=0, ScrollBarThickness=4,
    Size=UDim2.new(1,-20,1,-20), Position=UDim2.new(0,10,0,10),
    Visible=false, AutomaticCanvasSize=Enum.AutomaticSize.Y, CanvasSize=UDim2.new()
  }, self._content)
  create("UIListLayout",{Padding=UDim.new(0,12), SortOrder=Enum.SortOrder.LayoutOrder}, page)

  local tab = setmetatable({_win=self,_theme=theme,_btn=tabBtn,_page=page,_sections={},Name=name}, Tab)

  local function activate()
    for _,t in ipairs(self._tabs) do
      t._page.Visible=false
      t._btn.BackgroundColor3 = theme.panel
    end
    page.Visible=true
    tabBtn.BackgroundColor3 = theme.panel:lerp(theme.bg,0.18)
    self._active=tab
  end
  tabBtn.MouseButton1Click:Connect(activate)

  table.insert(self._tabs, tab)
  if not self._active then activate() end
  return tab
end

-- ===== Sections (การ์ดหัวข้อใน content) =====
function Tab:NewSection(title)
  local theme=self._theme
  local card = create("Frame",{BackgroundColor3=theme.panel, BorderSizePixel=0,
    Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y}, self._page)
  corner(card,10); stroke(card, theme.border, 1, 0.6)

  local head = create("TextLabel",{BackgroundTransparency=1, Text=(title or "Section"),
    TextColor3=theme.text, Font=Enum.Font.GothamBold, TextSize=15,
    Size=UDim2.new(1,-20,0,28), Position=UDim2.new(0,10,0,8), TextXAlignment=Enum.TextXAlignment.Left}, card)

  local content = create("Frame",{BackgroundTransparency=1, Size=UDim2.new(1,-20,0,0),
    Position=UDim2.new(0,10,0,40), AutomaticSize=Enum.AutomaticSize.Y}, card)
  create("UIListLayout",{Padding=UDim.new(0,8), SortOrder=Enum.SortOrder.LayoutOrder}, content)

  local sec = setmetatable({_tab=self,_theme=theme,_card=card,_content=content}, Section)
  function sec:UpdateSection(t) head.Text = t or head.Text end
  return sec
end

-- ===== Buttons (สี่เหลี่ยม, ข้อความอยู่กลาง) =====
local function buildButton(parent, theme)
  local b = create("TextButton", {
    Size=UDim2.new(1,0,0,38),
    BackgroundColor3 = theme.panel:lerp(theme.bg,0.06),
    Text = "Button", TextColor3=theme.text,
    Font=Enum.Font.Gotham, TextSize=14, AutoButtonColor=false
  }, parent)
  corner(b,8); local s=stroke(b, theme.border, 1, 0.65)
  b.MouseEnter:Connect(function() b.BackgroundColor3=theme.panel:lerp(theme.bg,0.14); s.Transparency=0.45 end)
  b.MouseLeave:Connect(function() b.BackgroundColor3=theme.panel:lerp(theme.bg,0.06); s.Transparency=0.65 end)
  return b
end

function Section:NewButton(text, info, callback)
  local b = buildButton(self._content, self._theme)
  b.Text = text or "Button"
  if typeof(callback)=="function" then b.MouseButton1Click:Connect(callback) end
  local h = {}
  function h:UpdateButton(t) b.Text = t or b.Text end
  function h:SetStyle(st)
    if not st then return end
    if st.bg   then b.BackgroundColor3 = st.bg end
    if st.text then b.TextColor3       = st.text end
  end
  function h:Show() b.Visible=true end
  function h:Hide() b.Visible=false end
  function h:Destroy() b:Destroy() end
  return h
end

return UFOUI
