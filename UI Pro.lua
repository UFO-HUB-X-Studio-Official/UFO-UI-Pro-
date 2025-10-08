--======================================================
-- UFO HUB X UI Pro | Tabs (Square Green) + Per-Page Title + Scroll L/R
--======================================================

-- เคลียร์เก่า
pcall(function()
    local cg = game:GetService("CoreGui")
    for _,n in ipairs({"UFO_HUB_X_UI","UFO_HUB_X_Toggle"}) do
        local g = cg:FindFirstChild(n); if g then g:Destroy() end
    end
end)

-- ---------- THEME (เหมือนต้นฉบับ) ----------
local GREEN        = Color3.fromRGB(0,255,140)
local MINT         = Color3.fromRGB(120,255,220)
local MINT_SOFT    = Color3.fromRGB(90,210,190)
local BG_WINDOW    = Color3.fromRGB(16,16,16)
local BG_HEADER    = Color3.fromRGB(6,6,6)
local BG_PANEL     = Color3.fromRGB(22,22,22)
local BG_INNER     = Color3.fromRGB(18,18,18)
local TEXT_WHITE   = Color3.fromRGB(235,235,235)
local DANGER_RED   = Color3.fromRGB(200,40,40)

-- ---------- SIZE ----------
local WIN_W, WIN_H = 720, 400
local GAP_OUTER    = 14
local GAP_BETWEEN  = 12
local LEFT_RATIO   = 0.26
local RIGHT_RATIO  = 0.74
local HEADER_H     = 46

-- ---------- IMAGES ----------
local IMG_UFO   = "rbxassetid://100650447103028"
local IMG_GLOW  = "rbxassetid://5028857084"
local IMG_TOGGLE= "rbxassetid://117052960049460"

-- ---------- HELPERS ----------
local function corner(gui, r) local c=Instance.new("UICorner",gui) c.CornerRadius=UDim.new(0,r or 10) return c end
local function stroke(gui, t, col, trans)
    local s=Instance.new("UIStroke",gui)
    s.Thickness=t or 1; s.Color=col or MINT; s.Transparency=trans or 0.35
    s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; s.LineJoinMode=Enum.LineJoinMode.Round
    return s
end
local function gradient(gui,c1,c2,rot) local g=Instance.new("UIGradient",gui) g.Color=ColorSequence.new(c1,c2) g.Rotation=rot or 0 return g end
local function isAssetId(s) s=tostring(s or "") return s:match("^rbxassetid://%d+$") or s:match("^%d+$") end

-- ---------- Services ----------
local CoreGui = game:GetService("CoreGui")
local UIS     = game:GetService("UserInputService")
local RunS    = game:GetService("RunService")
local CAS     = game:GetService("ContextActionService")

