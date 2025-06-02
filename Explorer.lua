local script, RbxApi, gets, isActor = ...

local cloneref = cloneref
local GetDebugId = clonefunction(game.GetDebugId)

if isActor then
	cloneref = function(...) return ... end
	GetDebugId = function(...) return ... end
end

-- initial states
local Option = {
	-- can modify object parents in the hierarchy
	Modifiable = false;
	-- can select objects
	Selectable = true;
}

local getfunctions = gets.getfunctions

-- MERELY

Option.Modifiable = true

-- END MERELY

-- general size of GUI objects, in pixels
local GUI_SIZE = 16
-- padding between items within each entry
local ENTRY_PADDING = 1
-- padding between each entry
local ENTRY_MARGIN = 1

local explorerPanel = script.Parent
local Input = cloneref(game:GetService("UserInputService"))
local HoldingCtrl = false
local HoldingShift = false

local DexOutput = Instance.new("Folder")
DexOutput.Name = "Output"
local DexOutputMain = Instance.new("ScreenGui", DexOutput)
DexOutputMain.Name = "Dex Output"

--[[

# Explorer Panel

A GUI panel that displays the game hierarchy.


## Selection Bindables

- `Function GetSelection ( )`

	Returns an array of objects representing the objects currently
	selected in the panel.

- `Function SetSelection ( Objects selection )`

	Sets the objects that are selected in the panel. `selection` is an array
	of objects.

- `Event SelectionChanged ( )`

	Fired after the selection changes.


## Option Bindables

- `Function GetOption ( string optionName )`

	If `optionName` is given, returns the value of that option. Otherwise,
	returns a table of options and their current values.

- `Function SetOption ( string optionName, bool value )`

	Sets `optionName` to `value`.

	Options:

	- Modifiable

		Whether objects can be modified by the panel.

		Note that modifying objects depends on being able to select them. If
		Selectable is false, then Actions will not be available. Reparenting
		is still possible, but only for the dragged object.

	- Selectable

		Whether objects can be selected.

		If Modifiable is false, then left-clicking will perform a drag
		selection.
]]

local ENTRY_SIZE = GUI_SIZE + ENTRY_PADDING*2
local ENTRY_BOUND = ENTRY_SIZE + ENTRY_MARGIN
local HEADER_SIZE = ENTRY_SIZE*2

local FONT = 'SourceSans'
local FONT_SIZE do
	local size = {8,9,10,11,12,14,18,24,83,48}
	local s
	local n = math.huge
	for i = 1,#size do
		if size[i] <= GUI_SIZE then
			FONT_SIZE = i - 1
		end
	end
end

-- old colors of dex (grey); below is the navy blue renditioned look
--[[local GuiColor = {
	Background      = Color3.fromRGB(43, 43, 43);
	Border          = Color3.fromRGB(20, 20, 20);
	Selected        = Color3.fromRGB(5, 102, 141);
	BorderSelected  = Color3.fromRGB(2, 128, 144);
	Text            = Color3.fromRGB(245, 245, 245);
	TextDisabled    = Color3.fromRGB(188, 188, 188);
	TextSelected    = Color3.fromRGB(255, 255, 255);
	Button          = Color3.fromRGB(33, 33, 33);
	ButtonBorder    = Color3.fromRGB(133, 133, 133);
	ButtonSelected  = Color3.fromRGB(0, 168, 150);
	Field           = Color3.fromRGB(43, 43, 43);
	FieldBorder     = Color3.fromRGB(50, 50, 50);
	TitleBackground = Color3.fromRGB(11, 11, 11);
}]]

local GuiColor = {
	Background      = Color3.fromRGB(43, 43, 60);
	Border          = Color3.fromRGB(10, 10, 30);
	Selected        = Color3.fromRGB(0, 100, 200);
	BorderSelected  = Color3.fromRGB(0, 50, 150);
	Text            = Color3.fromRGB(245, 245, 245);
	TextDisabled    = Color3.fromRGB(188, 188, 188);
	TextSelected    = Color3.fromRGB(255, 255, 255);
	Button          = Color3.fromRGB(33, 44, 66);
	ButtonBorder    = Color3.fromRGB(133, 166, 199);
	ButtonSelected  = Color3.fromRGB(0, 100, 200);
	Field           = Color3.fromRGB(43, 43, 60);
	FieldBorder     = Color3.fromRGB(50, 50, 100);
	TitleBackground = Color3.fromRGB(11, 11, 22);
}

local NODE_COLLAPSED      = getcustomasset and isfile("TSDex/arrowRight_dark.png") and getcustomasset("TSDex/arrowRight_dark.png")
	or "rbxasset://textures/ManageCollaborators/arrowRight_dark.png";

local NODE_EXPANDED       = getcustomasset and isfile("TSDex/arrowDown_dark.png") and getcustomasset("TSDex/arrowDown_dark.png")
	or "rbxasset://textures/ManageCollaborators/arrowDown_dark.png";

local--[[New]]ExplorerIndex = {
	["Accessory"] = 32,
	["AccessoryDescription"] = 0,
	["Accoutrement"] = 32,
	["Actor"] = 113,
	["AdGui"] = 145,
	["AdPortal"] = 146,
	["AdService"] = 145,
	["AdvancedDragger"] = 41,
	["AirController"] = 0,
	["AlignOrientation"] = 100,
	["AlignPosition"] = 99,
	["AngularVelocity"] = 103,
	["Animation"] = 60,
	["AnimationConstraint"] = 0,
	["AnimationController"] = 60,
	["AnimationRigData"] = 58,
	["AnimationTrack"] = 60,
	["Animator"] = 60,
	["ArcHandles"] = 56,
	["AssetService"] = 25,
	["Atmosphere"] = 28,
	["Attachment"] = 81,
	["AudioAnalyzer"] = 84,
	["AudioChorus"] = 84,
	["AudioCompressor"] = 84,
	["AudioDeviceInput"] = 84,
	["AudioDeviceOutput"] = 84,
	["AudioDistortion"] = 84,
	["AudioEcho"] = 84,
	["AudioEmitter"] = 84,
	["AudioEqualizer"] = 84,
	["AudioFader"] = 84,
	["AudioFlanger"] = 84,
	["AudioListener"] = 84,
	["AudioPitchShifter"] = 84,
	["AudioPlayer"] = 84,
	["AudioReverb"] = 84,
	["AudioSearchParams"] = 84,
	["AvatarEditorService"] = 40,
	["Backpack"] = 20,
	["BadgeService"] = 25,
	["BallSocketConstraint"] = 86,
	["Beam"] = 96,
	["BillboardGui"] = 64,
	["BinaryStringValue"] = 4,
	["BindableEvent"] = 67,
	["BindableFunction"] = 66,
	["BlockMesh"] = 8,
	["BloomEffect"] = 83,
	["BlurEffect"] = 83,
	["BodyAngularVelocity"] = 14,
	["BodyColors"] = 58,
	["BodyForce"] = 14,
	["BodyGyro"] = 14,
	["BodyPartDescription"] = 97,
	["BodyPosition"] = 14,
	["BodyThrust"] = 14,
	["BodyVelocity"] = 14,
	["Bone"] = 114,
	["BoolValue"] = 4,
	["BoxHandleAdornment"] = 111,
	["BrickColorValue"] = 4,
	["BubbleChatMessageProperties"] = 139,
	["BuoyancySensor"] = 0,
	["CFrameValue"] = 4,
	["Camera"] = 5,
	["CanvasGroup"] = 27,
	["CharacterMesh"] = 60,
	["Chat"] = 33,
	["ChatInputBarConfiguration"] = 143,
	["ChatWindowConfiguration"] = 143,
	["ChorusSoundEffect"] = 84,
	["ClickDetector"] = 41,
	["ClientReplicator"] = 16,
	["ClimbController"] = 137,
	["Clouds"] = 28,
	["CollectionService"] = 30,
	["Color3Value"] = 4,
	["ColorCorrectionEffect"] = 83,
	["CompressorSoundEffect"] = 84,
	["ConeHandleAdornment"] = 110,
	["Configuration"] = 58,
	["ContentProvider"] = 70,
	["ContextActionService"] = 41,
	["ControllerManager"] = 137,
	["ControllerPartSensor"] = 99,
	["CoreGui"] = 46,
	["CoreScript"] = 18,
	["CornerWedgePart"] = 1,
	["CurveAnimation"] = 60,
	["CustomEvent"] = 4,
	["CustomEventReceiver"] = 4,
	["CylinderHandleAdornment"] = 109,
	["CylinderMesh"] = 8,
	["CylindricalConstraint"] = 95,
	["DataStoreGetOptions"] = 58,
	["DataStoreIncrementOptions"] = 58,
	["DataStoreOptions"] = 58,
	["DataStoreSetOptions"] = 58,
	["Debris"] = 30,
	["DebuggerWatch"] = 58,
	["Decal"] = 7,
	["DepthOfFieldEffect"] = 83,
	["Dialog"] = 62,
	["DialogChoice"] = 63,
	["DistortionSoundEffect"] = 84,
	["DoubleConstrainedValue"] = 4,
	["DragDetector"] = 41,
	["Dragger"] = 41,
	["EchoSoundEffect"] = 84,
	["EditableImage"] = 49,
	["EditableMesh"] = 8,
	["EqualizerSoundEffect"] = 84,
	["EulerRotationCurve"] = 0,
	["ExperienceInviteOptions"] = 79,
	["Explosion"] = 83,
	["FaceControls"] = 129,
	["FileMesh"] = 8,
	["Fire"] = 61,
	["Flag"] = 38,
	["FlagStand"] = 39,
	["FlangeSoundEffect"] = 84,
	["FloatCurve"] = 96,
	["FloorWire"] = 125,
	["Folder"] = 77,
	["ForceField"] = 37,
	["Frame"] = 48,
	["FunctionalTest"] = 68,
	["GamePassService"] = 97,
	["GetTextBoundsParams"] = 141,
	["Glue"] = 34,
	["GroundController"] = 0,
	["GuiMain"] = 47,
	["GuiService"] = 47,
	["Handles"] = 53,
	["HapticService"] = 0,
	["Hat"] = 45,
	["HeightmapImporterService"] = 2,
	["HiddenSurfaceRemovalAsset"] = 0,
	["Highlight"] = 133,
	["HingeConstraint"] = 34,
	["Hint"] = 33,
	["Hole"] = 0,
	["HopperBin"] = 22,
	["HttpService"] = 121,
	["Humanoid"] = 9,
	["HumanoidController"] = 135,
	["HumanoidDescription"] = 104,
	["IKControl"] = 137,
	["ImageButton"] = 52,
	["ImageHandleAdornment"] = 108,
	["ImageLabel"] = 49,
	["InsertService"] = 25,
	["IntConstrainedValue"] = 4,
	["IntValue"] = 4,
	["IntersectOperation"] = 130,
	["JointInstance"] = 106,
	["JointsService"] = 106,
	["Keyframe"] = 60,
	["KeyframeMarker"] = 0,
	["KeyframeSequence"] = 60,
	["KeyframeSequenceProvider"] = 60,
	["Lighting"] = 13,
	["LineForce"] = 132,
	["LineHandleAdornment"] = 107,
	["LinearVelocity"] = 102,
	["LocalScript"] = 18,
	["LocalizationService"] = 92,
	["LocalizationTable"] = 97,
	["LogService"] = 26,
	["ManualGlue"] = 34,
	["ManualWeld"] = 34,
	["MarkerCurve"] = 96,
	["MarketplaceService"] = 46,
	["MaterialService"] = 123,
	["MaterialVariant"] = 123,
	["MemoryStoreService"] = 128,
	["MeshPart"] = 8,
	["Message"] = 33,
	["Model"] = 2,
	["ModuleScript"] = 76,
	["Motor"] = 34,
	["Motor6D"] = 34,
	["MotorFeature"] = 0,
	["NegateOperation"] = 0,
	["NetworkClient"] = 16,
	["NetworkReplicator"] = 29,
	["NetworkServer"] = 15,
	["NoCollisionConstraint"] = 0,
	["Noise"] = 84,
	["NumberPose"] = 0,
	["NumberValue"] = 4,
	["ObjectValue"] = 4,
	["OperationGraph"] = 0,
	["Pants"] = 44,
	["ParabolaAdornment"] = 0,
	["ParallelRampPart"] = 1,
	["Part"] = 1,
	["PartOperation"] = 0,
	["PartOperationAsset"] = 0,
	["PartPairLasso"] = 57,
	["ParticleEmitter"] = 33,
	["Path2D"] = 91,
	["PathfindingLink"] = 91,
	["PathfindingModifier"] = 91,
	["PathfindingService"] = 132,
	["PitchShiftSoundEffect"] = 84,
	["Plane"] = 134,
	["PlaneConstraint"] = 105,
	["Platform"] = 35,
	["Player"] = 12,
	["PlayerGui"] = 46,
	["Players"] = 21,
	["PlayerScripts"] = 79,
	["PluginAction"] = 0,
	["PluginCapabilities"] = 0,
	["PluginGuiService"] = 0,
	["PointLight"] = 13,
	["PointsService"] = 25,
	["Pose"] = 60,
	["PrismaticConstraint"] = 88,
	["PrismPart"] = 1,
	["ProximityPrompt"] = 124,
	["ProximityPromptService"] = 124,
	["PyramidPart"] = 1,
	["RayValue"] = 4,
	["ReflectionMetadata"] = 97,
	["ReflectionMetadataCallbacks"] = 97,
	["ReflectionMetadataClass"] = 97,
	["ReflectionMetadataClasses"] = 97,
	["ReflectionMetadataEnum"] = 97,
	["ReflectionMetadataEnumItem"] = 97,
	["ReflectionMetadataEnums"] = 97,
	["ReflectionMetadataEvents"] = 97,
	["ReflectionMetadataFunctions"] = 97,
	["ReflectionMetadataMember"] = 97,
	["ReflectionMetadataProperties"] = 97,
	["ReflectionMetadataYieldFunctions"] = 97,
	["RemoteEvent"] = 75,
	["RemoteFunction"] = 74,
	["RenderingTest"] = 68,
	["ReplicatedFirst"] = 70,
	["ReplicatedStorage"] = 70,
	["ReverbSoundEffect"] = 134,
	["RightAngleRampPart"] = 1,
	["RigidConstraint"] = 135,
	["RobloxEditableImage"] = 49,
	["RobloxEditableMesh"] = 8,
	["RocketPropulsion"] = 14,
	["RodConstraint"] = 90,
	["RopeConstraint"] = 89,
	["Rotate"] = 34,
	["RotateP"] = 34,
	["RotateV"] = 34,
	["RotationCurve"] = 0,
	["RunService"] = 66,
	["ScreenGui"] = 47,
	["Script"] = 6,
	["ScriptContext"] = 18,
	["ScrollingFrame"] = 48,
	["Seat"] = 35,
	["Selection"] = 55,
	["SelectionBox"] = 54,
	["SelectionPartLasso"] = 57,
	["SelectionPointLasso"] = 57,
	["SelectionSphere"] = 54,
	-- ["ServerScriptService"] = 71,
	-- ["ServerStorage"] = 69,
	["Shirt"] = 43,
	["ShirtGraphic"] = 40,
	["SkateboardController"] = 0,
	["SkateboardPlatform"] = 35,
	["Skin"] = 0,
	["Sky"] = 28,
	["SlidingBallConstraint"] = 86,
	["Smoke"] = 59,
	["Snap"] = 34,
	["Sound"] = 11,
	["SoundGroup"] = 38,
	["SoundService"] = 31,
	["Sparkles"] = 42,
	["SpawnLocation"] = 25,
	["SpecialMesh"] = 8,
	["SphereHandleAdornment"] = 112,
	["SpotLight"] = 13,
	["SpringConstraint"] = 91,
	["StandalonePluginScripts"] = 79,
	["StarterCharacterScripts"] = 78,
	["StarterGear"] = 20,
	["StarterGui"] = 46,
	["StarterPack"] = 20,
	["StarterPlayer"] = 79,
	["StarterPlayerScripts"] = 78,
	["Status"] = 2,
	["StringValue"] = 4,
	["StyleDerive"] = 0,
	["StyleLink"] = 0,
	["StyleRule"] = 0,
	["StyleSheet"] = 0,
	["SunRaysEffect"] = 83,
	["SurfaceAppearance"] = 0,
	["SurfaceGui"] = 64,
	["SurfaceLight"] = 13,
	["SurfaceSelection"] = 55,
	["SwimController"] = 0,
	["Team"] = 24,
	["Teams"] = 23,
	["TeleportOptions"] = 146,
	["TeleportService"] = 146,
	["Terrain"] = 65,
	["TerrainDetail"] = 65,
	["TerrainRegion"] = 65,
	["TestService"] = 68,
	["TextBox"] = 51,
	["TextButton"] = 51,
	["TextChannel"] = 142,
	["TextChatCommand"] = 138,
	["TextChatMessageProperties"] = 140,
	["TextLabel"] = 50,
	["Texture"] = 10,
	["TextureTrail"] = 4,
	["Tool"] = 17,
	["Torque"] = 103,
	["TorsionSpringConstraint"] = 125,
	["TouchTransmitter"] = 37,
	["TrackerStreamAnimation"] = 0,
	["Trail"] = 93,
	["TremoloSoundEffect"] = 84,
	["TrussPart"] = 1,
	["Tween"] = 0,
	["UIAspectRatioConstraint"] = 26,
	["UICorner"] = 0,
	["UIDragDetector"] = 0,
	["UIFlexItem"] = 0,
	["UIGradient"] = 0,
	["UIGridLayout"] = 0,
	["UIListLayout"] = 0,
	["UIPadding"] = 0,
	["UIPageLayout"] = 0,
	["UIScale"] = 0,
	["UISizeConstraint"] = 0,
	["UIStroke"] = 0,
	["UITableLayout"] = 0,
	["UITextSizeConstraint"] = 0,
	["Union"] = 73,
	["UnionOperation"] = 73,
	["UniversalConstraint"] = 0,
	["UnreliableRemoteEvent"] = 75,
	["UserInputService"] = 58,
	["UserService"] = 143,
	["Vector3Curve"] = 0,
	["Vector3Value"] = 4,
	["VectorForce"] = 102,
	["VehicleController"] = 0,
	["VehicleSeat"] = 35,
	["VelocityMotor"] = 34,
	["VideoDeviceInput"] = 0,
	["VideoFrame"] = 120,
	["ViewportFrame"] = 48,
	["VirtualInputManager"] = 143,
	["VisualizationMode"] = 0,
	["VisualizationModeCategory"] = 0,
	["WedgePart"] = 1,
	["Weld"] = 34,
	["WeldConstraint"] = 94,
	["Wire"] = 0,
	["WireframeHandleAdornment"] = 108,
	["Workspace"] = 19,
	["WorldModel"] = 2,
	["WrapLayer"] = 0,
	["WrapTarget"] = 0,
}

