local cloneref = cloneref or function(object) -- reference cloner for services
	return object
end

local shared = (shared or shared) or (getgenv and getgenv()) or _G or function(variable)
	return variable
end

local downloadAsset = function(path, url)
	if path ~= '' and url ~= '' then
		local downloadSuccess, results = pcall(function()
			return game:HttpGet(url, true)
		end)

		if downloadSuccess then
			writefile(path, results)
		elseif not downloadSuccess then
			warn('Failed to download asset: '..path..' ('..url..')')
		end
	end
end

local workspace = cloneref(game:GetService('Workspace'))
local players = cloneref(game:GetService('Players'))
local coreGui = cloneref(game:GetService('CoreGui'))
local debris = cloneref(game:GetService('Debris'))
local tweenService = cloneref(game:GetService('TweenService'))
local lighting = cloneref(game:GetService('Lighting'))
local userInput = cloneref(game:GetService("UserInputService"))
local soundService = cloneref(game:GetService('SoundService'))

local user = players.LocalPlayer

local userinformation = {
	executor = ({identifyexecutor()})[1],
	age = user.AccountAge,
	name = user.Name,
	display = user.DisplayName,
	alive = user.Character.Humanoid.Health > 0 and true or false,
	state = user.Character.Humanoid:GetState(),
	health = user.Character.Humanoid.Health
}

local inhalerTween = function(instance, duration, goal)
	if instance and duration and goal then
		local tweenSuccess, tweenResults = pcall(function()
			tweenService:Create(instance, TweenInfo.new(duration, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut), goal):Play()
		end)

		if not tweenSuccess and tweenResults ~= '' then
			warn('Failed to use tween: '..instance.Name..' ('..tostring(tweenResults)..')')
		end
	end
end

local inhaler

local inhalerCleanup = function()
	guis = {
		workspace,
		coreGui,
		lighting,
		user.PlayerGui,
        soundService
	}

	for i, gui in guis do
		for i, instance in ipairs(gui:GetDescendants()) do
			if instance.Name:lower():find('inhaler') then
				instance:Destroy()
			end
		end
	end
end

local createfile = function(path, contents)
	if not isfile(tostring(path)) and path ~= '' and contents ~= '' then
		print(tostring(path))
		writefile(tostring(path), (table.find({'.lua', '.luau'}, tostring(path)) and '-- This file was imported either from a older version of inhaler. Check if this file is up to date!: https://github.com/zulphdeveloper/Inhaler\n' .. tostring(contents)) or tostring(contents))
	end
end

local createfolder = function(path)
	if not isfolder(tostring(path)) and path ~= '' then
		print(tostring(path))
		makefolder(tostring(path))
	end
end
local downloadTodos = {
	['folders'] = {
		'inhaler/assets',
		'inhaler/assets/images',
		'inhaler/assets/sounds',
		'inhaler/github'
	},
	['files'] = {
		['inhaler/assets/images/inhaler.png'] = game:HttpGet('https://github.com/zulphdeveloper/Inhaler/blob/main/inhaler.png?raw=true', true),
		['inhaler/assets/images/bgsplash.png'] = game:HttpGet('https://github.com/zulphdeveloper/Inhaler/blob/main/bgsplash.png?raw=true', true),
		['inhaler/assets/images/inhalerversion.png'] = game:HttpGet('https://github.com/zulphdeveloper/Inhaler/blob/main/inhalerversion.png?raw=true', true),
		['inhaler/github/readme.md'] = game:HttpGet('https://github.com/zulphdeveloper/Inhaler/raw/refs/heads/main/readme.md', true),
		['inhaler/MainScript.lua'] = game:HttpGet('https://github.com/zulphdeveloper/Inhaler/raw/refs/heads/main/MainScript.lua', true),
		['inhaler/github/inhalerversion'] = game:HttpGet('https://github.com/zulphdeveloper/Inhaler/raw/refs/heads/main/inhalerversion', true),
		['inhaler/assets/images/notificationicon.png'] = game:HttpGet('https://github.com/zulphdeveloper/Inhaler/blob/main/notificationicon.png?raw=true', true),
        ['inhaler/assets/sounds/notificationsound.mp3'] = game:HttpGet('https://github.com/zulphdeveloper/Inhaler/raw/refs/heads/main/notificationsound.mp3', true)
	}
}

local generateID = function()
    len = math.random(10,20)
    str = tostring(math.random(500000000000,100000000))

    local h = 2166136261

    for i = 1, #str do
        h = bit32.band(bit32.bxor(h, string.byte(str, i)) * 16777619, 0xFFFFFFFF)
    end

    local res = ""

    for i = 1, len do
        h = bit32.band(h * 1103515245 + 12345, 0xFFFFFFFF)
        local b = bit32.band(bit32.rshift(h, (i % 4) * 8), 0xFF)
        res = res .. string.format("%02x", b)
    end

    return string.sub(res, 1, len)