--======================================================
-- สร้าง UI หลัก (ดีไซน์เดิม 100%) + เลื่อนซ้าย/ขวา
--======================================================
local function buildUI()
    if CoreGui:FindFirstChild("UFO_HUB_X_UI") then return CoreGui.UFO_HUB_X_UI end

    local GUI = Instance.new("ScreenGui")
    GUI.Name="UFO_HUB_X_UI"; GUI.IgnoreGuiInset=true; GUI.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
    GUI.ResetOnSpawn=false; GUI.Parent=CoreGui

    -- Window
    local Window = Instance.new("Frame", GUI)
    Window.Name="Window"; Window.AnchorPoint=Vector2.new(.5,.5); Window.Position=UDim2.new(.5,0,.5,0)
    Window.Size=UDim2.fromOffset(WIN_W,WIN_H); Window.BackgroundColor3=BG_WINDOW; Window.BorderSizePixel=0
    corner(Window,12); stroke(Window,3, GREEN, 0)

    -- Glow
    local Glow=Instance.new("ImageLabel",Window)
    Glow.BackgroundTransparency=1; Glow.AnchorPoint=Vector2.new(.5,.5); Glow.Position=UDim2.new(.5,0,.5,0)
    Glow.Size=UDim2.new(1.07,0,1.09,0); Glow.Image=IMG_GLOW; Glow.ImageColor3=GREEN; Glow.ImageTransparency=.78
    Glow.ScaleType=Enum.ScaleType.Slice; Glow.SliceCenter=Rect.new(24,24,276,276)

    -- Autoscale (ไม่ย่อเล็กเกิน)
    local UIScale=Instance.new("UIScale",Window)
    local function fit()
        local v=(workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize) or Vector2.new(1280,720)
        UIScale.Scale=math.clamp(math.min(v.X/960,v.Y/600),0.80,1.05)
    end
    fit(); RunS.RenderStepped:Connect(fit)

    -- Header
    local Header=Instance.new("Frame",Window)
    Header.Name="Header"; Header.Size=UDim2.new(1,0,0,HEADER_H); Header.BackgroundColor3=BG_HEADER; Header.BorderSizePixel=0
    corner(Header,12); gradient(Header, Color3.fromRGB(10,10,10), Color3.fromRGB(0,0,0), 0)

    local HeadAccent=Instance.new("Frame",Header)
    HeadAccent.AnchorPoint=Vector2.new(.5,1); HeadAccent.Position=UDim2.new(.5,0,1,0)
    HeadAccent.Size=UDim2.new(1,-20,0,1); HeadAccent.BackgroundColor3=MINT; HeadAccent.BackgroundTransparency=.35

    local Dot=Instance.new("Frame",Header)
    Dot.BackgroundColor3=MINT; Dot.Position=UDim2.new(0,14,0.5,-4); Dot.Size=UDim2.new(0,8,0,8); Dot.BorderSizePixel=0; corner(Dot,4)

    local Title=Instance.new("TextLabel",Header)
    Title.Name="TitleCenter"; Title.BackgroundTransparency=1; Title.AnchorPoint=Vector2.new(.5,0)
    Title.Position=UDim2.new(.5,0,0,8); Title.Size=UDim2.new(.8,0,0,36)
    Title.Font=Enum.Font.GothamBold; Title.RichText=true; Title.TextScaled=true
    Title.Text='<font color="#FFFFFF">UFO</font> <font color="#00FF8C">HUB X</font>'; Title.TextColor3=TEXT_WHITE

    local BtnClose=Instance.new("TextButton",Header)
    BtnClose.Name="BtnClose"; BtnClose.Size=UDim2.new(0,24,0,24); BtnClose.Position=UDim2.new(1,-34,0.5,-12)
    BtnClose.BackgroundColor3=DANGER_RED; BtnClose.Text="X"; BtnClose.Font=Enum.Font.GothamBold; BtnClose.TextSize=13; BtnClose.TextColor3=Color3.new(1,1,1)
    corner(BtnClose,6); stroke(BtnClose,1, Color3.fromRGB(255,0,0), .1)
    BtnClose.MouseButton1Click:Connect(function() Window.Visible=false; getgenv().UFO_ISOPEN=false end)

    -- Drag window (block camera)
    do
        local dragging,start,startPos
        local function block(on)
            local name="UFO_BlockLook_Window"
            if on then
                CAS:BindActionAtPriority(name,function() return Enum.ContextActionResult.Sink end,false,9000,
                    Enum.UserInputType.MouseMovement, Enum.UserInputType.Touch, Enum.UserInputType.MouseButton1)
            else pcall(function() CAS:UnbindAction(name) end) end
        end
        Header.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                dragging=true; start=i.Position; startPos=Window.Position; block(true)
                i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then dragging=false; block(false) end end)
            end
        end)
        UIS.InputChanged:Connect(function(i)
            if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
                local d=i.Position-start
                Window.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
            end
        end)
    end

    -- Body
    local Body=Instance.new("Frame",Window)
    Body.Name="Body"; Body.BackgroundTransparency=1; Body.Position=UDim2.new(0,0,0,HEADER_H); Body.Size=UDim2.new(1,0,1,-HEADER_H)

    local Inner=Instance.new("Frame",Body)
    Inner.BackgroundColor3=BG_INNER; Inner.BorderSizePixel=0; Inner.Position=UDim2.new(0,8,0,8); Inner.Size=UDim2.new(1,-16,1,-16)
    corner(Inner,12)

    local Content=Instance.new("Frame",Body)
    Content.Name="Content"; Content.BackgroundColor3=BG_PANEL; Content.Position=UDim2.new(0,GAP_OUTER,0,GAP_OUTER)
    Content.Size=UDim2.new(1,-GAP_OUTER*2,1,-GAP_OUTER*2); corner(Content,12); stroke(Content,.8,MINT,.28)
    local padC=Instance.new("UIPadding",Content); padC.PaddingTop=UDim.new(0,8); padC.PaddingLeft=UDim.new(0,8); padC.PaddingRight=UDim.new(0,8); padC.PaddingBottom=UDim.new(0,8)

    local Columns=Instance.new("Frame",Content)
    Columns.Name="Columns"; Columns.BackgroundTransparency=1; Columns.Position=UDim2.new(0,8,0,8); Columns.Size=UDim2.new(1,-16,1,-16)

    -- LEFT (Tabs) - Scrolling
    local Left=Instance.new("ScrollingFrame",Columns)
    Left.Name="Left"; Left.BackgroundColor3=BG_INNER; Left.Size=UDim2.new(LEFT_RATIO,-GAP_BETWEEN/2,1,0)
    Left.ScrollBarThickness=3; Left.CanvasSize=UDim2.new(); Left.ClipsDescendants=true
    corner(Left,10); stroke(Left,1.1,GREEN,.08); stroke(Left,.6,MINT,.28)
    local padL=Instance.new("UIPadding",Left); padL.PaddingTop=UDim.new(0,8); padL.PaddingLeft=UDim.new(0,8); padL.PaddingRight=UDim.new(0,8); padL.PaddingBottom=UDim.new(0,8)
    local listL=Instance.new("UIListLayout",Left); listL.Padding=UDim.new(0,8); listL.SortOrder=Enum.SortOrder.LayoutOrder
    listL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Left.CanvasSize=UDim2.new(0,0,0,listL.AbsoluteContentSize.Y+12) end)

    -- RIGHT (Pages) - Scrolling container
    local Right=Instance.new("ScrollingFrame",Columns)
    Right.Name="Right"; Right.BackgroundColor3=BG_INNER; Right.Position=UDim2.new(LEFT_RATIO,GAP_BETWEEN,0,0)
    Right.Size=UDim2.new(RIGHT_RATIO,-GAP_BETWEEN/2,1,0); Right.ScrollBarThickness=4; Right.ClipsDescendants=true; Right.CanvasSize=UDim2.new()
    corner(Right,10); stroke(Right,1.1,GREEN,.08); stroke(Right,.6,MINT,.28)
    local padR=Instance.new("UIPadding",Right); padR.PaddingTop=UDim.new(0,8); padR.PaddingLeft=UDim.new(0,8); padR.PaddingRight=UDim.new(0,8); padR.PaddingBottom=UDim.new(0,8)

    local PageHost=Instance.new("Frame",Right)
    PageHost.Name="PageHost"; PageHost.BackgroundTransparency=1; PageHost.Size=UDim2.new(1,-12,1,-12); PageHost.Position=UDim2.new(0,6,0,6)
    local layPages=Instance.new("UIListLayout",PageHost); layPages.Padding=UDim.new(0,0)
    layPages:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Right.CanvasSize=UDim2.new(0,0,0,layPages.AbsoluteContentSize.Y+12) end)

    -- UFO + Halo
    do
        local UFO=Instance.new("ImageLabel",Window)
        UFO.BackgroundTransparency=1; UFO.Image=IMG_UFO; UFO.Size=UDim2.new(0,168,0,168); UFO.AnchorPoint=Vector2.new(.5,1)
        UFO.Position=UDim2.new(.5,0,0,84); UFO.ZIndex=60
        local Halo=Instance.new("ImageLabel",Window)
        Halo.BackgroundTransparency=1; Halo.AnchorPoint=Vector2.new(.5,0); Halo.Position=UDim2.new(.5,0,0,0)
        Halo.Size=UDim2.new(0,200,0,60); Halo.Image=IMG_GLOW; Halo.ImageColor3=MINT_SOFT; Halo.ImageTransparency=.72; Halo.ZIndex=50
    end

    -- Toggle btn (RightShift)
    do
        local function findMain() local g=CoreGui:FindFirstChild("UFO_HUB_X_UI"); return g, g and g:FindFirstChild("Window") end
        local function showUI() local g,w=findMain(); if g then g.Enabled=true end; if w then w.Visible=true end; getgenv().UFO_ISOPEN=true end
        local function hideUI() local g,w=findMain(); if w then w.Visible=false end; getgenv().UFO_ISOPEN=false end
        do local _,w=findMain(); getgenv().UFO_ISOPEN=(w and w.Visible) and true or false end

        local old=CoreGui:FindFirstChild("UFO_HUB_X_Toggle"); if old then old:Destroy() end
        local TG=Instance.new("ScreenGui",CoreGui) TG.Name="UFO_HUB_X_Toggle" TG.IgnoreGuiInset=true
        local B=Instance.new("ImageButton",TG) B.Size=UDim2.fromOffset(64,64) B.Position=UDim2.fromOffset(80,200)
        B.BackgroundColor3=Color3.new(0,0,0) B.BorderSizePixel=0 B.Image=IMG_TOGGLE corner(B,8) stroke(B,2,GREEN,0)
        local function toggle() if getgenv().UFO_ISOPEN then hideUI() else showUI() end end
        B.MouseButton1Click:Connect(toggle) UIS.InputBegan:Connect(function(i,gp) if not gp and i.KeyCode==Enum.KeyCode.RightShift then toggle() end end)
        -- drag
        local dragging=false; local start; local startPos
        B.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                dragging=true; start=i.Position; startPos=Vector2.new(B.Position.X.Offset,B.Position.Y.Offset)
            end
        end)
        UIS.InputChanged:Connect(function(i)
            if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
                local d=i.Position-start; B.Position=UDim2.fromOffset(startPos.X+d.X,startPos.Y+d.Y)
            end
        end)
        UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end end)
    end

    return GUI
