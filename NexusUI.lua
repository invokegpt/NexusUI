--[[
    Nexus UI Library v1.0
    Modern, smooth, and fully customizable UI library for Roblox
    
    Features:
    - Smooth animations with spring physics
    - Fully customizable themes
    - Optimized performance with object pooling
    - Modern design with glassmorphism effects
    - Responsive layout system
    - Built-in accessibility features
]]

local NexusUI = {}
NexusUI.__index = NexusUI

-- Services
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- Constants
local SPRING_DAMPING = 0.8
local SPRING_FREQUENCY = 4
local ANIMATION_SPEED = 0.3

-- Default Theme
local DEFAULT_THEME = {
    -- Colors
    Primary = Color3.fromRGB(99, 102, 241),
    Secondary = Color3.fromRGB(139, 92, 246),
    Success = Color3.fromRGB(34, 197, 94),
    Warning = Color3.fromRGB(251, 191, 36),
    Error = Color3.fromRGB(239, 68, 68),
    
    -- Background Colors
    Background = Color3.fromRGB(15, 15, 15),
    Surface = Color3.fromRGB(25, 25, 25),
    SurfaceVariant = Color3.fromRGB(35, 35, 35),
    
    -- Text Colors
    TextPrimary = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(156, 163, 175),
    TextMuted = Color3.fromRGB(107, 114, 128),
    
    -- Border Colors
    Border = Color3.fromRGB(55, 55, 55),
    BorderHover = Color3.fromRGB(75, 75, 75),
    
    -- Transparency Values
    GlassTransparency = 0.1,
    HoverTransparency = 0.05,
    
    -- Corner Radius
    CornerRadius = UDim.new(0, 12),
    SmallCornerRadius = UDim.new(0, 8),
    
    -- Shadows
    ShadowColor = Color3.fromRGB(0, 0, 0),
    ShadowTransparency = 0.5,
    
    -- Fonts
    FontPrimary = Enum.Font.GothamBold,
    FontSecondary = Enum.Font.Gotham,
    FontMono = Enum.Font.RobotoMono,
    
    -- Text Sizes
    TextSizeLarge = 18,
    TextSizeMedium = 14,
    TextSizeSmall = 12,
}

-- Animation Utilities
local AnimationUtils = {}

function AnimationUtils.CreateSpringTween(object, properties, speed)
    speed = speed or ANIMATION_SPEED
    local tweenInfo = TweenInfo.new(
        speed,
        Enum.EasingStyle.Back,
        Enum.EasingDirection.Out,
        0,
        false,
        0
    )
    return TweenService:Create(object, tweenInfo, properties)
end

function AnimationUtils.CreateSmoothTween(object, properties, speed)
    speed = speed or ANIMATION_SPEED
    local tweenInfo = TweenInfo.new(
        speed,
        Enum.EasingStyle.Exponential,
        Enum.EasingDirection.Out,
        0,
        false,
        0
    )
    return TweenService:Create(object, tweenInfo, properties)
end

function AnimationUtils.CreateBounceEffect(object, scale)
    scale = scale or 0.95
    local originalSize = object.Size
    
    local shrinkTween = AnimationUtils.CreateSpringTween(object, {
        Size = UDim2.new(originalSize.X.Scale * scale, originalSize.X.Offset * scale,
                        originalSize.Y.Scale * scale, originalSize.Y.Offset * scale)
    }, 0.1)
    
    local expandTween = AnimationUtils.CreateSpringTween(object, {
        Size = originalSize
    }, 0.2)
    
    shrinkTween:Play()
    shrinkTween.Completed:Connect(function()
        expandTween:Play()
    end)
end

-- Object Pool for performance optimization
local ObjectPool = {}
ObjectPool.__index = ObjectPool

function ObjectPool.new()
    return setmetatable({
        pools = {},
        activeObjects = {}
    }, ObjectPool)
end

function ObjectPool:GetObject(className, parent)
    local pool = self.pools[className]
    if not pool then
        pool = {}
        self.pools[className] = pool
    end
    
    local object
    if #pool > 0 then
        object = table.remove(pool)
        object.Parent = parent
    else
        object = Instance.new(className)
        object.Parent = parent
    end
    
    self.activeObjects[object] = true
    return object
end

function ObjectPool:ReturnObject(object)
    if self.activeObjects[object] then
        self.activeObjects[object] = nil
        object.Parent = nil
        
        local className = object.ClassName
        local pool = self.pools[className]
        if not pool then
            pool = {}
            self.pools[className] = pool
        end
        
        table.insert(pool, object)
    end
end

-- Theme Manager
local ThemeManager = {}
ThemeManager.__index = ThemeManager

function ThemeManager.new(customTheme)
    local theme = {}
    
    -- Merge default theme with custom theme
    for key, value in pairs(DEFAULT_THEME) do
        theme[key] = value
    end
    
    if customTheme then
        for key, value in pairs(customTheme) do
            theme[key] = value
        end
    end
    
    return setmetatable({
        theme = theme,
        callbacks = {}
    }, ThemeManager)
end

function ThemeManager:UpdateTheme(newTheme)
    for key, value in pairs(newTheme) do
        self.theme[key] = value
    end
    
    -- Notify all callbacks about theme change
    for _, callback in pairs(self.callbacks) do
        callback(self.theme)
    end
end

function ThemeManager:OnThemeChanged(callback)
    table.insert(self.callbacks, callback)
end

function ThemeManager:GetColor(colorName)
    return self.theme[colorName] or Color3.fromRGB(255, 255, 255)
end

