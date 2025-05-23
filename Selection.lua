local script, _, __, isActor = ...

local cloneref = cloneref
if isActor then cloneref = function(...) return ... end end

local Gui = script.Parent

local HttpService = cloneref(game:GetService('HttpService'));
local ReplicatedStorage = cloneref(game:GetService('ReplicatedStorage'));

local IntroFrame = Gui:WaitForChild("IntroFrame")

local TopMenu = Gui:WaitForChild("TopMenu")
local OpenToggleButton = Gui:WaitForChild("Toggle")
local CloseToggleButton = TopMenu:WaitForChild("Toggle")
local OpenScriptEditorButton = TopMenu:WaitForChild("OpenScriptEditor")

local ScriptEditor = Gui:WaitForChild("ScriptEditor")

local SlideOut = TopMenu:WaitForChild("SlideOut")
local SlideFrame = SlideOut:WaitForChild("SlideFrame")

local ExplorerButton = SlideFrame:WaitForChild("Explorer")
local SettingsButton = SlideFrame:WaitForChild("Settings")

local ExplorerPanel = Gui:WaitForChild("ExplorerPanel")
local PropertiesFrame = Gui:WaitForChild("PropertiesFrame")
local SaveMapWindow = Gui:WaitForChild("SaveMapWindow")

local SettingsPanel = Gui:WaitForChild("SettingsPanel")
local AboutPanel = Gui:WaitForChild("About")
local SettingsListener = SettingsPanel:WaitForChild("GetSetting")
local SettingTemplate = SettingsPanel:WaitForChild("SettingTemplate")
local SettingList = SettingsPanel:WaitForChild("SettingList")

local SaveMapSettingFrame = SaveMapWindow:WaitForChild("MapSettings")
local SaveMapName = SaveMapWindow:WaitForChild("FileName")
local SaveMapButton = SaveMapWindow:WaitForChild("Save")

local SaveMapSettings = {
	SaveScripts = true,
}

--[[
local ClickSelectOption = SettingsPanel:WaitForChild("ClickSelect"):WaitForChild("Change")
local SelectionBoxOption = SettingsPanel:WaitForChild("SelectionBox"):WaitForChild("Change")
local ClearPropsOption = SettingsPanel:WaitForChild("ClearProperties"):WaitForChild("Change")
local SelectUngroupedOption = SettingsPanel:WaitForChild("SelectUngrouped"):WaitForChild("Change")
--]]

local TotallyNotSelectionChanged = ExplorerPanel:WaitForChild("TotallyNotSelectionChanged")
local TotallyNotGetSelection = ExplorerPanel:WaitForChild("TotallyNotGetSelection")
local TotallyNotSetSelection = ExplorerPanel:WaitForChild("TotallyNotSetSelection")

local Player = cloneref(game:GetService("Players").LocalPlayer)
local Mouse = Player:GetMouse()

local CurrentWindow = "Nothing c:"
local Windows = {
	Explorer = {
		ExplorerPanel,
		PropertiesFrame
	},
	Settings = {SettingsPanel},
	SaveMap = {SaveMapWindow},
	About = {AboutPanel},
}

local deb = false

function switchWindows(wName,over)
	if (CurrentWindow == wName and not over) or deb then return end

	deb = true
	local count = 0

	for i,v in pairs(Windows) do
		count = 0
		if i ~= wName then
			for _,c in pairs(v) do c:TweenPosition(UDim2.new(1, 30, count * 0.5, (count * 36) + (30-(count*30))), "Out", "Quad", 0.5, true) count = count + 1 end
		end
	end

	count = 0

	if Windows[wName] then
		for _,c in pairs(Windows[wName]) do c:TweenPosition(UDim2.new(1, -300, count * 0.5, (count * 36) + (30-(count*30))), "Out", "Quad", 0.5, true) count = count + 1 end
	end

	if wName ~= "Nothing c:" then
		CurrentWindow = wName
		for i,v in pairs(SlideFrame:GetChildren()) do
			v.BackgroundTransparency = 1
			v.Frame.BackgroundTransparency = 1
		end
		if SlideFrame:FindFirstChild(wName) then
			SlideFrame[wName].BackgroundTransparency = 1

			for i = 1, 10 do
				task.wait(.01)
				SlideFrame[wName].Frame.BackgroundTransparency = 1-(0.4*(i/10))
			end
		end
	end

	deb = false