end

local _GUI = buildUI()

--======================================================
-- UFOPro API (สร้างจากภายนอก) — ยังไม่สร้างปุ่มให้เองจนกว่าคุณจะสั่ง
--======================================================
local UFOPro = { _version = "1.2-tabs" }
UFOPro.__index = UFOPro
getgenv().UFOPro = UFOPro

-- ปุ่มแท็บซ้าย: สี่เหลี่ยมสีเขียว (เหมือนกรอบ)
local function makeSideButton(parent, opts, active)
    local text = tostring(opts.text or "Tab")
    local b = Instance.new("TextButton")
    b.Name = "Tab_"..text
    b.AutoButtonColor = false
    b.Size = UDim2.new(1,0,0,30)
    b.BackgroundColor3 = active and Color3.fromRGB(0,210,115) or GREEN
    b.Text = "  "..text
    b.Font = Enum.Font.GothamSemibold
    b.TextSize = 14
    b.TextColor3 = Color3.fromRGB(12,20,16)
    b.Parent = parent
    stroke(b,1, MINT, 0.10) -- ขอบอ่อนโทน MINT

    b.MouseEnter:Connect(function()
        if not active then b.BackgroundColor3 = Color3.fromRGB(0,230,126) end
    end)
    b.MouseLeave:Connect(function()
        if not active then b.BackgroundColor3 = GREEN end
    end)

    -- เก็บเมตาไว้ใช้กับหัวข้อหน้า
    b:SetAttribute("tab_text", text)
    if opts.icon then b:SetAttribute("tab_icon", tostring(opts.icon)) end
    return b