----------------------------------------------------------------
----------------------------------------------------------------
----------------------------------------------------------------
----------------------------------------------------------------
----------------------------------------------------------------

function Create(ty,data)
	local obj
	if type(ty) == 'string' then
		obj = Instance.new(ty)
	else
		obj = ty
	end
	for k, v in pairs(data) do
		if type(k) == 'number' then
			v.Parent = obj
		else
			obj[k] = v
		end
	end
	return obj
end

local barActive = false
local activeOptions = {}

function createDDown(dBut, callback,...)
	if barActive then
		for i,v in pairs(activeOptions) do
			v:Destroy()
		end
		activeOptions = {}
		barActive = false
		return
	else
		barActive = true
	end
	local slots = {...}
	local base = dBut
	for i,v in pairs(slots) do
		local newOption = base:Clone()
		newOption.ZIndex = 5
		newOption.Name = "Option "..tostring(i)
		newOption.Parent = base.Parent.Parent.Parent
		newOption.BackgroundTransparency = 0
		newOption.ZIndex = 2
		table.insert(activeOptions,newOption)
		newOption.Position = UDim2.new(-0.4, dBut.Position.X.Offset, dBut.Position.Y.Scale, dBut.Position.Y.Offset + (#activeOptions * dBut.Size.Y.Offset))
		newOption.Text = slots[i]
		newOption.MouseButton1Down:connect(function()
			dBut.Text = slots[i]
			callback(slots[i])
			for i,v in pairs(activeOptions) do
				v:Destroy()
			end
			activeOptions = {}
			barActive = false
		end)
	end
end

-- Connects a function to an event such that it fires asynchronously
local Connect = game.Changed.Connect;

-- returns the ascendant ScreenGui of an object
function GetScreen(screen)
	return screen:FindFirstAncestorOfClass("ScreenGui")
end

do
	local ZIndexLock = {}
	-- Sets the ZIndex of an object and its descendants. Objects are locked so
	-- that SetZIndexOnChanged doesn't spawn multiple threads that set the
	-- ZIndex of the same object.
	function SetZIndex(object,z)
		if not ZIndexLock[object] then
			ZIndexLock[object] = true
			if object:IsA'GuiObject' then
				object.ZIndex = z
			end
			local children = object:GetChildren()
			for i = 1,#children do
				SetZIndex(children[i],z)
			end
			ZIndexLock[object] = nil
		end
	end

	function SetZIndexOnChanged(object)
		return Connect(object.Changed, function(p)
			if p == "ZIndex" then
				SetZIndex(object,object.ZIndex)
			end
		end)
	end
end

---- IconMap ----
-- Image size: 2352px x 16px
-- Icon size: 16px x 16px
-- Padding between each icon: 0px
-- Padding around image edge: 0px
-- Total icons: 147 x 1 (147)

local Icon do
	local iconMap;
	if not getcustomasset then
		iconMap = "rbxasset://textures/ClassImages.png"
	else
		if not isfile("TSDex/ClassImages.png") then
			writefile("TSDex/ClassImages.png", game:HttpGet("https://raw.githubusercontent.com/FaithfulAC/TSD-script-storage/refs/heads/main/DexAssets/ClassImages.png"))
		end
		iconMap = getcustomasset("TSDex/ClassImages.png")
	end
	local floor = math.floor

	function Icon(IconFrame,index)
		index = floor(index)
		local mapSize = Vector2.new(2352,16)
		local iconSize = 16

		local class = 'Frame'
		if type(IconFrame) == 'string' then
			class = IconFrame
			IconFrame = nil
		end

		if not IconFrame then
			IconFrame = Create(class,{
				Name = "Icon";
				BackgroundTransparency = 1;
				ClipsDescendants = true;
				Create('ImageLabel',{
					Name = "IconMap";
					Active = false;
					BackgroundTransparency = 1;
					Image = iconMap;
					Size = UDim2.new(mapSize.x/iconSize,0,mapSize.y/iconSize,0);
				});
			})
		end

		IconFrame.IconMap.Position = UDim2.new(-index,0,0,0)
		return IconFrame
	end
end

---- IconMap2 ----
-- Image size: 512px x 512px
-- Icon size: 16px x 16px
-- Padding between each icon: 0px
-- Padding around image edge: 0px
-- Total icons: 1000

local Icon2 do
	local iconMap2;
	if not getcustomasset then
		iconMap2 = "rbxasset://textures/TagEditor/famfamfam.png"
	else
		if not isfile("TSDex/famfamfam.png") then
			writefile("TSDex/famfamfam.png", game:HttpGet("https://raw.githubusercontent.com/FaithfulAC/TSD-script-storage/refs/heads/main/DexAssets/famfamfam.png"))
		end
		iconMap2 = getcustomasset("TSDex/famfamfam.png")
	end
	local floor = math.floor

	local iconDehash do
		-- 14 x 14, 0-based input, 0-based output
		local f=math.floor
		function iconDehash(h)
			return f(h/32%32),f(h%32)
		end
	end

	function Icon2(IconFrame,index)
		local row, col = iconDehash(index)
		local mapSize = Vector2.new(512,512)
		local iconSize = 16

		local class = 'Frame'
		if type(IconFrame) == 'string' then
			class = IconFrame
			IconFrame = nil
		end

		if not IconFrame then
			IconFrame = Create(class,{
				Name = "Icon";
				BackgroundTransparency = 1;
				ClipsDescendants = true;
				Create('ImageLabel',{
					Name = "IconMap2";
					Active = false;
					BackgroundTransparency = 1;
					Image = iconMap2;
					Size = UDim2.new(mapSize.x/iconSize,0,mapSize.y/iconSize,0);
				});
			})
		end

		IconFrame.IconMap2.Position = UDim2.new(-col,0,-row,0)
		return IconFrame
	end
end


----------------------------------------------------------------
----------------------------------------------------------------
----------------------------------------------------------------
----------------------------------------------------------------
---- ScrollBar
do
	-- AutoButtonColor doesn't always reset properly
	local function ResetButtonColor(button)
		local active = button.Active
		button.Active = not active
		button.Active = active
	end

	local function ArrowGraphic(size,dir,scaled,template)
		local Frame = Create('Frame',{
			Name = "Arrow Graphic";
			BorderSizePixel = 0;
			Size = UDim2.new(0,size,0,size);
			Transparency = 1;
		})
		if not template then
			template = Instance.new("Frame")
			template.BorderSizePixel = 0
		end

		template.BackgroundColor3 = Color3.new(1, 1, 1);

		local transform
		if dir == nil or dir == 'Up' then
			function transform(p,s) return p,s end
		elseif dir == 'Down' then
			function transform(p,s) return UDim2.new(0,p.X.Offset,0,size-p.Y.Offset-1),s end
		elseif dir == 'Left' then
			function transform(p,s) return UDim2.new(0,p.Y.Offset,0,p.X.Offset),UDim2.new(0,s.Y.Offset,0,s.X.Offset) end
		elseif dir == 'Right' then
			function transform(p,s) return UDim2.new(0,size-p.Y.Offset-1,0,p.X.Offset),UDim2.new(0,s.Y.Offset,0,s.X.Offset) end
		end

		local scale
		if scaled then
			function scale(p,s) return UDim2.new(p.X.Offset/size,0,p.Y.Offset/size,0),UDim2.new(s.X.Offset/size,0,s.Y.Offset/size,0) end
		else
			function scale(p,s) return p,s end
		end

		local o = math.floor(size/4)
		if size%2 == 0 then
			local n = size/2-1
			for i = 0,n do
				local t = template:Clone()
				local p,s = scale(transform(
					UDim2.new(0,n-i,0,o+i),
					UDim2.new(0,(i+1)*2,0,1)
					))
				t.Position = p
				t.Size = s
				t.Parent = Frame
			end
		else
			local n = (size-1)/2
			for i = 0,n do
				local t = template:Clone()
				local p,s = scale(transform(
					UDim2.new(0,n-i,0,o+i),
					UDim2.new(0,i*2+1,0,1)
					))
				t.Position = p
				t.Size = s
				t.Parent = Frame
			end
		end
		if size%4 > 1 then
			local t = template:Clone()
			local p,s = scale(transform(
				UDim2.new(0,0,0,size-o-1),
				UDim2.new(0,size,0,1)
				))
			t.Position = p
			t.Size = s
			t.Parent = Frame
		end

		for i,v in pairs(Frame:GetChildren()) do
			v.BackgroundColor3 = Color3.new(1, 1, 1);
		end

		return Frame
	end


	local function GripGraphic(size,dir,spacing,scaled,template)
		local Frame = Create('Frame',{
			Name = "Grip Graphic";
			BorderSizePixel = 0;
			Size = UDim2.new(0,size.x,0,size.y);
			Transparency = 1;
		})
		if not template then
			template = Instance.new("Frame")
			template.BorderSizePixel = 0
		end

		spacing = spacing or 2

		local scale
		if scaled then
			function scale(p) return UDim2.new(p.X.Offset/size.x,0,p.Y.Offset/size.y,0) end
		else
			function scale(p) return p end
		end

		if dir == 'Vertical' then
			for i=0,size.x-1,spacing do
				local t = template:Clone()
				t.Size = scale(UDim2.new(0,1,0,size.y))
				t.Position = scale(UDim2.new(0,i,0,0))
				t.Parent = Frame
			end
		elseif dir == nil or dir == 'Horizontal' then
			for i=0,size.y-1,spacing do
				local t = template:Clone()
				t.Size = scale(UDim2.new(0,size.x,0,1))
				t.Position = scale(UDim2.new(0,0,0,i))
				t.Parent = Frame
			end
		end

		return Frame
	end

	local mt = {
		__index = {
			GetScrollPercent = function(self)
				return self.ScrollIndex/(self.TotalSpace-self.VisibleSpace)
			end;
			CanScrollDown = function(self)
				return self.ScrollIndex + self.VisibleSpace < self.TotalSpace
			end;
			CanScrollUp = function(self)
				return self.ScrollIndex > 0
			end;
			ScrollDown = function(self)
				self.ScrollIndex = self.ScrollIndex + self.PageIncrement
				self:Update()
			end;
			ScrollUp = function(self)
				self.ScrollIndex = self.ScrollIndex - self.PageIncrement
				self:Update()
			end;
			ScrollTo = function(self,index)
				self.ScrollIndex = index
				self:Update()
			end;
			SetScrollPercent = function(self,percent)
				self.ScrollIndex = math.floor((self.TotalSpace - self.VisibleSpace)*percent + 0.5)
				self:Update()
			end;
		};
	}
	mt.__index.CanScrollRight = mt.__index.CanScrollDown
	mt.__index.CanScrollLeft = mt.__index.CanScrollUp
	mt.__index.ScrollLeft = mt.__index.ScrollUp
	mt.__index.ScrollRight = mt.__index.ScrollDown

	function ScrollBar(horizontal)
		-- create row scroll bar
		local ScrollFrame = Create('Frame',{
			Name = "ScrollFrame";
			BorderSizePixel = 0;
			Position = horizontal and UDim2.new(0,0,1,-GUI_SIZE) or UDim2.new(1,-GUI_SIZE,0,0);
			Size = horizontal and UDim2.new(1,0,0,GUI_SIZE) or UDim2.new(0,GUI_SIZE,1,0);
			BackgroundTransparency = 1;
			Create('ImageButton',{
				Name = "ScrollDown";
				Position = horizontal and UDim2.new(1,-GUI_SIZE,0,0) or UDim2.new(0,0,1,-GUI_SIZE);
				Size = UDim2.new(0, GUI_SIZE, 0, GUI_SIZE);
				BackgroundColor3 = GuiColor.Button;
				BorderColor3 = GuiColor.Border;
				BorderSizePixel = 0;
			});
			Create('ImageButton',{
				Name = "ScrollUp";
				Size = UDim2.new(0, GUI_SIZE, 0, GUI_SIZE);
				BackgroundColor3 = GuiColor.Button;
				BorderColor3 = GuiColor.Border;
				BorderSizePixel = 0;
			});
			Create('ImageButton',{
				Name = "ScrollBar";
				Size = horizontal and UDim2.new(1,-GUI_SIZE*2,1,0) or UDim2.new(1,0,1,-GUI_SIZE*2);
				Position = horizontal and UDim2.new(0,GUI_SIZE,0,0) or UDim2.new(0,0,0,GUI_SIZE);
				AutoButtonColor = false;
				BackgroundColor3 = Color3.fromRGB(40, 50, 100);
				BorderColor3 = GuiColor.Border;
				BorderSizePixel = 0;
				Create('ImageButton',{
					Name = "ScrollThumb";
					AutoButtonColor = false;
					Size = UDim2.new(0, GUI_SIZE, 0, GUI_SIZE);
					BackgroundColor3 = GuiColor.Button;
					BorderColor3 = GuiColor.Border;
					BorderSizePixel = 0;
				});
			});
		})

		local graphicTemplate = Create('Frame',{
			Name="Graphic";
			BorderSizePixel = 0;
			BackgroundColor3 = GuiColor.Border;
		})
		local graphicSize = GUI_SIZE/2

		local ScrollDownFrame = ScrollFrame.ScrollDown
		local ScrollDownGraphic = ArrowGraphic(graphicSize,horizontal and 'Right' or 'Down',true,graphicTemplate)
		ScrollDownGraphic.Position = UDim2.new(0.5,-graphicSize/2,0.5,-graphicSize/2)
		ScrollDownGraphic.Parent = ScrollDownFrame
		local ScrollUpFrame = ScrollFrame.ScrollUp
		local ScrollUpGraphic = ArrowGraphic(graphicSize,horizontal and 'Left' or 'Up',true,graphicTemplate)
		ScrollUpGraphic.Position = UDim2.new(0.5,-graphicSize/2,0.5,-graphicSize/2)
		ScrollUpGraphic.Parent = ScrollUpFrame
		local ScrollBarFrame = ScrollFrame.ScrollBar
		local ScrollThumbFrame = ScrollBarFrame.ScrollThumb
		do
			local size = GUI_SIZE*3/8
			local Decal = GripGraphic(Vector2.new(size,size),horizontal and 'Vertical' or 'Horizontal',2,graphicTemplate)
			Decal.Position = UDim2.new(0.5,-size/2,0.5,-size/2)
			Decal.Parent = ScrollThumbFrame
		end

		local Class = setmetatable({
			GUI = ScrollFrame;
			ScrollIndex = 0;
			VisibleSpace = 0;
			TotalSpace = 0;
			PageIncrement = 1;
		},mt)

		local UpdateScrollThumb
		if horizontal then
			function UpdateScrollThumb()
				ScrollThumbFrame.Size = UDim2.new(Class.VisibleSpace/Class.TotalSpace,0,0,GUI_SIZE)
				if ScrollThumbFrame.AbsoluteSize.x < GUI_SIZE then
					ScrollThumbFrame.Size = UDim2.new(0,GUI_SIZE,0,GUI_SIZE)
				end
				local barSize = ScrollBarFrame.AbsoluteSize.x
				ScrollThumbFrame.Position = UDim2.new(Class:GetScrollPercent()*(barSize - ScrollThumbFrame.AbsoluteSize.x)/barSize,0,0,0)
			end
		else
			function UpdateScrollThumb()
				ScrollThumbFrame.Size = UDim2.new(0,GUI_SIZE,Class.VisibleSpace/Class.TotalSpace,0)
				if ScrollThumbFrame.AbsoluteSize.y < GUI_SIZE then
					ScrollThumbFrame.Size = UDim2.new(0,GUI_SIZE,0,GUI_SIZE)
				end
				local barSize = ScrollBarFrame.AbsoluteSize.y
				ScrollThumbFrame.Position = UDim2.new(0,0,Class:GetScrollPercent()*(barSize - ScrollThumbFrame.AbsoluteSize.y)/barSize,0)
			end
		end

		local lastDown
		local lastUp
		local scrollStyle = {BackgroundColor3=Color3.new(1, 1, 1),BackgroundTransparency=0}
		local scrollStyle_ds = {BackgroundColor3=Color3.new(1, 1, 1),BackgroundTransparency=0.7}

		local function Update()
			local t = Class.TotalSpace
			local v = Class.VisibleSpace
			local s = Class.ScrollIndex
			if v <= t then
				if s > 0 then
					if s + v > t then
						Class.ScrollIndex = t - v
					end
				else
					Class.ScrollIndex = 0
				end
			else
				Class.ScrollIndex = 0
			end

			if Class.UpdateCallback then
				if Class.UpdateCallback(Class) == false then
					return
				end
			end

			local down = Class:CanScrollDown()
			local up = Class:CanScrollUp()
			if down ~= lastDown then
				lastDown = down
				ScrollDownFrame.Active = down
				ScrollDownFrame.AutoButtonColor = down
				local children = ScrollDownGraphic:GetChildren()
				local style = down and scrollStyle or scrollStyle_ds
				for i = 1,#children do
					Create(children[i],style)
				end
			end
			if up ~= lastUp then
				lastUp = up
				ScrollUpFrame.Active = up
				ScrollUpFrame.AutoButtonColor = up
				local children = ScrollUpGraphic:GetChildren()
				local style = up and scrollStyle or scrollStyle_ds
				for i = 1,#children do
					Create(children[i],style)
				end
			end
			ScrollThumbFrame.Visible = down or up
			UpdateScrollThumb()
		end
		Class.Update = Update

		SetZIndexOnChanged(ScrollFrame)

		local MouseDrag = Create('ImageButton',{
			Name = "MouseDrag";
			Position = UDim2.new(-.25,0,-.25,0);
			Size = UDim2.new(1.5,0,1.5,0);
			Transparency = 1;
			AutoButtonColor = false;
			Active = true;
			ZIndex = 10;
		})

		local scrollEventID = 0
		Connect(ScrollDownFrame.MouseButton1Down, function()
			scrollEventID = tick()
			local current = scrollEventID
			local up_con
			up_con = Connect(MouseDrag.MouseButton1Up, function()
				scrollEventID = tick()
				MouseDrag.Parent = nil
				ResetButtonColor(ScrollDownFrame)
				up_con:Disconnect(); drag = nil
			end)
			MouseDrag.Parent = GetScreen(ScrollFrame)
			Class:ScrollDown()
			task.wait(.2) -- delay before auto scroll
			while scrollEventID == current do
				Class:ScrollDown()
				if not Class:CanScrollDown() then break end
				task.wait()
			end
		end)

		Connect(ScrollDownFrame.MouseButton1Up, function()
			scrollEventID = tick()
		end)

		Connect(ScrollUpFrame.MouseButton1Down, function()
			scrollEventID = tick()
			local current = scrollEventID
			local up_con
			up_con = Connect(MouseDrag.MouseButton1Up, function()
				scrollEventID = tick()
				MouseDrag.Parent = nil
				ResetButtonColor(ScrollUpFrame)
				up_con:Disconnect(); drag = nil
			end)
			MouseDrag.Parent = GetScreen(ScrollFrame)
			Class:ScrollUp()
			task.wait(.2)
			while scrollEventID == current do
				Class:ScrollUp()
				if not Class:CanScrollUp() then break end
				task.wait()
			end
		end)

		Connect(ScrollUpFrame.MouseButton1Up, function()
			scrollEventID = tick()
		end)

		if horizontal then
			Connect(ScrollBarFrame.MouseButton1Down, function(x,y)
				scrollEventID = tick()
				local current = scrollEventID
				local up_con
				up_con = Connect(MouseDrag.MouseButton1Up, function()
					scrollEventID = tick()
					MouseDrag.Parent = nil
					ResetButtonColor(ScrollUpFrame)
					up_con:Disconnect(); drag = nil
				end)
				MouseDrag.Parent = GetScreen(ScrollFrame)
				if x > ScrollThumbFrame.AbsolutePosition.x then
					Class:ScrollTo(Class.ScrollIndex + Class.VisibleSpace)
					task.wait(.2)
					while scrollEventID == current do
						if x < ScrollThumbFrame.AbsolutePosition.x + ScrollThumbFrame.AbsoluteSize.x then break end
						Class:ScrollTo(Class.ScrollIndex + Class.VisibleSpace)
						task.wait()
					end
				else
					Class:ScrollTo(Class.ScrollIndex - Class.VisibleSpace)
					task.wait(.2)
					while scrollEventID == current do
						if x > ScrollThumbFrame.AbsolutePosition.x then break end
						Class:ScrollTo(Class.ScrollIndex - Class.VisibleSpace)
						task.wait()
					end
				end
			end)
		else
			Connect(ScrollBarFrame.MouseButton1Down, function(x,y)
				scrollEventID = tick()
				local current = scrollEventID
				local up_con
				up_con = Connect(MouseDrag.MouseButton1Up, function()
					scrollEventID = tick()
					MouseDrag.Parent = nil
					ResetButtonColor(ScrollUpFrame)
					up_con:Disconnect(); drag = nil
				end)
				MouseDrag.Parent = GetScreen(ScrollFrame)
				if y > ScrollThumbFrame.AbsolutePosition.y then
					Class:ScrollTo(Class.ScrollIndex + Class.VisibleSpace)
					task.wait(.2)
					while scrollEventID == current do
						if y < ScrollThumbFrame.AbsolutePosition.y + ScrollThumbFrame.AbsoluteSize.y then break end
						Class:ScrollTo(Class.ScrollIndex + Class.VisibleSpace)
						task.wait()
					end
				else
					Class:ScrollTo(Class.ScrollIndex - Class.VisibleSpace)
					task.wait(.2)
					while scrollEventID == current do
						if y > ScrollThumbFrame.AbsolutePosition.y then break end
						Class:ScrollTo(Class.ScrollIndex - Class.VisibleSpace)
						task.wait()
					end
				end
			end)
		end

		if horizontal then
			Connect(ScrollThumbFrame.MouseButton1Down, function(x,y)
				scrollEventID = tick()
				local mouse_offset = x - ScrollThumbFrame.AbsolutePosition.x
				local drag_con
				local up_con
				drag_con = Connect(MouseDrag.MouseMoved, function(x,y)
					local bar_abs_pos = ScrollBarFrame.AbsolutePosition.x
					local bar_drag = ScrollBarFrame.AbsoluteSize.x - ScrollThumbFrame.AbsoluteSize.x
					local bar_abs_one = bar_abs_pos + bar_drag
					x = x - mouse_offset
					x = x < bar_abs_pos and bar_abs_pos or x > bar_abs_one and bar_abs_one or x
					x = x - bar_abs_pos
					Class:SetScrollPercent(x/(bar_drag))
				end)
				up_con = Connect(MouseDrag.MouseButton1Up, function()
					scrollEventID = tick()
					MouseDrag.Parent = nil
					ResetButtonColor(ScrollThumbFrame)
					drag_con:Disconnect(); drag_con = nil
					up_con:Disconnect(); drag = nil
				end)
				MouseDrag.Parent = GetScreen(ScrollFrame)
			end)
		else
			Connect(ScrollThumbFrame.MouseButton1Down, function(x,y)
				scrollEventID = tick()
				local mouse_offset = y - ScrollThumbFrame.AbsolutePosition.y
				local drag_con
				local up_con
				drag_con = Connect(MouseDrag.MouseMoved, function(x,y)
					local bar_abs_pos = ScrollBarFrame.AbsolutePosition.y
					local bar_drag = ScrollBarFrame.AbsoluteSize.y - ScrollThumbFrame.AbsoluteSize.y
					local bar_abs_one = bar_abs_pos + bar_drag
					y = y - mouse_offset
					y = y < bar_abs_pos and bar_abs_pos or y > bar_abs_one and bar_abs_one or y
					y = y - bar_abs_pos
					Class:SetScrollPercent(y/(bar_drag))
				end)
				up_con = Connect(MouseDrag.MouseButton1Up, function()
					scrollEventID = tick()
					MouseDrag.Parent = nil
					ResetButtonColor(ScrollThumbFrame)
					drag_con:Disconnect(); drag_con = nil
					up_con:Disconnect(); drag = nil
				end)
				MouseDrag.Parent = GetScreen(ScrollFrame)
			end)
		end

		function Class:Destroy()
			ScrollFrame:Destroy()
			MouseDrag:Destroy()
			for k in pairs(Class) do
				Class[k] = nil
			end
			setmetatable(Class,nil)
		end

		Update()

		return Class
	end
end

----------------------------------------------------------------
----------------------------------------------------------------
----------------------------------------------------------------
----------------------------------------------------------------
---- Explorer panel

Create(explorerPanel,{
	BackgroundColor3 = GuiColor.Field;
	BorderColor3 = GuiColor.Border;
	Active = true;
})

local SettingsRemote = explorerPanel.Parent:WaitForChild("SettingsPanel"):WaitForChild("GetSetting")
local GetAwaitRemote = explorerPanel.Parent:WaitForChild("PropertiesFrame"):WaitForChild("GetAwaiting")
local bindSetAwaiting = explorerPanel.Parent:WaitForChild("PropertiesFrame"):WaitForChild("SetAwaiting")

local ConfirmationWindow = explorerPanel.Parent:WaitForChild("Confirmation")
local CautionWindow = explorerPanel.Parent:WaitForChild("Caution")
local TableCautionWindow = explorerPanel.Parent:WaitForChild("TableCaution")

local RemoteWindow = explorerPanel.Parent:WaitForChild("CallRemote")

local ScriptEditor = explorerPanel.Parent:WaitForChild("ScriptEditor")
local ScriptEditorEvent = ScriptEditor:WaitForChild("OpenScript")

local CurrentRemoteWindow

local lastSelectedNode

local DexStorage
local DexStorageMain
local DexStorageEnabled

if saveinstance then DexStorageEnabled = true end

local _decompile = decompile;

function decompile(s, ...)
	if SettingsRemote:Invoke'UseNewDecompiler' then
		return _decompile(s, 'new');
	else
		return _decompile(s, 'legacy');
	end 
end

if DexStorageEnabled then
	DexStorage = Instance.new("Folder")
	DexStorage.Name = "Dex"
	DexStorageMain = Instance.new("Folder",DexStorage)
	DexStorageMain.Name = "DexStorage"
end

local RunningScriptsStorage
local RunningScriptsStorageMain
local RunningScriptsStorageEnabled

if getscripts then RunningScriptsStorageEnabled = true end

if RunningScriptsStorageEnabled then
	RunningScriptsStorage = Instance.new("Folder")
	RunningScriptsStorage.Name = "Dex Internal Storage"
	RunningScriptsStorageMain = Instance.new("Folder", RunningScriptsStorage)
	RunningScriptsStorageMain.Name = "Running Scripts"
end

local LoadedModulesStorage
local LoadedModulesStorageMain
local LoadedModulesStorageEnabled

if getloadedmodules then LoadedModulesStorageEnabled = true end

if LoadedModulesStorageEnabled then
	LoadedModulesStorage = Instance.new("Folder")
	LoadedModulesStorage.Name = "Dex Internal Storage"
	LoadedModulesStorageMain = Instance.new("Folder", LoadedModulesStorage)
	LoadedModulesStorageMain.Name = "Loaded Modules"
end

local NilStorage
local NilStorageMain
local NilStorageEnabled

if getnilinstances then NilStorageEnabled = true end

if NilStorageEnabled then
	NilStorage = Instance.new("Folder")
	NilStorage.Name = "Dex Internal Storage"
	NilStorageMain = Instance.new("Folder",NilStorage)
	NilStorageMain.Name = "Nil Instances"
end

local listFrame = Create('Frame',{
	Name = "List";
	BorderSizePixel = 0;
	BackgroundTransparency = 1;
	ClipsDescendants = true;
	Position = UDim2.new(0,0,0,HEADER_SIZE);
	Size = UDim2.new(1,-GUI_SIZE,1,-HEADER_SIZE);
	Parent = explorerPanel;
})

local scrollBar = ScrollBar(false)
scrollBar.PageIncrement = 1
Create(scrollBar.GUI,{
	Position = UDim2.new(1,-GUI_SIZE,0,HEADER_SIZE);
	Size = UDim2.new(0,GUI_SIZE,1,-HEADER_SIZE);
	Parent = explorerPanel;
})

local scrollBarH = ScrollBar(true)
scrollBarH.PageIncrement = GUI_SIZE
Create(scrollBarH.GUI,{
	Position = UDim2.new(0,0,1,-GUI_SIZE);
	Size = UDim2.new(1,-GUI_SIZE,0,GUI_SIZE);
	Visible = false;
	Parent = explorerPanel;
})

--[[local headerFrame = Create('Frame',{
	Name = "Header";
	BorderSizePixel = 0;
	BackgroundColor3 = GuiColor.Background;
	BorderColor3 = GuiColor.Border;
	Position = UDim2.new(0,0,0,0);
	Size = UDim2.new(1,0,0,HEADER_SIZE);
	Parent = explorerPanel;
	Create('TextLabel',{
		Text = "Explorer";
		BackgroundTransparency = 1;
		TextColor3 = GuiColor.Text;
		TextXAlignment = 'Left';
		Font = FONT;
		FontSize = FONT_SIZE;
		Position = UDim2.new(0,4,0,0);
		Size = UDim2.new(1,-4,0.5,0);
	});
})

local explorerFilter = 	Create('TextBox',{
	Text = "Filter Workspace";
	BackgroundTransparency = 0.8;
	TextColor3 = GuiColor.Text;
	TextXAlignment = 'Left';
	Font = FONT;
	FontSize = FONT_SIZE;
	Position = UDim2.new(0,4,0.5,0);
	Size = UDim2.new(1,-8,0.5,-2);
});
explorerFilter.Parent = headerFrame]]
local headerFrame = explorerPanel:FindFirstChild("Header")
local explorerFilter = headerFrame:FindFirstChildWhichIsA("TextBox")
explorerFilter = cloneref(explorerFilter) -- mitigation

SetZIndexOnChanged(explorerPanel)

local Styles = {
	Font = Enum.Font.Arial;
	Margin = 5;
	Black = Color3.fromRGB(0,0,0);
	Black2 = Color3.fromRGB(24, 24, 24);
	White = Color3.fromRGB(244,244,244);
	Hover = Color3.fromRGB(2, 128, 144);
	Hover2 = Color3.fromRGB(0, 100, 200);
}

local Row = {
	Font = Styles.Font;
	FontSize = Enum.FontSize.Size14;
	TextXAlignment = Enum.TextXAlignment.Left;
	TextColor = Styles.White;
	TextColorOver = Styles.White;
	TextLockedColor = Color3.fromRGB(155,155,155);
	Height = 20;
	BorderColor = Color3.fromRGB(216/4,216/4,216/4);
	BackgroundColor = Color3.fromRGB(10, 20, 30);
	BackgroundColorAlternate = Color3.fromRGB(32, 32, 64);
	BackgroundColorMouseover = Color3.fromRGB(40, 40, 80);
	TitleMarginLeft = 15;
}

local DropDown = {
	Font = Styles.Font;
	FontSize = Enum.FontSize.Size14;
	TextColor = Color3.fromRGB(255,255,255);
	TextColorOver = Styles.White;
	TextXAlignment = Enum.TextXAlignment.Left;
	Height = 20;
	BackColor = Color3.fromRGB(10,10,30);
	BackColorOver = Styles.Hover2;
	BorderColor = Color3.fromRGB(45,45,60);
	BorderSizePixel = 0;
	ArrowColor = Color3.fromRGB(80, 80, 80);
	ArrowColorOver = Styles.Hover;
}

local BrickColors = {
	BoxSize = 13;
	BorderSizePixel = 1;
	BorderColor = Color3.fromRGB(160/3,160/3,160/3);
	FrameColor = Color3.fromRGB(160/3,160/3,160/3);
	Size = 20;
	Padding = 4;
	ColorsPerRow = 8;
	OuterBorder = 1;
	OuterBorderColor = Styles.Black;
}

local currentRightClickMenu
local CurrentInsertObjectWindow
local CurrentFunctionCallerWindow

function ClassCanCreate(IName)
	return (pcall(Instance.new, IName))
end

function GetClasses()
	if RbxApi == nil then
		return {}
	end

	local classTable = {}

	for _, classData in pairs(RbxApi.Classes) do
		if ClassCanCreate(classData.Name) then
			table.insert(classTable, classData.Name)
		end
	end

	return classTable
end


local function sortAlphabetic(t, property)
	table.sort(t, function(x,y)
		return x[property] < y[property]
	end)
end

local function FunctionIsHidden(functionData)
	local tags = functionData.Tags or {}
	for _, name in pairs(tags) do
		if name == "Deprecated" or name == "Hidden" or name == "ReadOnly" then
			return true
		end
	end
	return false
end

local function GetAllFunctions(className)
	if not RbxApi then
		return {}
	end

	local functions = getfunctions(className)

	for i, v in pairs(functions) do
		if FunctionIsHidden(v) then table.remove(functions, i) end
	end

	return functions
end

function GetFunctions()
	if not RbxApi then
		return {}
	end

	local List = SelectionVar():Get()

	if #List == 0 then
		return {}
	end

	local MyObject = List[1]

	local functionTable = {}
	for _, functionData in pairs(GetAllFunctions(MyObject.ClassName)) do
		table.insert(functionTable, functionData)
	end
	return functionTable
end

local Players = cloneref(game:GetService("Players"));

local blackBkg = getcustomasset and isfile("TSDex/blackBkg_square.png") and getcustomasset("TSDex/blackBkg_square.png")
		or "rbxasset://textures/blackBkg_square.png";

function CreateInsertObjectMenu(choices, currentChoice, readOnly, onClick)
	local mouse = Players.LocalPlayer:GetMouse()
	local totalSize = explorerPanel.Parent.AbsoluteSize.y
	if #choices == 0 then return end

	table.sort(choices, function(a,b) return a < b end)

	local frame = Instance.new("Frame")	
	frame.Name = "InsertObject"
	frame.Size = UDim2.new(0, 200, 1, 0)
	frame.BackgroundTransparency = 1
	frame.Active = true

	local menu = nil
	local arrow = nil
	local expanded = false
	local margin = DropDown.BorderSizePixel;

	--[[
	local button = Instance.new("TextButton")
	button.Font = Row.Font
	button.FontSize = Row.FontSize
	button.TextXAlignment = Row.TextXAlignment
	button.BackgroundTransparency = 1
	button.TextColor3 = Row.TextColor
	if readOnly then
		button.TextColor3 = Row.TextLockedColor
	end
	button.Text = currentChoice
	button.Size = UDim2.new(1, -2 * Styles.Margin, 1, 0)
	button.Position = UDim2.new(0, Styles.Margin, 0, 0)
	button.Parent = frame
	--]]

	local function hideMenu()
		expanded = false
		--showArrow(DropDown.ArrowColor)
		if frame then 
			--frame:Destroy()
			CurrentInsertObjectWindow.Visible = false
		end
	end

	local function showMenu()
		expanded = true
		menu = Instance.new("ScrollingFrame")
		menu.Size = UDim2.new(0,200,1,0)
		menu.CanvasSize = UDim2.new(0, 200, 0, #choices * DropDown.Height)
		menu.Position = UDim2.new(0, margin, 0, 0)
		menu.BackgroundTransparency = 0
		menu.BackgroundColor3 = DropDown.BackColor
		menu.BorderColor3 = DropDown.BorderColor
		menu.BorderSizePixel = DropDown.BorderSizePixel
		menu.TopImage = blackBkg
		menu.MidImage = blackBkg
		menu.BottomImage = blackBkg
		menu.Active = true
		menu.ZIndex = 5
		menu.Parent = frame

		--local parentFrameHeight = script.Parent.List.Size.Y.Offset
		--local rowHeight = mouse.Y
		--if (rowHeight + menu.Size.Y.Offset) > parentFrameHeight then
		--	menu.Position = UDim2.new(0, margin, 0, -1 * (#choices * DropDown.Height) - margin)
		--end

		local function choice(name)
			onClick(name)
			hideMenu()
		end

		for i,name in pairs(choices) do
			local option = CreateRightClickMenuItem(name, function()
				choice(name)
			end,1)
			option.Size = UDim2.new(1, 0, 0, 20)
			option.Position = UDim2.new(0, 0, 0, (i - 1) * DropDown.Height)
			option.ZIndex = menu.ZIndex
			option.Parent = menu
		end
	end


	showMenu()


	return frame
end

function CreateFunctionCallerMenu(choices, currentChoice, readOnly, onClick)
	local mouse = Players.LocalPlayer:GetMouse()
	local totalSize = explorerPanel.Parent.AbsoluteSize.y
	if #choices == 0 then return end

	table.sort(choices, function(a,b) return a.Name < b.Name end)

	local frame = Instance.new("Frame")	
	frame.Name = "InsertObject"
	frame.Size = UDim2.new(0, 200, 1, 0)
	frame.BackgroundTransparency = 1
	frame.Active = true

	local menu = nil
	local arrow = nil
	local expanded = false
	local margin = DropDown.BorderSizePixel;

	local function hideMenu()
		expanded = false
		--showArrow(DropDown.ArrowColor)
		if frame then 
			--frame:Destroy()
			CurrentInsertObjectWindow.Visible = false
		end
	end

	local function showMenu()
		expanded = true
		menu = Instance.new("ScrollingFrame")
		menu.Size = UDim2.new(0,300,1,0)
		menu.CanvasSize = UDim2.new(0, 300, 0, #choices * DropDown.Height)
		menu.Position = UDim2.new(0, margin, 0, 0)
		menu.BackgroundTransparency = 0
		menu.BackgroundColor3 = DropDown.BackColor
		menu.BorderColor3 = DropDown.BorderColor
		menu.BorderSizePixel = DropDown.BorderSizePixel
		menu.TopImage = blackBkg
		menu.MidImage = blackBkg
		menu.BottomImage = blackBkg
		menu.Active = true
		menu.ZIndex = 5
		menu.Parent = frame

		--local parentFrameHeight = script.Parent.List.Size.Y.Offset
		--local rowHeight = mouse.Y
		--if (rowHeight + menu.Size.Y.Offset) > parentFrameHeight then
		--	menu.Position = UDim2.new(0, margin, 0, -1 * (#choices * DropDown.Height) - margin)
		--end

		local function GetParameters(functionData)
			local paraString = ""
			paraString = paraString .. "("

			-- note from europa, jesus this code looks so ugly
			for i, v in pairs(functionData.Parameters) do
				paraString = paraString .. v.Type.Name .. " " .. v.Name

				if i < #functionData.Parameters then
					paraString = paraString .. ", "
				end
			end

			paraString = paraString .. ")"
			return paraString
		end

		local function choice(name)
			onClick(name)
			hideMenu()
		end

		for i,name in pairs(choices) do
			local returntype = name.ReturnType.Name

			if (not returntype) and #name.ReturnType > 1 then
				returntype = ""

				for i, v in ipairs(name.ReturnType) do
					returntype = returntype .. v.Name

					if i ~= #name.ReturnType then
						returntype = returntype .. ", "
					end
				end
			end

			local option = CreateRightClickMenuItem(returntype .. " " .. name.Name .. GetParameters(name), function()
				choice(name)
			end, 2)
			option.Size = UDim2.new(1, 0, 0, 20)
			option.Position = UDim2.new(0, 0, 0, (i - 1) * DropDown.Height)
			option.ZIndex = menu.ZIndex
			option.Parent = menu
		end
	end


	showMenu()


	return frame
end

function CreateInsertObject()
	if not CurrentInsertObjectWindow then return end
	CurrentInsertObjectWindow.Visible = true
	if currentRightClickMenu and CurrentInsertObjectWindow.Visible then
		CurrentInsertObjectWindow.Position = UDim2.new(0,currentRightClickMenu.Position.X.Offset-currentRightClickMenu.Size.X.Offset-2,0,0)
	end
	if CurrentInsertObjectWindow.Visible then
		CurrentInsertObjectWindow.Parent = explorerPanel.Parent
	end
end

function CreateFunctionCaller(oh)
	if CurrentFunctionCallerWindow then
		CurrentFunctionCallerWindow:Destroy()
		CurrentFunctionCallerWindow = nil
	end
	CurrentFunctionCallerWindow = CreateFunctionCallerMenu(
		GetFunctions(),
		"",
		false,
		function(option)
			CurrentFunctionCallerWindow:Destroy()
			CurrentFunctionCallerWindow = nil
			local list = SelectionVar():Get()
			for i,v in pairs(list) do
				print(pcall(v[option.Name], v))
			end

			DestroyRightClick()
		end
	)
	if currentRightClickMenu and CurrentFunctionCallerWindow then
		CurrentFunctionCallerWindow.Position = UDim2.new(0,currentRightClickMenu.Position.X.Offset-currentRightClickMenu.Size.X.Offset*1.5-2,0,0)
	end
	if CurrentFunctionCallerWindow then
		CurrentFunctionCallerWindow.Parent = explorerPanel.Parent
	end
end

function CreateRightClickMenuItem(text, onClick, insObj)
	local button = Instance.new("TextButton")
	button.Font = DropDown.Font
	button.FontSize = DropDown.FontSize
	button.TextColor3 = DropDown.TextColor
	button.TextXAlignment = DropDown.TextXAlignment
	button.BackgroundColor3 = DropDown.BackColor
	button.AutoButtonColor = false
	button.BorderSizePixel = 0
	button.Active = true
	button.Text = text

	if insObj == 1 then
		local newIcon = Icon(nil,ExplorerIndex[text] or 0)
		newIcon.Position = UDim2.new(0,0,0,2)
		newIcon.Size = UDim2.new(0,16,0,16)
		newIcon.IconMap.ZIndex = 5
		newIcon.Parent = button
		button.Text = "     "..button.Text
	elseif insObj == 2 then
		button.FontSize = Enum.FontSize.Size11
	end

	Connect(button.MouseEnter, function()
		button.TextColor3 = DropDown.TextColorOver
		button.BackgroundColor3 = DropDown.BackColorOver
		if not insObj and CurrentInsertObjectWindow then
			if CurrentInsertObjectWindow.Visible == false and button.Text == "Insert Object" then
				CreateInsertObject()
			elseif CurrentInsertObjectWindow.Visible and button.Text ~= "Insert Object" then
				CurrentInsertObjectWindow.Visible = false
			end
		end
		if not insObj then
			if CurrentFunctionCallerWindow and button.Text ~= "Call Function" then
				CurrentFunctionCallerWindow:Destroy()
				CurrentFunctionCallerWindow = nil
			elseif button.Text == "Call Function" then
				CreateFunctionCaller()
			end
		end
	end)
	Connect(button.MouseLeave, function()
		button.TextColor3 = DropDown.TextColor
		button.BackgroundColor3 = DropDown.BackColor
	end)
	Connect(button.MouseButton1Click, function()
		button.TextColor3 = DropDown.TextColor
		button.BackgroundColor3 = DropDown.BackColor
		onClick(text)
	end)	
	return button
end

function CreateRightClickMenu(choices, currentChoice, readOnly, onClick)

	local mouse = Players.LocalPlayer:GetMouse()

	local frame = Instance.new("Frame")	
	frame.Name = "DropDown"
	frame.Size = UDim2.new(0, 200, 1, 0)
	frame.BackgroundTransparency = 1
	frame.Active = true

	local menu = nil
	local arrow = nil
	local expanded = false
	local margin = DropDown.BorderSizePixel;

	--[[
	local button = Instance.new("TextButton")
	button.Font = Row.Font
	button.FontSize = Row.FontSize
	button.TextXAlignment = Row.TextXAlignment
	button.BackgroundTransparency = 1
	button.TextColor3 = Row.TextColor
	if readOnly then
		button.TextColor3 = Row.TextLockedColor
	end
	button.Text = currentChoice
	button.Size = UDim2.new(1, -2 * Styles.Margin, 1, 0)
	button.Position = UDim2.new(0, Styles.Margin, 0, 0)
	button.Parent = frame
	--]]

	local function hideMenu()
		expanded = false
		--showArrow(DropDown.ArrowColor)
		if frame then 
			frame:Destroy()
			DestroyRightClick()
		end
	end

	local function showMenu()
		expanded = true
		menu = Instance.new("Frame")
		menu.Size = UDim2.new(0, 200, 0, #choices * DropDown.Height)
		menu.Position = UDim2.new(0, margin, 0, 5)
		menu.BackgroundTransparency = 0
		menu.BackgroundColor3 = DropDown.BackColor
		menu.BorderColor3 = DropDown.BorderColor
		menu.BorderSizePixel = DropDown.BorderSizePixel
		menu.Active = true
		menu.ZIndex = 5
		menu.Parent = frame

		--local parentFrameHeight = script.Parent.List.Size.Y.Offset
		--local rowHeight = mouse.Y
		--if (rowHeight + menu.Size.Y.Offset) > parentFrameHeight then
		--	menu.Position = UDim2.new(0, margin, 0, -1 * (#choices * DropDown.Height) - margin)
		--end

		local function choice(name)
			onClick(name)
			hideMenu()
		end

		for i,name in pairs(choices) do
			local option = CreateRightClickMenuItem(name, function()
				choice(name)
			end)
			option.Size = UDim2.new(1, 0, 0, 20)
			option.Position = UDim2.new(0, 0, 0, (i - 1) * DropDown.Height)
			option.ZIndex = menu.ZIndex
			option.Parent = menu
		end
	end


	showMenu()


	return frame
end

function checkMouseInGui(gui)
	if gui == nil then return false end

	local plrMouse = Players.LocalPlayer:GetMouse()
	local guiPosition = gui.AbsolutePosition
	local guiSize = gui.AbsoluteSize	

	if plrMouse.X >= guiPosition.x and plrMouse.X <= guiPosition.x + guiSize.x and plrMouse.Y >= guiPosition.y and plrMouse.Y <= guiPosition.y + guiSize.y then
		return true
	else
		return false
	end
end

local clipboard = {}
local function delete(o)
	o.Parent = nil
end

local getTextWidth do
	local text = Create('TextLabel',{
		Name = "TextWidth";
		TextXAlignment = 'Left';
		TextYAlignment = 'Center';
		Font = FONT;
		FontSize = FONT_SIZE;
		Text = "";
		Position = UDim2.new(0,0,0,0);
		Size = UDim2.new(1,0,1,0);
		Visible = false;
		Parent = explorerPanel;
	})
	function getTextWidth(s)
		text.Text = s
		return text.TextBounds.x
	end
end

local nameScanned = false
-- Holds the game tree converted to a list.
local TreeList = {}
-- Matches objects to their tree node representation.
local NodeLookup = {}

local nodeWidth = 0

local QuickButtons = {}

function filteringWorkspace()
	if explorerFilter.Text ~= "" and explorerFilter.Text ~= "Search Workspace" then
		return true
	end
	return false
end

function lookForAName(obj,name)
	for i,v in pairs(obj:GetChildren()) do
		if string.find(string.lower(v.Name),string.lower(name)) then nameScanned = true end
		lookForAName(v,name)
	end
end

function scanName(obj)
	nameScanned = false
	if string.find(string.lower(obj.Name),string.lower(explorerFilter.Text)) then
		nameScanned = true
	else
		lookForAName(obj,explorerFilter.Text)
	end
	return nameScanned
end

function updateActions()
	for i,v in pairs(QuickButtons) do
		if v.Cond() then
			v.Toggle(true)
		else
			v.Toggle(false)
		end
	end
end

local updateList,rawUpdateList,updateScroll,rawUpdateSize do
	local function r(t)
		for i = 1,#t do
			if i%100 == 0 then task.wait() end
			if not filteringWorkspace() or scanName(t[i].Object) then
				TreeList[#TreeList+1] = t[i]

				local w = (t[i].Depth)*(2+ENTRY_PADDING+GUI_SIZE) + 2 + ENTRY_SIZE + 4 + getTextWidth(t[i].Object.Name) + 4
				if w > nodeWidth then
					nodeWidth = w
				end
				if t[i].Expanded or filteringWorkspace() then
					r(t[i])
				end
			end
		end
	end

	function rawUpdateSize()
		scrollBarH.TotalSpace = nodeWidth
		scrollBarH.VisibleSpace = listFrame.AbsoluteSize.x
		scrollBarH:Update()
		local visible = scrollBarH:CanScrollDown() or scrollBarH:CanScrollUp()
		scrollBarH.GUI.Visible = visible

		listFrame.Size = UDim2.new(1,-GUI_SIZE,1,-GUI_SIZE*(visible and 1 or 0) - HEADER_SIZE)

		scrollBar.VisibleSpace = math.ceil(listFrame.AbsoluteSize.y/ENTRY_BOUND)
		scrollBar.GUI.Size = UDim2.new(0,GUI_SIZE,1,-GUI_SIZE*(visible and 1 or 0) - HEADER_SIZE)

		scrollBar.TotalSpace = #TreeList+1
		scrollBar:Update()
	end

	function rawUpdateList()
		-- Clear then repopulate the entire list. It appears to be fast enough.		
		TreeList = {}
		nodeWidth = 0
		r(NodeLookup[GetDebugId(workspace.Parent)])
		r(NodeLookup[GetDebugId(DexOutput)])
		if DexStorageEnabled then
			r(NodeLookup[GetDebugId(DexStorage)])
		end
		if NilStorageEnabled then
			r(NodeLookup[GetDebugId(NilStorage)])
		end
		if RunningScriptsStorageEnabled then
			r(NodeLookup[GetDebugId(RunningScriptsStorage)])
		end
		if LoadedModulesStorageEnabled then
			r(NodeLookup[GetDebugId(LoadedModulesStorage)])
		end
		rawUpdateSize()
		updateActions()
	end

	-- Adding or removing large models will cause many updates to occur. We
	-- can reduce the number of updates by creating a delay, then dropping any
	-- updates that occur during the delay.
	local updatingList = false
	function updateList()
		if updatingList or filteringWorkspace() then return end
		updatingList = true
		wait(1.5)
		updatingList = false
		rawUpdateList()
	end

	local updatingScroll = false
	function updateScroll()
		if updatingScroll then return end
		updatingScroll = true
		wait(1.5)
		updatingScroll = false
		scrollBar:Update()
	end
end

local Selection do
	local bindGetSelection = explorerPanel:FindFirstChild("TotallyNotGetSelection")
	if not bindGetSelection then
		bindGetSelection = Create('BindableFunction',{Name = "TotallyNotGetSelection"})
		bindGetSelection.Parent = explorerPanel
	end

	local bindSetSelection = explorerPanel:FindFirstChild("TotallyNotSetSelection")
	if not bindSetSelection then
		bindSetSelection = Create('BindableFunction',{Name = "TotallyNotSetSelection"})
		bindSetSelection.Parent = explorerPanel
	end

	local bindSelectionChanged = explorerPanel:FindFirstChild("TotallyNotSelectionChanged")
	if not bindSelectionChanged then
		bindSelectionChanged = Create('BindableEvent',{Name = "TotallyNotSelectionChanged"})
		bindSelectionChanged.Parent = explorerPanel
	end

	local SelectionList = {}
	local SelectionSet = {}
	local Updates = true
	Selection = {
		Selected = SelectionSet;
		List = SelectionList;
	}

	local function addObject(object)
		-- list update
		local lupdate = false
		-- scroll update
		local supdate = false

		if not SelectionSet[object] then
			local node = NodeLookup[GetDebugId(object)]
			if node then
				table.insert(SelectionList,object)
				SelectionSet[object] = true
				node.Selected = true

				-- expand all ancestors so that selected node becomes visible
				node = node.Parent
				while node do
					if not node.Expanded then
						node.Expanded = true
						lupdate = true
					end
					node = node.Parent
				end
				supdate = true
			end
		end
		return lupdate,supdate
	end

	function Selection:Set(objects)
		local lupdate = false
		local supdate = false

		if #SelectionList > 0 then
			for i = 1,#SelectionList do
				local object = SelectionList[i]
				local node = NodeLookup[GetDebugId(object)]
				if node then
					node.Selected = false
					SelectionSet[object] = nil
				end
			end

			SelectionList = {}
			Selection.List = SelectionList
			supdate = true
		end

		for i = 1,#objects do
			local l,s = addObject(objects[i])
			lupdate = l or lupdate
			supdate = s or supdate
		end

		if lupdate then
			rawUpdateList()
			supdate = true
		elseif supdate then
			scrollBar:Update()
		end

		if supdate then
			bindSelectionChanged:Fire()
			updateActions()
		end
	end

	function Selection:Add(object)
		local l,s = addObject(object)
		if l then
			rawUpdateList()
			if Updates then
				bindSelectionChanged:Fire()
				updateActions()
			end
		elseif s then
			scrollBar:Update()
			if Updates then
				bindSelectionChanged:Fire()
				updateActions()
			end
		end
	end

	function Selection:StopUpdates()
		Updates = false
	end

	function Selection:ResumeUpdates()
		Updates = true
		bindSelectionChanged:Fire()
		updateActions()
	end

	function Selection:Remove(object,noupdate)
		if SelectionSet[object] then
			local node = NodeLookup[GetDebugId(object)]
			if node then
				node.Selected = false
				SelectionSet[object] = nil
				for i = 1,#SelectionList do
					if compareinstances(SelectionList[i], object) then
						table.remove(SelectionList,i)
						break
					end
				end

				if not noupdate then
					scrollBar:Update()
				end
				bindSelectionChanged:Fire()
				updateActions()
			end
		end
	end

	function Selection:Get()
		return table.clone(SelectionList)
	end

	bindSetSelection.OnInvoke = function(...)
		Selection:Set(...)
	end

	bindGetSelection.OnInvoke = function()
		return Selection:Get()
	end
end

function CreateCaution(title,msg)
	local newCaution = CautionWindow
	newCaution.Visible = true
	newCaution.Title.Text = title
	newCaution.MainWindow.Desc.Text = msg
	Connect(newCaution.MainWindow.Ok.MouseButton1Up, function()
		newCaution.Visible = false
	end)
end

function CreateTableCaution(title,msg)
	if type(msg) ~= "table" then return CreateCaution(title,tostring(msg)) end
	local newCaution = TableCautionWindow:Clone()
	newCaution.Title.Text = title

	local TableList = newCaution.MainWindow.TableResults
	local TableTemplate = newCaution.MainWindow.TableTemplate

	for i,v in pairs(msg) do
		local newResult = TableTemplate:Clone()
		newResult.Type.Text = type(v)
		newResult.Value.Text = tostring(v)
		newResult.Position = UDim2.new(0,0,0,#TableList:GetChildren() * 20)
		newResult.Parent = TableList
		TableList.CanvasSize = UDim2.new(0,0,0,#TableList:GetChildren() * 20)
		newResult.Visible = true
	end
	newCaution.Parent = explorerPanel.Parent
	newCaution.Visible = true
	Connect(newCaution.MainWindow.Ok.MouseButton1Up, function()
		newCaution:Destroy()
	end)
end

local function Split(str, delimiter)
	local start = 1
	local t = {}
	while true do
		local pos = string.find(str, delimiter, start, true)
		if not pos then
			break
		end
		table.insert (t, string.sub(str, start, pos - 1))
		start = pos + string.len(delimiter)
	end
	table.insert (t, string.sub(str, start))
	return t
end

local function ToValue(value,type)
	if type == "Vector2" then
		local list = Split(value,",")
		if #list < 2 then return nil end
		local x = tonumber(list[1]) or 0
		local y = tonumber(list[2]) or 0
		return Vector2.new(x,y)
	elseif type == "Vector3" then
		local list = Split(value,",")
		if #list < 3 then return nil end
		local x = tonumber(list[1]) or 0
		local y = tonumber(list[2]) or 0
		local z = tonumber(list[3]) or 0
		return Vector3.new(x,y,z)
	elseif type == "Color3" then
		local list = Split(value,",")
		if #list < 3 then return nil end
		local r = tonumber(list[1]) or 0
		local g = tonumber(list[2]) or 0
		local b = tonumber(list[3]) or 0
		return Color3.new(r/255,g/255, b/255)
	elseif type == "UDim2" then
		local list = Split(string.gsub(string.gsub(value, "{", ""),"}",""),",")
		if #list < 4 then return nil end
		local xScale = tonumber(list[1]) or 0
		local xOffset = tonumber(list[2]) or 0
		local yScale = tonumber(list[3]) or 0
		local yOffset = tonumber(list[4]) or 0
		return UDim2.new(xScale, xOffset, yScale, yOffset)
	elseif type == "Number" then
		return tonumber(value)
	elseif type == "String" then
		return value
	elseif type == "NumberRange" then
		local list = Split(value,",")
		if #list == 1 then
			if tonumber(list[1]) == nil then return nil end
			local newVal = tonumber(list[1]) or 0
			return NumberRange.new(newVal)
		end
		if #list < 2 then return nil end
		local x = tonumber(list[1]) or 0
		local y = tonumber(list[2]) or 0
		return NumberRange.new(x,y)
	else
		return nil
	end
end

local function ToPropValue(value,type)
	if type == "Vector2" then
		local list = Split(value,",")
		if #list < 2 then return nil end
		local x = tonumber(list[1]) or 0
		local y = tonumber(list[2]) or 0
		return Vector2.new(x,y)
	elseif type == "Vector3" then
		local list = Split(value,",")
		if #list < 3 then return nil end
		local x = tonumber(list[1]) or 0
		local y = tonumber(list[2]) or 0
		local z = tonumber(list[3]) or 0
		return Vector3.new(x,y,z)
	elseif type == "Color3" then
		local list = Split(value,",")
		if #list < 3 then return nil end
		local r = tonumber(list[1]) or 0
		local g = tonumber(list[2]) or 0
		local b = tonumber(list[3]) or 0
		return Color3.new(r/255,g/255, b/255)
	elseif type == "UDim2" then
		local list = Split(string.gsub(string.gsub(value, "{", ""),"}",""),",")
		if #list < 4 then return nil end
		local xScale = tonumber(list[1]) or 0
		local xOffset = tonumber(list[2]) or 0
		local yScale = tonumber(list[3]) or 0
		local yOffset = tonumber(list[4]) or 0
		return UDim2.new(xScale, xOffset, yScale, yOffset)
	elseif type == "Content" then
		return value
	elseif type == "float" or type == "int" or type == "double" then
		return tonumber(value)
	elseif type == "string" then
		return value
	elseif type == "NumberRange" then
		local list = Split(value,",")
		if #list == 1 then
			if tonumber(list[1]) == nil then return nil end
			local newVal = tonumber(list[1]) or 0
			return NumberRange.new(newVal)
		end
		if #list < 2 then return nil end
		local x = tonumber(list[1]) or 0
		local y = tonumber(list[2]) or 0
		return NumberRange.new(x,y)
	elseif string.sub(value,1,4) == "Enum" then
		local getEnum = value
		while true do
			local x,y = string.find(getEnum,".")
			if y then
				getEnum = string.sub(getEnum,y+1)
			else
				break
			end
		end
		return getEnum
	else
		return nil
	end
end

function PromptRemoteCaller(inst)
	if CurrentRemoteWindow then
		CurrentRemoteWindow:Destroy()
		CurrentRemoteWindow = nil
	end
	CurrentRemoteWindow = RemoteWindow:Clone()
	CurrentRemoteWindow.Parent = explorerPanel.Parent
	CurrentRemoteWindow.Visible = true

	local displayValues = false

	local ArgumentList = CurrentRemoteWindow.MainWindow.Arguments
	local ArgumentTemplate = CurrentRemoteWindow.MainWindow.ArgumentTemplate

	if inst:IsA("BaseRemoteEvent") then
		CurrentRemoteWindow.Title.Text = "Fire RemoteEvent"
		CurrentRemoteWindow.MainWindow.Ok.Text = "Fire"
		CurrentRemoteWindow.MainWindow.DisplayReturned.Visible = false
		CurrentRemoteWindow.MainWindow.Desc2.Visible = false
	elseif inst:IsA("RemoteFunction") then
		CurrentRemoteWindow.Title.Text = "Fire RemoteFunction"
		CurrentRemoteWindow.MainWindow.Ok.Text = "Fire"
		CurrentRemoteWindow.MainWindow.DisplayReturned.Visible = true
		CurrentRemoteWindow.MainWindow.Desc2.Visible = true
	end

	local newArgument = ArgumentTemplate:Clone()
	newArgument.Parent = ArgumentList
	newArgument.Visible = true
	Connect(newArgument.Type.MouseButton1Down, function()
		createDDown(newArgument.Type,function(choice)
			newArgument.Type.Text = choice
		end,"Number","String","Color3","Vector3","Vector2","UDim2","NumberRange")
	end)

	Connect(CurrentRemoteWindow.MainWindow.Ok.MouseButton1Up, function()
		if CurrentRemoteWindow and inst.Parent ~= nil then
			local MyArguments = {}
			for i,v in pairs(ArgumentList:GetChildren()) do
				table.insert(MyArguments,ToValue(v.Value.Text,v.Type.Text))
			end
			if inst:IsA("RemoteFunction") then
				if displayValues then
					task.spawn(function()
						local myResults = {inst:InvokeServer(unpack(MyArguments))}
						if myResults and #myResults > 0 then
							CreateTableCaution("Remote Caller",myResults)
						else
							CreateCaution("Remote Caller","This remote did not return anything.")
						end
					end)
				else
					task.spawn(function()
						inst:InvokeServer(unpack(MyArguments))
					end)
				end
			else
				inst:FireServer(unpack(MyArguments))
			end
			CurrentRemoteWindow:Destroy()
			CurrentRemoteWindow = nil
		end
	end)

	Connect(CurrentRemoteWindow.MainWindow.Add.MouseButton1Up, function()
		if CurrentRemoteWindow then
			local newArgument = ArgumentTemplate:Clone()
			newArgument.Position = UDim2.new(0,0,0,#ArgumentList:GetChildren() * 20)
			newArgument.Parent = ArgumentList
			ArgumentList.CanvasSize = UDim2.new(0,0,0,#ArgumentList:GetChildren() * 20)
			newArgument.Visible = true
			Connect(newArgument.Type.MouseButton1Down, function()
				createDDown(newArgument.Type,function(choice)
					newArgument.Type.Text = choice
				end,"Number","String","Color3","Vector3","Vector2","UDim2","NumberRange")
			end)
		end
	end)

	Connect(CurrentRemoteWindow.MainWindow.Subtract.MouseButton1Up, function()
		if CurrentRemoteWindow then
			if #ArgumentList:GetChildren() > 1 then
				ArgumentList:GetChildren()[#ArgumentList:GetChildren()]:Destroy()
				ArgumentList.CanvasSize = UDim2.new(0,0,0,#ArgumentList:GetChildren() * 20)
			end
		end
	end)

	Connect(CurrentRemoteWindow.MainWindow.Cancel.MouseButton1Up, function()
		if CurrentRemoteWindow then
			CurrentRemoteWindow:Destroy()
			CurrentRemoteWindow = nil
		end
	end)

	Connect(CurrentRemoteWindow.MainWindow.DisplayReturned.MouseButton1Up, function()
		if displayValues then
			displayValues = false
			CurrentRemoteWindow.MainWindow.DisplayReturned.enabled.Visible = false
		else
			displayValues = true
			CurrentRemoteWindow.MainWindow.DisplayReturned.enabled.Visible = true
		end
	end)
end

function DestroyRightClick()
	if currentRightClickMenu then
		currentRightClickMenu:Destroy()
		currentRightClickMenu = nil
	end
	if CurrentInsertObjectWindow and CurrentInsertObjectWindow.Visible then
		CurrentInsertObjectWindow.Visible = false
	end
end

local tabChar = "    "

local function getSmaller(a, b, notLast)
	local aByte = a:byte() or -1
	local bByte = b:byte() or -1
	if aByte == bByte then
		if notLast and #a == 1 and #b == 1 then
			return -1
		elseif #b == 1 then
			return false
		elseif #a == 1 then
			return true
		else
			return getSmaller(a:sub(2), b:sub(2), notLast)
		end
	else
		return aByte < bByte
	end
end

local function parseData(obj, numTabs, isKey, overflow, noTables, forceDict)
	local objType = typeof(obj)
	local objStr;

	if typeof(obj) ~= "userdata" and typeof(obj) ~= "table" then
		objStr = tostring(obj)
	else
		local getmetatable = getrawmetatable or getmetatable
		local mt = getmetatable(obj)

		if typeof(mt) == "table" then
			local __tostring = rawget(mt, "__tostring")
			rawset(mt, "__tostring", nil)
			objStr = tostring(obj)
			rawset(mt, "__tostring", __tostring)
		else
			objStr = tostring(obj)
		end

		mt = nil
	end

	if objType == "table" then
		if noTables then
			return objStr
		end
		local isCyclic = overflow[obj]
		overflow[obj] = true
		local out = {}
		local nextIndex = 1
		local isDict = false
		local hasTables = false
		local data = {}

		for key, val in next, obj do
			if not hasTables and typeof(val) == "table" then
				hasTables = true
			end

			if not isDict and key ~= nextIndex then
				isDict = true
			else
				nextIndex = nextIndex + 1
			end

			data[#data+1] = {key, val}
		end

		if isDict or hasTables or forceDict then
			out[#out+1] = (isCyclic and "Cyclic " or "") .. "{"
			table.sort(data, function(a, b)
				local aType = typeof(a[2])
				local bType = typeof(b[2])
				if bType == "string" and aType ~= "string" then
					return false
				end
				local res = getSmaller(aType, bType, true)
				if res == -1 then
					return getSmaller(tostring(a[1]), tostring(b[1]))
				else
					return res
				end
			end)
			for i = 1, #data do
				local arr = data[i]
				local nowKey = arr[1]
				local nowVal = arr[2]
				local parseKey = parseData(nowKey, numTabs+1, true, overflow, isCyclic)
				local parseVal = parseData(nowVal, numTabs+1, false, overflow, isCyclic)
				if isDict then
					local nowValType = typeof(nowVal)
					local preStr = ""
					local postStr = ""
					if i > 1 and (nowValType == "table" or typeof(data[i-1][2]) ~= nowValType) then
						preStr = "\n"
					end
					if i < #data and nowValType == "table" and typeof(data[i+1][2]) ~= "table" and typeof(data[i+1][2]) == nowValType then
						postStr = "\n"
					end
					out[#out+1] = preStr .. string.rep(tabChar, numTabs+1) .. parseKey .. " = " .. parseVal .. ";" .. postStr
				else
					out[#out+1] = string.rep(tabChar, numTabs+1) .. parseVal .. ";"
				end
			end
			out[#out+1] = string.rep(tabChar, numTabs) .. "}"
		else
			local data2 = {}
			for i = 1, #data do
				local arr = data[i]
				local nowVal = arr[2]
				local parseVal = parseData(nowVal, 0, false, overflow, isCyclic)
				data2[#data2+1] = parseVal
			end
			out[#out+1] = "{" .. table.concat(data2, ", ") .. "}"
		end

		return table.concat(out, "\n")
	else
		local returnVal = nil
		if (objType == "string" or objType == "Content") and (not isKey or tonumber(obj:sub(1, 1))) then
			local retVal = '"' .. objStr .. '"'
			if isKey then
				retVal = "[" .. retVal .. "]"
			end
			returnVal = retVal
		elseif objType == "EnumItem" then
			returnVal = "Enum." .. tostring(obj.EnumType) .. "." .. obj.Name
		elseif objType == "Enum" then
			returnVal = "Enum." .. objStr
		elseif objType == "Instance" then
			returnVal = obj.Parent and obj:GetFullName() or obj.ClassName
		elseif objType == "CFrame" then
			returnVal = "CFrame.new(" .. objStr .. ")"
		elseif objType == "Vector3" then
			returnVal = "Vector3.new(" .. objStr .. ")"
		elseif objType == "Vector2" then
			returnVal = "Vector2.new(" .. objStr .. ")"
		elseif objType == "UDim2" then
			returnVal = "UDim2.new(" .. objStr:gsub("[{}]", "") .. ")"
		elseif objType == "BrickColor" then
			returnVal = "BrickColor.new(\"" .. objStr .. "\")"
		elseif objType == "Color3" then
			returnVal = "Color3.new(" .. objStr .. ")"
		elseif objType == "NumberRange" then
			returnVal = "NumberRange.new(" .. objStr:gsub("^%s*(.-)%s*$", "%1"):gsub(" ", ", ") .. ")"
		elseif objType == "PhysicalProperties" then
			returnVal = "PhysicalProperties.new(" .. objStr .. ")"
		else
			returnVal = objStr
		end
		return returnVal
	end
end

function tableToString(t)
	local success, result = pcall(function()
		return parseData(t, 0, false, {}, nil, false)
	end)
	return success and result or 'error';
end

local HasSpecial = function(string)
	return (string:match("%c") or string:match("%s") or string:match("%p")) ~= nil
end

local GetPath = function(Instance) -- ripped from some random script
	local Obj = Instance
	local string = {}
	local temp = {}
	local error = false
	local game = workspace.Parent -- :(

	while Obj ~= game do
		if Obj == nil then
			error = true
			break
		end
		table.insert(temp, Obj.Parent == game and Obj.ClassName or tostring(Obj))
		Obj = Obj.Parent
	end

	table.insert(string, "game:GetService(\"" .. temp[#temp] .. "\")")

	for i = #temp - 1, 1, -1 do
		table.insert(string, HasSpecial(temp[i]) and "[\"" .. temp[i] .. "\"]" or "." .. temp[i])
	end

	return (error and "nil -- Path contained an invalid instance" or table.concat(string, ""))
end

function rightClickMenu(sObj)

	local mouse = Players.LocalPlayer:GetMouse()

	local extra = (
		(
			compareinstances(sObj, RunningScriptsStorageMain)
			or
			compareinstances(sObj, LoadedModulesStorageMain)
			or
			compareinstances(sObj, NilStorageMain)
		)
		and 'Refresh Instances'
		or nil
	)

	currentRightClickMenu = CreateRightClickMenu(
		{
			'Cut',
			'Copy',
			'Paste Into',
			'Duplicate',
			'Delete',
			'Group',
			'Ungroup',
			'Select Children',
			'Teleport To',
			'Insert Object',
			'View Script',
			'Save Script',
			'Copy Path',
			'Call Function',
			'Call Remote',
			extra
		},
		"",
		false,
		function(option)
			if option == "Cut" then
				if not Option.Modifiable then return end
				clipboard = {}
				local list = Selection.List
				local cut = {}
				for i = 1,#list do
					local obj;

					if list[i].Archivable then
						obj = list[i]:Clone()
					else
						obj = Instance.fromExisting(list[i])
					end

					if obj then
						table.insert(clipboard,obj)
						table.insert(cut,list[i])
					end
				end
				for i = 1,#cut do
					pcall(delete,cut[i])
				end
				updateActions()
			elseif option == "Copy" then
				if not Option.Modifiable then return end
				clipboard = {}
				local list = Selection.List

				for i = 1, #list do
					table.insert(clipboard,(list[i].Archivable and list[i]:Clone() or Instance.fromExisting(list[i])))
				end

				updateActions()
			elseif option == "Paste Into" then
				if not Option.Modifiable then return end
				local parent = Selection.List[1] or workspace

				for i = 1, #clipboard do
					(clipboard[i].Archivable and clipboard[i]:Clone() or Instance.fromExisting(clipboard[i])).Parent = parent
				end
			elseif option == "Duplicate" then
				if not Option.Modifiable then return end
				local list = Selection:Get()

				for i = 1, #list do
					Instance.fromExisting(list[i]).Parent = Selection.List[1].Parent or workspace
				end
			elseif option == "Delete" then
				if not Option.Modifiable then return end
				local list = Selection:Get()

				for i = 1, #list do
					pcall(delete,list[i])
				end

				Selection:Set({})
			elseif option == "Group" then
				if not Option.Modifiable then return end
				local newModel = Instance.new("Model")
				local list = Selection:Get()
				newModel.Parent = Selection.List[1].Parent or workspace

				for i = 1, #list do
					local CanChangeParent = select(2, pcall(function() list[i].Parent = list[i] end)) == "Attempt to set " .. list[i]:GetFullName() .. " as its own parent"

					if CanChangeParent then
						list[i].Parent = newModel
					end
				end

				Selection:Set({})
			elseif option == "Ungroup" then
				if not Option.Modifiable then return end
				local ungrouped = {}
				local list = Selection:Get()

				for i = 1, #list do
					-- calling workspace:IsA("Model") returns true, so let's just do a classname check ;)
					if list[i].ClassName == "Model" then
						for i2, v2 in pairs(list[i]:GetChildren()) do
							pcall(function()
								v2.Parent = list[i].Parent or workspace
							end)

							table.insert(ungrouped,v2)
						end		
						pcall(delete,list[i])			
					end
				end

				Selection:Set({})

				if SettingsRemote:Invoke("SelectUngrouped") then
					for i,v in pairs(ungrouped) do
						Selection:Add(v)
					end
				end
			elseif option == "Select Children" then
				if not Option.Modifiable then return end
				local list = Selection:Get()
				Selection:Set({})
				Selection:StopUpdates()

				for i = 1, #list do
					for i2,v2 in pairs(list[i]:GetChildren()) do
						Selection:Add(v2)
					end
				end

				Selection:ResumeUpdates()
			elseif option == "Teleport To" then
				if not Option.Modifiable then return end
				local list = Selection:Get()
				for i = 1,#list do
					if list[i]:IsA("BasePart") then
						pcall(function()
							Players.LocalPlayer.Character.HumanoidRootPart.CFrame = list[i].CFrame * CFrame.new(0, 3, 0);
						end)
						break
					end
				end
			elseif option == 'Copy Path' then
				if not Option.Modifiable then return end
				local list = Selection:Get()
				local paths = {};
				for i = 1,#list do
					paths[#paths + 1] = GetPath(list[i]);
				end
				if #paths > 1 then
					setclipboard(tableToString(paths))
				elseif #paths == 1 then
					setclipboard(paths[1])
				end
			elseif option == "Call Remote" then
				if not Option.Modifiable then return end
				local list = Selection:Get()
				for i = 1,#list do
					if list[i]:IsA("RemoteFunction") or list[i]:IsA("BaseRemoteEvent") then
						PromptRemoteCaller(list[i])
						break
					end
				end
			elseif option == "View Script" then
				if not Option.Modifiable then return end
				local list = Selection:Get()
				for i = 1,#list do
					if list[i]:IsA("LocalScript") or list[i]:IsA("ModuleScript") or
						(list[i]:IsA("Script") and list[i].RunContext == Enum.RunContext.Client)
					then
						ScriptEditorEvent:Fire(list[i])
					end
				end
			elseif option == "Save Script" then
				if not Option.Modifiable then return end
				local list = Selection:Get()
				for i = 1,#list do
					if list[i]:IsA("LocalScript") or list[i]:IsA("ModuleScript") or
						(list[i]:IsA("Script") and list[i].RunContext == Enum.RunContext.Client)
					then
						local decompile = decompile or disassemble or getscriptbytecode or function()
							return "-- No function exists to load this script"
						end;

						-- to set
						local data = nil;

						local s, res = pcall(decompile, list[i]);

						if s then
							data = res
						else
							decompile = getscriptbytecode or function()
								return "-- An error occurred while loading this script: " .. res
							end;
							s, res = pcall(decompile, list[i]);			

							if s then
								data = "-- Function decompile failed to decompile this script, falling back to getscriptbytecode...\n\n"
									..
									res;
							else
								task.wait()
								data = "-- An error occurred while loading this script: " .. res
							end
						end

						writefile("TSDex/" .. game.PlaceId .. '_' .. list[i].Name:gsub('%W', '') .. '_' .. math.random(100000, 999999) .. '.lua', data);
					end
				end
			elseif option == 'Refresh Instances' then
				if sObj == NilStorageMain then
					for i, v in pairs(getnilinstances()) do
						if v ~= DexOutput and v ~= DexOutputMain and v ~= DexStorage and v ~= DexStorageMain and v ~= RunningScriptsStorage and v ~= RunningScriptsStorageMain and v ~= LoadedModulesStorage and v ~= LoadedModulesStorageMain and v ~= NilStorage and v ~= NilStorageMain then
							pcall(function()
								v:Clone().Parent = NilStorageMain;
							end)
						end
					end
				elseif sObj == RunningScriptsStorageMain then
					for i,v in pairs(getscripts()) do
						if v ~= RunningScriptsStorage and v ~= LoadedModulesStorage and v ~= DexStorage then
							if v:IsA("BaseScript") then
								v.Archivable = true;
								local ls = v:Clone()
								if v:IsA("LocalScript") or v:IsA("Script") then ls.Disabled = true end
								ls.Parent = RunningScriptsStorageMain
							end
						end
					end
				elseif sObj == LoadedModulesStorageMain then
					for i,v in pairs(getloadedmodules()) do
						if v ~= RunningScriptsStorage and v ~= LoadedModulesStorage and v ~= DexStorage then
							if (v:IsA'LocalScript' or v:IsA'ModuleScript' or v:IsA'Script') then
								v.Archivable = true;
								local ls = v:clone()
								if v:IsA'LocalScript' or v:IsA'Script' then ls.Disabled = true; end
								ls.Parent = LoadedModulesStorageMain
							end
						end
					end
				end
			end
		end)
	currentRightClickMenu.Parent = explorerPanel.Parent
	currentRightClickMenu.Position = UDim2.new(0,mouse.X,0,mouse.Y)
	if currentRightClickMenu.AbsolutePosition.X + currentRightClickMenu.AbsoluteSize.X > explorerPanel.AbsolutePosition.X + explorerPanel.AbsoluteSize.X then
		currentRightClickMenu.Position = UDim2.new(0, explorerPanel.AbsolutePosition.X + explorerPanel.AbsoluteSize.X - currentRightClickMenu.AbsoluteSize.X, 0, mouse.Y)
	end
end

local function cancelReparentDrag()end
local function cancelSelectDrag()end
do
	local listEntries = {}
	local nameConnLookup = {}

	local mouseDrag = Create('ImageButton',{
		Name = "MouseDrag";
		Position = UDim2.new(-.25,0,-.25,0);
		Size = UDim2.new(1.5,0,1.5,0);
		Transparency = 1;
		AutoButtonColor = false;
		Active = true;
		ZIndex = 10;
	})
	local function dragSelect(last,add,button)
		local connDrag
		local conUp

		conDrag = Connect(mouseDrag.MouseMoved, function(x,y)
			local pos = Vector2.new(x,y) - listFrame.AbsolutePosition
			local size = listFrame.AbsoluteSize
			if pos.x < 0 or pos.x > size.x or pos.y < 0 or pos.y > size.y then return end

			local i = math.ceil(pos.y/ENTRY_BOUND) + scrollBar.ScrollIndex
			-- Mouse may have made a large step, so interpolate between the
			-- last index and the current.
			for n = i<last and i or last, i>last and i or last do
				local node = TreeList[n]
				if node then
					if add then
						Selection:Add(node.Object)
					else
						Selection:Remove(node.Object)
					end
				end
			end
			last = i
		end)

		function cancelSelectDrag()
			mouseDrag.Parent = nil
			conDrag:Disconnect()
			conUp:Disconnect()
			function cancelSelectDrag()end
		end

		conUp = Connect(mouseDrag[button], cancelSelectDrag)

		mouseDrag.Parent = GetScreen(listFrame)
	end

	local function dragReparent(object,dragGhost,clickPos,ghostOffset)
		local connDrag
		local conUp
		local conUp2

		local parentIndex = nil
		local dragged = false

		local parentHighlight = Create('Frame',{
			Transparency = 1;
			Visible = false;
			Create('Frame',{
				BorderSizePixel = 0;
				BackgroundColor3 = Color3.new(0,0,0);
				BackgroundTransparency = 0.1;
				Position = UDim2.new(0,0,0,0);
				Size = UDim2.new(1,0,0,1);
			});
			Create('Frame',{
				BorderSizePixel = 0;
				BackgroundColor3 = Color3.new(0,0,0);
				BackgroundTransparency = 0.1;
				Position = UDim2.new(1,0,0,0);
				Size = UDim2.new(0,1,1,0);
			});
			Create('Frame',{
				BorderSizePixel = 0;
				BackgroundColor3 = Color3.new(0,0,0);
				BackgroundTransparency = 0.1;
				Position = UDim2.new(0,0,1,0);
				Size = UDim2.new(1,0,0,1);
			});
			Create('Frame',{
				BorderSizePixel = 0;
				BackgroundColor3 = Color3.new(0,0,0);
				BackgroundTransparency = 0.1;
				Position = UDim2.new(0,0,0,0);
				Size = UDim2.new(0,1,1,0);
			});
		})
		SetZIndex(parentHighlight,9)

		conDrag = Connect(mouseDrag.MouseMoved, function(x,y)
			local dragPos = Vector2.new(x,y)
			if dragged then
				local pos = dragPos - listFrame.AbsolutePosition
				local size = listFrame.AbsoluteSize

				parentIndex = nil
				parentHighlight.Visible = false
				if pos.x >= 0 and pos.x <= size.x and pos.y >= 0 and pos.y <= size.y + ENTRY_SIZE*2 then
					local i = math.ceil(pos.y/ENTRY_BOUND-2)
					local node = TreeList[i + scrollBar.ScrollIndex]
					if node and not compareinstances(node.Object, object) and not object:IsAncestorOf(node.Object) then
						parentIndex = i
						local entry = listEntries[i]
						if entry then
							parentHighlight.Visible = true
							parentHighlight.Position = UDim2.new(0,1,0,entry.AbsolutePosition.y-listFrame.AbsolutePosition.y)
							parentHighlight.Size = UDim2.new(0,size.x-4,0,entry.AbsoluteSize.y)
						end
					end
				end

				dragGhost.Position = UDim2.new(0,dragPos.x+ghostOffset.x,0,dragPos.y+ghostOffset.y)
			elseif (clickPos-dragPos).magnitude > 8 then
				dragged = true
				SetZIndex(dragGhost,9)
				dragGhost.IndentFrame.Transparency = .25
				dragGhost.IndentFrame.EntryText.TextColor3 = GuiColor.TextSelected
				dragGhost.Position = UDim2.new(0,dragPos.x+ghostOffset.x,0,dragPos.y+ghostOffset.y)
				dragGhost.Parent = GetScreen(listFrame)
				parentHighlight.Parent = listFrame
			end
		end)

		function cancelReparentDrag()
			mouseDrag.Parent = nil
			conDrag:Disconnect()
			conUp:Disconnect()
			conUp2:Disconnect()
			dragGhost:Destroy()
			parentHighlight:Destroy()
			function cancelReparentDrag()end
		end

		local wasSelected = Selection.Selected[object]
		if not wasSelected and Option.Selectable then
			Selection:Set({object})
		end

		conUp = Connect(mouseDrag.MouseButton1Up, function()
			cancelReparentDrag()
			if dragged then
				if parentIndex then
					local parentNode = TreeList[parentIndex + scrollBar.ScrollIndex]
					if parentNode then
						parentNode.Expanded = true

						local parentObj = parentNode.Object
						local function parent(a,b)
							a.Parent = b
						end
						if Option.Selectable then
							local list = Selection.List
							for i = 1,#list do
								pcall(parent,list[i],parentObj)
							end
						else
							pcall(parent,object,parentObj)
						end
					end
				end
			else
				-- do selection click
				if wasSelected and Option.Selectable then
					Selection:Set({})
				end
			end
		end)
		conUp2 = Connect(mouseDrag.MouseButton2Down, function()
			cancelReparentDrag()
		end)

		mouseDrag.Parent = GetScreen(listFrame)
	end

	local entryTemplate = Create('ImageButton',{
		Name = "Entry";
		Transparency = 1;
		AutoButtonColor = false;
		Position = UDim2.new(0,0,0,0);
		Size = UDim2.new(1,0,0,ENTRY_SIZE);
		Create('Frame',{
			Name = "IndentFrame";
			BackgroundTransparency = 1;
			BackgroundColor3 = GuiColor.Selected;
			BorderColor3 = GuiColor.BorderSelected;
			Position = UDim2.new(0,0,0,0);
			Size = UDim2.new(1,0,1,0);
			Create("ImageButton",{
				Name = "Expand";
				AutoButtonColor = false;
				BackgroundTransparency = 1;
				Position = UDim2.new(0,-GUI_SIZE,0.5,-GUI_SIZE/2);
				Size = UDim2.new(0,GUI_SIZE,0,GUI_SIZE);
			});
			Create(Icon(nil,0),{
				Name = "ExplorerIcon";
				Position = UDim2.new(0,2+ENTRY_PADDING,0.5,-GUI_SIZE/2);
				Size = UDim2.new(0,GUI_SIZE,0,GUI_SIZE);
			});
			Create('TextLabel',{
				Name = "EntryText";
				BackgroundTransparency = 1;
				TextColor3 = GuiColor.Text;
				TextXAlignment = 'Left';
				TextYAlignment = 'Center';
				Font = FONT;
				FontSize = FONT_SIZE;
				Text = "";
				Position = UDim2.new(0,2+ENTRY_SIZE+4,0,0);
				Size = UDim2.new(1,-2,1,0);
			});
		});
	})

	function scrollBar.UpdateCallback(self)
		for i = 1,self.VisibleSpace do
			local node = TreeList[i + self.ScrollIndex]
			if node then
				local entry = listEntries[i]
				if not entry then
					entry = Create(entryTemplate:Clone(),{
						Position = UDim2.new(0,2,0,ENTRY_BOUND*(i-1)+2);
						Size = UDim2.new(0,nodeWidth,0,ENTRY_SIZE);
						ZIndex = listFrame.ZIndex;
					})
					listEntries[i] = entry

					local expand = entry.IndentFrame.Expand
					Connect(expand.MouseEnter, function()
						local node = TreeList[i + self.ScrollIndex]
						if #node > 0 then
							if node.Expanded then
								expand.Image = NODE_EXPANDED
							else
								expand.Image = NODE_COLLAPSED
							end
						end
					end)
					Connect(expand.MouseLeave, function()
						local node = TreeList[i + self.ScrollIndex]

						if not node then
							local a = tick()

							repeat
								node = TreeList[i + self.ScrollIndex]
								task.wait()
							until node or tick() - a > 1
						end

						if #node > 0 then
							if node.Expanded then
								expand.Image = NODE_EXPANDED
							else
								expand.Image = NODE_COLLAPSED
							end
						end
					end)
					Connect(expand.MouseButton1Down, function()
						local node = TreeList[i + self.ScrollIndex]

						if not node then
							local a = tick()

							repeat
								node = TreeList[i + self.ScrollIndex]
								task.wait()
							until node or tick() - a > 1
						end

						if #node > 0 then
							node.Expanded = not node.Expanded
							if compareinstances(node.Object, explorerPanel.Parent) and node.Expanded then
								CreateCaution("Warning","Please be careful when editing instances inside here, this is like the System32 of Dex and modifying objects here can break Dex.")
							end
							-- use raw update so the list updates instantly
							rawUpdateList()
						end
					end)

					Connect(entry.MouseButton1Down, function(x,y)
						local node = TreeList[i + self.ScrollIndex]
						DestroyRightClick()
						if GetAwaitRemote:Invoke() then
							bindSetAwaiting:Fire(node.Object)
							return
						end

						if not HoldingShift then
							lastSelectedNode = i + self.ScrollIndex
						end

						if HoldingShift and not filteringWorkspace() then
							if lastSelectedNode then
								if i + self.ScrollIndex - lastSelectedNode > 0 then
									Selection:StopUpdates()
									for i2 = 1, i + self.ScrollIndex - lastSelectedNode do
										local newNode = TreeList[lastSelectedNode + i2]
										if newNode then
											Selection:Add(newNode.Object)
										end
									end
									Selection:ResumeUpdates()
								else
									Selection:StopUpdates()
									for i2 = i + self.ScrollIndex - lastSelectedNode, 1 do
										local newNode = TreeList[lastSelectedNode + i2]
										if newNode then
											Selection:Add(newNode.Object)
										end
									end
									Selection:ResumeUpdates()
								end
							end
							return
						end

						if HoldingCtrl then
							if Selection.Selected[node.Object] then
								Selection:Remove(node.Object)
							else
								Selection:Add(node.Object)
							end
							return
						end
						if Option.Modifiable then
							local pos = Vector2.new(x,y)
							dragReparent(node.Object,entry:Clone(),pos,entry.AbsolutePosition-pos)
						elseif Option.Selectable then
							if Selection.Selected[node.Object] then
								Selection:Set({})
							else
								Selection:Set({node.Object})
							end
							dragSelect(i+self.ScrollIndex,true,'MouseButton1Up')
						end
					end)

					Connect(entry.MouseButton2Down, function()
						if not Option.Selectable then return end

						DestroyRightClick()

						curSelect = entry

						local node = TreeList[i + self.ScrollIndex]

						if GetAwaitRemote:Invoke() then
							bindSetAwaiting:Fire(node.Object)
							return
						end

						if not Selection.Selected[node.Object] then
							Selection:Set({node.Object})
						end
					end)


					Connect(entry.MouseButton2Up, function()
						if not Option.Selectable then return end

						local node = TreeList[i + self.ScrollIndex]

						if checkMouseInGui(curSelect) then
							rightClickMenu(node.Object)
						end
					end)

					entry.Parent = listFrame
				end

				entry.Visible = true

				local object = node.Object

				-- update expand icon
				if #node == 0 then
					entry.IndentFrame.Expand.Visible = false
				elseif node.Expanded then
					entry.IndentFrame.Expand.Image = NODE_EXPANDED
					entry.IndentFrame.Expand.Visible = true
				else
					entry.IndentFrame.Expand.Image = NODE_COLLAPSED
					entry.IndentFrame.Expand.Visible = true
				end

				-- update explorer icon
				Icon(entry.IndentFrame.ExplorerIcon,ExplorerIndex[object.ClassName] or 0)

				-- update indentation
				local w = (node.Depth)*(2+ENTRY_PADDING+GUI_SIZE)
				entry.IndentFrame.Position = UDim2.new(0,w,0,0)
				entry.IndentFrame.Size = UDim2.new(1,-w,1,0)

				-- update name change detection
				if nameConnLookup[entry] then
					nameConnLookup[entry]:Disconnect()
				end
				local text = entry.IndentFrame.EntryText
				text.Text = object.Name
				nameConnLookup[entry] = Connect(node.Object.Changed, function(p)
					if p == 'Name' then
						text.Text = object.Name
					end
				end)

				-- update selection
				entry.IndentFrame.Transparency = node.Selected and 0 or 1
				text.TextColor3 = GuiColor[node.Selected and 'TextSelected' or 'Text']

				entry.Size = UDim2.new(0,nodeWidth,0,ENTRY_SIZE)
			elseif listEntries[i] then
				listEntries[i].Visible = false
			end
		end
		for i = self.VisibleSpace+1,self.TotalSpace do
			local entry = listEntries[i]
			if entry then
				listEntries[i] = nil
				entry:Destroy()
			end
		end
	end

	function scrollBarH.UpdateCallback(self)
		for i = 1,scrollBar.VisibleSpace do
			local node = TreeList[i + scrollBar.ScrollIndex]
			if node then
				local entry = listEntries[i]
				if entry then
					entry.Position = UDim2.new(0,2 - scrollBarH.ScrollIndex,0,ENTRY_BOUND*(i-1)+2)
				end
			end
		end
	end

	Connect(listFrame.Changed,function(p)
		if p == 'AbsoluteSize' then
			rawUpdateSize()
		end
	end)

	local wheelAmount = 6
	Connect(explorerPanel.MouseWheelForward, function()
		if scrollBar.VisibleSpace - 1 > wheelAmount then
			scrollBar:ScrollTo(scrollBar.ScrollIndex - wheelAmount)
		else
			scrollBar:ScrollTo(scrollBar.ScrollIndex - scrollBar.VisibleSpace)
		end
	end)
	Connect(explorerPanel.MouseWheelBackward, function()
		if scrollBar.VisibleSpace - 1 > wheelAmount then
			scrollBar:ScrollTo(scrollBar.ScrollIndex + wheelAmount)
		else
			scrollBar:ScrollTo(scrollBar.ScrollIndex + scrollBar.VisibleSpace)
		end
	end)
end

----------------------------------------------------------------
----------------------------------------------------------------
----------------------------------------------------------------
----------------------------------------------------------------
---- Object detection

-- Inserts `v` into `t` at `i`. Also sets `Index` field in `v`.
local function insert(t,i,v)
	for n = #t,i,-1 do
		local v = t[n]
		v.Index = n+1
		t[n+1] = v
	end
	v.Index = i
	t[i] = v
end

-- Removes `i` from `t`. Also sets `Index` field in removed value.
local function remove(t,i)
	local v = t[i]
	for n = i+1,#t do
		local v = t[n]
		v.Index = n-1
		t[n-1] = v
	end
	t[#t] = nil
	v.Index = 0
	return v
end

-- Returns how deep `o` is in the tree.
local function depth(o)
	local d = -1
	while o do
		o = o.Parent
		d = d + 1
	end
	return d
end


local connLookup = {}

-- Returns whether a node would be present in the tree list
local function nodeIsVisible(node)
	local visible = true
	node = node.Parent
	while node and visible do
		visible = visible and node.Expanded
		node = node.Parent
	end
	return visible
end

-- Removes an object's tree node. Called when the object stops existing in the
-- game tree.
local function removeObject(object)
	local debugid = GetDebugId(object)

	local objectNode = NodeLookup[debugid]
	if not objectNode then
		return
	end

	local visible = nodeIsVisible(objectNode)

	Selection:Remove(object,true)

	local parent = objectNode.Parent
	remove(parent,objectNode.Index)
	NodeLookup[debugid] = nil
	connLookup[debugid]:Disconnect()
	connLookup[debugid] = nil

	if visible then
		updateList()
	elseif nodeIsVisible(parent) then
		updateScroll()
	end
end

-- Moves a tree node to a new parent. Called when an existing object's parent
-- changes.
local function moveObject(object,parent)
	local objectNode = NodeLookup[GetDebugId(object)]
	if not objectNode then
		return
	end

	local parentNode = NodeLookup[GetDebugId(parent)]
	if not parentNode then
		return
	end

	local visible = nodeIsVisible(objectNode)

	remove(objectNode.Parent,objectNode.Index)
	objectNode.Parent = parentNode

	objectNode.Depth = depth(object)
	local function r(node,d)
		for i = 1,#node do
			node[i].Depth = d
			r(node[i],d+1)
		end
	end
	r(objectNode,objectNode.Depth+1)

	insert(parentNode,#parentNode+1,objectNode)

	if visible or nodeIsVisible(objectNode) then
		updateList()
	elseif nodeIsVisible(objectNode.Parent) then
		updateScroll()
	end
end

local InstanceBlacklist = {
	'Instance';
	'VRService';
	'ContextActionService';
	'AssetService';
	'TouchInputService';
	'FilteredSelection';
	'MeshContentProvider';
	'SolidModelContentProvider';
	'AnalyticsService';
	'RobloxReplicatedStorage';
	'GamepadService';
	'HapticService';
	'ChangeHistoryService';
	'Visit';
	'SocialService';
	'SpawnerService';
	'FriendService';
	'Geometry';
	'BadgeService';
	'PhysicsService';
	'CollectionService';
	'TeleportService';
	'HttpRbxApiService';
	'TweenService';
	'TextService';
	'NotificationService';
	'AdService';
	'CSGDictionaryService';
	'ControllerService';
	'RuntimeScriptService';
	'ScriptService';
	'MouseService';
	'KeyboardService';
	'CookiesService';
	'TimerService';
	'GamePassService';
	'KeyframeSequenceProvider';
	'NonReplicatedCSGDictionaryService';
	'GuidRegistryService';
	'PathfindingService';
	'GroupService';
	'MessageBusService';
}

for i, v in ipairs(InstanceBlacklist) do
	InstanceBlacklist[v] = true;
	InstanceBlacklist[i] = nil;
end

-- ScriptContext['/Libraries/LibraryRegistration/LibraryRegistration']
-- This RobloxLocked object lets me index its properties for some reason

local function check(object)
	return object.AncestryChanged
end

-- Creates a new tree node from an object. Called when an object starts
-- existing in the game tree.

local function addObject(object,noupdate)
	if (object == nil or object.Parent == nil) or (object.Parent == game and InstanceBlacklist[object.ClassName] or object.ClassName == '') then
		return;
	end

	if script then
		-- protect against naughty RobloxLocked objects
		local s = pcall(check,object)
		if not s then
			return
		end
	end

	local debugid = GetDebugId(object)
	local parentdebugid = GetDebugId(object.Parent)

	local parentNode = NodeLookup[parentdebugid]
	if not parentNode then
		return
	end

	local objectNode = {
		Object = object; -- since this is cloneref'd by default we need not cloneref it here
		Parent = parentNode;
		Index = 0;
		Expanded = false;
		Selected = false;
		Depth = depth(object);
	}

	connLookup[debugid] = object.AncestryChanged:Connect(function(c,p)
		if compareinstances(c, object) then
			if p == nil then
				removeObject(c)
			else
				moveObject(c,p)
			end
		end
	end)

	NodeLookup[debugid] = objectNode
	insert(parentNode,#parentNode+1,objectNode)
	
	if not noupdate then
		if nodeIsVisible(objectNode) then
			updateList()
		elseif nodeIsVisible(objectNode.Parent) then
			updateScroll()
		end
	end
end

local function makeObject(obj,par)
	local newObject = Instance.new(obj.ClassName)
	for i,v in pairs(obj.Properties) do
		pcall(function()
			local newProp
			newProp = ToPropValue(v.Value,v.Type)
			newObject[v.Name] = newProp
		end)
	end
	newObject.Parent = par
end

local function writeObject(obj)
	local newObject = {ClassName = obj.ClassName, Properties = {}}
	for i,v in pairs(RbxApi.GetProperties(obj.className)) do
		if v["Name"] ~= "Parent" then
			table.insert(newObject.Properties,{Name = v["Name"], Type = v["ValueType"].Name, Value = tostring(obj[v["Name"]])})
		end
	end
	return newObject
end

local function buildDexStorage()
	local localDexStorage

	local success,err = pcall(function()
		localDexStorage = game:GetObjects("rbxasset://DexStorage.rbxm")[1]
	end)

	if success and localDexStorage then
		for i,v in pairs(localDexStorage:GetChildren()) do
			pcall(function()
				v.Parent = DexStorageMain
			end)
		end
	end

	updateDexStorageListeners()
	--[[
	local localDexStorage = readfile(getelysianpath().."DexStorage.txt")--game:GetService("CookiesService"):GetCookieValue("DexStorage")
	--local success,err = pcall(function()
		if localDexStorage then
			local objTable = game:GetService("HttpService"):JSONDecode(localDexStorage)
			for i,v in pairs(objTable) do
				makeObject(v,DexStorageMain)
			end
		end
	--end)
	--]]
end

local dexStorageDebounce = false
local dexStorageListeners = {}

local function updateDexStorage()
	if dexStorageDebounce then return end
	dexStorageDebounce = true	

	task.wait()

	pcall(function()
		-- saveinstance("content//DexStorage.rbxm",DexStorageMain)
	end)

	updateDexStorageListeners()

	dexStorageDebounce = false
	--[[
	local success,err = pcall(function()
		local objs = {}
		for i,v in pairs(DexStorageMain:GetChildren()) do
			table.insert(objs,writeObject(v))
		end
		writefile(getelysianpath().."DexStorage.txt",game:GetService("HttpService"):JSONEncode(objs))
		--game:GetService("CookiesService"):SetCookieValue("DexStorage",game:GetService("HttpService"):JSONEncode(objs))
	end)
	if err then
		CreateCaution("DexStorage Save Fail!","DexStorage broke! If you see this message, report to Raspberry Pi!")
	end
	--]]
end

function updateDexStorageListeners()
	for i,v in pairs(dexStorageListeners) do
		v:Disconnect()
	end
	dexStorageListeners = {}
	for i,v in pairs(DexStorageMain:GetChildren()) do
		pcall(function()
			local ev = Connect(v.Changed, updateDexStorage)
			table.insert(dexStorageListeners,ev)
		end)
	end
end

do
	NodeLookup[GetDebugId(workspace.Parent)] = {
		Object = workspace.Parent;
		Parent = nil;
		Index = 0;
		Expanded = true;
	}

	NodeLookup[GetDebugId(DexOutput)] = {
		Object = DexOutput;
		Parent = nil;
		Index = 0;
		Expanded = true;
	}

	if DexStorageEnabled then
		NodeLookup[GetDebugId(DexStorage)] = {
			Object = DexStorage;
			Parent = nil;
			Index = 0;
			Expanded = true;
		}
	end

	if NilStorageEnabled then
		NodeLookup[GetDebugId(NilStorage)] = {
			Object = NilStorage;
			Parent = nil;
			Index = 0;
			Expanded = true;
		}
	end

	if RunningScriptsStorageEnabled then
		NodeLookup[GetDebugId(RunningScriptsStorage)] = {
			Object = RunningScriptsStorage;
			Parent = nil;
			Index = 0;
			Expanded = true;
		}
	end

	if LoadedModulesStorageEnabled then
		NodeLookup[GetDebugId(LoadedModulesStorage)] = {
			Object = LoadedModulesStorage;
			Parent = nil;
			Index = 0;
			Expanded = true;
		}
	end

	-- Connects a function to an event such that it fires asynchronously
	local function Connect(event,func)
		return event:Connect(function(...)
			task.spawn(func, ...)
		end)
	end

	Connect(game.DescendantAdded,function(a) addObject(cloneref(a)) end)
	Connect(game.DescendantRemoving,removeObject)

	Connect(DexOutput.DescendantAdded,function(a) addObject(cloneref(a)) end)
	Connect(DexOutput.DescendantRemoving,removeObject)

	if DexStorageEnabled then
		--[[if readfile(getelysianpath().."DexStorage.txt") == nil then
			writefile(getelysianpath().."DexStorage.txt","")
		end

		buildDexStorage()]]

		Connect(DexStorage.DescendantAdded,function(a) addObject(cloneref(a)) end)
		Connect(DexStorage.DescendantRemoving,removeObject)

		Connect(DexStorage.DescendantAdded,updateDexStorage)
		Connect(DexStorage.DescendantRemoving,updateDexStorage)
	end

	if NilStorageEnabled then
		Connect(NilStorage.DescendantAdded,function(a) addObject(cloneref(a)) end)
		Connect(NilStorage.DescendantRemoving,removeObject)	

		--[[local currentTable = get_nil_instances()	
		
		spawn(function()
			while task.wait() do
				if #currentTable ~= #get_nil_instances() then
					currentTable = get_nil_instances()
					--NilStorageMain:ClearAllChildren()
					for i,v in pairs(get_nil_instances()) do
						if v ~= NilStorage and v ~= DexStorage then
							pcall(function()
								v.Parent = NilStorageMain
							end)
							--[ [
							local newNil = v
							newNil.Archivable = true
							newNil:Clone().Parent = NilStorageMain
							-- ] ]
						end
					end
				end
			end
		end)]]
	end
	if RunningScriptsStorageEnabled then
		Connect(RunningScriptsStorage.DescendantAdded,function(a) addObject(cloneref(a)) end)
		Connect(RunningScriptsStorage.DescendantRemoving,removeObject)
	end
	if LoadedModulesStorageEnabled then
		Connect(LoadedModulesStorage.DescendantAdded,function(a) addObject(cloneref(a)) end)
		Connect(LoadedModulesStorage.DescendantRemoving,removeObject)
	end

	local function get(o)
		return o:GetDescendants()
	end

	local StarterClassNames = {
		[1] = "Workspace", [2] = "Players", [3] = "CoreGui", [4] = "Lighting", [5] = "NetworkClient",
		[6] = "ReplicatedFirst", [7] = "ReplicatedStorage", [8] = "StarterGui", [9] = "StarterPack",
		[10] = "StarterPlayer", [11] = "Teams", [12] = "SoundService", [13] = "TestService", [14] = "Stats",
	}

	for hey, class in ipairs(StarterClassNames) do
		addObject(cloneref(game:GetService(class)), true)
	end

	local function r(o)
		local s,children = pcall(get, o)
		if s then
			for i, v in pairs(children) do
				if not table.find(StarterClassNames, v.ClassName) then
					addObject(cloneref(v), true);
				end
			end
		end
	end

	r(workspace.Parent)
	r(DexOutput)
	if DexStorageEnabled then
		r(DexStorage)
	end
	if NilStorageEnabled then
		r(NilStorage)
	end
	if RunningScriptsStorageEnabled then
		r(RunningScriptsStorage)
	end
	if LoadedModulesStorageEnabled then
		r(LoadedModulesStorage)
	end

	scrollBar.VisibleSpace = math.ceil(listFrame.AbsoluteSize.y/ENTRY_BOUND)
	updateList()
end

function SelectionVar()
	return Selection
end

Connect(Input.InputBegan, function(key)
	if key.KeyCode == Enum.KeyCode.LeftControl then
		HoldingCtrl = true
	end
	if key.KeyCode == Enum.KeyCode.LeftShift then
		HoldingShift = true
	end
end)

Connect(Input.InputEnded, function(key)
	if key.KeyCode == Enum.KeyCode.LeftControl then
		HoldingCtrl = false
	end
	if key.KeyCode == Enum.KeyCode.LeftShift then
		HoldingShift = false
	end
end)

Connect(explorerFilter.FocusLost, function(EnterPressed)
	if EnterPressed then
		rawUpdateList()
	end
end)

CurrentInsertObjectWindow = CreateInsertObjectMenu(
	GetClasses(),
	"",
	false,
	function(option)
		CurrentInsertObjectWindow.Visible = false
		local list = SelectionVar():Get()
		for i = 1,#list do
			pcall(function() Instance.new(option,list[i]) end)
		end
		DestroyRightClick()
	end
)
