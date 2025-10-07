--[[
UFO UI Pro — STEP 1 (Sidebar, Active Tabs, Close X, Toggle Button, Theme API)

API ที่ใช้ตอนนี้:
  local UFOUI = loadstring(game:HttpGet(...))()
  local win   = UFOUI.CreateLib("Thunder-ish Starter")         -- สร้างหน้าต่าง
  local tab   = win:NewTab("Main")                             -- สร้างแท็บใน Sidebar (ยังไม่ active)
  local sec   = tab:NewSection("Pet")                          -- การ์ดหัวข้อในคอนเทนต์ขวา
  sec:NewButton("Auto Middle Pets","", function() print("ok") end)

  -- ปุ่มลอย เปิด/ปิด UI (ผู้ใช้เปลี่ยนสี/รูปได้)
  win:SetToggleButton({
    borderColor = Color3.fromRGB(255,255,255),
    bg          = Color3.fromRGB(20,20,22),
    imageId     = "rbxassetid://0",  -- ใส่รูปได้ (0 = ไม่ใช้รูป)
    pos         = UDim2.new(0, 20, 1, -100), -- มุมล่างซ้าย
    size        = UDim2.new(0, 48, 0, 48)
  })

  -- เปลี่ยนธีมทั้ง UI (สดๆ)
  win:SetTheme({
    bg        = Color3.fromRGB(18,18,20),
    panel     = Color3.fromRGB(24,24,26),
    header    = Color3.fromRGB(26,26,28),
    text      = Color3.fromRGB(235,235,235),
    subtext   = Color3.fromRGB(170,170,175),
    primary   = Color3.fromRGB(0,255,140),
    border    = Color3.fromRGB(60,60,70)
  })
]]--

-- ========= Utilities =========
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

-- ========= Theme =========
local DEFAULT = {
  bg        = Color3.fromRGB(18,18,20),
  panel     = Color3.fromRGB(24,24,26),
  header    = Color3.fromRGB(26,26,28),
  text      = Color3.fromRGB(235,235,235),
  subtext   = Color3.fromRGB(170,170,175),
  primary   = Color3.fromRGB(0,255,140),
  border    = Color3.fromRGB(60,60,70)
}

-- ========= Module / Classes =========
local UFOUI  = {} ; UFOUI.__index = UFOUI
local Window = {} ; Window.__index = Window
local Tab    = {} ; Tab.__index    = Tab
local Section= {} ; Section.__index= Section