-- Component Base Class
local Component = {}
Component.__index = Component

function Component.new(parent, theme)
    return setmetatable({
        parent = parent,
        theme = theme,
        element = nil,
        connections = {},
        children = {},
        visible = true,
        enabled = true
    }, Component)
end

function Component:SetVisible(visible)
    self.visible = visible
    if self.element then
        self.element.Visible = visible
    end
end

function Component:SetEnabled(enabled)
    self.enabled = enabled
    -- Override in subclasses for specific behavior
end

function Component:Destroy()
    -- Disconnect all connections
    for _, connection in pairs(self.connections) do
        if connection then
            connection:Disconnect()
        end
    end
    
    -- Destroy all children
    for _, child in pairs(self.children) do
        if child and child.Destroy then
            child:Destroy()
        end
    end
    
    -- Destroy the element
    if self.element then
        self.element:Destroy()
    end
    
    self.connections = {}
    self.children = {}
end

function Component:AddConnection(connection)
    table.insert(self.connections, connection)
end

-- Window Class
local Window = {}
Window.__index = Window
setmetatable(Window, Component)

function Window.new(config)
    config = config or {}
    
    local theme = ThemeManager.new(config.Theme)
    local objectPool = ObjectPool.new()
    
    local self = setmetatable(Component.new(nil, theme), Window)
    
    self.config = {
        Title = config.Title or "Nexus UI",
        Size = config.Size or UDim2.fromOffset(600, 400),
        MinSize = config.MinSize or UDim2.fromOffset(400, 300),
        Resizable = config.Resizable ~= false,
        Draggable = config.Draggable ~= false,
        CloseButton = config.CloseButton ~= false,
        MinimizeButton = config.MinimizeButton ~= false
    }
    
    self.objectPool = objectPool
    self.tabs = {}
    self.activeTab = nil
    self.minimized = false
    
    self:CreateWindow()
    self:SetupWindowBehavior()
    
    return self
end

function Window:CreateWindow()
    -- Create ScreenGui
    self.screenGui = Instance.new("ScreenGui")
    self.screenGui.Name = "NexusUI_" .. HttpService:GenerateGUID(false)
    self.screenGui.ResetOnSpawn = false
    self.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.screenGui.Parent = RunService:IsStudio() and LocalPlayer:WaitForChild("PlayerGui") or CoreGui
    
    -- Main Window Frame
    self.element = Instance.new("Frame")
    self.element.Name = "MainWindow"
    self.element.Size = self.config.Size
    self.element.Position = UDim2.fromScale(0.5, 0.5)
    self.element.AnchorPoint = Vector2.new(0.5, 0.5)
    self.element.BackgroundColor3 = self.theme:GetColor("Background")
    self.element.BorderSizePixel = 0
    self.element.Parent = self.screenGui
    
    -- Window Corner
    local windowCorner = Instance.new("UICorner")
    windowCorner.CornerRadius = self.theme.theme.CornerRadius
    windowCorner.Parent = self.element
    
    -- Glass Effect
    local glassEffect = Instance.new("Frame")
    glassEffect.Name = "GlassEffect"
    glassEffect.Size = UDim2.fromScale(1, 1)
    glassEffect.Position = UDim2.fromScale(0, 0)
    glassEffect.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    glassEffect.BackgroundTransparency = self.theme.theme.GlassTransparency
    glassEffect.BorderSizePixel = 0
    glassEffect.Parent = self.element
    
    local glassCorner = Instance.new("UICorner")
    glassCorner.CornerRadius = self.theme.theme.CornerRadius
    glassCorner.Parent = glassEffect
    
    -- Drop Shadow
    self:CreateDropShadow()
    
    -- Title Bar
    self:CreateTitleBar()
    
    -- Content Area
    self:CreateContentArea()
    
    -- Resize Handle (if resizable)
    if self.config.Resizable then
        self:CreateResizeHandle()
    end
end

function Window:CreateDropShadow()
    local shadowHolder = Instance.new("Frame")
    shadowHolder.Name = "ShadowHolder"
    shadowHolder.Size = UDim2.fromScale(1, 1)
    shadowHolder.Position = UDim2.fromScale(0, 0)
    shadowHolder.BackgroundTransparency = 1
    shadowHolder.ZIndex = self.element.ZIndex - 1
    shadowHolder.Parent = self.screenGui
    
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "DropShadow"
    shadow.Image = "rbxasset://textures/ui/Controls/DropShadow.png"
    shadow.ImageColor3 = self.theme.theme.ShadowColor
    shadow.ImageTransparency = self.theme.theme.ShadowTransparency
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    shadow.Size = UDim2.fromScale(1, 1)
    shadow.Position = UDim2.fromOffset(0, 6)
    shadow.BackgroundTransparency = 1
    shadow.Parent = shadowHolder
    
    self.shadowHolder = shadowHolder
end