end

-- เพจด้านขวา + TitleBar (ชื่อ/ไอคอนของแต่ละแท็บ)
local function makePage(host, name)
    local page = Instance.new("Frame", host)
    page.Name = "Page_"..name
    page.BackgroundTransparency = 1
    page.Size = UDim2.new(1,0,1,0)
    page.Visible = false

    local bar = Instance.new("Frame", page)
    bar.Name = "TitleBar"
    bar.BackgroundColor3 = GREEN
    bar.BorderSizePixel = 0
    bar.Size = UDim2.new(0, 240, 0, 28)
    bar.Position = UDim2.new(0, 0, 0, 0)
    stroke(bar, 1, MINT, 0.1)

    local iconImg = Instance.new("ImageLabel", bar)
    iconImg.Name = "IconImg"
    iconImg.BackgroundTransparency = 1
    iconImg.Size = UDim2.new(0, 20, 0, 20)
    iconImg.Position = UDim2.new(0, 6, 0.5, -10)
    iconImg.Visible = false

    local iconEmoji = Instance.new("TextLabel", bar)
    iconEmoji.Name = "IconEmoji"
    iconEmoji.BackgroundTransparency = 1
    iconEmoji.Size = UDim2.new(0, 20, 1, 0)
    iconEmoji.Position = UDim2.new(0, 6, 0, 0)
    iconEmoji.Font = Enum.Font.GothamBold
    iconEmoji.TextScaled = true
    iconEmoji.TextColor3 = Color3.fromRGB(12,20,16)
    iconEmoji.Visible = false

    local title = Instance.new("TextLabel", bar)
    title.Name = "TitleText"
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 32, 0, 0)
    title.Size = UDim2.new(1, -36, 1, 0)
    title.Font = Enum.Font.GothamSemibold
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextColor3 = Color3.fromRGB(12,20,16)
    title.Text = name

    -- พื้นที่เลื่อนจริง
    local sf = Instance.new("ScrollingFrame", page)
    sf.Name = "Scroll"
    sf.BackgroundTransparency = 1
    sf.Position = UDim2.new(0, 0, 0, 36)
    sf.Size = UDim2.new(1, 0, 1, -36)
    sf.ScrollBarThickness = 4
    sf.CanvasSize = UDim2.new()

    local lay = Instance.new("UIListLayout", sf)
    lay.Padding = UDim.new(0, 10)
    lay.SortOrder = Enum.SortOrder.LayoutOrder
    lay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        sf.CanvasSize = UDim2.new(0, 0, 0, lay.AbsoluteContentSize.Y + 12)
    end)

    function page:SetHeader(text, icon)
        title.Text = tostring(text or name)
        iconImg.Visible = false; iconEmoji.Visible = false
        if icon then
            local s = tostring(icon)
            if isAssetId(s) then
                iconImg.Image = s:match("^rbxassetid://") and s or ("rbxassetid://"..s)
                iconImg.Visible = true
            else
                iconEmoji.Text = s
                iconEmoji.Visible = true
            end
        end
    end

    return page, sf