end

function toggleDex(on)
	if on then
		TopMenu:TweenPosition(UDim2.new(1, -300, 0, 0), "Out", "Quad", 0.5, true)
		OpenToggleButton:TweenPosition(UDim2.new(1,0,0,0), "Out", "Quad", 0.5, true)
		switchWindows(CurrentWindow,true)
	else
		TopMenu:TweenPosition(UDim2.new(1, 30, 0, 0), "Out", "Quad", 0.5, true)
		OpenToggleButton:TweenPosition(UDim2.new(1,-40,0,0), "Out", "Quad", 0.5, true)
		switchWindows("Nothing c:")
	end
end

local Settings = {
	ClickSelect = false,
	SelBox = false,
	ClearProps = false,
	SelectUngrouped = true,
	SaveInstanceScripts = true
}

local foldername = "TSDex"

if not isfolder(foldername) then
	makefolder(foldername)
end

pcall(function()
	local content = readfile(foldername .. "/dex_settings.json");
	if content ~= nil and content ~= '' then
		local Saved = HttpService:JSONDecode(content);
		for i, v in pairs(Saved) do
			if Settings[i] ~= nil then
				Settings[i] = v;
			end
		end
	end
end)

function SaveSettings()
	local JSON = HttpService:JSONEncode(Settings);
	writefile(foldername .. "/dex_settings.json", JSON);
end

function ReturnSetting(set)
	if set == 'ClearProps' then
		return Settings.ClearProps
	elseif set == 'SelectUngrouped' then
		return Settings.SelectUngrouped
	end
end

OpenToggleButton.MouseButton1Up:connect(function()
	toggleDex(true)
end)

OpenScriptEditorButton.MouseButton1Up:connect(function()
	if OpenScriptEditorButton.Active then
		ScriptEditor.Visible = true
	end
end)

CloseToggleButton.MouseButton1Up:connect(function()
	if CloseToggleButton.Active then
		toggleDex(false)
	end
end)

--[[
OpenToggleButton.MouseButton1Up:connect(function()
	TopMenu:TweenPosition(UDim2.new(1, -330, 0, 0), "Out", "Quad", 0.5, true)
	
	if CurrentWindow == "Explorer" then
		ExplorerPanel:TweenPosition(UDim2.new(1, -300, 0, 0), "Out", "Quad", 0.5, true)
		PropertiesFrame:TweenPosition(UDim2.new(1, -300, 0.5, 36), "Out", "Quad", 0.5, true)
	else
		SettingsPanel:TweenPosition(UDim2.new(1, -300, 0, 0), "Out", "Quad", 0.5, true)
	end
	
	OpenToggleButton:TweenPosition(UDim2.new(1,0,0,0), "Out", "Quad", 0.5, true)
end)

CloseToggleButton.MouseButton1Up:connect(function()
	TopMenu:TweenPosition(UDim2.new(1, 0, 0, 0), "Out", "Quad", 0.5, true)
	
	ExplorerPanel:TweenPosition(UDim2.new(1, 30, 0, 0), "Out", "Quad", 0.5, true)
	PropertiesFrame:TweenPosition(UDim2.new(1, 30, 0.5, 36), "Out", "Quad", 0.5, true)
	SettingsPanel:TweenPosition(UDim2.new(1, 30, 0, 0), "Out", "Quad", 0.5, true)
	
	OpenToggleButton:TweenPosition(UDim2.new(1,-30,0,0), "Out", "Quad", 0.5, true)
end)
--]]

--[[
ExplorerButton.MouseButton1Up:connect(function()
	switchWindows("Explorer")
end)

SettingsButton.MouseButton1Up:connect(function()
	switchWindows("Settings")
end)
--]]

local targetImage = "rbxasset://textures/TagEditor/famfamfam.png"

if getcustomasset then
	if not isfile("TSDex/famfamfam.png") then
		writefile("TSDex/famfamfam.png", game:HttpGet("https://raw.githubusercontent.com/FaithfulAC/TSD-script-storage/refs/heads/main/DexAssets/famfamfam.png"))
	end
	targetImage = getcustomasset("TSDex/famfamfam.png")
end

-- manually set the Icon-named imagelabels' image to targetImage
for _, icon in pairs(TopMenu:GetDescendants()) do
	if icon:IsA("ImageLabel") and icon.Name == "Icon" then
		icon.Image = targetImage
	end