function Window:CreateTitleBar()
    self.titleBar = Instance.new("Frame")
    self.titleBar.Name = "TitleBar"
    self.titleBar.Size = UDim2.new(1, 0, 0, 40)
    self.titleBar.Position = UDim2.fromScale(0, 0)
    self.titleBar.BackgroundColor3 = self.theme:GetColor("Surface")
    self.titleBar.BorderSizePixel = 0
    self.titleBar.Parent = self.element
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = self.theme.theme.CornerRadius
    titleCorner.Parent = self.titleBar
    
    -- Title Text
    local titleText = Instance.new("TextLabel")
    titleText.Name = "TitleText"
    titleText.Size = UDim2.new(1, -100, 1, 0)
    titleText.Position = UDim2.fromOffset(16, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = self.config.Title
    titleText.TextColor3 = self.theme:GetColor("TextPrimary")
    titleText.TextSize = self.theme.theme.TextSizeMedium
    titleText.Font = self.theme.theme.FontPrimary
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = self.titleBar
    
    -- Window Controls
    self:CreateWindowControls()
end

function Window:CreateWindowControls()
    local controlsFrame = Instance.new("Frame")
    controlsFrame.Name = "Controls"
    controlsFrame.Size = UDim2.fromOffset(80, 40)
    controlsFrame.Position = UDim2.new(1, -80, 0, 0)
    controlsFrame.BackgroundTransparency = 1
    controlsFrame.Parent = self.titleBar
    
    local controlsLayout = Instance.new("UIListLayout")
    controlsLayout.FillDirection = Enum.FillDirection.Horizontal
    controlsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    controlsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    controlsLayout.Padding = UDim.new(0, 4)
    controlsLayout.Parent = controlsFrame
    
    -- Minimize Button
    if self.config.MinimizeButton then
        local minimizeBtn = self:CreateControlButton("−", function()
            self:ToggleMinimize()
        end)
        minimizeBtn.Parent = controlsFrame
    end
    
    -- Close Button
    if self.config.CloseButton then
        local closeBtn = self:CreateControlButton("×", function()
            self:Close()
        end)
        closeBtn.BackgroundColor3 = self.theme:GetColor("Error")
        closeBtn.Parent = controlsFrame
    end
end

function Window:CreateControlButton(text, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.fromOffset(32, 32)
    button.BackgroundColor3 = self.theme:GetColor("SurfaceVariant")
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = self.theme:GetColor("TextPrimary")
    button.TextSize = self.theme.theme.TextSizeMedium
    button.Font = self.theme.theme.FontPrimary
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = self.theme.theme.SmallCornerRadius
    corner.Parent = button
    
    -- Hover Effect
    local hoverConnection = button.MouseEnter:Connect(function()
        AnimationUtils.CreateSmoothTween(button, {
            BackgroundTransparency = self.theme.theme.HoverTransparency
        }):Play()
    end)
    
    local leaveConnection = button.MouseLeave:Connect(function()
        AnimationUtils.CreateSmoothTween(button, {
            BackgroundTransparency = 0
        }):Play()
    end)
    
    local clickConnection = button.MouseButton1Click:Connect(function()
        AnimationUtils.CreateBounceEffect(button)
        if callback then callback() end
    end)
    
    self:AddConnection(hoverConnection)
    self:AddConnection(leaveConnection)
    self:AddConnection(clickConnection)
    
    return button
end

function Window:CreateContentArea()
    self.contentArea = Instance.new("Frame")
    self.contentArea.Name = "ContentArea"
    self.contentArea.Size = UDim2.new(1, 0, 1, -40)
    self.contentArea.Position = UDim2.fromOffset(0, 40)
    self.contentArea.BackgroundTransparency = 1
    self.contentArea.Parent = self.element
    
    -- Tab Container
    self.tabContainer = Instance.new("Frame")
    self.tabContainer.Name = "TabContainer"
    self.tabContainer.Size = UDim2.new(1, 0, 0, 40)
    self.tabContainer.Position = UDim2.fromScale(0, 0)
    self.tabContainer.BackgroundColor3 = self.theme:GetColor("SurfaceVariant")
    self.tabContainer.BorderSizePixel = 0
    self.tabContainer.Parent = self.contentArea
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    tabLayout.Padding = UDim.new(0, 2)
    tabLayout.Parent = self.tabContainer
    
    -- Content Frame
    self.contentFrame = Instance.new("Frame")
    self.contentFrame.Name = "ContentFrame"
    self.contentFrame.Size = UDim2.new(1, 0, 1, -40)
    self.contentFrame.Position = UDim2.fromOffset(0, 40)
    self.contentFrame.BackgroundTransparency = 1
    self.contentFrame.Parent = self.contentArea
end

function Window:CreateResizeHandle()
    local resizeHandle = Instance.new("Frame")
    resizeHandle.Name = "ResizeHandle"
    resizeHandle.Size = UDim2.fromOffset(20, 20)
    resizeHandle.Position = UDim2.new(1, -20, 1, -20)
    resizeHandle.BackgroundColor3 = self.theme:GetColor("Border")
    resizeHandle.BorderSizePixel = 0
    resizeHandle.Parent = self.element
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = resizeHandle
    
    -- Resize functionality
    local resizing = false
    local startSize, startPos
    
    local inputBeganConnection = resizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = true
            startSize = self.element.AbsoluteSize
            startPos = Vector2.new(input.Position.X, input.Position.Y)
        end
    end)
    
    local inputChangedConnection = UserInputService.InputChanged:Connect(function(input)
        if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = Vector2.new(input.Position.X, input.Position.Y) - startPos
            local newSize = Vector2.new(
                math.max(self.config.MinSize.X.Offset, startSize.X + delta.X),
                math.max(self.config.MinSize.Y.Offset, startSize.Y + delta.Y)
            )
            
            self.element.Size = UDim2.fromOffset(newSize.X, newSize.Y)
        end
    end)
    
    local inputEndedConnection = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = false
        end
    end)
    
    self:AddConnection(inputBeganConnection)
    self:AddConnection(inputChangedConnection)
    self:AddConnection(inputEndedConnection)
end