end

local getasset = function(asset)
    if not asset or asset == "" then
        return nil
    end

    local success, result = pcall(function()
        return getcustomasset(asset)
    end)

    if success and result then
        return result
    end

    local contents = downloadTodos and downloadTodos.files and downloadTodos.files[asset]

    if contents then
        pcall(function()
            local parent = tostring(asset):match("^(.+)/[^/]+$")

            if parent and parent ~= "" and not isfolder(parent) then
                local parts = {}

                for part in parent:gmatch("[^/]+") do 
					table.insert(parts, part) 
				end

                local path = ""

                for index, part in ipairs(parts) do
                    path = (index == 1) and part or (path .. "/" .. part)
                    if not isfolder(path) then
                        makefolder(path)
                    end
                end
            end

            writefile(asset, tostring(contents))
        end)

        local ok2, result2 = pcall(function()
            return getcustomasset(asset)
        end)

        if ok2 and result2 then
            return result2
        end
    end

    return asset
end


inhalerCleanup()

createfolder('inhaler')

local Inhaler = Instance.new('Folder')
Inhaler.Name = 'Inhaler'
Inhaler.Archivable = false
Inhaler.Parent = coreGui

local InhalerGui = Instance.new('ScreenGui')
InhalerGui.ResetOnSpawn = false
InhalerGui.ClipToDeviceSafeArea = false
InhalerGui.Enabled = true
InhalerGui.IgnoreGuiInset = true
InhalerGui.Parent = Inhaler

local NotificationGui = Instance.new('ScreenGui')
local activenotifications = {}

NotificationGui.ResetOnSpawn = false
NotificationGui.ClipToDeviceSafeArea = false
NotificationGui.Enabled = true
NotificationGui.IgnoreGuiInset = true
NotificationGui.Parent = InhalerGui

local TextService = game:GetService("TextService")

local notif = function(title1, description1, duration)
	if title1 and title1 ~= '' and description1 and description1 ~= '' and duration and duration ~= '' then
		local id = generateID()
		table.insert(activenotifications, id)

		local notification = Instance.new("Frame")
		local splash = Instance.new("ImageLabel")
		local corner = Instance.new("UICorner")
		local stroke = Instance.new("UIStroke")
		local title = Instance.new("TextLabel")
		local description = Instance.new("TextLabel")
		local Icon = Instance.new("ImageLabel")
		local ApectRatio = Instance.new("UIAspectRatioConstraint")
		local UIScaling = Instance.new("UIScale")

		notification.Name = "notification_"..id
		notification.Parent = NotificationGui
		notification.AnchorPoint = Vector2.new(1, 1)
		notification.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		notification.BackgroundTransparency = 0.5
		notification.BorderSizePixel = 0
		notification.ClipsDescendants = true

		local spacing = 90
		local baseY = 0.95
		local index = #activenotifications
		local offsetY = -(spacing * (index - 1)) / workspace.CurrentCamera.ViewportSize.Y
		notification.Position = UDim2.new(1, 330, baseY + offsetY, 0)

		splash.Name = "splash"
		splash.Parent = notification
		splash.BackgroundTransparency = 1
		splash.Position = UDim2.new(-0.853, 0, -2.44, 0)
		splash.Size = UDim2.new(0, 686, 0, 622)
		splash.Image = "rbxassetid://11427370337"
		splash.ImageTransparency = 0.97

		corner.Parent = notification

		stroke.Parent = notification
		stroke.Color = Color3.fromRGB(255, 255, 255)
		stroke.Transparency = 0.6
		stroke.Thickness = 1.3

		title.Name = "title"
		title.Parent = notification
		title.BackgroundTransparency = 1
		title.Position = UDim2.new(0.07, 0, 0.05, 0)
		title.Size = UDim2.new(0, 230, 0, 30)
		title.Font = Enum.Font.Ubuntu
		title.Text = title1
		title.TextColor3 = Color3.fromRGB(255, 255, 255)
		title.TextSize = 30
		title.TextWrapped = true
		title.TextXAlignment = Enum.TextXAlignment.Right

		description.Name = "description"
		description.Parent = notification
		description.BackgroundTransparency = 1
		description.Position = UDim2.new(0.07, 0, 0.4, 0)
		description.Size = UDim2.new(0, 230, 0, 30)
		description.Font = Enum.Font.Ubuntu
		description.Text = description1
		description.TextColor3 = Color3.fromRGB(255, 255, 255)
		description.TextSize = 20
		description.TextTransparency = 0.4
		description.TextWrapped = true
		description.TextXAlignment = Enum.TextXAlignment.Right

		Icon.Name = "Icon"
		Icon.Parent = notification
		Icon.BackgroundTransparency = 1
		Icon.Position = UDim2.new(0.83, 0, 0.06, 0)
		Icon.Size = UDim2.new(0, 35, 0, 35)
		Icon.Image = "rbxassetid://17328930401"
		Icon.ImageColor3 = Color3.fromRGB(218, 218, 218)

		ApectRatio.Parent = notification
		ApectRatio.AspectRatio = 4.4

		UIScaling.Parent = notification
		UIScaling.Scale = 0.3

		local titleSize = TextService:GetTextSize(title1, title.TextSize, title.Font, Vector2.new(230, math.huge))
		local descriptionSize = TextService:GetTextSize(description1, description.TextSize, description.Font, Vector2.new(230, math.huge))
		local finalHeight = math.max(titleSize.Y + descriptionSize.Y + 20, 80)

		notification.Size = UDim2.new(0, 310, 0, finalHeight)

		description.Position = UDim2.new(0.07, 0, titleSize.Y / finalHeight, 0)

		inhalerTween(notification, 0.3, {Position = UDim2.new(1, -10, baseY + offsetY, 0)})
		inhalerTween(UIScaling, 0.3, {Scale = 1})

		task.delay(duration, function()
			inhalerTween(notification, 0.3, {Position = UDim2.new(1, 330, baseY + offsetY, 0)})
			inhalerTween(UIScaling, 0.3, {Scale = 0.8})

			task.delay(0.35, function()
				notification:Destroy()

				for i, v in ipairs(activenotifications) do
					if v == id then
						table.remove(activenotifications, i)
						break
					end
				end

				for i, notifId in ipairs(activenotifications) do
					local notifFrame = NotificationGui:FindFirstChild("notification_"..notifId)
					if notifFrame then
						local newOffsetY = -(spacing * (i - 1)) / workspace.CurrentCamera.ViewportSize.Y
						local currentX = notifFrame.Position.X
						inhalerTween(notifFrame, 0.3, {Position = UDim2.new(currentX.Scale, currentX.Offset, baseY + newOffsetY, 0)})
					end
				end
			end)
		end)
	end