-- ---- CreateLib ----
function UFOUI.CreateLib(title, theme)
  theme = theme or DEFAULT
  local gui = create("ScreenGui", {Name="UFO_UI_PRO", ResetOnSpawn=false, IgnoreGuiInset=true})
  safeParent(gui)
  local scale = create("UIScale", {Scale=scaleFor(Camera.ViewportSize)}, gui)
  Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function() scale.Scale=scaleFor(Camera.ViewportSize) end)

  -- Root
  local root = create("Frame", {Size=UDim2.new(0, 900, 0, 540), Position=UDim2.new(0.5,-450,0.5,-270),
    BackgroundColor3=theme.bg, BorderSizePixel=0}, gui)
  corner(root,14); stroke(root, theme.border, 1, 0.6)

  -- Header
  local header = create("Frame", {Size=UDim2.new(1,0,0,38), BackgroundColor3=theme.header, BorderSizePixel=0}, root)
  corner(header,14); stroke(header, theme.border, 1, 0.6)

  local titleLbl = create("TextLabel", {
    BackgroundTransparency=1, Text=(title or "UFO HUB X — Starter"),
    Font=Enum.Font.GothamBold, TextColor3=theme.text, TextSize=16,
    Size=UDim2.new(1,-80,1,0), Position=UDim2.new(0,16,0,0), TextXAlignment=Enum.TextXAlignment.Left
  }, header)

  -- ปุ่มกากบาท (X) ขวาบน
  local closeBtn = create("TextButton", {
    Size=UDim2.new(0,28,0,28), Position=UDim2.new(1,-36,0,5),
    BackgroundColor3=theme.panel, Text="x", TextColor3=theme.text,
    Font=Enum.Font.GothamBold, TextSize=14, AutoButtonColor=false
  }, header)
  corner(closeBtn,8); stroke(closeBtn, theme.border, 1, 0.6)
  closeBtn.MouseButton1Click:Connect(function() gui.Enabled=false end)

  -- Body split: Sidebar + Content
  local body = create("Frame",{Size=UDim2.new(1,-16,1,-(38+12)), Position=UDim2.new(0,8,0,38+8),
    BackgroundTransparency=1}, root)

  -- Sidebar
  local sidebar = create("Frame",{Size=UDim2.new(0,230,1,0), BackgroundColor3=theme.panel, BorderSizePixel=0}, body)
  corner(sidebar,12); stroke(sidebar, theme.border, 1, 0.6)
  local sideList = create("ScrollingFrame",{BackgroundTransparency=1, BorderSizePixel=0, ScrollBarThickness=4,
    Size=UDim2.new(1,-16,1,-16), Position=UDim2.new(0,8,0,8), AutomaticCanvasSize=Enum.AutomaticSize.Y, CanvasSize=UDim2.new()}, sidebar)
  create("UIListLayout",{Padding=UDim.new(0,8), SortOrder=Enum.SortOrder.LayoutOrder}, sideList)

  -- Content (พื้นที่แท็บ)
  local content = create("Frame",{Size=UDim2.new(1,-(230+12),1,0), Position=UDim2.new(0,230+12,0,0),
    BackgroundColor3=theme.panel, BorderSizePixel=0}, body)
  corner(content,12); stroke(content, theme.border, 1, 0.6)

  -- สถานะ/รีจิสทรีสำหรับ theme update
  local win = setmetatable({
    _gui=gui, _theme=theme, _sidebar=sideList, _content=content,
    _header=header, _root=root, _controls={}, _tabs={}, _active=nil,
    _toggleBtn=nil
  }, Window)

  -- API: ปุ่มลอย เปิด/ปิด UI (custom border/img)
  function win:SetToggleButton(opt)
    opt = opt or {}
    if self._toggleBtn then self._toggleBtn:Destroy() self._toggleBtn=nil end
    local holder = create("Frame", {BackgroundTransparency=1, Size=opt.size or UDim2.new(0,48,0,48),
                                    Position=opt.pos or UDim2.new(0,20,1,-100)}, gui)
    local btn = create("ImageButton", {
      BackgroundColor3 = opt.bg or Color3.fromRGB(20,20,22),
      Size = UDim2.new(1,0,1,0), Image = opt.imageId or "rbxassetid://0",
      ImageTransparency = (opt.imageId and 0) or 1
    }, holder)
    corner(btn,10)
    local st = stroke(btn, opt.borderColor or Color3.fromRGB(255,255,255), 2, 0) -- เส้นขาวรอบกรอบ
    btn.MouseButton1Click:Connect(function() gui.Enabled = not gui.Enabled end)
    self._toggleBtn = holder
    -- method ไว้เปลี่ยน runtime
    function self._toggleBtn:SetStyle(o)
      o=o or {}
      btn.BackgroundColor3 = o.bg or btn.BackgroundColor3
      st.Color             = o.borderColor or st.Color
      btn.Image            = o.imageId or btn.Image
      holder.Size          = o.size or holder.Size
      holder.Position      = o.pos  or holder.Position
    end
    return self._toggleBtn
  end

  -- API: เปลี่ยนธีมสด ๆ
  function win:SetTheme(colors)
    for k,v in pairs(colors or {}) do self._theme[k]=v end
    local t=self._theme
    self._root.BackgroundColor3  = t.bg
    self._header.BackgroundColor3= t.header
    self._content.BackgroundColor3= t.panel
    sidebar.BackgroundColor3     = t.panel
    -- ปรับ UIStroke/ตัวอักษรคร่าว ๆ
    for _,inst in ipairs({self._root,self._header,self._content,sidebar}) do
      local s = inst:FindFirstChildOfClass("UIStroke"); if s then s.Color=t.border end
    end
    for _,tobj in ipairs(self._tabs) do
      tobj:_applyTheme()
    end
  end

  return win
end