end

-- สร้างการ์ด Section เปล่า ๆ (ยังไม่สร้างปุ่มให้เอง จนกว่าจะเรียกจากภายนอก)
local function makeSection(parent, title)
    local holder = Instance.new("Frame", parent)
    holder.Size = UDim2.new(1,0,0,52)
    holder.BackgroundColor3 = Color3.fromRGB(28,28,34)
    holder.BorderSizePixel = 0
    corner(holder, 10); stroke(holder, 1, Color3.fromRGB(100,160,140), 0.18)

    local inner = Instance.new("Frame", holder)
    inner.BackgroundTransparency = 1
    inner.Size = UDim2.new(1,-20,1,-14)
    inner.Position = UDim2.new(0,10,0,7)

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
    lab.Size = UDim2.new(1,-18,1,0)
    lab.Font = Enum.Font.GothamSemibold
    lab.TextSize = 16
    lab.TextXAlignment = Enum.TextXAlignment.Left
    lab.TextColor3 = TEXT_WHITE
    lab.Text = title or "Section"

    -- ที่วางคอนเทนต์จริง
    local content = Instance.new("Frame", parent)
    content.BackgroundTransparency = 1
    content.Size = UDim2.new(1,0,0,0)
    local v = Instance.new("UIListLayout", content); v.Padding = UDim.new(0,6)

    -- auto height
    local function sync()
        local total=0
        for _,o in ipairs(content:GetChildren()) do
            if o:IsA("GuiObject") then total = total + o.AbsoluteSize.Y + 6 end
        end
        content.Size = UDim2.new(1,0,0,total)
    end
    content.ChildAdded:Connect(sync); content.ChildRemoved:Connect(sync)

    -- ส่ง API section (เปล่า ๆ ไว้คุณเติมเองภายหลัง)
    local api = { _content = content }
    return api
