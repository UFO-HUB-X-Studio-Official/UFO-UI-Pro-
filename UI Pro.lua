--[[
UFO UI Pro — STEP 1 (L/R Column Prototype, Fixed Placement)
โฟกัส: 1) แท็บแรกเปิดอัตโนมัติ  2) มี "คอลัมน์ซ้าย/ขวา" ชัดเจน (การ์ดมีขอบ)
       3) ปุ่มถูกวาง "ใน Section content" ไม่ไปโผล่ด้านบน

API ที่มีตอนนี้:
  local win = UFOUI.CreateLib("TITLE", themeTable?)
  local tab = win:NewTab("Main")
  local leftSec  = tab:NewSection("Left Panel", "Left")
  local rightSec = tab:NewSection("Right Panel", "Right")
  leftSec:NewButton("ปุ่มซ้าย", "", function() print("Left!") end)
  rightSec:NewButton("ปุ่มขวา", "", function() print("Right!") end)
]]--

-- ====== Utilities ======
local Camera = workspace.CurrentCamera
local function create(c, p, parent) local o=Instance.new(c) if p then for k,v in pairs(p) do o[k]=v end end if parent then o.Parent=parent end return o end
local function safeParent(gui)
  local ok=false
  if gethui then local s,p=pcall(gethui) if s and typeof(p)=="Instance" then gui.Parent=p ok=true end end
  if syn and syn.protect_gui then pcall(function() syn.protect_gui(gui) end) end
  if not ok then gui.Parent=game:GetService("CoreGui") end
end
local function scaleFor(v) local sx,sy=v.X/1280,v.Y/720 return math.clamp(math.min(sx,sy),0.85,1.35) end
local function stroke(inst,c,w) local s=inst:FindFirstChildOfClass("UIStroke") or create("UIStroke",nil,inst) s.Color=c; s.Thickness=w or 1; s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border return s end
local function corner(inst,r) local u=inst:FindFirstChildOfClass("UICorner") or create("UICorner",nil,inst) u.CornerRadius=UDim.new(0,r or 8) return u end

-- ====== Theme (ปรับง่าย) ======
local THEME = {
  SchemeColor  = Color3.fromRGB(0,255,140),
  Background   = Color3.fromRGB(14,14,14),
  Header       = Color3.fromRGB(20,20,20),
  TextColor    = Color3.fromRGB(235,235,235),
  ElementColor = Color3.fromRGB(22,22,22),
  Border       = Color3.fromRGB(30,90,60),
}

-- ====== Module / Classes ======
local UFOUI = {} ; UFOUI.__index = UFOUI
local Window = {} ; Window.__index = Window
local Tab    = {} ; Tab.__index    = Tab
local Section= {} ; Section.__index= Section

