--[[
UFO UI Pro — STEP 1/?? : Core Window + Tabs + Sections + Button
เวอร์ชัน: 0.1.0-dev (foundation)

❑ ในไฟล์นี้มีอะไรบ้าง
  1) Namespace UFOUI (โมดูลหลัก) + Version
  2) Safe GUI parenting (รองรับ gethui/syn.protect_gui)
  3) DPI/Responsive Scale (คำนวณสเกลตาม ViewportSize)
  4) Theme Tokens (รับ table แบบ Kavo และแปลงเป็น tokens)
  5) Window.CreateLib(title, theme) → สร้างหน้าต่างหลัก + TabBar
  6) Window:NewTab(name) → สร้างแท็บ + จัดการโชว์/ซ่อน
  7) Tab:NewSection(name, side) → สร้าง Section ซ้าย/ขวา (L/R)
  8) Section:NewButton(text, info, callback) → ปุ่มพื้นฐาน + Handle:
        :UpdateButton(text)
        :SetStyle(styleTable)
        :SetStateStyles(stateStyleTable)
        :SetIcon({id=rbxassetid://..., placement="left|right|top|background", size=UDim2,...})
        :Show(), :Hide(), :Destroy()
     (รองรับ “เส้นขอบสีเขียว”, “ไอคอนรูป asset id”, “มุมโค้ง/เงา/พื้นหลังรูป”)
  9) Expose/Attach registry → win:Expose("main"), UFOUI:Attach("main")

❑ ยังไม่ใส่ (จะมาทีหลังใน STEP ถัดไป)
  - Toggle/Slider/Dropdown/Keybind/Label/TextBox/ColorPicker (กำลังเสริมทีละชุด)
  - Exec(Command Runner), Plugin Registry, MountInstance, Pages (KeyGate/Download)
  - Loader/SelfUpdate/Luarmor helper

ทุกฟังก์ชัน/section มีคอมเมนต์ไทยกำกับว่าคืออะไร และจุดที่ "ควรแก้" อยู่ตรงไหน
]]--

-------------------------
-- 0) Utilities & State
-------------------------
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- โครงโมดูลหลัก
local UFOUI = {}
UFOUI.__index = UFOUI

-- เก็บ registry ของหน้าต่างที่ Expose เอาไว้ให้ Attach จากสคริปต์อื่นได้
local __REGISTRY = {
    windows = {}  -- name -> window
}

-- เวอร์ชันปัจจุบัน (เอาไว้เช็ค/แสดง)
function UFOUI.Version()
    return "0.1.0-dev"
end

---------------------------------------
-- 1) Safe Parent + create helpers
---------------------------------------
-- ฟังก์ชัน: วาง GUI ใน parent ที่ปลอดภัย (รองรับ executor หลายแบบ)
local function safeParent(gui)
    local ok = false
    -- gethui() ถ้ามี ให้ใช้ก่อน (มักจะกันชนกับ UI อื่นได้ดี)
    if gethui then
        local okP, parent = pcall(gethui)
        if okP and typeof(parent) == "Instance" then
            gui.Parent = parent
            ok = true
        end
    end
    -- syn.protect_gui หากมี ให้เรียกเพื่อปกป้อง GUI
    if syn and syn.protect_gui then
        pcall(function() syn.protect_gui(gui) end)
    end
    if not ok then
        local cg = game:FindFirstChildOfClass("CoreGui") or game:GetService("CoreGui")
        gui.Parent = cg
    end
end

-- ฟังก์ชันช่วยสร้าง Instance พร้อม props
local function create(className, props, parent)
    local obj = Instance.new(className)
    if props then
        for k, v in pairs(props) do
            obj[k] = v
        end
    end
    if parent then obj.Parent = parent end
    return obj
end

------------------------------------------------
-- 2) DPI/Responsive Scale (สเกลอัตโนมัติ)
------------------------------------------------
local function computeScale(viewSize)
    -- ฐานออกแบบ: 1280x720 (ปรับได้)
    local baseX, baseY = 1280, 720
    local sx = viewSize.X / baseX
    local sy = viewSize.Y / baseY
    -- ใช้สเกลที่ต่ำสุดเพื่อให้พอดีทั้งสองมิติ แล้ว clamp ให้อ่านง่าย
    local scale = math.clamp(math.min(sx, sy), 0.75, 1.5)
    return scale
end