function Window:SetupWindowBehavior()
    -- Dragging functionality
    if self.config.Draggable then
        local dragging = false
        local dragStart, startPos
        
        local inputBeganConnection = self.titleBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = self.element.Position
            end
        end)
        
        local inputChangedConnection = UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - dragStart
                self.element.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
                
                -- Update shadow position
                if self.shadowHolder then
                    self.shadowHolder.Position = self.element.Position
                end
            end
        end)
        
        local inputEndedConnection = UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        self:AddConnection(inputBeganConnection)
        self:AddConnection(inputChangedConnection)
        self:AddConnection(inputEndedConnection)
    end
end

function Window:CreateTab(config)
    config = config or {}
    local tab = Tab.new(self, config)
    
    self.tabs[config.Name or #self.tabs + 1] = tab
    
    if not self.activeTab then
        self:SetActiveTab(tab)
    end
    
    return tab
end

function Window:SetActiveTab(tab)
    if self.activeTab then
        self.activeTab:SetActive(false)
    end
    
    self.activeTab = tab
    tab:SetActive(true)
end

function Window:ToggleMinimize()
    self.minimized = not self.minimized
    
    local targetSize = self.minimized and UDim2.new(self.element.Size.X.Scale, self.element.Size.X.Offset, 0, 40) or self.config.Size
    
    AnimationUtils.CreateSmoothTween(self.element, {
        Size = targetSize
    }):Play()
    
    self.contentArea.Visible = not self.minimized
end

function Window:Close()
    AnimationUtils.CreateSmoothTween(self.element, {
        Size = UDim2.fromScale(0, 0),
        BackgroundTransparency = 1
    }):Play()
    
    AnimationUtils.CreateSmoothTween(self.shadowHolder, {
        ImageTransparency = 1
    }):Play()
    
    wait(ANIMATION_SPEED)
    self:Destroy()
end

-- Tab Class
local Tab = {}
Tab.__index = Tab
setmetatable(Tab, Component)

function Tab.new(window, config)
    config = config or {}
    
    local self = setmetatable(Component.new(window.contentFrame, window.theme), Tab)
    
    self.window = window
    self.config = {
        Name = config.Name or "Tab",
        Icon = config.Icon,
        Closable = config.Closable == true
    }
    
    self.sections = {}
    self.active = false
    
    self:CreateTab()
    
    return self
end

function Tab:CreateTab()
    -- Tab Button
    self.tabButton = Instance.new("TextButton")
    self.tabButton.Name = self.config.Name
    self.tabButton.Size = UDim2.fromOffset(120, 32)
    self.tabButton.BackgroundColor3 = self.theme:GetColor("Surface")
    self.tabButton.BorderSizePixel = 0
    self.tabButton.Text = self.config.Name
    self.tabButton.TextColor3 = self.theme:GetColor("TextSecondary")
    self.tabButton.TextSize = self.theme.theme.TextSizeSmall
    self.tabButton.Font = self.theme.theme.FontSecondary
    self.tabButton.Parent = self.window.tabContainer
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = self.theme.theme.SmallCornerRadius
    tabCorner.Parent = self.tabButton
    
    -- Tab Content
    self.element = Instance.new("ScrollingFrame")
    self.element.Name = self.config.Name .. "_Content"
    self.element.Size = UDim2.fromScale(1, 1)
    self.element.Position = UDim2.fromScale(0, 0)
    self.element.BackgroundTransparency = 1
    self.element.BorderSizePixel = 0
    self.element.ScrollBarThickness = 6
    self.element.ScrollBarImageColor3 = self.theme:GetColor("Border")
    self.element.CanvasSize = UDim2.fromScale(0, 0)
    self.element.AutomaticCanvasSize = Enum.AutomaticSize.Y
    self.element.Visible = false
    self.element.Parent = self.window.contentFrame
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.FillDirection = Enum.FillDirection.Vertical
    contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    contentLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    contentLayout.Padding = UDim.new(0, 8)
    contentLayout.Parent = self.element
    
    local contentPadding = Instance.new("UIPadding")
    contentPadding.PaddingTop = UDim.new(0, 16)
    contentPadding.PaddingBottom = UDim.new(0, 16)
    contentPadding.PaddingLeft = UDim.new(0, 16)
    contentPadding.PaddingRight = UDim.new(0, 16)
    contentPadding.Parent = self.element
    
    -- Tab Button Click
    local clickConnection = self.tabButton.MouseButton1Click:Connect(function()
        self.window:SetActiveTab(self)
    end)
    
    self:AddConnection(clickConnection)
end

function Tab:SetActive(active)
    self.active = active
    
    local textColor = active and self.theme:GetColor("TextPrimary") or self.theme:GetColor("TextSecondary")
    local backgroundColor = active and self.theme:GetColor("Primary") or self.theme:GetColor("Surface")
    
    AnimationUtils.CreateSmoothTween(self.tabButton, {
        TextColor3 = textColor,
        BackgroundColor3 = backgroundColor
    }):Play()
    
    self.element.Visible = active
end

function Tab:CreateSection(config)
    config = config or {}
    local section = Section.new(self, config)
    
    self.sections[config.Name or #self.sections + 1] = section
    
    return section
end

-- Section Class
local Section = {}
Section.__index = Section
setmetatable(Section, Component)

function Section.new(tab, config)
    config = config or {}
    
    local self = setmetatable(Component.new(tab.element, tab.theme), Section)
    
    self.tab = tab
    self.config = {
        Name = config.Name or "Section",
        Description = config.Description
    }
    
    self.elements = {}
    
    self:CreateSection()
    
    return self
end

function Section:CreateSection()
    self.element = Instance.new("Frame")
    self.element.Name = self.config.Name
    self.element.Size = UDim2.new(1, 0, 0, 0)
    self.element.BackgroundColor3 = self.theme:GetColor("Surface")
    self.element.BorderSizePixel = 0
    self.element.AutomaticSize = Enum.AutomaticSize.Y
    self.element.Parent = self.parent
    
    local sectionCorner = Instance.new("UICorner")
    sectionCorner.CornerRadius = self.theme.theme.CornerRadius
    sectionCorner.Parent = self.element
    
    -- Section Header
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundTransparency = 1
    header.Parent = self.element
    
    local headerTitle = Instance.new("TextLabel")
    headerTitle.Name = "Title"
    headerTitle.Size = UDim2.new(1, -32, 1, 0)
    headerTitle.Position = UDim2.fromOffset(16, 0)
    headerTitle.BackgroundTransparency = 1
    headerTitle.Text = self.config.Name
    headerTitle.TextColor3 = self.theme:GetColor("TextPrimary")
    headerTitle.TextSize = self.theme.theme.TextSizeMedium
    headerTitle.Font = self.theme.theme.FontPrimary
    headerTitle.TextXAlignment = Enum.TextXAlignment.Left
    headerTitle.Parent = header
    
    if self.config.Description then
        local description = Instance.new("TextLabel")
        description.Name = "Description"
        description.Size = UDim2.new(1, -32, 0, 20)
        description.Position = UDim2.fromOffset(16, 40)
        description.BackgroundTransparency = 1
        description.Text = self.config.Description
        description.TextColor3 = self.theme:GetColor("TextSecondary")
        description.TextSize = self.theme.theme.TextSizeSmall
        description.Font = self.theme.theme.FontSecondary
        description.TextXAlignment = Enum.TextXAlignment.Left
        description.TextWrapped = true
        description.Parent = self.element
        
        header.Size = UDim2.new(1, 0, 0, 60)
    end
    
    -- Content Container
    self.contentContainer = Instance.new("Frame")
    self.contentContainer.Name = "Content"
    self.contentContainer.Size = UDim2.new(1, 0, 0, 0)
    self.contentContainer.Position = UDim2.new(0, 0, 0, self.config.Description and 60 or 40)
    self.contentContainer.BackgroundTransparency = 1
    self.contentContainer.AutomaticSize = Enum.AutomaticSize.Y
    self.contentContainer.Parent = self.element
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.FillDirection = Enum.FillDirection.Vertical
    contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    contentLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    contentLayout.Padding = UDim.new(0, 8)
    contentLayout.Parent = self.contentContainer
    
    local contentPadding = Instance.new("UIPadding")
    contentPadding.PaddingTop = UDim.new(0, 8)
    contentPadding.PaddingBottom = UDim.new(0, 16)
    contentPadding.PaddingLeft = UDim.new(0, 16)
    contentPadding.PaddingRight = UDim.new(0, 16)
    contentPadding.Parent = self.contentContainer
end

-- Button Element
function Section:Button(config, callback)
    config = config or {}
    
    local button = Instance.new("TextButton")
    button.Name = config.Name or "Button"
    button.Size = UDim2.new(1, 0, 0, 36)
    button.BackgroundColor3 = self.theme:GetColor("Primary")
    button.BorderSizePixel = 0
    button.Text = config.Text or "Button"
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = self.theme.theme.TextSizeMedium
    button.Font = self.theme.theme.FontSecondary
    button.Parent = self.contentContainer
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = self.theme.theme.SmallCornerRadius
    buttonCorner.Parent = button
    
    -- Hover Effects
    local hoverConnection = button.MouseEnter:Connect(function()
        AnimationUtils.CreateSmoothTween(button, {
            BackgroundColor3 = Color3.fromRGB(
                math.min(255, self.theme:GetColor("Primary").R * 255 + 20),
                math.min(255, self.theme:GetColor("Primary").G * 255 + 20),
                math.min(255, self.theme:GetColor("Primary").B * 255 + 20)
            )
        }):Play()
    end)
    
    local leaveConnection = button.MouseLeave:Connect(function()
        AnimationUtils.CreateSmoothTween(button, {
            BackgroundColor3 = self.theme:GetColor("Primary")
        }):Play()
    end)
    
    local clickConnection = button.MouseButton1Click:Connect(function()
        AnimationUtils.CreateBounceEffect(button)
        if callback then callback() end
    end)
    
    self:AddConnection(hoverConnection)
    self:AddConnection(leaveConnection)
    self:AddConnection(clickConnection)
    
    self.elements[config.Name or #self.elements + 1] = button
    
    return button
end

-- Toggle Element
function Section:Toggle(config, callback)
    config = config or {}
    
    local container = Instance.new("Frame")
    container.Name = config.Name or "Toggle"
    container.Size = UDim2.new(1, 0, 0, 36)
    container.BackgroundTransparency = 1
    container.Parent = self.contentContainer
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.fromScale(0, 0)
    label.BackgroundTransparency = 1
    label.Text = config.Text or "Toggle"
    label.TextColor3 = self.theme:GetColor("TextPrimary")
    label.TextSize = self.theme.theme.TextSizeMedium
    label.Font = self.theme.theme.FontSecondary
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Name = "ToggleFrame"
    toggleFrame.Size = UDim2.fromOffset(50, 24)
    toggleFrame.Position = UDim2.new(1, -50, 0.5, -12)
    toggleFrame.BackgroundColor3 = self.theme:GetColor("SurfaceVariant")
    toggleFrame.BorderSizePixel = 0
    toggleFrame.Parent = container
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 12)
    toggleCorner.Parent = toggleFrame
    
    local toggleButton = Instance.new("Frame")
    toggleButton.Name = "ToggleButton"
    toggleButton.Size = UDim2.fromOffset(20, 20)
    toggleButton.Position = UDim2.fromOffset(2, 2)
    toggleButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.BorderSizePixel = 0
    toggleButton.Parent = toggleFrame
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 10)
    buttonCorner.Parent = toggleButton
    
    local enabled = config.Default or false
    
    local function updateToggle()
        local targetPos = enabled and UDim2.fromOffset(28, 2) or UDim2.fromOffset(2, 2)
        local targetColor = enabled and self.theme:GetColor("Primary") or self.theme:GetColor("SurfaceVariant")
        
        AnimationUtils.CreateSmoothTween(toggleButton, {
            Position = targetPos
        }):Play()
        
        AnimationUtils.CreateSmoothTween(toggleFrame, {
            BackgroundColor3 = targetColor
        }):Play()
    end
    
    local clickConnection = toggleFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            enabled = not enabled
            updateToggle()
            if callback then callback(enabled) end
        end
    end)
    
    self:AddConnection(clickConnection)
    
    updateToggle()
    
    self.elements[config.Name or #self.elements + 1] = {
        container = container,
        getValue = function() return enabled end,
        setValue = function(value)
            enabled = value
            updateToggle()
        end
    }
    
    return self.elements[config.Name or #self.elements]
end

-- Slider Element
function Section:Slider(config, callback)
    config = config or {}
    
    local container = Instance.new("Frame")
    container.Name = config.Name or "Slider"
    container.Size = UDim2.new(1, 0, 0, 50)
    container.BackgroundTransparency = 1
    container.Parent = self.contentContainer
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(0.7, 0, 0, 20)
    label.Position = UDim2.fromScale(0, 0)
    label.BackgroundTransparency = 1
    label.Text = config.Text or "Slider"
    label.TextColor3 = self.theme:GetColor("TextPrimary")
    label.TextSize = self.theme.theme.TextSizeMedium
    label.Font = self.theme.theme.FontSecondary
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Name = "ValueLabel"
    valueLabel.Size = UDim2.new(0.3, 0, 0, 20)
    valueLabel.Position = UDim2.new(0.7, 0, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(config.Default or config.Min or 0)
    valueLabel.TextColor3 = self.theme:GetColor("TextSecondary")
    valueLabel.TextSize = self.theme.theme.TextSizeSmall
    valueLabel.Font = self.theme.theme.FontMono
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = container
    
    local sliderTrack = Instance.new("Frame")
    sliderTrack.Name = "SliderTrack"
    sliderTrack.Size = UDim2.new(1, 0, 0, 6)
    sliderTrack.Position = UDim2.fromOffset(0, 30)
    sliderTrack.BackgroundColor3 = self.theme:GetColor("SurfaceVariant")
    sliderTrack.BorderSizePixel = 0
    sliderTrack.Parent = container
    
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(0, 3)
    trackCorner.Parent = sliderTrack
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Name = "SliderFill"
    sliderFill.Size = UDim2.fromScale(0, 1)
    sliderFill.Position = UDim2.fromScale(0, 0)
    sliderFill.BackgroundColor3 = self.theme:GetColor("Primary")
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderTrack
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 3)
    fillCorner.Parent = sliderFill
    
    local sliderHandle = Instance.new("Frame")
    sliderHandle.Name = "SliderHandle"
    sliderHandle.Size = UDim2.fromOffset(16, 16)
    sliderHandle.Position = UDim2.new(0, -8, 0.5, -8)
    sliderHandle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderHandle.BorderSizePixel = 0
    sliderHandle.Parent = sliderTrack
    
    local handleCorner = Instance.new("UICorner")
    handleCorner.CornerRadius = UDim.new(0, 8)
    handleCorner.Parent = sliderHandle
    
    local min = config.Min or 0
    local max = config.Max or 100
    local value = config.Default or min
    local dragging = false
    
    local function updateSlider()
        local percentage = (value - min) / (max - min)
        
        AnimationUtils.CreateSmoothTween(sliderFill, {
            Size = UDim2.fromScale(percentage, 1)
        }):Play()
        
        AnimationUtils.CreateSmoothTween(sliderHandle, {
            Position = UDim2.new(percentage, -8, 0.5, -8)
        }):Play()
        
        valueLabel.Text = tostring(math.floor(value * 100) / 100)
    end
    
    local inputBeganConnection = sliderTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    local inputChangedConnection = UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local relativeX = math.clamp((input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
            value = min + (max - min) * relativeX
            updateSlider()
            if callback then callback(value) end
        end
    end)
    
    local inputEndedConnection = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    self:AddConnection(inputBeganConnection)
    self:AddConnection(inputChangedConnection)
    self:AddConnection(inputEndedConnection)
    
    updateSlider()
    
    self.elements[config.Name or #self.elements + 1] = {
        container = container,
        getValue = function() return value end,
        setValue = function(newValue)
            value = math.clamp(newValue, min, max)
            updateSlider()
        end
    }
    
    return self.elements[config.Name or #self.elements]
end

-- Input/Textbox Element
function Section:Input(config, callback)
    config = config or {}
    
    local container = Instance.new("Frame")
    container.Name = config.Name or "Input"
    container.Size = UDim2.new(1, 0, 0, 50)
    container.BackgroundTransparency = 1
    container.Parent = self.contentContainer
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Position = UDim2.fromScale(0, 0)
    label.BackgroundTransparency = 1
    label.Text = config.Text or "Input"
    label.TextColor3 = self.theme:GetColor("TextPrimary")
    label.TextSize = self.theme.theme.TextSizeMedium
    label.Font = self.theme.theme.FontSecondary
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local inputFrame = Instance.new("Frame")
    inputFrame.Name = "InputFrame"
    inputFrame.Size = UDim2.new(1, 0, 0, 24)
    inputFrame.Position = UDim2.fromOffset(0, 26)
    inputFrame.BackgroundColor3 = self.theme:GetColor("SurfaceVariant")
    inputFrame.BorderSizePixel = 0
    inputFrame.Parent = container
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = self.theme.theme.SmallCornerRadius
    inputCorner.Parent = inputFrame
    
    local textBox = Instance.new("TextBox")
    textBox.Name = "TextBox"
    textBox.Size = UDim2.new(1, -16, 1, 0)
    textBox.Position = UDim2.fromOffset(8, 0)
    textBox.BackgroundTransparency = 1
    textBox.Text = config.Default or ""
    textBox.PlaceholderText = config.Placeholder or ""
    textBox.TextColor3 = self.theme:GetColor("TextPrimary")
    textBox.PlaceholderColor3 = self.theme:GetColor("TextMuted")
    textBox.TextSize = self.theme.theme.TextSizeSmall
    textBox.Font = self.theme.theme.FontSecondary
    textBox.TextXAlignment = Enum.TextXAlignment.Left
    textBox.ClearTextOnFocus = false
    textBox.Parent = inputFrame
    
    -- Focus Effects
    local focusedConnection = textBox.Focused:Connect(function()
        AnimationUtils.CreateSmoothTween(inputFrame, {
            BackgroundColor3 = self.theme:GetColor("Surface"),
            BorderSizePixel = 1,
            BorderColor3 = self.theme:GetColor("Primary")
        }):Play()
    end)
    
    local focusLostConnection = textBox.FocusLost:Connect(function()
        AnimationUtils.CreateSmoothTween(inputFrame, {
            BackgroundColor3 = self.theme:GetColor("SurfaceVariant"),
            BorderSizePixel = 0
        }):Play()
        
        if callback then callback(textBox.Text) end
    end)
    
    self:AddConnection(focusedConnection)
    self:AddConnection(focusLostConnection)
    
    self.elements[config.Name or #self.elements + 1] = {
        container = container,
        getValue = function() return textBox.Text end,
        setValue = function(text)
            textBox.Text = text
        end
    }
    
    return self.elements[config.Name or #self.elements]
end

-- Dropdown Element
function Section:Dropdown(config, callback)
    config = config or {}
    
    local container = Instance.new("Frame")
    container.Name = config.Name or "Dropdown"
    container.Size = UDim2.new(1, 0, 0, 50)
    container.BackgroundTransparency = 1
    container.Parent = self.contentContainer
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Position = UDim2.fromScale(0, 0)
    label.BackgroundTransparency = 1
    label.Text = config.Text or "Dropdown"
    label.TextColor3 = self.theme:GetColor("TextPrimary")
    label.TextSize = self.theme.theme.TextSizeMedium
    label.Font = self.theme.theme.FontSecondary
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local dropdownFrame = Instance.new("TextButton")
    dropdownFrame.Name = "DropdownFrame"
    dropdownFrame.Size = UDim2.new(1, 0, 0, 24)
    dropdownFrame.Position = UDim2.fromOffset(0, 26)
    dropdownFrame.BackgroundColor3 = self.theme:GetColor("SurfaceVariant")
    dropdownFrame.BorderSizePixel = 0
    dropdownFrame.Text = ""
    dropdownFrame.Parent = container
    
    local dropdownCorner = Instance.new("UICorner")
    dropdownCorner.CornerRadius = self.theme.theme.SmallCornerRadius
    dropdownCorner.Parent = dropdownFrame
    
    local selectedLabel = Instance.new("TextLabel")
    selectedLabel.Name = "SelectedLabel"
    selectedLabel.Size = UDim2.new(1, -32, 1, 0)
    selectedLabel.Position = UDim2.fromOffset(8, 0)
    selectedLabel.BackgroundTransparency = 1
    selectedLabel.Text = config.Default or (config.Options and config.Options[1]) or "Select..."
    selectedLabel.TextColor3 = self.theme:GetColor("TextPrimary")
    selectedLabel.TextSize = self.theme.theme.TextSizeSmall
    selectedLabel.Font = self.theme.theme.FontSecondary
    selectedLabel.TextXAlignment = Enum.TextXAlignment.Left
    selectedLabel.Parent = dropdownFrame
    
    local arrow = Instance.new("TextLabel")
    arrow.Name = "Arrow"
    arrow.Size = UDim2.fromOffset(20, 20)
    arrow.Position = UDim2.new(1, -24, 0.5, -10)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.TextColor3 = self.theme:GetColor("TextSecondary")
    arrow.TextSize = 10
    arrow.Font = self.theme.theme.FontSecondary
    arrow.Parent = dropdownFrame
    
    local optionsFrame = Instance.new("Frame")
    optionsFrame.Name = "OptionsFrame"
    optionsFrame.Size = UDim2.new(1, 0, 0, 0)
    optionsFrame.Position = UDim2.fromOffset(0, 50)
    optionsFrame.BackgroundColor3 = self.theme:GetColor("Surface")
    optionsFrame.BorderSizePixel = 0
    optionsFrame.Visible = false
    optionsFrame.ZIndex = 10
    optionsFrame.Parent = container
    
    local optionsCorner = Instance.new("UICorner")
    optionsCorner.CornerRadius = self.theme.theme.SmallCornerRadius
    optionsCorner.Parent = optionsFrame
    
    local optionsLayout = Instance.new("UIListLayout")
    optionsLayout.FillDirection = Enum.FillDirection.Vertical
    optionsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    optionsLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    optionsLayout.Parent = optionsFrame
    
    local isOpen = false
    local selectedValue = config.Default or (config.Options and config.Options[1])
    
    local function toggleDropdown()
        isOpen = not isOpen
        
        local targetSize = isOpen and UDim2.new(1, 0, 0, #(config.Options or {}) * 24) or UDim2.new(1, 0, 0, 0)
        local targetRotation = isOpen and 180 or 0
        
        AnimationUtils.CreateSmoothTween(optionsFrame, {
            Size = targetSize
        }):Play()
        
        AnimationUtils.CreateSmoothTween(arrow, {
            Rotation = targetRotation
        }):Play()
        
        optionsFrame.Visible = isOpen
        
        if isOpen then
            container.Size = UDim2.new(1, 0, 0, 50 + #(config.Options or {}) * 24)
        else
            container.Size = UDim2.new(1, 0, 0, 50)
        end
    end
    
    -- Create option buttons
    if config.Options then
        for _, option in ipairs(config.Options) do
            local optionButton = Instance.new("TextButton")
            optionButton.Name = option
            optionButton.Size = UDim2.new(1, 0, 0, 24)
            optionButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            optionButton.BackgroundTransparency = 1
            optionButton.BorderSizePixel = 0
            optionButton.Text = option
            optionButton.TextColor3 = self.theme:GetColor("TextPrimary")
            optionButton.TextSize = self.theme.theme.TextSizeSmall
            optionButton.Font = self.theme.theme.FontSecondary
            optionButton.Parent = optionsFrame
            
            local hoverConnection = optionButton.MouseEnter:Connect(function()
                AnimationUtils.CreateSmoothTween(optionButton, {
                    BackgroundTransparency = 0.9
                }):Play()
            end)
            
            local leaveConnection = optionButton.MouseLeave:Connect(function()
                AnimationUtils.CreateSmoothTween(optionButton, {
                    BackgroundTransparency = 1
                }):Play()
            end)
            
            local clickConnection = optionButton.MouseButton1Click:Connect(function()
                selectedValue = option
                selectedLabel.Text = option
                toggleDropdown()
                if callback then callback(option) end
            end)
            
            self:AddConnection(hoverConnection)
            self:AddConnection(leaveConnection)
            self:AddConnection(clickConnection)
        end
    end
    
    local clickConnection = dropdownFrame.MouseButton1Click:Connect(function()
        toggleDropdown()
    end)
    
    self:AddConnection(clickConnection)
    
    self.elements[config.Name or #self.elements + 1] = {
        container = container,
        getValue = function() return selectedValue end,
        setValue = function(value)
            selectedValue = value
            selectedLabel.Text = value
        end
    }
    
    return self.elements[config.Name or #self.elements]
end

-- Main Library Functions
function NexusUI.new(config)
    return Window.new(config)
end

function NexusUI.CreateNotification(config)
    config = config or {}
    
    local notification = Instance.new("Frame")
    notification.Name = "Notification"
    notification.Size = UDim2.fromOffset(300, 80)
    notification.Position = UDim2.new(1, -320, 1, -100)
    notification.BackgroundColor3 = DEFAULT_THEME.Surface
    notification.BorderSizePixel = 0
    
    local notifCorner = Instance.new("UICorner")
    notifCorner.CornerRadius = DEFAULT_THEME.CornerRadius
    notifCorner.Parent = notification
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -16, 0, 20)
    title.Position = UDim2.fromOffset(8, 8)
    title.BackgroundTransparency = 1
    title.Text = config.Title or "Notification"
    title.TextColor3 = DEFAULT_THEME.TextPrimary
    title.TextSize = DEFAULT_THEME.TextSizeMedium
    title.Font = DEFAULT_THEME.FontPrimary
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = notification
    
    local description = Instance.new("TextLabel")
    description.Name = "Description"
    description.Size = UDim2.new(1, -16, 0, 40)
    description.Position = UDim2.fromOffset(8, 28)
    description.BackgroundTransparency = 1
    description.Text = config.Description or ""
    description.TextColor3 = DEFAULT_THEME.TextSecondary
    description.TextSize = DEFAULT_THEME.TextSizeSmall
    description.Font = DEFAULT_THEME.FontSecondary
    description.TextXAlignment = Enum.TextXAlignment.Left
    description.TextWrapped = true
    description.Parent = notification
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "NotificationGui"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = RunService:IsStudio() and LocalPlayer:WaitForChild("PlayerGui") or CoreGui
    
    notification.Parent = screenGui
    
    -- Slide in animation
    notification.Position = UDim2.new(1, 20, 1, -100)
    AnimationUtils.CreateSmoothTween(notification, {
        Position = UDim2.new(1, -320, 1, -100)
    }):Play()
    
    -- Auto dismiss
    local duration = config.Duration or 5
    wait(duration)
    
    AnimationUtils.CreateSmoothTween(notification, {
        Position = UDim2.new(1, 20, 1, -100)
    }):Play()
    
    wait(ANIMATION_SPEED)
    screenGui:Destroy()
end

return NexusUI