function UFOUI.CreateLib(title, theme)
  theme = theme or THEME
  local gui = create("ScreenGui", {Name="UFO_UI_PRO", ResetOnSpawn=false, IgnoreGuiInset=true}); safeParent(gui)
  local scale = create("UIScale", {Scale=scaleFor(Camera.ViewportSize)}, gui)
  Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function() scale.Scale=scaleFor(Camera.ViewportSize) end)

  -- หน้าต่างหลัก
  local root = create("Frame", {Size=UDim2.new(0,860,0,520), Position=UDim2.new(0.5,-430,0.5,-260),
                                BackgroundColor3=theme.Background, BorderSizePixel=0}, gui)
  corner(root,10); stroke(root, theme.Border, 1)

  -- Header
  local header = create("Frame", {Size=UDim2.new(1,0,0,36), BackgroundColor3=theme.Header, BorderSizePixel=0}, root)
  corner(header,8); stroke(header, theme.Border, 1)
  create("TextLabel", {BackgroundTransparency=1, Text=(title or "TITLE"), TextColor3=theme.TextColor, Font=Enum.Font.GothamBold,
                       TextXAlignment=Enum.TextXAlignment.Left, TextSize=16, Size=UDim2.new(1,-100,1,0), Position=UDim2.new(0,12,0,0)}, header)
  local hide = create("TextButton", {Size=UDim2.new(0,70,1,0), Position=UDim2.new(1,-74,0,0), BackgroundColor3=theme.Header,
                                     Text="Hide", TextColor3=theme.TextColor, AutoButtonColor=false, Font=Enum.Font.Gotham, TextSize=14}, header)
  corner(hide,8); stroke(hide, theme.Border, 1); hide.MouseButton1Click:Connect(function() gui.Enabled=false end)

  -- TabBar
  local tabbar = create("Frame", {Size=UDim2.new(1,-16,0,34), Position=UDim2.new(0,8,0,44), BackgroundColor3=theme.Header, BorderSizePixel=0}, root)
  corner(tabbar,8); stroke(tabbar, theme.Border, 1)
  local tabStrip = create("ScrollingFrame", {BackgroundTransparency=1, BorderSizePixel=0, ScrollBarThickness=4,
                                             Size=UDim2.new(1,-16,1,-8), Position=UDim2.new(0,8,0,4),
                                             AutomaticCanvasSize=Enum.AutomaticSize.X, CanvasSize=UDim2.new()}, tabbar)
  create("UIListLayout", {FillDirection=Enum.FillDirection.Horizontal, Padding=UDim.new(0,8),
                          SortOrder=Enum.SortOrder.LayoutOrder, VerticalAlignment=Enum.VerticalAlignment.Center}, tabStrip)

  -- Content
  local main = create("Frame", {Size=UDim2.new(1,-16,1,-(44+34+8)), Position=UDim2.new(0,8,0,44+34+8),
                                BackgroundTransparency=1, BorderSizePixel=0, ClipsDescendants=true}, root)

  return setmetatable({_gui=gui,_theme=theme,_tabBar=tabStrip,_main=main,_tabs={},_active=nil}, Window)
end

-- ====== Tabs ======
function Window:NewTab(name)
  local theme=self._theme
  local btn = create("TextButton", {AutomaticSize=Enum.AutomaticSize.X, Size=UDim2.new(0,0,1,0),
                                    BackgroundColor3=theme.Header, Text="  "..name.."  ",
                                    TextColor3=theme.TextColor, Font=Enum.Font.GothamBold, TextSize=14, AutoButtonColor=false}, self._tabBar)
  corner(btn,8); stroke(btn, theme.Border, 1)

  -- พื้นที่ของแท็บนี้
  local page = create("Frame", {BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), Visible=false}, self._main)

  -- คอลัมน์ซ้าย/ขวา = “การ์ดมีขอบ” เห็นชัด
  local LEFT_RATIO, RIGHT_RATIO = 0.25, 0.75
  local leftCard = create("Frame", {BackgroundColor3=theme.ElementColor, BorderSizePixel=0,
                                    Size=UDim2.new(LEFT_RATIO,-10,1,0), Position=UDim2.new(0,0,0,0)}, page)
  corner(leftCard,10); local ls=stroke(leftCard, theme.SchemeColor,1); ls.Transparency=0.25

  local rightCard = create("Frame", {BackgroundColor3=theme.ElementColor, BorderSizePixel=0,
                                     Size=UDim2.new(RIGHT_RATIO,-0,1,0), Position=UDim2.new(LEFT_RATIO,10,0,0)}, page)
  corner(rightCard,10); local rs=stroke(rightCard, theme.SchemeColor,1); rs.Transparency=0.25

  -- ที่วางคอนเทนต์จริง (ScrollingFrame) ในการ์ดแต่ละฝั่ง
  local left = create("ScrollingFrame", {BackgroundTransparency=1, BorderSizePixel=0, ScrollBarThickness=4,
                                         Size=UDim2.new(1,-20,1,-20), Position=UDim2.new(0,10,0,10),
                                         AutomaticCanvasSize=Enum.AutomaticSize.Y, CanvasSize=UDim2.new()}, leftCard)
  create("UIListLayout", {Padding=UDim.new(0,8), SortOrder=Enum.SortOrder.LayoutOrder}, left)

  local right = create("ScrollingFrame", {BackgroundTransparency=1, BorderSizePixel=0, ScrollBarThickness=4,
                                          Size=UDim2.new(1,-20,1,-20), Position=UDim2.new(0,10,0,10),
                                          AutomaticCanvasSize=Enum.AutomaticSize.Y, CanvasSize=UDim2.new()}, rightCard)
  create("UIListLayout", {Padding=UDim.new(0,8), SortOrder=Enum.SortOrder.LayoutOrder}, right)

  local tab = setmetatable({Name=name,_theme=theme,_btn=btn,_page=page,_left=left,_right=right,_sections={}}, Tab)

  local function activate()
    for _,t in ipairs(self._tabs) do t._page.Visible=false; t._btn.BackgroundColor3=theme.Header end
    page.Visible=true
    btn.BackgroundColor3=theme.Header:Lerp(theme.Background,0.20)
    self._active=tab
  end
  btn.MouseButton1Click:Connect(activate)

  table.insert(self._tabs, tab)
  if not self._active then activate() end -- เปิดแท็บแรกทันที
  return tab