------------------------------------------------
-- 3) Theme Tokens (รองรับ table แบบ Kavo)
------------------------------------------------
local DEFAULT_TOKENS = {
    colors = {
        primary  = Color3.fromRGB(0,255,140), -- เขียวหลัก UFO
        bg       = Color3.fromRGB(16,16,16),
        header   = Color3.fromRGB(16,16,16),
        text     = Color3.fromRGB(230,230,230),
        element  = Color3.fromRGB(24,24,24),
        border   = Color3.fromRGB(30,30,30),
        subtle   = Color3.fromRGB(140,140,140),
    },
    radius = { sm = 6, md = 8, lg = 12 },
    stroke = { width = 1 },
    spacing = { x = 10, y = 8 },
    layout = { leftRatio = 0.22, rightRatio = 0.78 } -- ค่า L/R ดีฟอลต์ (แก้ได้)
}

-- แปลง colors table ของ Kavo -> tokens ของเรา
local function normalizeTheme(theme)
    if typeof(theme) == "string" or theme == nil then
        -- ใช้ชื่อธีมหรือค่า default ไปก่อน (ตอนหลังค่อยเพิ่ม preset ชื่อธีม)
        return DEFAULT_TOKENS
    end
    if typeof(theme) == "table" then
        local t = table.clone(DEFAULT_TOKENS)
        local c = theme
        t.colors.SchemeColor = c.SchemeColor or t.colors.primary
        t.colors.primary     = c.SchemeColor or t.colors.primary
        t.colors.bg          = c.Background  or t.colors.bg
        t.colors.header      = c.Header      or t.colors.header
        t.colors.text        = c.TextColor   or t.colors.text
        t.colors.element     = c.ElementColor or t.colors.element
        -- border/subtle เก็บตาม default ถ้าไม่ส่งมา
        return t
    end
    return DEFAULT_TOKENS
end

------------------------------------------------
-- 4) Style helpers สำหรับปุ่ม/องค์ประกอบ
------------------------------------------------
local function applyCornerStroke(instance, tokens, radius, borderColor, borderWidth)
    local corner = instance:FindFirstChildOfClass("UICorner") or create("UICorner", nil, instance)
    corner.CornerRadius = UDim.new(0, radius or tokens.radius.md)

    local stroke = instance:FindFirstChildOfClass("UIStroke") or create("UIStroke", nil, instance)
    stroke.Thickness = borderWidth or tokens.stroke.width
    stroke.Color = borderColor or tokens.colors.border
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return corner, stroke
end

-- สร้าง “ปุ่ม” แบบมีพื้นที่ให้ใส่ไอคอน
local function buildButton(parent, tokens)
    local btn = create("TextButton", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = tokens.colors.element,
        TextColor3 = tokens.colors.text,
        Text = "Button",
        Font = Enum.Font.Gotham,
        TextSize = 14,
        AutoButtonColor = false,
        ClipsDescendants = true,
    }, parent)

    applyCornerStroke(btn, tokens, tokens.radius.md, tokens.colors.border, tokens.stroke.width)

    -- พื้นที่ไอคอน
    local icon = create("ImageLabel", {
        Name = "Icon",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 18, 0, 18),
        Position = UDim2.new(0, 10, 0.5, -9),
        ImageTransparency = 0,
        ImageColor3 = Color3.new(1,1,1),
        Visible = false,
    }, btn)

    -- padding ให้ตัวหนังสือขยับเมื่อมีไอคอนซ้าย
    local padding = create("UIPadding", {
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
    }, btn)

    -- สถานะ hover/press (ง่าย ๆ ใน Step 1)
    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = tokens.colors.element:Lerp(tokens.colors.bg, 0.2)
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = tokens.colors.element
    end)
    btn.MouseButton1Down:Connect(function()
        btn.BackgroundColor3 = tokens.colors.element:Lerp(tokens.colors.bg, 0.35)
    end)
    btn.MouseButton1Up:Connect(function()
        btn.BackgroundColor3 = tokens.colors.element:Lerp(tokens.colors.bg, 0.2)
    end)

    return btn, icon, padding
end

------------------------------------------------
-- 5) Window/Tab/Section โครงหลัก
------------------------------------------------
local Window = {} ; Window.__index = Window
local Tab = {} ; Tab.__index = Tab
local Section = {} ; Section.__index = Section

-- Window:ToggleUI() ซ่อน/แสดงทั้งหน้าต่าง
function Window:ToggleUI()
    self._gui.Enabled = not self._gui.Enabled