-- ---- Tabs (Sidebar item + page) ----
function Window:NewTab(name)
  local t=self._theme
  -- ปุ่ม sidebar: สี่เหลี่ยม กลาง, มีสถานะ hover/active
  local btn = create("TextButton", {
    Size=UDim2.new(1,0,0,36), BackgroundColor3=t.panel, Text=name,
    TextColor3=t.text, Font=Enum.Font.Gotham, TextSize=14, AutoButtonColor=false
  }, self._sidebar)
  corner(btn,10); local bStroke = stroke(btn, t.border, 1, 0.7)

  -- “ความรู้สึกกดปุ่ม”: hover/press/active
  local active=false
  local function setActive(a)
    active=a
    if a then
      btn.BackgroundColor3 = t.panel:lerp(t.bg,0.18)
      bStroke.Transparency = 0.35
    else
      btn.BackgroundColor3 = t.panel
      bStroke.Transparency = 0.7
    end
  end
  btn.MouseEnter:Connect(function() if not active then btn.BackgroundColor3=t.panel:lerp(t.bg,0.1) end end)
  btn.MouseLeave:Connect(function() if not active then btn.BackgroundColor3=t.panel end end)
  btn.MouseButton1Down:Connect(function() btn.BackgroundColor3=t.panel:lerp(t.bg,0.22) end)
  btn.MouseButton1Up:Connect(function() if not active then btn.BackgroundColor3=t.panel:lerp(t.bg,0.1) end end)

  -- หน้าของแท็บนี้ (เริ่มต้นซ่อน → ต้อง “กด” Main ก่อนจึงเห็น)
  local page = create("ScrollingFrame", {
    BackgroundTransparency=1, BorderSizePixel=0, ScrollBarThickness=4,
    Size=UDim2.new(1,-20,1,-20), Position=UDim2.new(0,10,0,10),
    Visible=false, AutomaticCanvasSize=Enum.AutomaticSize.Y, CanvasSize=UDim2.new()
  }, self._content)
  create("UIListLayout",{Padding=UDim.new(0,12), SortOrder=Enum.SortOrder.LayoutOrder}, page)

  local tab = setmetatable({_win=self,_theme=t,_btn=btn,_page=page,_sections={},Name=name}, Tab)

  function tab:_applyTheme()
    local tt=self._win._theme
    self._theme = tt
    self._btn.TextColor3 = tt.text
    local s=self._btn:FindFirstChildOfClass("UIStroke"); if s then s.Color=tt.border end
    -- หน้า page ไม่มีพื้นหลัง ให้คุมผ่าน parent content แล้ว
  end

  btn.MouseButton1Click:Connect(function()
    -- ปิดหน้าอื่น เปิดหน้านี้ และตั้ง active แท็บนี้ “ค้าง” จนกดแท็บอื่น
    for _,tobj in ipairs(self._tabs) do
      tobj._page.Visible=false
      tobj._btn.BackgroundColor3=self._theme.panel
      local s=tobj._btn:FindFirstChildOfClass("UIStroke"); if s then s.Transparency=0.7 end
      if tobj~=tab then tobj._active=false end
    end
    page.Visible=true
    self._active = tab
    setActive(true)
  end)

  table.insert(self._tabs, tab)
  -- หมายเหตุ: **ไม่** auto-activate → ผู้ใช้ต้องกด "Main" เองถึงจะแสดงคอนเทนต์ (ตามที่ขอ)

  return tab
end

-- ---- Sections ----
function Tab:NewSection(title)
  local t=self._theme
  local card = create("Frame",{BackgroundColor3=t.panel, BorderSizePixel=0,
    Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y}, self._page)
  corner(card,10); stroke(card, t.border, 1, 0.55)

  local head = create("TextLabel",{BackgroundTransparency=1, Text=(title or "Section"),
    TextColor3=t.text, Font=Enum.Font.GothamBold, TextSize=15,
    Size=UDim2.new(1,-20,0,28), Position=UDim2.new(0,10,0,8), TextXAlignment=Enum.TextXAlignment.Left}, card)

  local content = create("Frame",{BackgroundTransparency=1, Size=UDim2.new(1,-20,0,0),
    Position=UDim2.new(0,10,0,40), AutomaticSize=Enum.AutomaticSize.Y}, card)
  create("UIListLayout",{Padding=UDim.new(0,8), SortOrder=Enum.SortOrder.LayoutOrder}, content)

  local sec = setmetatable({_tab=self,_theme=t,_card=card,_content=content}, Section)
  function sec:UpdateSection(ti) head.Text = ti or head.Text end
  return sec
end

-- ---- Buttons (สี่เหลี่ยม ข้อความกลาง)----
local function buildButton(parent, t)
  local b = create("TextButton", {
    Size=UDim2.new(1,0,0,38),
    BackgroundColor3 = t.panel:lerp(DEFAULT.bg,0.06),
    Text = "Button", TextColor3=t.text, Font=Enum.Font.Gotham, TextSize=14, AutoButtonColor=false
  }, parent)
  corner(b,8); local s=stroke(b, t.border, 1, 0.65)
  b.MouseEnter:Connect(function() b.BackgroundColor3=t.panel:lerp(DEFAULT.bg,0.14); s.Transparency=0.45 end)
  b.MouseLeave:Connect(function() b.BackgroundColor3=t.panel:lerp(DEFAULT.bg,0.06); s.Transparency=0.65 end)
  return b
end

function Section:NewButton(text, info, callback)
  local b = buildButton(self._content, self._theme)
  b.Text = text or "Button"
  if typeof(callback)=="function" then b.MouseButton1Click:Connect(callback) end
  local h={}
  function h:UpdateButton(t) b.Text=t or b.Text end
  function h:SetStyle(st) if not st then return end
    if st.bg   then b.BackgroundColor3=st.bg end
    if st.text then b.TextColor3      =st.text end
  end
  function h:Show() b.Visible=true end
  function h:Hide() b.Visible=false end
  function h:Destroy() b:Destroy() end
  return h
end

return UFOUI