end

for i,v in pairs(SlideFrame:GetChildren()) do
	v.MouseButton1Click:connect(function()
		switchWindows(v.Name)
	end)

	-- v.MouseEnter:connect(function()v.BackgroundTransparency = 0.5 end)
	-- v.MouseLeave:connect(function()if CurrentWindow~=v.Name then v.BackgroundTransparency = 1 end end)
end

--[[
ExplorerButton.MouseButton1Up:connect(function()
	if CurrentWindow ~= "Explorer" then
		CurrentWindow = "Explorer"
		
		ExplorerPanel:TweenPosition(UDim2.new(1, -300, 0, 0), "Out", "Quad", 0.5, true)
		PropertiesFrame:TweenPosition(UDim2.new(1, -300, 0.5, 36), "Out", "Quad", 0.5, true)
		SettingsPanel:TweenPosition(UDim2.new(1, 0, 0, 0), "Out", "Quad", 0.5, true)
	end
end)

SettingsButton.MouseButton1Up:connect(function()
	if CurrentWindow ~= "Settings" then
		CurrentWindow = "Settings"
		
		ExplorerPanel:TweenPosition(UDim2.new(1, 0, 0, 0), "Out", "Quad", 0.5, true)
		PropertiesFrame:TweenPosition(UDim2.new(1, 0, 0.5, 36), "Out", "Quad", 0.5, true)
		SettingsPanel:TweenPosition(UDim2.new(1, -300, 0, 0), "Out", "Quad", 0.5, true)
	end
end)
--]]

