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
			tweenService:Create(instance, TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.In), goal):Play()
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
		user.PlayerGui
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
		['inhaler/assets/inhaler.png'] = game:HttpGet('https://github.com/zulphdeveloper/Inhaler/blob/main/inhaler.png?raw=true', true),
		['inhaler/assets/bgsplash.png'] = game:HttpGet('https://github.com/zulphdeveloper/Inhaler/blob/main/bgsplash.png?raw=true', true),
		['inhaler/assets/inhalerversion.png'] = game:HttpGet('https://github.com/zulphdeveloper/Inhaler/blob/main/inhalerversion.png?raw=true', true),
		['inhaler/github/readme.md'] = game:HttpGet('https://github.com/zulphdeveloper/Inhaler/raw/refs/heads/main/readme.md', true),
		['inhaler/MainScript.lua'] = game:HttpGet('https://github.com/zulphdeveloper/Inhaler/raw/refs/heads/main/MainScript.lua', true),
		['inhaler/github/inhalerversion'] = game:HttpGet('https://github.com/zulphdeveloper/Inhaler/raw/refs/heads/main/inhalerversion', true)
	}
}

local function getasset(asset)
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

local loadInstaller = function()
	if isfolder('inhaler') then
		for i, folder in downloadTodos['folders'] do
			if isfolder(folder) then
				for file, i in downloadTodos['files'] do
					if isfile(file) then
						return
					end
				end
			end
		end
	end
	local Installer = Instance.new("ScreenGui")
	local InstallerFrame = Instance.new("Frame")
	local Corner = Instance.new("UICorner")
	local BackgroundSplash = Instance.new("ImageLabel")
	local BackgroundSplash2 = Instance.new("ImageLabel")
	local Stroke = Instance.new("UIStroke")
	local Inhalerlogo = Instance.new("ImageLabel")
	local PercentBar = Instance.new("Frame")
	local BarCorner = Instance.new("UICorner")
	local BarStroke = Instance.new("UIStroke")
	local PercentGreen = Instance.new("Frame")
	local GreenCorner = Instance.new("UICorner")

	local InstallationBlur = Instance.new('BlurEffect')

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
	BackgroundSplash.Image = getasset('inhaler/assets/bgsplash.png')
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
	Inhalerlogo.Image = getasset('inhaler/assets/inhaler.png')

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
	progressing = 30

	function makeProgress(amount)
		if amount ~= '' then
			inhalerTween(PercentGreen, slide, {Size = UDim2.new(0, PercentGreen.Size.X.Offset + tonumber(amount), 0, 10)})
		end
	end

	function finish()
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