end

local loadInstaller = function()
	if isfolder('inhaler') then
		filesInstalled = true
	
		for _, folder in ipairs(downloadTodos['folders']) do
			if not isfolder(folder) then
				filesInstalled = false
				break
			end
		end
	
		if filesInstalled then
			for _, file in ipairs(downloadTodos['files']) do
				if not isfile(file) then
					filesInstalled = false
					break
				end
			end
		end
	
		if filesInstalled then
			return
		end
	end
	Installer = Instance.new("ScreenGui")
	InstallerFrame = Instance.new("Frame")
	Corner = Instance.new("UICorner")
	BackgroundSplash = Instance.new("ImageLabel")
	BackgroundSplash2 = Instance.new("ImageLabel")
	Stroke = Instance.new("UIStroke")
	Inhalerlogo = Instance.new("ImageLabel")
	PercentBar = Instance.new("Frame")
	BarCorner = Instance.new("UICorner")
	BarStroke = Instance.new("UIStroke")
	PercentGreen = Instance.new("Frame")
	GreenCorner = Instance.new("UICorner")

	InstallationBlur = Instance.new('BlurEffect')

	InstallationBlur.Parent = lighting
	InstallationBlur.Name = 'installblur:inhaler'
	InstallationBlur.Size = 10

	Installer.Name = "Installer"
	Installer.IgnoreGuiInset = false
	Installer.ClipToDeviceSafeArea  = true
	Installer.Parent = InhalerGui
	Installer.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	InstallerFrame.Name = "InstallerFrame"
	InstallerFrame.Parent = Installer
	InstallerFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	InstallerFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
	InstallerFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	InstallerFrame.BorderSizePixel = 0
	InstallerFrame.ClipsDescendants = true
	InstallerFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	InstallerFrame.Size = UDim2.new(0, 400, 0, 250)

    uidrag, startdrag, startposition = false

    InstallerFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            uidrag = true
            startdrag = input.Position
            startposition = InstallerFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    uidrag = false
                end
            end)
        end
    end)

    InstallerFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            userInput.InputChanged:Connect(function(moveInput)
                if moveInput == input and uidrag then
                    local delta = moveInput.Position - startdrag
                    InstallerFrame.Position = UDim2.new(startposition.X.Scale, startposition.X.Offset + delta.X, startposition.Y.Scale, startposition.Y.Offset + delta.Y)
                end
            end)
        end
    end)

	Corner.CornerRadius = UDim.new(0.0299999993, 0)
	Corner.Name = "Corner"
	Corner.Parent = InstallerFrame

	BackgroundSplash.Name = "BackgroundSplash"
	BackgroundSplash.Parent = InstallerFrame
	BackgroundSplash.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	BackgroundSplash.BackgroundTransparency = 1.000
	BackgroundSplash.BorderColor3 = Color3.fromRGB(0, 0, 0)
	BackgroundSplash.BorderSizePixel = 0
	BackgroundSplash.Position = UDim2.new(-0.589999974, 0, -1.648, 0)
	BackgroundSplash.Size = UDim2.new(0, 700, 0, 800)
	BackgroundSplash.Image = getasset('inhaler/assets/images/bgsplash.png')
	BackgroundSplash.ImageTransparency = 0.985

	Stroke.Name = "Stroke"
	Stroke.Parent = InstallerFrame
	Stroke.Color = Color3.fromRGB(255, 255, 255)
	Stroke.Transparency = 0.600
	Stroke.Thickness = 1.200

	Inhalerlogo.Name = "Inhaler"
	Inhalerlogo.Parent = InstallerFrame
	Inhalerlogo.AnchorPoint = Vector2.new(0.5, 0.5)
	Inhalerlogo.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Inhalerlogo.BackgroundTransparency = 1.000
	Inhalerlogo.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Inhalerlogo.BorderSizePixel = 0
	Inhalerlogo.Position = UDim2.new(0.5, 0,0.4, 0)
	Inhalerlogo.Size = UDim2.new(0.25, 0,0.1, 0)
	Inhalerlogo.Image = getasset('inhaler/assets/images/inhaler.png')

	PercentBar.Name = "PercentBar"
	PercentBar.Parent = InstallerFrame
	PercentBar.AnchorPoint = Vector2.new(0.5, 0.5)
	PercentBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	PercentBar.BackgroundTransparency = 0.600
	PercentBar.BorderColor3 = Color3.fromRGB(0, 0, 0)
	PercentBar.BorderSizePixel = 0
	PercentBar.ClipsDescendants = true
	PercentBar.Position = UDim2.new(0.5, 0, 0.600000024, 0)
	PercentBar.Size = UDim2.new(0, 320, 0, 10)

	BarCorner.CornerRadius = UDim.new(1, 0)
	BarCorner.Name = "BarCorner"
	BarCorner.Parent = PercentBar

	BarStroke.Name = "BarStroke"
	BarStroke.Parent = PercentBar
	BarStroke.Color = Color3.fromRGB(255, 255, 255)
	BarStroke.Transparency = 0.800
	BarStroke.Thickness = 0.500

	PercentGreen.Name = "PercentGreen"
	PercentGreen.Parent = PercentBar
	PercentGreen.BackgroundColor3 = Color3.fromRGB(185, 255, 131)
	PercentGreen.BackgroundTransparency = 0.200
	PercentGreen.BorderColor3 = Color3.fromRGB(0, 0, 0)
	PercentGreen.BorderSizePixel = 0
	PercentGreen.Position = UDim2.new(2.86102306e-07, 0, 0, 0)
	PercentGreen.Size = UDim2.new(0, 0, 0, 10)

	GreenCorner.CornerRadius = UDim.new(1, 0)
	GreenCorner.Name = "GreenCorner"
	GreenCorner.Parent = PercentGreen

	slide = 0.3
	progressing = 320 / (#downloadTodos.folders + table.getn(downloadTodos.files))

	makeProgress = function(amount)
		if amount ~= '' then
			inhalerTween(PercentGreen, slide, {Size = UDim2.new(0, PercentGreen.Size.X.Offset + tonumber(amount), 0, 10)})
		end
	end

    finish = function()
		task.wait(0.1)
		inhalerTween(PercentGreen, slide, {Size = UDim2.new(0, 320, 0, 10)})
		task.wait(1)
		inhalerCleanup()
	end

	for _, folder in downloadTodos['folders'] do
		task.wait(math.random(0.03, 0.1))
		createfolder(folder)
		task.spawn(function()
			repeat
				makeProgress(progressing)
				task.wait()
			until isfolder(folder)
		end)
	end

	for file, contents in downloadTodos['files'] do
		createfile(file, contents)
		task.spawn(function()
			repeat
				makeProgress(progressing)
				task.wait()
			until isfile(file)
		end)
		task.wait(math.random(0.03, 0.1))
	end

	task.wait(0.3)

	finish()
end

loadInstaller()

notif('Inhaler Client', 'Loaded!', 2)