function createSetting(name,interName,defaultOn)
	local newSetting = SettingTemplate:Clone()
	newSetting.Position = UDim2.new(0,0,0,#SettingList:GetChildren() * 60)
	newSetting.SName.Text = name

	local function toggle(on)
		if on then
			newSetting.Change.Bar:TweenPosition(UDim2.new(0,30,0,-2),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.25,true)
			newSetting.Change.OnBar:TweenSize(UDim2.new(0,34,0,15),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.25,true)
			newSetting.Status.Text = "On"
			Settings[interName] = true
		else
			newSetting.Change.Bar:TweenPosition(UDim2.new(0,-2,0,-2),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.25,true)
			newSetting.Change.OnBar:TweenSize(UDim2.new(0,0,0,15),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.25,true)
			newSetting.Status.Text = "Off"
			Settings[interName] = false
		end
	end	

	newSetting.Change.MouseButton1Click:connect(function()
		toggle(not Settings[interName])
		task.wait(1/12);
		pcall(SaveSettings);
	end)

	newSetting.Visible = true
	newSetting.Parent = SettingList

	if defaultOn then
		toggle(true)
	end
end

createSetting("Click part to select","ClickSelect",false)
createSetting("Selection Box","SelBox",false)
createSetting("Clear property value on focus","ClearProps",false)
createSetting("Select ungrouped models","SelectUngrouped",true)
createSetting("SaveInstance decompiles scripts","SaveInstanceScripts",true)

--[[
ClickSelectOption.MouseButton1Up:connect(function()
	if Settings.ClickSelect then
		Settings.ClickSelect = false
		ClickSelectOption.Text = "OFF"
	else
		Settings.ClickSelect = true
		ClickSelectOption.Text = "ON"
	end
end)

SelectionBoxOption.MouseButton1Up:connect(function()
	if Settings.SelBox then
		Settings.SelBox = false
		SelectionBox.Adornee = nil
		SelectionBoxOption.Text = "OFF"
	else
		Settings.SelBox = true
		SelectionBoxOption.Text = "ON"
	end
end)

ClearPropsOption.MouseButton1Up:connect(function()
	if Settings.ClearProps then
		Settings.ClearProps = false
		ClearPropsOption.Text = "OFF"
	else
		Settings.ClearProps = true
		ClearPropsOption.Text = "ON"
	end
end)

SelectUngroupedOption.MouseButton1Up:connect(function()
	if Settings.SelectUngrouped then
		Settings.SelectUngrouped = false
		SelectUngroupedOption.Text = "OFF"
	else
		Settings.SelectUngrouped = true
		SelectUngroupedOption.Text = "ON"
	end
end)
--]]

local function getSelection()
	local t = TotallyNotGetSelection:Invoke()
	if t and #t > 0 then
		return t[1]
	else
		return nil
	end
end

local SelectionBoxIns = Instance.new("SelectionBox")
SelectionBoxIns.Parent = Dex or script.Parent
SelectionBoxIns.Color3 = Color3.fromRGB(0, 100, 200)
SelectionBoxIns.SurfaceColor3 = Color3.fromRGB(0, 100, 200)

Mouse.Button1Down:connect(function()
	if CurrentWindow == "Explorer" and Settings.ClickSelect then
		local target = Mouse.Target
		if target then
			if Settings.SelBox then
				SelectionBoxIns.Adornee = target
			end
			TotallyNotSetSelection:Invoke({target})
		end
	end
end)

TotallyNotSelectionChanged.Event:connect(function()
	if getSelection() ~= SelectionBoxIns.Adornee then
		SelectionBoxIns.Adornee = nil
	end
end)

SettingsListener.OnInvoke = ReturnSetting

-- Map Copier

function createMapSetting(obj,interName,defaultOn)
	local function toggle(on)
		if on then
			obj.Change.Bar:TweenPosition(UDim2.new(0,30,0,-2),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.25,true)
			obj.Change.OnBar:TweenSize(UDim2.new(0,34,0,15),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.25,true)
			obj.Status.Text = "On"
			SaveMapSettings[interName] = true
		else
			obj.Change.Bar:TweenPosition(UDim2.new(0,-2,0,-2),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.25,true)
			obj.Change.OnBar:TweenSize(UDim2.new(0,0,0,15),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.25,true)
			obj.Status.Text = "Off"
			SaveMapSettings[interName] = false
		end
	end	

	obj.Change.MouseButton1Click:connect(function()
		toggle(not SaveMapSettings[interName])
	end)

	obj.Visible = true
	obj.Parent = SaveMapSettingFrame

	if defaultOn then
		toggle(true)
	end
end

createMapSetting(SaveMapSettingFrame.Scripts,"SaveScripts",true)
-- createMapSetting(SaveMapSettingFrame.Terrain,"SaveTerrain",true)
-- createMapSetting(SaveMapSettingFrame.Lighting,"LightingProperties",true)
-- createMapSetting(SaveMapSettingFrame.CameraInstances,"CameraInstances",true)

SaveMapName.Text = tostring(game.PlaceId).."MapCopy"

SaveMapButton.MouseButton1Click:connect(function()
	local copyWhat = {}

	-- local copyGroup = Instance.new("Model", ReplicatedStorage)

	local copyScripts = SaveMapSettings.SaveScripts

	-- local copyTerrain = SaveMapSettings.SaveTerrain

	-- local lightingProperties = SaveMapSettings.LightingProperties

	-- local cameraInstances = SaveMapSettings.CameraInstances

	-- local PlaceName = game:GetService'MarketplaceService':GetProductInfo(game.PlaceId).Name;
	-- PlaceName = PlaceName:gsub('%p', '');

	if copyScripts then
		saveinstance{noscripts = false, mode = "optimized"}
	else
		saveinstance{noscripts = true, mode = "optimized"}
	end
end)

-- End Copier

task.wait()

IntroFrame:TweenPosition(UDim2.new(1,-301,0,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.4,true)

switchWindows("Explorer")

task.wait(.75)

TopMenu.Visible = true

for i = 0, 1, 0.1 do
	IntroFrame.BackgroundTransparency = i
	IntroFrame.Title.TextTransparency = i
	IntroFrame.Version.TextTransparency = i
	IntroFrame.Creator.TextTransparency = i
	task.wait()
end

IntroFrame.Visible = false

-- so it doesnt run a recursive findfirstchild 10 times
local tempimage = OpenScriptEditorButton:FindFirstChild("Icon", true)

for i = 1, 0, -0.1 do
	tempimage.ImageTransparency = i
	SlideOut.BackgroundTransparency = i
	task.wait()
end

SlideFrame:TweenPosition(UDim2.new(0,0,0,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.5,true)
OpenScriptEditorButton:TweenPosition(UDim2.new(0,156,0,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.5,true)

task.wait(.5)

CloseToggleButton.Active = true
CloseToggleButton.AutoButtonColor = false

OpenScriptEditorButton.Active = true
OpenScriptEditorButton.AutoButtonColor = false