end

-- ====== Sections ======
function Tab:NewSection(title, side)
  local theme=self._theme
  local parent = (string.lower(side or "Left")=="right") and self._right or self._left

  -- “การ์ดย่อย” ภายในคอลัมน์
  local card = create("Frame", {BackgroundColor3=theme.ElementColor, BorderSizePixel=0,
                                Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y}, parent)
  corner(card,10); local st=stroke(card, theme.SchemeColor,1); st.Transparency=0.35
  local ttl = create("TextLabel", {BackgroundTransparency=1, Text=(title or "Section"), TextColor3=theme.TextColor,
                                   Font=Enum.Font.GothamBold, TextSize=15, TextXAlignment=Enum.TextXAlignment.Left,
                                   Size=UDim2.new(1,-20,0,26), Position=UDim2.new(0,10,0,8)}, card)
  create("Frame", {BackgroundColor3=theme.SchemeColor, BackgroundTransparency=0.88,
                   Size=UDim2.new(1,-20,0,1), Position=UDim2.new(0,10,0,36), BorderSizePixel=0}, card)

  -- คอนเทนต์จริงของ Section (ใส่ปุ่มลง “ตรงนี้”)
  local content = create("Frame", {BackgroundTransparency=1, Size=UDim2.new(1,-20,0,0),
                                   Position=UDim2.new(0,10,0,44), AutomaticSize=Enum.AutomaticSize.Y}, card)
  create("UIListLayout", {Padding=UDim.new(0,8), SortOrder=Enum.SortOrder.LayoutOrder}, content)

  local sec = setmetatable({_theme=theme,_card=card,_title=ttl,_content=content}, Section)
  function sec:UpdateSection(t) ttl.Text=t or ttl.Text end
  return sec
end

-- ====== Buttons ======
local function buildButton(parent, theme)
  local b = create("TextButton", {Size=UDim2.new(1,0,0,36), BackgroundColor3=theme.ElementColor:Lerp(theme.Background,0.06),
                                  Text="Button", TextColor3=theme.TextColor, Font=Enum.Font.Gotham, TextSize=14,
                                  AutoButtonColor=false, ClipsDescendants=true}, parent)
  corner(b,8); local s=stroke(b, theme.Border,1); s.Transparency=0.4
  b.MouseEnter:Connect(function() b.BackgroundColor3=theme.ElementColor:Lerp(theme.Background,0.14); s.Transparency=0.25 end)
  b.MouseLeave:Connect(function() b.BackgroundColor3=theme.ElementColor:Lerp(theme.Background,0.06); s.Transparency=0.4 end)
  local pad = create("UIPadding",{PaddingLeft=UDim.new(0,12),PaddingRight=UDim.new(0,12)}, b)
  return b,pad
end

function Section:NewButton(text, info, cb)
  local b,pad = buildButton(self._content, self._theme) -- << ใส่ปุ่ม “ใน” Section content
  b.Text = text or "Button"
  if typeof(cb)=="function" then b.MouseButton1Click:Connect(cb) end
  local h = {}
  function h:UpdateButton(t) b.Text=t or b.Text end
  function h:SetStyle(st) if not st then return end
    if st.bg then b.BackgroundColor3=st.bg end
    if st.text then b.TextColor3=st.text end
    if st.padding then pad.PaddingLeft=UDim.new(0,st.padding); pad.PaddingRight=UDim.new(0,st.padding) end
  end
  function h:Show() b.Visible=true end
  function h:Hide() b.Visible=false end
  function h:Destroy() b:Destroy() end
  return h
end

return UFOUI