end
function Window:IsVisible() return self._gui.Enabled end

-- Window:Expose(name) ให้สคริปต์อื่น Attach เข้ามาใช้งานหน้าต่างนี้
function Window:Expose(name)
    __REGISTRY.windows[name] = self
    return self
end

-- UFOUI:Attach(name) ดึงหน้าต่างที่ expose ไว้
function UFOUI:Attach(name)
    local win = __REGISTRY.windows[name]
    assert(win, "[UFO UI Pro] Attach failed: window '"..tostring(name).."' not found.")
    return win
end

-- Window:NewTab(name) — สร้างแท็บ + ปุ่มที่ TabBar
function Window:NewTab(name)
    assert(type(name)=="string" and #name>0, "[UFO UI Pro] Tab name invalid")
    local tokens = self._tokens

    -- ปุ่มบน TabBar
    local tabBtn = create("TextButton", {
        Size = UDim2.new(0, 120, 1, 0),
        BackgroundColor3 = tokens.colors.header,
        TextColor3 = tokens.colors.text,
        Text = name,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        AutoButtonColor = false,
    }, self._tabBar)

    applyCornerStroke(tabBtn, tokens, tokens.radius.sm, tokens.colors.border, tokens.stroke.width)

    -- เนื้อหาของแท็บ (มี L/R)
    local tabFrame = create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, -54), -- ลบพื้นที่ header+tabbar
        Position = UDim2.new(0, 0, 0, 54),
        Visible = false,
    }, self._main)

    -- สองฝั่ง L/R (ScrollingFrame)
    local left = create("ScrollingFrame", {
        BackgroundColor3 = Color3.fromRGB(0,0,0),
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        ScrollBarThickness = 6,
        Size = UDim2.new(self._tokens.layout.leftRatio, -8, 1, -0),
        Position = UDim2.new(0, 8, 0, 0),
        CanvasSize = UDim2.new(0,0,0,0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, tabFrame)
    applyCornerStroke(left, tokens, tokens.radius.md, tokens.colors.border, tokens.stroke.width)

    local right = create("ScrollingFrame", {
        BackgroundColor3 = Color3.fromRGB(0,0,0),
        BackgroundTransparency = 0.35,
        BorderSizePixel = 0,
        ScrollBarThickness = 6,
        Size = UDim2.new(self._tokens.layout.rightRatio, -16, 1, -0),
        Position = UDim2.new(self._tokens.layout.leftRatio, 16, 0, 0),
        CanvasSize = UDim2.new(0,0,0,0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, tabFrame)
    applyCornerStroke(right, tokens, tokens.radius.md, tokens.colors.border, tokens.stroke.width)

    -- Layout แนวตั้งในแต่ละฝั่ง
    local function addList(container)
        local list = create("UIListLayout", {
            Padding = UDim.new(0, self._tokens.spacing.y),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }, container)
        create("UIPadding", {
            PaddingTop = UDim.new(0, 10),
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 10),
        }, container)
        return list
    end
    addList(left); addList(right)

    local tabObj = setmetatable({
        _win = self,
        _tokens = tokens,
        _frame = tabFrame,
        _left = left,
        _right = right,
        _btn = tabBtn,
        _sections = {},
        Name = name,
    }, Tab)

    -- สลับแท็บเมื่อกดปุ่ม
    tabBtn.MouseButton1Click:Connect(function()
        for _, t in ipairs(self._tabs) do
            t._frame.Visible = false
            t._btn.BackgroundColor3 = tokens.colors.header
        end
        tabFrame.Visible = true
        tabBtn.BackgroundColor3 = tokens.colors.header:Lerp(tokens.colors.bg, 0.2)
        self._activeTab = tabObj
    end)

    table.insert(self._tabs, tabObj)
    if not self._activeTab then tabBtn:Activate() end

    return tabObj
end

-- Tab:NewSection(name, side) — สร้าง Section ในฝั่ง Left/Right
function Tab:NewSection(name, side)
    side = side or "Left"
    local container = (string.lower(side)=="right") and self._right or self._left
    local tokens = self._tokens

    -- กรอบ Section
    local sec = create("Frame", {
        BackgroundColor3 = self._tokens.colors.element,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
    }, container)
    applyCornerStroke(sec, tokens, tokens.radius.lg, tokens.colors.border, tokens.stroke.width)

    -- ชื่อ Section
    local title = create("TextLabel", {
        BackgroundTransparency = 1,
        Text = name or "Section",
        Font = Enum.Font.GothamBold,
        TextColor3 = tokens.colors.text,
        TextSize = 15,
        Size = UDim2.new(1, -16, 0, 26),
        Position = UDim2.new(0, 8, 0, 8),
        TextXAlignment = Enum.TextXAlignment.Left,
    }, sec)

    -- Layout ภายใน Section
    local list = create("UIListLayout", {
        Padding = UDim.new(0, self._tokens.spacing.y),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, sec)
    local pad = create("UIPadding", {
        PaddingTop = UDim.new(0, 36),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
    }, sec)

    local sectionObj = setmetatable({
        _tab = self,
        _tokens = tokens,
        _frame = sec,
        _title = title,
        _controls = {},
        Name = name or "Section",
        Side = side,
    }, Section)

    function sectionObj:UpdateSection(newTitle)
        self._title.Text = newTitle
    end

    table.insert(self._sections, sectionObj)
    return sectionObj
end

-- Section:NewButton(...) — ปุ่มพื้นฐาน + handle ปรับแต่งสไตล์/ไอคอน
function Section:NewButton(text, info, callback)
    local tokens = self._tokens
    local btn, icon, padding = buildButton(self._frame, tokens)
    btn.Text = text or "Button"

    -- tooltip/info (Step 1: แสดงใน output; STEP ถัดไปจะทำ tooltip UI)
    local _info = info

    local handle = {}
    handle._btn = btn
    handle._icon = icon
    handle._tokens = tokens
    handle._stateStyles = {} -- hover/pressed/active/disabled กำหนดภายหลังได้

    -- คลิก
    btn.MouseButton1Click:Connect(function()
        if typeof(callback) == "function" then
            callback()
        end
    end)

    -- === [สำคัญ] ฟังก์ชันปรับแต่งสไตล์รายปุ่ม ===
    function handle:UpdateButton(newText)
        btn.Text = newText or btn.Text
    end

    function handle:SetStyle(st)
        -- ตัวอย่าง key ที่รองรับ: bg, text, radius, shadow, padding, border{color,width}, bgImage{id,transparency,fit}
        if st then
            if st.bg then btn.BackgroundColor3 = st.bg end
            if st.text then btn.TextColor3 = st.text end
            if st.padding then
                padding.PaddingLeft  = UDim.new(0, st.padding)
                padding.PaddingRight = UDim.new(0, st.padding)
            end
            local _, stroke = applyCornerStroke(btn, tokens, st.radius or tokens.radius.md,
                (st.border and st.border.color) or tokens.colors.border,
                (st.border and st.border.width) or tokens.stroke.width
            )
            -- พื้นหลังรูป
            if st.bgImage and st.bgImage.id then
                local bg = btn:FindFirstChild("BGImage") or create("ImageLabel", {
                    Name = "BGImage", BackgroundTransparency = 1, Size = UDim2.fromScale(1,1),
                    ZIndex = 0
                }, btn)
                bg.Image = st.bgImage.id
                bg.ImageTransparency = st.bgImage.transparency or 0.1
                bg.ScaleType = Enum.ScaleType.Fit
                if st.bgImage.fit == "cover" then bg.ScaleType = Enum.ScaleType.Crop end
            end
        end
    end

    function handle:SetStateStyles(map)
        -- map: { hover={...}, pressed={...}, active={...}, disabled={...} }
        self._stateStyles = map or {}
        -- (STEP ถัดไปจะทำระบบสถานะเต็ม + animation manager)
    end

    function handle:SetIcon(opt)
        -- opt: {id=..., placement="left|right|top|background", size=UDim2, padding=number, colorize=bool}
        if not opt or not opt.id then
            icon.Visible = false
            return
        end
        icon.Visible = true
        icon.Image = opt.id
        if opt.size then icon.Size = opt.size end
        if opt.colorize == true then icon.ImageColor3 = tokens.colors.primary end
        local place = (opt.placement or "left"):lower()
        if place == "left" then
            icon.Position = UDim2.new(0, 10, 0.5, -icon.AbsoluteSize.Y/2)
            padding.PaddingLeft = UDim.new(0, (opt.padding or 8) + icon.AbsoluteSize.X + 10)
        elseif place == "right" then
            icon.Position = UDim2.new(1, -((opt.padding or 8) + icon.AbsoluteSize.X + 10), 0.5, -icon.AbsoluteSize.Y/2)
            padding.PaddingRight = UDim.new(0, (opt.padding or 8) + icon.AbsoluteSize.X + 10)
        elseif place == "top" then
            icon.Position = UDim2.new(0, 10, 0, 6)
        elseif place == "background" then
            icon.Size = UDim2.new(1, 0, 1, 0)
            icon.ImageTransparency = 0.85
        end
    end

    function handle:Show() btn.Visible = true end
    function handle:Hide() btn.Visible = false end
    function handle:Destroy() btn:Destroy() end

    table.insert(self._controls, handle)
    return handle
end

--------------------------------------
-- 6) สร้าง Window หลัก (CreateLib)
--------------------------------------
function UFOUI.CreateLib(title, theme)
    -- 6.1 สร้าง ScreenGui + Main Window
    local gui = create("ScreenGui", {
        Name = "UFO_UI_PRO",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        Enabled = true,
    })
    safeParent(gui)

    -- 6.2 UIScale ตาม DPI/Viewport
    local scale = create("UIScale", { Scale = computeScale(Camera.ViewportSize) }, gui)
    Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        scale.Scale = computeScale(Camera.ViewportSize)
    end)

    -- 6.3 Theme Tokens
    local tokens = normalizeTheme(theme)

    -- 6.4 โครงหน้าต่าง
    local root = create("Frame", {
        Name = "Root",
        Size = UDim2.new(0, 900, 0, 560),
        Position = UDim2.new(0.5, -450, 0.5, -280),
        BackgroundColor3 = tokens.colors.bg,
        BorderSizePixel = 0,
    }, gui)
    applyCornerStroke(root, tokens, tokens.radius.lg, tokens.colors.border, tokens.stroke.width)

    -- 6.5 Header (Title bar)
    local header = create("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = tokens.colors.header,
        BorderSizePixel = 0,
    }, root)
    applyCornerStroke(header, tokens, tokens.radius.sm, tokens.colors.border, tokens.stroke.width)

    local titleLbl = create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -100, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = title or ("UFO UI Pro v"..UFOUI.Version()),
        Font = Enum.Font.GothamBold,
        TextColor3 = tokens.colors.text,
        TextSize = 16,
    }, header)

    local hideBtn = create("TextButton", {
        Size = UDim2.new(0, 80, 1, 0),
        Position = UDim2.new(1, -84, 0, 0),
        BackgroundColor3 = tokens.colors.header,
        Text = "Hide",
        TextColor3 = tokens.colors.text,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        AutoButtonColor = false
    }, header)
    applyCornerStroke(hideBtn, tokens, tokens.radius.sm, tokens.colors.border, tokens.stroke.width)
    hideBtn.MouseButton1Click:Connect(function()
        gui.Enabled = false
    end)

    -- 6.6 TabBar
    local tabBar = create("Frame", {
        Name = "TabBar",
        Size = UDim2.new(1, -16, 0, 34),
        Position = UDim2.new(0, 8, 0, 42),
        BackgroundColor3 = tokens.colors.header,
        BorderSizePixel = 0
    }, root)
    applyCornerStroke(tabBar, tokens, tokens.radius.sm, tokens.colors.border, tokens.stroke.width)

    -- แถบปุ่มแท็บเลื่อนได้
    local tabList = create("ScrollingFrame", {
        Size = UDim2.new(1, -16, 1, -8),
        Position = UDim2.new(0, 8, 0, 4),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        AutomaticCanvasSize = Enum.AutomaticSize.X,
        CanvasSize = UDim2.new(0,0,0,0),
    }, tabBar)
    local tabLayout = create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Center
    }, tabList)

    -- 6.7 พื้นที่เนื้อหา (ของแท็บ)
    local main = create("Frame", {
        Name = "Main",
        Size = UDim2.new(1, -16, 1, - (42 + 34 + 8)), -- ลบ header+tabbar+margin
        Position = UDim2.new(0, 8, 0, 42+34+8),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    }, root)

    -- 6.8 สร้าง object Window
    local win = setmetatable({
        _gui = gui,
        _root = root,
        _header = header,
        _tabBar = tabList,
        _main = main,
        _tokens = tokens,
        _tabs = {},
        _activeTab = nil,
    }, Window)

    return win
end

-- เพื่อความคุ้นมือแบบ Kavo: ให้ alias (เผื่อบางสคริปต์อ้างผ่าน UFOUI.CreateLib)
UFOUI.CreateLib = UFOUI.CreateLib

return UFOUI
