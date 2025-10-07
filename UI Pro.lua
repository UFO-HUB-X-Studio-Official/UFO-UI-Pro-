--==[ UFO HUB X UI Pro | STEP 2: Adapter Shell (keep original UI 100%) ]==--
-- โมดูลชื่อ: UFOPro  (ใช้โหลดด้วย loadstring(game:HttpGet(...))())
-- ทำหน้าที่: หยิบ UI เดิมของนาย (ชื่อ ScreenGui = "UFO_HUB_X_UI") แล้วเปิด API แบบ Kavo-สไตล์

local CoreGui = game:GetService("CoreGui")
local UIS     = game:GetService("UserInputService")

local UFOPro = { _version = "0.2-adapter" }
UFOPro.__index = UFOPro

-- หา UI เดิมของนาย
local function findUI()
    local gui = CoreGui:FindFirstChild("UFO_HUB_X_UI")
    if not gui then return end
    local win = gui:FindFirstChildWhichIsA("Frame")
    local body = win and win:FindFirstChild("Body")
    local inner = body and body:FindFirstChild("Inner")
    local content = body and body:FindFirstChild("Content")
    local columns = content and content:FindFirstChild("Columns")
    local left = columns and columns:FindFirstChild("Left")
    local right = columns and columns:FindFirstChild("Right")
    return gui, win, left, right
end

-- ถ้ายังไม่มี UI เดิม ให้ dev วาง "สคริปต์ UI ที่นายชอบ" รันก่อน (เราไม่แตะรูปร่าง)
local function assureUI()
    local gui, win, left, right = findUI()
    if not gui or not win or not left or not right then
        error("[UFOPro] ไม่พบ UI เดิมของนาย (UFO_HUB_X_UI). ให้รันสคริปต์ UI ของนายก่อน แล้วค่อยโหลดโมดูลนี้", 0)
    end
    return gui, win, left, right
end

-- เครื่องมือทำ UI ย่อย
local function corner(gui, r)
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 10); c.Parent = gui; return c
end
local function stroke(gui, t, col, tr)
    local s = Instance.new("UIStroke"); s.Thickness = t or 1; s.Color = col or Color3.fromRGB(120,255,220); s.Transparency = tr or 0.35
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; s.LineJoinMode = Enum.LineJoinMode.Round; s.Parent = gui; return s
end

-- จัด Scroll ให้ฝั่งขวา (ถ้ายังไม่มี)
local function assurePageHost(right)
    local host = right:FindFirstChild("PageHost")
    if not host then
        host = Instance.new("Frame")
        host.Name = "PageHost"
        host.BackgroundTransparency = 1
        host.Size = UDim2.new(1,0,1,0)
        host.Parent = right
    end
    return host
end

-- ปุ่ม Tab บนซ้าย
local function assureTabList(left)
    local list = left:FindFirstChild("TabList")
    if not list then
        list = Instance.new("ScrollingFrame")
        list.Name = "TabList"
        list.BackgroundTransparency = 1
        list.Size = UDim2.new(1,0,1,0)
        list.ScrollBarThickness = 3
        list.Parent = left
        local layout = Instance.new("UIListLayout", list)
        layout.Padding = UDim.new(0,8)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            list.CanvasSize = UDim2.new(0,0,0, layout.AbsoluteContentSize.Y + 12)
        end)
        local pad = Instance.new("UIPadding", list)
        pad.PaddingTop = UDim.new(0,10); pad.PaddingLeft = UDim.new(0,10)
        pad.PaddingRight = UDim.new(0,10); pad.PaddingBottom = UDim.new(0,10)
    end
    return list
end

-- สร้างปุ่มสไตล์ซ้ายให้เข้ากับ UI เดิม
local function makeSideButton(parent, text, active)
    local b = Instance.new("TextButton")
    b.Name = "Tab_"..text
    b.AutoButtonColor = false
    b.Size = UDim2.new(1,0,0,32)
    b.BackgroundColor3 = active and Color3.fromRGB(28,28,28) or Color3.fromRGB(20,20,20)
    b.Text = "· "..text
    b.Font = Enum.Font.GothamSemibold
    b.TextSize = 15
    b.TextColor3 = active and Color3.fromRGB(240,240,250) or Color3.fromRGB(180,185,200)
    b.Parent = parent
    corner(b, 10); stroke(b, 1, Color3.fromRGB(120,255,220), 0.25)
    b.MouseEnter:Connect(function() if not active then b.BackgroundColor3 = Color3.fromRGB(26,26,26) end end)
    b.MouseLeave:Connect(function() if not active then b.BackgroundColor3 = Color3.fromRGB(20,20,20) end end)
    return b
end

-- สร้าง “หน้า” (ScrollingFrame) ให้แท็บ
local function makePage(parent)
    local page = Instance.new("ScrollingFrame")
    page.Name = "Page"
    page.Visible = false
    page.BackgroundTransparency = 1
    page.Size = UDim2.new(1,-12,1,-12)
    page.Position = UDim2.new(0,6,0,6)
    page.ScrollBarThickness = 4
    page.Parent = parent
    local lay = Instance.new("UIListLayout", page)
    lay.Padding = UDim.new(0,10)
    lay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0,0,0, lay.AbsoluteContentSize.Y + 12)
    end)
    return page
end

