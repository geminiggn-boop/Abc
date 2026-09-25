--// FINDER 2D FULL v2
--// ไม่มีป้ายชื่อวัตถุ
--// UI เล็ก + ลากได้
--// กรอบติดตามวัตถุแบบ Real-time

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

--==================================================
-- CLEAN OLD UI
--==================================================

local oldGui = Player:WaitForChild("PlayerGui"):FindFirstChild("BoxFinder2D")
if oldGui then
    oldGui:Destroy()
end

--==================================================
-- SETTINGS
--==================================================

local Categories = {
    {
        name = "GHOST",
        color = Color3.fromRGB(255, 60, 60),
        words = {
            "ghost",
            "spirit",
            "monster",
            "ผี"
        }
    },

    {
        name = "KEY",
        color = Color3.fromRGB(255, 220, 40),
        words = {
            "key",
            "กุญแจ"
        }
    },

    {
        name = "CODE",
        color = Color3.fromRGB(40, 220, 255),
        words = {
            "password",
            "passcode",
            "code",
            "รหัส",
            "รหัสผ่าน"
        }
    }
}

--==================================================
-- GUI
--==================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BoxFinder2D"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = Player.PlayerGui

--==================================================
-- SMALL FINDER PANEL
--==================================================

local Panel = Instance.new("Frame")
Panel.Name = "FinderPanel"
Panel.Size = UDim2.new(0, 125, 0, 45)
Panel.Position = UDim2.new(0, 15, 0, 100)
Panel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Panel.BackgroundTransparency = 0.15
Panel.BorderSizePixel = 0
Panel.Active = true
Panel.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 😎
Corner.Parent = Panel

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(90, 90, 90)
Stroke.Thickness = 1
Stroke.Parent = Panel

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "🔎 FINDER"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Center
Title.TextYAlignment = Enum.TextYAlignment.Center
Title.Parent = Panel

--==================================================
-- DRAG UI
--==================================================

local dragging = false
local dragStart
local startPos

Panel.InputBegan:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPos = Panel.Position

        input.Changed:Connect(function()

            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end

        end)

    end

end)

UserInputService.InputChanged:Connect(function(input)

    if not dragging then
        return
    end

    if input.UserInputType ~= Enum.UserInputType.MouseMovement
        and input.UserInputType ~= Enum.UserInputType.Touch then
        return
    end

    local delta = input.Position - dragStart

    Panel.Position = UDim2.new(
        startPos.X.Scale,
        startPos.X.Offset + delta.X,
        startPos.Y.Scale,
        startPos.Y.Offset + delta.Y
    )

end)

--==================================================
-- OBJECT STORAGE
--==================================================

local Objects = {}

--==================================================
-- FIND CATEGORY
--==================================================

local function FindCategory(object)

    local name = string.lower(object.Name)

    for _, category in ipairs(Categories) do

        for _, word in ipairs(category.words) do

            if string.find(name, string.lower(word), 1, true) then
                return category
            end

        end

    end

    return nil
end

--==================================================
-- GET TARGET PART
--==================================================

local function GetTarget(object)

    if object:IsA("BasePart") then
        return object
    end

    if object:IsA("Model") then

        local primary = object.PrimaryPart

        if primary then
            return primary
        end

        local part = object:FindFirstChildWhichIsA(
            "BasePart",
            true
        )

        return part
    end

    return nil
end

--==================================================
-- CREATE BOX
--==================================================

local function CreateBox(object, category)

    if Objects[object] then
        return
    end

    local target = GetTarget(object)

    if not target then
        return
    end

    local Box = Instance.new("Frame")

    Box.Name = "FinderBox"
    Box.BackgroundTransparency = 1
    Box.BorderSizePixel = 0
    Box.Visible = false
    Box.Parent = ScreenGui

    local BoxStroke = Instance.new("UIStroke")

    BoxStroke.Thickness = 2
    BoxStroke.Color = category.color
    BoxStroke.Transparency = 0
    BoxStroke.Parent = Box

    Objects[object] = {
        object = object,
        target = target,
        box = Box,
        category = category
    }

end

--==================================================
-- SCAN
--==================================================

local function Scan()

    for _, object in ipairs(Workspace:GetDescendants()) do

        if not Objects[object] then

            local category = FindCategory(object)

            if category then
                CreateBox(object, category)
            end

        end

    end

end

Scan()

--==================================================
-- NEW OBJECT DETECTION
--==================================================

Workspace.DescendantAdded:Connect(function(object)

    task.wait(0.05)

    if Objects[object] then
        return
    end

    local category = FindCategory(object)

    if category then
        CreateBox(object, category)
    end

end)

--==================================================
-- GET MODEL CORNERS
--==================================================

local function GetCorners(part)

    local cf = part.CFrame
    local size = part.Size

    local x = size.X / 2
    local y = size.Y / 2
    local z = size.Z / 2

    return {

        cf * Vector3.new(-x, -y, -z),
        cf * Vector3.new(-x, -y,  z),
        cf * Vector3.new(-x,  y, -z),
        cf * Vector3.new(-x,  y,  z),

        cf * Vector3.new( x, -y, -z),
        cf * Vector3.new( x, -y,  z),
        cf * Vector3.new( x,  y, -z),
        cf * Vector3.new( x,  y,  z)

    }

end

--==================================================
-- CALCULATE SCREEN BOX
--==================================================

local function GetScreenBounds(part)

    local corners = GetCorners(part)

    local minX = math.huge
    local minY = math.huge
    local maxX = -math.huge
    local maxY = -math.huge

    local visible = false

    for _, worldPos in ipairs(corners) do

        local screenPos, onScreen =
            Camera:WorldToViewportPoint(worldPos)

        if screenPos.Z > 0 then

            visible = true

            minX = math.min(minX, screenPos.X)
            minY = math.min(minY, screenPos.Y)

            maxX = math.max(maxX, screenPos.X)
            maxY = math.max(maxY, screenPos.Y)

        end

    end

    if not visible then
        return nil
    end

    return minX, minY, maxX, maxY

end

--==================================================
-- REALTIME UPDATE
--==================================================

RunService.RenderStepped:Connect(function()

    for object, data in pairs(Objects) do

        if not object
            or not object.Parent
            or not data.target
            or not data.target.Parent then

            if data.box then
                data.box:Destroy()
            end

            Objects[object] = nil

            continue
        end

        -- อัปเดต Target เผื่อ Model เปลี่ยน Part
        if object:IsA("Model") then

            local newTarget = GetTarget(object)

            if newTarget then
                data.target = newTarget
            end

        end

        local bounds = GetScreenBounds(data.target)

        if bounds then

            local minX, minY, maxX, maxY = bounds

            local width = maxX - minX
            local height = maxY - minY

            -- กันกรอบเล็ก/ใหญ่ผิดปกติ
            width = math.clamp(width, 8, 1000)
            height = math.clamp(height, 8, 1000)

            data.box.Position = UDim2.fromOffset(
                minX,
                minY
            )

            data.box.Size = UDim2.fromOffset(
                width,
                height
            )

            data.box.Visible = true

        else

            data.box.Visible = false

        end

    end

end)

--==================================================
-- PERIODIC RESCAN
--==================================================

task.spawn(function()

    while ScreenGui.Parent do

        task.wait(1)

        Scan()

    end

end)