end

-- ---------- PUBLIC ----------
function UFOPro.CreateLib(title)
    local gui = CoreGui:FindFirstChild("UFO_HUB_X_UI") or buildUI()
    local win   = gui.Window
    local left  = gui.Window.Body.Content.Columns.Left
    local host  = gui.Window.Body.Content.Columns.Right.PageHost

    -- ชื่อหัว
    local label = win.Header.TitleCenter
    if label then label.Text = string.format('<font color="#FFFFFF">%s</font> <font color="#00FF8C">HUB X</font>', title or "UFO") end

    local api = { _win=win, _left=left, _host=host, _tabs={}, _active=nil }

    function api:ToggleUI()
        self._win.Visible = not self._win.Visible
        getgenv().UFO_ISOPEN = self._win.Visible
    end

    -- สร้างแท็บ (รับ {text=..., icon=...} หรือ "ชื่อ")
    function api:NewTab(nameOrOpts)
        local opts = typeof(nameOrOpts)=="table" and nameOrOpts or { text = tostring(nameOrOpts or "Tab") }
        local name = opts.text
        local isFirst = (self._active == nil)

        local btn = makeSideButton(self._left, opts, isFirst)
        local page, scroll = makePage(self._host, name)

        self._tabs[name] = { btn = btn, page = page, scroll = scroll, icon = opts.icon }

        local function activate()
            for _,t in pairs(self._tabs) do
                t.page.Visible = false
                t.btn.BackgroundColor3 = GREEN
                t.btn.TextColor3       = Color3.fromRGB(12,20,16)
            end
            page.Visible = true
            page:SetHeader(name, opts.icon)
            btn.BackgroundColor3 = Color3.fromRGB(0,210,115)
            self._active = btn
        end
        btn.MouseButton1Click:Connect(activate)
        if isFirst then activate() end

        -- API: Section (ภายนอกจะมาเติมปุ่ม/ไอเทมเองทีหลัง)
        local tabAPI = {}
        function tabAPI:NewSection(title)
            return makeSection(scroll, title or "Section")
        end
        return tabAPI
    end

    return api
end

--======================================================
-- (ตัวอย่างสั้น ๆ — ลบได้)
-- local UI   = UFOPro.CreateLib("UFO")
-- local Tab1 = UI:NewTab({ text="Main", icon="🔥" }) -- หรือ icon เป็นเลข asset id ก็ได้
-- local Sec1 = Tab1:NewSection("Actions")
--======================================================