-- ===== API ภายนอก =====
function UFOPro.CreateLib(title, theme)
    -- title/theme ตอนนี้รับไว้เฉย ๆ เพื่อเข้ากันได้ (UI มองเห็นอยู่แล้วตรง Header เดิม)
    local gui, win, left, right = assureUI()
    local tabList  = assureTabList(left)
    local pageHost = assurePageHost(right)

    local api = {
        _gui = gui, _win = win,
        _tabList = tabList, _pageHost = pageHost,
        _activeTabBtn = nil, _pages = {}
    }

    -- ซ่อน/โชว์หน้าต่าง (ยังใช้ปุ่ม X เดิมได้เหมือนเดิม)
    function api:ToggleUI()
        local vis = self._win.Visible
        self._win.Visible = not vis
        getgenv().UFO_ISOPEN = self._win.Visible
    end

    -- เปลี่ยนชื่อหัว (บน UI เดิม) แบบไม่เปลี่ยนสไตล์
    function api:SetTitle(txt)
        local header = self._win:FindFirstChild("Header") or self._win:FindFirstChild("TopBar")
        local label = header and header:FindFirstChildWhichIsA("TextLabel", true)
        if label then
            -- คงสไตล์ RichText เดิม
            label.Text = string.format('<font color="#FFFFFF">%s</font> <font color="#00FF8C">HUB X</font>', txt or "UFO")
        end
    end

    -- สร้างแท็บใหม่ (ปุ่มซ้าย + หน้า)
    function api:NewTab(name)
        name = tostring(name or "Tab")
        local isFirst = (self._activeTabBtn == nil)

        local btn = makeSideButton(self._tabList, name, isFirst)
        local page = makePage(self._pageHost)
        page.Name = "Page_"..name
        self._pages[name] = page

        local function activate()
            -- ปิดหน้าทั้งหมด
            for n,pg in pairs(self._pages) do pg.Visible = false end
            -- ปุ่มทั้งหมด -> non-active
            for _,o in ipairs(self._tabList:GetChildren()) do
                if o:IsA("TextButton") then
                    o.BackgroundColor3 = Color3.fromRGB(20,20,20)
                    o.TextColor3 = Color3.fromRGB(180,185,200)
                end
            end
            -- เปิดอันนี้
            page.Visible = true
            btn.BackgroundColor3 = Color3.fromRGB(28,28,28)
            btn.TextColor3 = Color3.fromRGB(240,240,250)
            self._activeTabBtn = btn
        end
        btn.MouseButton1Click:Connect(activate)
        if isFirst then activate() end

        -- ====== Section API ======
        local tabAPI = {}
        function tabAPI:NewSection(title)
            title = tostring(title or "Section")

            -- Header แคปซูลแบบเดิม (เข้ากับธีม)
            local holder = Instance.new("Frame")
            holder.Size = UDim2.new(1,0,0,56)
            holder.BackgroundColor3 = Color3.fromRGB(28,28,28)
            holder.BorderSizePixel = 0
            holder.Parent = page
            corner(holder, 12); stroke(holder, 1.1, Color3.fromRGB(120,180,255), 0.15)

            do
                local inner = Instance.new("Frame", holder)
                inner.BackgroundTransparency = 1
                inner.Size = UDim2.new(1,-22,1,-16)
                inner.Position = UDim2.new(0,11,0,8)

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
                lab.Font = Enum.Font.GothamMedium
                lab.TextSize = 16
                lab.TextXAlignment = Enum.TextXAlignment.Left
                lab.TextColor3 = Color3.fromRGB(240,240,250)
                lab.Text = title
                lab.Size = UDim2.new(1,-80,1,0)

                -- อนุญาต update ชื่อ section
                function tabAPI:UpdateSection(newTitle) lab.Text = newTitle end
            end

            -- host สำหรับคอนโทรล
            local ctrlHost = Instance.new("Frame")
            ctrlHost.BackgroundTransparency = 1
            ctrlHost.Size = UDim2.new(1,0,0,0)
            ctrlHost.Parent = page
            local v = Instance.new("UIListLayout", ctrlHost); v.Padding = UDim.new(0,8)

            -- ===== Controls (เริ่มด้วย Label/Button ก่อน) =====
            local secAPI = {}

            function secAPI:NewLabel(text)
                local tl = Instance.new("TextLabel")
                tl.BackgroundTransparency = 1
                tl.Size = UDim2.new(1,0,0,22)
                tl.Font = Enum.Font.Gotham
                tl.TextSize = 14
                tl.TextXAlignment = Enum.TextXAlignment.Left
                tl.TextColor3 = Color3.fromRGB(210,214,230)
                tl.Text = text or ""
                tl.Parent = ctrlHost
                return { UpdateLabel = function(_,t) tl.Text = t end }
            end

            function secAPI:NewButton(text, info, callback)
                local b = Instance.new("TextButton")
                b.AutoButtonColor = false
                b.Size = UDim2.new(1,0,0,34)
                b.BackgroundColor3 = Color3.fromRGB(40,40,50)
                b.Text = text or "Button"
                b.Font = Enum.Font.GothamSemibold
                b.TextSize = 14
                b.TextColor3 = Color3.fromRGB(235,235,245)
                b.Parent = ctrlHost
                corner(b,10); stroke(b,1, Color3.fromRGB(120,255,220), 0.28)
                b.MouseEnter:Connect(function() b.BackgroundColor3 = Color3.fromRGB(48,48,60) end)
                b.MouseLeave:Connect(function() b.BackgroundColor3 = Color3.fromRGB(40,40,50) end)
                b.MouseButton1Click:Connect(function() if callback then pcall(callback) end end)
                return { UpdateButton = function(_,t) b.Text = t end }
            end

            -- ที่เหลือ (Toggle/Slider/Textbox/Keybind/Dropdown/ColorPicker) จะใส่ในขั้นถัดไป
            return secAPI
        end

        return tabAPI
    end

    return api
end

return UFOPro
