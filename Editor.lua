local script = ...

local editor = script.Parent;
local bindable = editor:WaitForChild("OpenScript");

local SaveScript = editor:WaitForChild("TopBar"):WaitForChild("Other"):WaitForChild('SaveScript')
local CopyScript = editor:WaitForChild("TopBar"):WaitForChild("Other"):WaitForChild('CopyScript');
local ClearScript = editor:WaitForChild("TopBar"):WaitForChild("Other"):WaitForChild('ClearScript');
local CloseEditor = editor:WaitForChild("TopBar"):WaitForChild("Close");
local FileName = editor:WaitForChild("TopBar"):WaitForChild("Other"):WaitForChild('FileName');
local Title	= editor:WaitForChild("TopBar"):WaitForChild("title");

local cache = {};
local GetDebugId = clonefunction(game.GetDebugId);

local dragger = {}; do
	local Players = cloneref(game:GetService("Players"))
	local mouse = Players.LocalPlayer:GetMouse();
	local inputService = cloneref(game:GetService('UserInputService'));
	local RunService = cloneref(game:GetService("RunService"));
	-- // credits to Ririchi / Inori for this cute drag function :)
	function dragger.new(frame)
		frame.Draggable = false;

		local s, event = pcall(function()
			return frame.MouseEnter
		end)

		if s then
			frame.Active = true;

			event:connect(function()
				local input = frame.InputBegan:connect(function(key)
					if key.UserInputType == Enum.UserInputType.MouseButton1 then
						local objectPosition = Vector2.new(mouse.X - frame.AbsolutePosition.X, mouse.Y - frame.AbsolutePosition.Y);
						while RunService.Heartbeat:wait() and inputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
							pcall(function()
								frame:TweenPosition(UDim2.new(0, mouse.X - objectPosition.X + (frame.Size.X.Offset * frame.AnchorPoint.X), 0, mouse.Y - objectPosition.Y + (frame.Size.Y.Offset * frame.AnchorPoint.Y)), 'Out', 'Quad', 0.1, true);
							end)
						end
					end
				end)

				local leave;
				leave = frame.MouseLeave:connect(function()
					input:disconnect();
					leave:disconnect();
				end)
			end)
		end
	end
end

dragger.new(editor)

local newline, tab = "\n", "\t"
local TabText = (" "):rep(4)
local min, max, floor, ceil = math.min, math.max, math.floor, math.ceil
local sub, gsub, match, gmatch, find = string.sub, string.gsub, string.match, string.gmatch, string.find
local toNumber = tonumber
local udim2 = UDim2.new
local newInst = Instance.new
local SplitCacheResult, SplitCacheStr, SplitCacheDel
function Split(str, del)
	if SplitCacheStr == str and SplitCacheDel == del then
		return SplitCacheResult
	end
	local res = {}
	if #del == 0 then
		for i in gmatch(str, ".") do
			res[#res + 1] = i
		end
	else
		local i = 0
		local Si = 1
		local si
		str = str .. del
		while i do
			si, Si, i = i, find(str, del, i + 1, true)
			if i == nil then
				return res
			end
			res[#res + 1] = sub(str, si + 1, Si - 1)
		end
	end
	SplitCacheResult, SplitCacheStr, SplitCacheDel = res, str, del
	return res
end
local Place = {}
function Place.new(X, Y)
	return {X = X, Y = Y}
end

local Lexer; do
	local find, match, rep, sub = string.find, string.match, string.rep, string.sub
	local lua_builtin = {
		"assert",
		"collectgarbage",
		"error",
		"_G",
		"gcinfo",
		"getfenv",
		"getmetatable",
		"ipairs",
		"loadstring",
		"newproxy",
		"next",
		"PathWaypoint",
		"Path2DControlPoint",
		"PhysicalProperties",
		"pairs",
		"pcall",
		"print",
		"printidentity",
		"rawequal",
		"rawget",
		"rawset",
		"select",
		"setfenv",
		"setmetatable",
		"tonumber",
		"tostring",
		"type",
		"typeof",
		"unpack",
		"_VERSION",
		"version",
		"Version",
		"xpcall",
		"delay",
		"Delay",
		"DockWidgetPluginGuiInfo",
		"DateTime",
		"DateTime.fromUnixTimestamp",
		"DateTime.now",
		"DateTime.fromIsoDate",
		"DateTime.fromUnixTimestampMillis",
		"DateTime.fromLocalTime",
		"DateTime.fromUniversalTime",
		"task",
		"task.defer",
		"task.cancel",
		"task.wait",
		"task.desynchronize",
		"task.synchronize",
		"task.delay",
		"task.spawn",
		"elapsedTime",
		"ElapsedTime",
		"require",
		"spawn",
		"Spawn",
		"tick",
		"time",
		"typeof",
		"UserSettings",
		"wait",
		"warn",
		"game",
		"Enum",
		"script",
		"shared",
		"workspace",
		"Axes",
		"bit32",
		"bit32.band",
		"bit32.extract",
		"bit32.byteswap",
		"bit32.bor",
		"bit32.bnot",
		"bit32.countrz",
		"bit32.bxor",
		"bit32.arshift",
		"bit32.rshift",
		"bit32.rrotate",
		"bit32.replace",
		"bit32.lshift",
		"bit32.lrotate",
		"bit32.btest",
		"bit32.countlz",
		"buffer",
		"buffer.readf64",
		"buffer.readu32",
		"buffer.tostring",
		"buffer.readi8",
		"buffer.readu16",
		"buffer.copy",
		"buffer.readu8",
		"buffer.writei16",
		"buffer.writeu16",
		"buffer.fromstring",
		"buffer.readi32",
		"buffer.fill",
		"buffer.writeu32",
		"buffer.writeu8",
		"buffer.create",
		"buffer.writestring",
		"buffer.writei8",
		"buffer.writef32",
		"buffer.readi16",
		"buffer.writef64",
		"buffer.len",
		"buffer.writei32",
		"buffer.readstring",
		"buffer.readf32",
		"BrickColor",
		"CFrame",
		"Color3",
		"ColorSequence",
		"ColorSequenceKeypoint",
		"CatalogSearchParams",
		"Faces",
		"FloatCurveKey",
		"Font",
		"Font.fromId",
		"Font.fromEnum",
		"Font.fromName",
		"Instance",
		"Instance.new",
		"Instance.fromExisting",
		"NumberRange",
		"NumberSequence",
		"NumberSequenceKeypoint",
		"Random",
		"Ray",
		"RotationCurveKey",
		"RaycastParams",
		"Rect",
		"Region3",
		"Region3int16",
		"TweenInfo",
		"utf8",
		"utf8.char",
		"UDim",
		"UDim2",
		"Vector2",
		"Vector3",
		"Vector3int16",
		"next",
		"OverlapParams",
		"os",
		"os.clock",
		"os.time",
		"os.date",
		"os.difftime",
		"debug",
		"debug.dumpheap",
		"debug.getmemorycategory",
		"debug.resetmemorycategory",
		"debug.setmemorycategory",
		"debug.dumpcodesize",
		"debug.profilebegin",
		"debug.loadmodule",
		"debug.profileend",
		"debug.info",
		"debug.dumprefs",
		"debug.traceback",
		"math",
		"math.abs",
		"math.acos",
		"math.asin",
		"math.atan",
		"math.atan2",
		"math.ceil",
		"math.clamp",
		"math.cos",
		"math.cosh",
		"math.deg",
		"math.exp",
		"math.floor",
		"math.fmod",
		"math.frexp",
		"math.ldexp",
		"math.log",
		"math.log10",
		"math.max",
		"math.min",
		"math.modf",
		"math.noise",
		"math.pow",
		"math.rad",
		"math.random",
		"math.randomseed",
		"math.sign",
		"math.sin",
		"math.sinh",
		"math.sqrt",
		"math.tan",
		"math.tanh",
		"coroutine",
		"coroutine.create",
		"coroutine.resume",
		"coroutine.running",
		"coroutine.status",
		"coroutine.wrap",
		"coroutine.yield",
		"coroutine.close",
		"coroutine.isyieldable",
		"stats",
		"Stats",
		"string",
		"string.split",
		"string.match",
		"string.gmatch",
		"string.upper",
		"string.gsub",
		"string.format",
		"string.lower",
		"string.sub",
		"string.pack",
		"string.find",
		"string.char",
		"string.packsize",
		"string.reverse",
		"string.byte",
		"string.unpack",
		"string.rep",
		"string.len",
		"table",
		"table.getn",
		"table.foreachi",
		"table.foreach",
		"table.sort",
		"table.unpack",
		"table.freeze",
		"table.clear",
		"table.pack",
		"table.move",
		"table.insert",
		"table.create",
		"table.maxn",
		"table.isfrozen",
		"table.concat",
		"table.clone",
		"table.find",
		"table.remove",
	}
	local Keywords = {
		["and"] = true,
		["break"] = true,
		["do"] = true,
		["else"] = true,
		["elseif"] = true,
		["end"] = true,
		["false"] = true,
		["for"] = true,
		["function"] = true,
		["if"] = true,
		["in"] = true,
		["local"] = true,
		["nil"] = true,
		["not"] = true,
		["or"] = true,
		["repeat"] = true,
		["return"] = true,
		["then"] = true,
		["true"] = true,
		["until"] = true,
		["continue"] = true,
		["while"] = true,
		["self"] = true;
	}
	local Tokens = {
		Comment = 1,
		Keyword = 2,
		Number = 3,
		Operator = 4,
		String = 5,
		Identifier = 6,
		Builtin = 7,
		Symbol = 19400
	}

	local Stream; do
		local sub, newline = string.sub, "\n"
		function Stream(Input, FileName)
			local Index = 1
			local Line = 1
			local Column = 0
			FileName = FileName or "{none}"
			local cols = {}
			local function Back()
				Index = Index - 1
				local Char = sub(Input, Index, Index)
				if Char == newline then
					Line = Line - 1
					Column = cols[#cols]
					cols[#cols] = nil
				else
					Column = Column - 1
				end
			end
			local function Next()
				local Char = sub(Input, Index, Index)
				Index = Index + 1
				if Char == newline then
					Line = Line + 1
					cols[#cols + 1] = Column
					Column = 0
				else
					Column = Column + 1
				end
				return Char, {
					Index = Index,
					Line = Line,
					Column = Column,
					File = FileName
				}
			end
			local function Peek(length)
				return sub(Input, Index, Index + (length or 1) - 1)
			end
			local function EOF()
				return Index > #Input
			end
			local function Fault(Error)
				error(Error .. " (col " .. Column .. ", ln " .. Line .. ", file " .. FileName .. ")", 0)
			end
			return {
				Back = Back,
				Next = Next,
				Peek = Peek,
				EOF = EOF,
				Fault = Fault
			}
		end
	end

	local idenCheck, numCheck, opCheck = "abcdefghijklmnopqrstuvwxyz_", "0123456789", "+-*/%^#~=<>(){}[];:,."
	local blank, dot, equal, openbrak, closebrak, newline, backslash, dash, quote, apos = "", ".", "=", "[", "]", "\n", "\\", "-", "\"", "'"
	function Lexer(Code)
		local Input = Stream(Code)
		local Current, LastToken, self
		local Clone = function(Table)
			local R = {}
			for K, V in pairs(Table) do
				R[K] = V
			end
			return R
		end
		for Key, Value in pairs(Clone(Tokens)) do
			Tokens[Value] = Key
		end
		local function Check(Value, Type, Start)
			if Type == Tokens.Identifier then
				return find(idenCheck, Value:lower(), 1, true) ~= nil or not Start and find(numCheck, Value, 1, true) ~= nil
			elseif Type == Tokens.Keyword then
				if Keywords[Value] then
					return true
				end
				return false
			elseif Type == Tokens.Number then
				if Value == "." and not Start then
					return true
				end
				return find(numCheck, Value, 1, true) ~= nil
			elseif Type == Tokens.Operator then
				return find(opCheck, Value, 1, true) ~= nil
			end
		end
		local function Next()
			if Current ~= nil then
				local Token = Current
				Current = nil
				return Token
			end
			if Input.EOF() then
				return nil
			end
			local Char, DebugInfo = Input.Next()
			local Result = {
				Type = Tokens.Symbol
			}
			local sValue = Char
			for i = 0, 256 do
				local open = openbrak .. rep(equal, i) .. openbrak
				if Char .. Input.Peek(#open - 1) == open then
					self.StringDepth = i + 1
					break
				end
			end
			local resulting = false
			if 0 < self.StringDepth then
				local closer = closebrak .. rep(equal, self.StringDepth - 1) .. closebrak
				Input.Back()
				local Value = blank
				while not Input.EOF() and Input.Peek(#closer) ~= closer do
					Char, DebugInfo = Input.Next()
					Value = Value .. Char
				end
				if Input.Peek(#closer) == closer then
					for i = 1, #closer do
						Value = Value .. Input.Next()
					end
					self.StringDepth = 0
				end
				Result.Value = Value
				Result.Type = Tokens.String
				resulting = true
			elseif 0 < self.CommentDepth then
				local closer = closebrak .. rep(equal, self.CommentDepth - 1) .. closebrak
				Input.Back()
				local Value = blank
				while not Input.EOF() and Input.Peek(#closer) ~= closer do
					Char, DebugInfo = Input.Next()
					Value = Value .. Char
				end
				if Input.Peek(#closer) == closer then
					for i = 1, #closer do
						Value = Value .. Input.Next()
					end
					self.CommentDepth = 0
				end
				Result.Value = Value
				Result.Type = Tokens.Comment
				resulting = true
			end
			local skip = 1
			for i = 1, #lua_builtin do
				local k = lua_builtin[i]
				if Input.Peek(#k - 1) == sub(k, 2) and Char == sub(k, 1, 1) and skip < #k then
					Result.Type = Tokens.Builtin
					Result.Value = k
					skip = #k
					resulting = true
				end
			end
			for i = 1, skip - 1 do
				Char, DebugInfo = Input.Next()
			end
			if resulting then
			elseif Check(Char, Tokens.Identifier, true) then
				local Value = Char
				while Check(Input.Peek(), Tokens.Identifier) and not Input.EOF() do
					Value = Value .. Input.Next()
				end
				if Check(Value, Tokens.Keyword) then
					Result.Type = Tokens.Keyword
				else
					Result.Type = Tokens.Identifier
				end
				Result.Value = Value
			elseif Char == dash and Input.Peek() == dash then
				local Value = Char .. Input.Next()
				for i = 0, 256 do
					local open = openbrak .. rep(equal, i) .. openbrak
					if Input.Peek(#open) == open then
						self.CommentDepth = i + 1
						break
					end
				end
				if 0 < self.CommentDepth then
					local closer = closebrak .. rep(equal, self.CommentDepth - 1) .. closebrak
					while not Input.EOF() and Input.Peek(#closer) ~= closer do
						Char, DebugInfo = Input.Next()
						Value = Value .. Char
					end
					if Input.Peek(#closer) == closer then
						for i = 1, #closer do
							Value = Value .. Input.Next()
						end
						self.CommentDepth = 0
					end
				else
					while not Input.EOF() and not find(newline, Char, 1, true) do
						Char, DebugInfo = Input.Next()
						Value = Value .. Char
					end
				end
				Result.Value = Value
				Result.Type = Tokens.Comment
			elseif Check(Char, Tokens.Number, true) or Char == dot and Check(Input.Peek(), Tokens.Number, true) then
				local Value = Char
				while Check(Input.Peek(), Tokens.Number) and not Input.EOF() do
					Value = Value .. Input.Next()
				end
				Result.Value = Value
				Result.Type = Tokens.Number
			elseif Char == quote then
				local Escaped = false
				local String = blank
				Result.Value = quote
				while not Input.EOF() do
					local Char = Input.Next()
					Result.Value = Result.Value .. Char
					if Escaped then
						String = String .. Char
						Escaped = false
					elseif Char == backslash then
						Escaped = true
					elseif Char == quote or Char == newline then
						break
					else
						String = String .. Char
					end
				end
				Result.Type = Tokens.String
			elseif Char == apos then
				local Escaped = false
				local String = blank
				Result.Value = apos
				while not Input.EOF() do
					local Char = Input.Next()
					Result.Value = Result.Value .. Char
					if Escaped then
						String = String .. Char
						Escaped = false
					elseif Char == backslash then
						Escaped = true
					elseif Char == apos or Char == newline then
						break
					else
						String = String .. Char
					end
				end
				Result.Type = Tokens.String
			elseif Check(Char, Tokens.Operator) then
				Result.Value = Char
				Result.Type = Tokens.Operator
			else
				Result.Value = Char
			end
			Result.TypeName = Tokens[Result.Type]
			LastToken = Result
			return Result
		end
		local function Peek()
			local Result = Next()
			Current = Result
			return Result
		end
		local function EOF()
			return Peek() == nil
		end
		local function GetLast()
			return LastToken
		end
		self = {
			Next = Next,
			Peek = Peek,
			EOF = EOF,
			GetLast = GetLast,
			CommentDepth = 0,
			StringDepth = 0
		}
		return self
	end
end

function Place.fromIndex(CodeEditor, Index)
	local cache = CodeEditor.PlaceCache
	local fromCache
	if cache.fromIndex then
		fromCache = cache.fromIndex
	else
		fromCache = {}
		cache.fromIndex = fromCache
	end
	if fromCache[Index] then
	end
	local Content = CodeEditor.Content
	local ContentUpto = sub(Content, 1, Index)
	if Index == 0 then
		return Place.new(0, 0)
	end
	local Lines = Split(ContentUpto, newline)
	local res = Place.new(#gsub(Lines[#Lines], tab, TabText), #Lines - 1)
	fromCache[Index] = res
	return res
end
function Place.toIndex(CodeEditor, Place)
	local cache = CodeEditor.PlaceCache
	local toCache
	if cache.toIndex then
		toCache = cache.toIndex
	else
		toCache = {}
		cache.toIndex = toCache
	end
	local Content = CodeEditor.Content
	if Place.X == 0 and Place.Y == 0 then
		return 0
	end
	local Lines = CodeEditor.Lines
	local Index = 0
	for I = 1, Place.Y do
		Index = Index + #Lines[I] + 1
	end
	local line = Lines[Place.Y + 1]
	local roundedX = Place.X
	local ix = 0
	for i = 1, #line do
		local c = sub(line, i, i)
		local pix = ix
		if c == tab then
			ix = ix + #TabText
		else
			ix = ix + 1
		end
		if Place.X == ix then
			roundedX = i
		elseif pix < Place.X and ix > Place.X then
			if Place.X - pix < ix - Place.X then
				roundedX = i - 1
			else
				roundedX = i
			end
		end
	end
	local res = Index + min(#line, roundedX)
	toCache[Place.X .. "-$-" .. Place.Y] = res
	return res
end
local Selection = {}
local Side = {Left = 1, Right = 2}
function Selection.new(Start, End, CaretSide)
	return {
		Start = Start,
		End = End,
		Side = CaretSide
	}
end

local Themes = {
	Plain = {
		LineSelection = Color3.fromRGB(46, 46, 46),
		SelectionBackground = Color3.fromRGB(118, 118, 118),
		SelectionColor = Color3.fromRGB(10, 10, 10),
		SelectionGentle = Color3.fromRGB(46, 46, 46);
		Background = Color3.fromRGB(40, 41, 35),
		Comment = Color3.fromRGB(120, 120, 120),
		Keyword =  Color3.fromRGB(248, 109, 124),
		Builtin =  Color3.fromRGB(135, 183, 247),
		Number = Color3.fromRGB(255, 198, 0),
		Operator = Color3.fromRGB(204, 204, 204),
		String = Color3.fromRGB(123, 171, 106),
		Text = Color3.fromRGB(255, 255, 255);
		--SelectionBackground = Color3.fromRGB(150, 150, 150),
		--SelectionColor = Color3.fromRGB(0, 0, 0),
		--SelectionGentle = Color3.fromRGB(65, 65, 65)
	}
}

local EditorLib = {}
EditorLib.Place = Place
EditorLib.Selection = Selection
function EditorLib.NewTheme(Name, Theme)
	Themes[Name] = Theme
end
function EditorLib.Initialize(Frame, Options)
	local themestuff = {}
	local function ThemeSet(obj, prop, val)
		themestuff[obj] = themestuff[obj] or {}
		themestuff[obj][prop] = val
	end
	local baseZIndex = Frame.ZIndex
	Options.CaretBlinkingRate = toNumber(Options.CaretBlinkingRate) or 0.25
	Options.FontSize = toNumber(Options.FontSize or Options.TextSize) or 14
	Options.CaretFocusedOpacity = toNumber(Options.CaretOpacity and Options.CaretOpacity.Focused or Options.CaretFocusedOpacity) or 1
	Options.CaretUnfocusedOpacity = toNumber(Options.CaretOpacity and Options.CaretOpacity.Unfocused or Options.CaretUnfocusedOpacity) or 0
	Options.Theme = type(Options.Theme) == "string" and Options.Theme or "Plain"
	local TextService = cloneref(game:GetService("TextService"));
	local SizeDot = TextService:GetTextSize(".", Options.FontSize, Options.Font, Vector2.new(1000, 1000))
	local SizeM = TextService:GetTextSize("m", Options.FontSize, Options.Font, Vector2.new(1000, 1000))
	local SizeAV = TextService:GetTextSize("AV", Options.FontSize, Options.Font, Vector2.new(1000, 1000))
	local Editor = {
		Content = "",
		Lines = {""},
		Focused = false,
		PlaceCache = {},
		Selection = Selection.new(0, 0, Side.Left),
		StartingSelection = Selection.new(0, 0, Side.Left),
		LastKeyCode = false,
		UndoStack = {},
		RedoStack = {}
	}
	local CharWidth = SizeM.X
	local CharHeight = SizeM.Y + 4
	if (SizeDot.X ~= SizeM.X or SizeDot.Y ~= SizeM.Y) and SizeAV.X ~= SizeM.X + SizeDot.X then
		return error("CodeEditor requires a monospace font with no currying", 2)
	end
	local ContentChangedEvent = newInst("BindableEvent")
	local FocusLostEvent = newInst("BindableEvent")
	local Players = cloneref(game:GetService("Players"))
	local PlayerGui = Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")
	local Container = newInst("Frame")
	Container.Name = "Container"
	Container.BorderSizePixel = 0
	Container.BackgroundColor3 = Themes[Options.Theme].Background
	ThemeSet(Container, "BackgroundColor3", "Background")
	Container.Size = udim2(1, 0, 1, 0)
	Container.ClipsDescendants = true
	local GutterSize = CharWidth * 4
	local TextArea = newInst("ScrollingFrame")
	TextArea.Name = "TextArea"
	TextArea.BackgroundTransparency = 1;
	TextArea.BorderSizePixel = 0
	TextArea.Size = udim2(1, -GutterSize, 1, 0)
	TextArea.Position = udim2(0, GutterSize, 0, 0)
	TextArea.ScrollBarThickness = 10;
	TextArea.ScrollBarImageTransparency = 0;
	TextArea.ScrollBarImageColor3 = Color3.fromRGB(20, 20, 20)
	TextArea.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
	TextArea.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
	TextArea.ZIndex = 3;

	local Gutter = newInst("Frame")
	Gutter.Name = "Gutter"
	Gutter.ZIndex = baseZIndex
	Gutter.BorderSizePixel = 0
	Gutter.BackgroundTransparency = 0.96
	Gutter.Size = udim2(0, GutterSize - 5, 1.5, 0)
	local GoodMouseDetector = newInst("TextButton")
	GoodMouseDetector.Text = ""
	GoodMouseDetector.BackgroundTransparency = 1
	GoodMouseDetector.Size = udim2(1, 0, 1, 0)
	GoodMouseDetector.Position = udim2(0, 0, 0, 0)
	GoodMouseDetector.Visible = false
	local Mouse = Players.LocalPlayer:GetMouse()
	local Scroll = newInst("TextButton")
	Scroll.Name = "VertScroll"
	Scroll.Size = udim2(0, 10, 1, 0)
	Scroll.Position = udim2(1, -10, 0, 0)
	Scroll.BackgroundTransparency = 1
	Scroll.Text = ""
	Scroll.ZIndex = 1000
	Scroll.Parent = Container
	local ScrollBar = newInst("TextButton")
	ScrollBar.Name = "ScrollBar"
	ScrollBar.Size = udim2(1, 0, 0, 36)
	ScrollBar.Position = udim2(0, 0, 0, 0)
	ScrollBar.Text = ""
	ScrollBar.BackgroundColor3 = Themes[Options.Theme].ScrollBar or Color3.fromRGB(120, 120, 120)
	ScrollBar.BackgroundTransparency = 0.75
	ScrollBar.BorderSizePixel = 0
	ScrollBar.AutoButtonColor = false
	ScrollBar.ZIndex = 3 + baseZIndex
	ScrollBar.Parent = Scroll
	local CaretIndicator = newInst("Frame")
	CaretIndicator.Name = "CaretIndicator"
	CaretIndicator.Size = udim2(1, 0, 0, 2)
	CaretIndicator.Position = udim2(0, 0, 0, 0)
	CaretIndicator.BorderSizePixel = 0
	CaretIndicator.BackgroundColor3 = Themes[Options.Theme].Text
	ThemeSet(CaretIndicator, "BackgroundColor3", "Text")
	CaretIndicator.BackgroundTransparency = 0.29803921568627456
	CaretIndicator.ZIndex = 4 + baseZIndex
	CaretIndicator.Parent = Scroll
	local MarkersFolder = newInst("Folder", Scroll)
	local markers = {}
	local updateMarkers

	do
		local lerp = function(a, b, r)
			return a + r * (b - a)
		end
		function updateMarkers()
			MarkersFolder:ClearAllChildren()
			local ra = Themes[Options.Theme].Background.r
			local ga = Themes[Options.Theme].Background.g
			local ba = Themes[Options.Theme].Background.b
			local rb = Themes[Options.Theme].Text.r
			local gb = Themes[Options.Theme].Text.g
			local bb = Themes[Options.Theme].Text.b
			local r = lerp(ra, rb, 0.2980392156862745)
			local g = lerp(ga, gb, 0.2980392156862745)
			local b = lerp(ba, bb, 0.2980392156862745)
			local color = Color3.new(r, g, b)
			for i, v in ipairs(markers) do
				local Marker = newInst("Frame")
				Marker.BorderSizePixel = 0
				Marker.BackgroundColor3 = color
				Marker.Size = udim2(0, 4, 0, 6)
				Marker.Position = udim2(0, 4, v * CharHeight / TextArea.CanvasSize.Y.Offset, 0)
				Marker.ZIndex = 4 + baseZIndex
				Marker.Parent = MarkersFolder
			end
		end
	end
	do
		TextArea.Changed:Connect(function(property)
			if property == "CanvasSize" or property == "CanvasPosition" then
				Gutter.Position = udim2(0, 0, 0, -TextArea.CanvasPosition.Y)
			end
		end)
	end
	local ScrollBorder = newInst("Frame")
	ScrollBorder.Name = "ScrollBorder"
	ScrollBorder.Position = udim2(0, -1, 0, 0)
	ScrollBorder.Size = udim2(0, 1, 1, 0)
	ScrollBorder.BorderSizePixel = 0
	ScrollBorder.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
	ScrollBorder.Parent = Scroll
	do
		TextArea.Changed:Connect(function(property)
			if property == "CanvasSize" or property == "CanvasPosition" then
				local percent = TextArea.AbsoluteWindowSize.X / TextArea.CanvasSize.X.Offset
				ScrollBar.Size = udim2(percent, 0, 1, 0)
				local max = max(TextArea.CanvasSize.X.Offset - TextArea.AbsoluteWindowSize.X, 0)
				local percent = max == 0 and 0 or TextArea.CanvasPosition.X / max
				local x = percent * (Scroll.AbsoluteSize.X - ScrollBar.AbsoluteSize.X)
				ScrollBar.Position = udim2(0, x, 0, 0)
				Scroll.Visible = false
			end
		end)
	end
	local LineSelection = newInst("Frame")
	LineSelection.Name = "LineSelection"
	LineSelection.BackgroundColor3 = Themes[Options.Theme].Background
	ThemeSet(LineSelection, "BackgroundColor3", "Background")
	LineSelection.BorderSizePixel = 2
	LineSelection.BorderColor3 = Themes[Options.Theme].LineSelection
	ThemeSet(LineSelection, "BorderColor3", "LineSelection")
	LineSelection.Size = udim2(1, -4, 0, CharHeight - 4)
	LineSelection.Position = udim2(0, 2, 0, 2)
	LineSelection.ZIndex = -1 + baseZIndex
	LineSelection.Parent = TextArea
	LineSelection.Visible = false;

	local ErrorHighlighter = newInst("Frame")
	ErrorHighlighter.Name = "ErrorHighlighter"
	ErrorHighlighter.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	ErrorHighlighter.BackgroundTransparency = 0.9
	ErrorHighlighter.BorderSizePixel = 0
	ErrorHighlighter.Size = udim2(1, -4, 0, CharHeight - 4)
	ErrorHighlighter.Position = udim2(0, 2, 0, 2)
	ErrorHighlighter.ZIndex = 5 + baseZIndex
	ErrorHighlighter.Visible = false
	ErrorHighlighter.Parent = TextArea
	local ErrorMessage = newInst("TextLabel")
	ErrorMessage.Name = "ErrorMessage"
	ErrorMessage.BackgroundColor3 = Themes[Options.Theme].Background:lerp(Color3.new(1, 1, 1), 0.1)
	ErrorMessage.TextColor3 = Color3.fromRGB(255, 152, 152)
	ErrorMessage.BorderSizePixel = 0
	ErrorMessage.Visible = false
	ErrorMessage.Size = udim2(0, 150, 0, CharHeight - 4)
	ErrorMessage.Position = udim2(0, 2, 0, 2)
	ErrorMessage.ZIndex = 6 + baseZIndex
	ErrorMessage.Parent = Container
	local Tokens = newInst("Frame", TextArea)
	Tokens.BackgroundTransparency = 1
	Tokens.Name = "Tokens"
	local Selection = newInst("Frame", TextArea)
	Selection.BackgroundTransparency = 1
	Selection.Name = "Selection"
	Selection.ZIndex = baseZIndex
	local TextBox = newInst("TextBox")
	TextBox.BackgroundTransparency = 1
	TextBox.Size = udim2(0, 0, 0, 0)
	TextBox.Position = udim2(-1, 0, -1, 0)
	TextBox.Text = ""
	TextBox.ShowNativeInput = false
	TextBox.MultiLine = true
	TextBox.ClearTextOnFocus = true
	local Caret = newInst("Frame")
	Caret.Name = "Caret"
	Caret.BorderSizePixel = 0

	Caret.BackgroundColor3 = Themes[Options.Theme].Text
	ThemeSet(Caret, "BackgroundColor3", "Text")
	Caret.Size = udim2(0, 2, 0, CharHeight)
	Caret.Position = udim2(0, 0, 0, 0)
	Caret.ZIndex = 100
	Caret.Visible = false;

	local selectedword = nil;
	local tokens = {}
	local function NewToken(Content, Color, Position, Parent)		
		local Token = newInst("TextLabel")
		Token.BorderSizePixel = 0
		Token.TextColor3 = Themes[Options.Theme][Color]
		Token.BackgroundTransparency = 1
		Token.BackgroundColor3 = Themes[Options.Theme].SelectionGentle
		if Content == selectedword then
			Token.BackgroundTransparency = 0
		end
		Token.Size = udim2(0, CharWidth * #Content, 0, CharHeight)
		Token.Position = udim2(0, Position.X * CharWidth, 0, Position.Y * CharHeight)
		Token.Font = Options.Font
		Token.TextSize = Options.FontSize
		Token.Text = Content
		Token.TextXAlignment = "Left"
		Token.ZIndex = baseZIndex
		Token.Parent = Parent
		tokens[#tokens + 1] = Token
	end
	local function updateselected()
		for i, v in ipairs(tokens) do
			if v.Text == selectedword then
				v.BackgroundTransparency = 0
			else
				v.BackgroundTransparency = 1
			end
		end
		markers = {}
		if selectedword and selectedword ~= "" and selectedword ~= tab then
			for LineNumber = 1, #Editor.Lines do
				local line = Editor.Lines[LineNumber]
				local Dnable = "[^A-Za-z0-9_]"
				local has = false
				if sub(line, 1, #selectedword) == selectedword then
					has = true
				elseif sub(line, #line - #selectedword + 1) == selectedword then
					has = true
				elseif line:match(Dnable .. gsub(selectedword, "%W", "%%%1") .. Dnable) then
					has = true
				end
				if has then
					markers[#markers + 1] = LineNumber - 1
				end
			end
		end
		updateMarkers()
	end
	local DrawnLines = {}
	local depth = {}
	local sdepth = {}
	local function DrawTokens()
		local LineBegin = floor(TextArea.CanvasPosition.Y / CharHeight)
		local LineEnd = ceil((TextArea.CanvasPosition.Y + TextArea.AbsoluteWindowSize.Y) / CharHeight)
		LineEnd = min(LineEnd, #Editor.Lines)
		for LineNumber = 1, LineBegin - 1 do
			if not depth[LineNumber] then
				local line = Editor.Lines[LineNumber] or ""
				if line:match("%[%=+%[") or line:match("%]%=+%]") then
					local LexerStream = Lexer(line)
					LexerStream.CommentDepth = depth[LineNumber - 1] or 0
					LexerStream.StringDepth = sdepth[LineNumber - 1] or 0
					while not LexerStream.EOF() do
						LexerStream.Next()
					end
					sdepth[LineNumber] = LexerStream.StringDepth
					depth[LineNumber] = LexerStream.CommentDepth
				else
					sdepth[LineNumber] = sdepth[LineNumber - 1] or 0
					depth[LineNumber] = depth[LineNumber - 1] or 0
				end
			end
		end
		for LineNumber = LineBegin, LineEnd do
			if not DrawnLines[LineNumber] then
				DrawnLines[LineNumber] = true
				local X, Y = 0, LineNumber - 1
				local LineLabel = newInst("TextLabel")
				LineLabel.BorderSizePixel = 0
				LineLabel.TextColor3 = Color3.fromRGB(144, 145, 139)
				LineLabel.BackgroundTransparency = 1
				LineLabel.Size = udim2(1, 0, 0, CharHeight)
				LineLabel.Position = udim2(0, 0, 0, Y * CharHeight)
				LineLabel.Font = Enum.Font.Roboto
				LineLabel.TextSize = Options.FontSize
				LineLabel.TextXAlignment = Enum.TextXAlignment.Right
				LineLabel.Text = LineNumber
				LineLabel.Parent = Gutter
				LineLabel.ZIndex = baseZIndex
				if Editor.Lines[Y + 1] then
					local LexerStream = Lexer(Editor.Lines[Y + 1])
					LexerStream.CommentDepth = depth[LineNumber - 1] or 0
					LexerStream.StringDepth = sdepth[LineNumber - 1] or 0
					while not LexerStream.EOF() do
						local Token = LexerStream.Next()
						local Value = Token.Value
						local TokenType = Token.TypeName
						if TokenType == "Identifier" or TokenType == "Symbol" then
							TokenType = "Text"
						end
						if (" \t\r\n"):find(Value, 1, true) == nil then
							NewToken(gsub(Value, tab, TabText), TokenType, Place.new(X, Y), Tokens)
						end
						X = X + #gsub(Value, tab, TabText)
					end
					depth[LineNumber] = LexerStream.CommentDepth
					sdepth[LineNumber] = LexerStream.StringDepth
				end
			end
		end
	end
	TextArea.Changed:Connect(function(Property)
		if Property == "CanvasPosition" or Property == "AbsoluteWindowSize" then
			DrawTokens()
		end
	end)
	local function ClearTokensAndSelection()
		depth = {}
		Tokens:ClearAllChildren()
		Selection:ClearAllChildren()
		Gutter:ClearAllChildren()
	end
	local function Write(Content, Start, End)
		local InBetween = sub(Editor.Content, Start + 1, End)
		local NoLN = find(InBetween, newline, 1, true) == nil and find(Content, newline, 1, true) == nil
		local StartPlace, EndPlace
		if NoLN then
			StartPlace, EndPlace = Place.fromIndex(Editor, Start), Place.fromIndex(Editor, End)
		end
		Editor.Content = sub(Editor.Content, 1, Start) .. Content .. sub(Editor.Content, End + 1)
		ContentChangedEvent:Fire(Editor.Content)
		Editor.PlaceCache = {}
		local CanvasWidth = TextArea.CanvasSize.X.Offset - 14
		Editor.Lines = Split(Editor.Content, newline)
		for _, Res in ipairs(Editor.Lines) do
			local width = #gsub(Res, tab, TabText) * CharWidth
			if CanvasWidth < width then
				CanvasWidth = width
			end
		end

		ClearTokensAndSelection()
		TextArea.CanvasSize = udim2(0, 3000, 0, select(2, gsub(Editor.Content, newline, "")) * CharHeight + TextArea.AbsoluteWindowSize.Y)
		DrawnLines = {}
		DrawTokens()
	end
	local function SetContent(Content)
		Editor.Content = Content
		ContentChangedEvent:Fire(Editor.Content)
		Editor.PlaceCache = {}
		Editor.Lines = Split(Editor.Content, newline)
		ClearTokensAndSelection()
		local CanvasWidth = TextArea.CanvasSize.X.Offset - 14
		for _, Res in ipairs(Editor.Lines) do
			if CanvasWidth < #Res then
				CanvasWidth = #Res * CharWidth
			end
		end
		TextArea.CanvasSize = udim2(0, 3000, 0, select(2, gsub(Editor.Content, newline, "")) * CharHeight + TextArea.AbsoluteWindowSize.Y)
		DrawnLines = {}
		DrawTokens()
	end
	local function UpdateSelection()
		Selection:ClearAllChildren()
		if Themes[Options.Theme].SelectionColor then
			Selection.ZIndex = 2 + baseZIndex
			Tokens.ZIndex = 1 + baseZIndex
		else
			Selection.ZIndex = 1 + baseZIndex
			Tokens.ZIndex = 2 + baseZIndex
		end
		if Editor.Selection.Start == Editor.Selection.End then
			LineSelection.Visible = true
			local CaretPlace = Place.fromIndex(Editor, Editor.Selection.Start)
			LineSelection.Position = UDim2.new(0, 2, 0, CharHeight * CaretPlace.Y + 2)
		else
			LineSelection.Visible = false
		end
		local Index = 0
		local Start = #gsub(sub(Editor.Content, 1, Editor.Selection.Start), tab, TabText)
		local End = #gsub(sub(Editor.Content, 1, Editor.Selection.End), tab, TabText)
		for LineNumber, Line in ipairs(Editor.Lines) do
			Line = gsub(Line, tab, TabText)
			local StartX = Start - Index
			local EndX = End - Index
			local Y = LineNumber - 1
			local GoesOverLine = false
			if StartX < 0 then
				StartX = 0
			end
			if EndX > #Line then
				GoesOverLine = true
				EndX = #Line
			end
			local Width = EndX - StartX
			if GoesOverLine then
				Width = Width + 0.5
			end
			if Width > 0 then
				local color = Themes[Options.Theme].SelectionColor
				local SelectionSegment = newInst(color and "TextLabel" or "Frame")
				SelectionSegment.BorderSizePixel = 0
				if color then
					SelectionSegment.TextColor3 = color
					SelectionSegment.Font = Options.Font
					SelectionSegment.TextSize = Options.FontSize
					SelectionSegment.Text = sub(Line, StartX + 1, EndX)
					SelectionSegment.TextXAlignment = "Left"
					SelectionSegment.ZIndex = baseZIndex
				else
					SelectionSegment.BorderSizePixel = 0
				end
				SelectionSegment.BackgroundColor3 = Themes[Options.Theme].SelectionBackground
				SelectionSegment.Size = udim2(0, CharWidth * Width, 0, CharHeight)
				SelectionSegment.Position = udim2(0, StartX * CharWidth, 0, Y * CharHeight)
				SelectionSegment.Parent = Selection
			end
			Index = Index + #Line + 1
		end
		local NewY = Caret.Position.Y.Offset
		local MinBoundsY = TextArea.CanvasPosition.Y
		local MaxBoundsY = TextArea.CanvasPosition.Y + TextArea.AbsoluteWindowSize.Y - CharHeight
		if NewY < MinBoundsY then
			TextArea.CanvasPosition = Vector2.new(0, NewY)
		end
		if NewY > MaxBoundsY then
			TextArea.CanvasPosition = Vector2.new(0, NewY - TextArea.AbsoluteWindowSize.Y + CharHeight)
		end
	end
	TextBox.Parent = TextArea
	Caret.Parent = TextArea
	TextArea.Parent = Container
	Gutter.Parent = Container
	Container.Parent = Frame
	local function updateCaret(CaretPlace)
		Caret.Position = udim2(0, CaretPlace.X * CharWidth, 0, CaretPlace.Y * CharHeight)
		local percent = CaretPlace.Y * CharHeight / TextArea.CanvasSize.Y.Offset
		CaretIndicator.Position = udim2(0, 0, percent, -1)
	end
	local PressedKey, WorkingKey, LeftShift, RightShift, Shift, LeftCtrl, RightCtrl, Ctrl
	local UIS = cloneref(game:GetService("UserInputService"))
	local MovementTimeout = tick()
	local BeginSelect, MoveCaret
	local function SetVisibility(Visible)
		Editor.Visible = Visible
	end
	local function selectWord()
		local Index = Editor.Selection.Start
		if Editor.Selection.Side == Side.Right then
			Index = Editor.Selection.End
		end
		local code = Editor.Content
		local left = max(Index - 1, 0)
		local right = min(Index + 1, #code)
		local Dable = "[A-Za-z0-9_]"
		while left ~= 0 and match(sub(code, left + 1, left + 1), Dable) do
			left = left - 1
		end
		while right ~= #code and match(sub(code, right, right), Dable) do
			right = right + 1
		end
		if not match(sub(code, left + 1, left + 1), Dable) then
			left = left + 1
		end
		if not match(sub(code, right, right), Dable) then
			right = right - 1
		end
		if left < right then
			Editor.Selection.Start = left
			Editor.Selection.End = right
		else
			Editor.Selection.Start = Index
			Editor.Selection.End = Index
		end
	end
	local settledAt
	local lastClick = 0
	local lastCaretPos = 0
	local function PushToUndoStack()
		Editor.UndoStack[#Editor.UndoStack + 1] = {
			Content = Editor.Content,
			Selection = {
				Start = Editor.Selection.Start,
				End = Editor.Selection.End,
				Side = Editor.Selection.Side
			},
			LastKeyCode = false
		}
		if #Editor.RedoStack > 0 then
			Editor.RedoStack = {}
		end
	end
	local function Undo()
		if #Editor.UndoStack > 1 then
			local Thing = Editor.UndoStack[#Editor.UndoStack - 1]
			for Key, Value in pairs(Thing) do
				Editor[Key] = Value
			end
			Editor.SetContent(Thing.Content)
			Editor.RedoStack[#Editor.RedoStack + 1] = Editor.UndoStack[#Editor.UndoStack]
			Editor.UndoStack[#Editor.UndoStack] = nil
		end
	end
	local function Redo()
		if #Editor.RedoStack > 0 then
			local Thing = Editor.RedoStack[#Editor.RedoStack]
			for Key, Value in pairs(Thing) do
				Editor[Key] = Value
			end
			Editor.SetContent(Thing.Content)
			Editor.UndoStack[#Editor.UndoStack + 1] = Thing
			Editor.RedoStack[#Editor.RedoStack] = nil
		end
	end
	Mouse.Move:Connect(function()
		if BeginSelect then
			local Index = GetIndexAtMouse()
			if type(BeginSelect) == "number" then
				BeginSelect = {BeginSelect, BeginSelect}
			end
			Editor.Selection.Start = min(BeginSelect[1], Index)
			Editor.Selection.End = max(BeginSelect[2], Index)
			if Editor.Selection.Start ~= Editor.Selection.End then
				if Editor.Selection.Start == Index then
					Editor.Selection.Side = Side.Left
				else
					Editor.Selection.Side = Side.Right
				end
			end
			if BeginSelect[3] then
				selectWord()
				Editor.Selection.Start = min(BeginSelect[1], Editor.Selection.Start)
				Editor.Selection.End = max(BeginSelect[2], Editor.Selection.End)
			end
			local Ind = Editor.Selection.Start
			if Editor.Selection.Side == Side.Right then
				Ind = Editor.Selection.End
			end
			local CaretPlace = Place.fromIndex(Editor, Ind)
			updateCaret(CaretPlace)
			UpdateSelection()
		end
	end)
	TextBox.Focused:Connect(function()
		Editor.Focused = true
	end)
	TextBox.FocusLost:Connect(function()
		Editor.Focused = false
		FocusLostEvent:Fire()
		PressedKey = nil
		WorkingKey = nil
	end)
	function MoveCaret(Amount)
		local Direction = Amount < 0 and -1 or 1
		if Amount < 0 then
			Amount = -Amount
		end
		for Index = 1, Amount do
			if Direction == -1 then
				local Start = Editor.Selection.Start
				local End = Editor.Selection.End
				if Shift then
					if Start == End then
						if Start > 0 then
							Editor.Selection.Start = Start - 1
							Editor.Selection.Side = Side.Left
						end
					elseif Editor.Selection.Side == Side.Left then
						if Start > 0 then
							Editor.Selection.Start = Start - 1
						end
					elseif Editor.Selection.Side == Side.Right then
						Editor.Selection.End = End - 1
					end
				elseif Start ~= End then
					Editor.Selection.End = Start
				elseif Start > 0 then
					Editor.Selection.Start = Start - 1
					Editor.Selection.End = End - 1
				end
			elseif Direction == 1 then
				local Start = Editor.Selection.Start
				local End = Editor.Selection.End
				if Shift then
					if Start == End then
						if Start < #Editor.Content then
							Editor.Selection.End = End + 1
							Editor.Selection.Side = Side.Right
						end
					elseif Editor.Selection.Side == Side.Left then
						Editor.Selection.Start = Start + 1
					elseif Editor.Selection.Side == Side.Right and End < #Editor.Content then
						Editor.Selection.End = End + 1
					end
				elseif Start ~= End then
					Editor.Selection.Start = End
				elseif Start < #Editor.Content then
					Editor.Selection.Start = Start + 1
					Editor.Selection.End = End + 1
				end
			end
		end
	end
	local LastKeyCode
	local function ProcessInput(Type, Data)
		MovementTimeout = tick() + 0.25
		if Type == "Control+Key" then
			LastKeyCode = nil
		elseif Type == "KeyPress" then
			local Dat = Data
			if Dat == Enum.KeyCode.Up then
				Dat = Enum.KeyCode.Down
			end
			if LastKeyCode ~= Dat then
				Editor.StartingSelection.Start = Editor.Selection.Start
				Editor.StartingSelection.End = Editor.Selection.End
				Editor.StartingSelection.Side = Editor.Selection.Side
			end
			LastKeyCode = Dat
		elseif Type == "StringInput" then
			local Start = Editor.Selection.Start
			local End = Editor.Selection.End
			if Data == newline then
				local CaretPlaceInd = Editor.Selection.Start
				if Editor.Selection.Side == Side.Right then
					CaretPlaceInd = Editor.Selection.End
				end
				local CaretPlace = Place.fromIndex(Editor, CaretPlaceInd)
				local CaretLine = Editor.Lines
				CaretLine = CaretLine[CaretPlace.Y + 1]
				CaretLine = sub(CaretLine, 1, CaretPlace.X)
				local TabAmount = 0
				while sub(CaretLine, TabAmount + 1, TabAmount + 1) == tab do
					TabAmount = TabAmount + 1
				end
				Data = Data .. tab:rep(TabAmount)
				local SpTabAmount = 0
				while CaretLine:sub(SpTabAmount + 1, SpTabAmount + 1) == " " do
					SpTabAmount = SpTabAmount + 1
				end
				Data = Data .. gsub((" "):rep(SpTabAmount), TabText, tab)
				Write(Data, Start, End)
				Editor.Selection.Start = Start + #Data
				Editor.Selection.End = Editor.Selection.Start
				PushToUndoStack()
			elseif Data == tab and Editor.Selection.Start ~= Editor.Selection.End then
				local lstart = Place.fromIndex(Editor, Editor.Selection.Start)
				local lend = Place.fromIndex(Editor, Editor.Selection.End)
				local changes = 0
				local change1 = 0
				for i = lstart.Y + 1, lend.Y + 1 do
					local line = Editor.Lines[i]
					local change = 0
					if Shift then
						if sub(line, 1, 1) == tab then
							line = sub(line, 2)
							change = -1
						end
					else
						line = tab .. line
						change = 1
					end
					changes = changes + change
					if i == lstart.Y + 1 then
						change1 = change
					end
					Editor.Lines[i] = line
				end
				SetContent(table.concat(Editor.Lines, newline))
				Editor.Selection.Start = Editor.Selection.Start + change1
				Editor.Selection.End = Editor.Selection.End + changes
				PushToUndoStack()
			else
				Write(Data, Start, End)
				Editor.Selection.Start = Start + #Data
				Editor.Selection.End = Editor.Selection.Start
				PushToUndoStack()
			end
		end
		local CaretPlaceInd = Editor.Selection.Start
		if Editor.Selection.Side == Side.Right then
			CaretPlaceInd = Editor.Selection.End
		end
		local CaretPlace = Place.fromIndex(Editor, CaretPlaceInd)
		updateCaret(CaretPlace)
		UpdateSelection()
	end
	TextBox:GetPropertyChangedSignal("Text"):Connect(function()
		if TextBox.Text ~= "" then
			ProcessInput("StringInput", (gsub(TextBox.Text, "\r", "")))
			TextBox.Text = ""
			--TextBox:CaptureFocus()
		end
	end)
	UIS.InputBegan:Connect(function(Input)
		if UIS:GetFocusedTextBox() == TextBox and Input.UserInputType ~= Enum.UserInputType.MouseButton1 then
			local KeyCode = Input.KeyCode
			if KeyCode == Enum.KeyCode.LeftShift then
				LeftShift = true
				Shift = true
			elseif KeyCode == Enum.KeyCode.RightShift then
				RightShift = true
				Shift = true
			elseif KeyCode == Enum.KeyCode.LeftControl then
				LeftCtrl = true
				Ctrl = true
			elseif KeyCode == Enum.KeyCode.RightControl then
				RightCtrl = true
				Ctrl = true
			else
				PressedKey = KeyCode
				ProcessInput(not (not Ctrl or Shift) and "Control+Key" or "KeyPress", KeyCode)
				local UniqueID = newproxy(false)
				WorkingKey = UniqueID
				wait(0.25)
				if WorkingKey == UniqueID then
					WorkingKey = true
				end
			end
		end
	end)
	UIS.InputEnded:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			BeginSelect = nil
		end
		if Input.KeyCode == Enum.KeyCode.LeftShift then
			LeftShift = false
		end
		if Input.KeyCode == Enum.KeyCode.RightShift then
			RightShift = false
		end
		if Input.KeyCode == Enum.KeyCode.LeftControl then
			LeftCtrl = false
		end
		if Input.KeyCode == Enum.KeyCode.RightControl then
			RightCtrl = false
		end
		Shift = LeftShift or RightShift
		Ctrl = LeftCtrl or RightCtrl
		if PressedKey == Input.KeyCode then
			PressedKey = nil
			WorkingKey = nil
		end
	end)
	local Count = 0
	local RunService = cloneref(game:GetService("RunService"))
	RunService.Heartbeat:Connect(function()
		if Count == 0 and WorkingKey == true then
			ProcessInput(not (not Ctrl or Shift) and "Control+Key" or "KeyPress", PressedKey)
		end
		Count = (Count + 1) % 2
	end)
	Editor.Write = Write
	Editor.SetContent = SetContent
	Editor.SetVisibility = SetVisibility
	Editor.PushToUndoStack = PushToUndoStack
	Editor.Undo = Undo
	Editor.Redo = Redo
	function Editor.UpdateTheme(theme)
		for obj, v in pairs(themestuff) do
			for key, value in pairs(v) do
				obj[key] = Themes[theme][value]
			end
		end
		Options.Theme = theme
		ClearTokensAndSelection()
		updateMarkers()
	end
	function Editor.HighlightError(Visible, Line, Msg)
		if Visible then
			ErrorHighlighter.Position = udim2(0, 2, 0, CharHeight * Line + 2 - CharHeight)
			ErrorMessage.Text = "Line " .. Line .. " - " .. Msg
			ErrorMessage.Size = udim2(0, ErrorMessage.TextBounds.X + 15, 0, ErrorMessage.TextBounds.Y + 8)
		else
			ErrorMessage.Visible = false
		end
		ErrorHighlighter.Visible = Visible
	end
	Editor.ContentChanged = ContentChangedEvent.Event
	Editor.FocusLost = FocusLostEvent.Event
	TextArea.CanvasPosition = Vector2.new(0, 0);
	return Editor, TextBox, ClearTokensAndSelection, TextArea;
end

local ScriptEditor, EditorGrid, Clear, TxtArea = EditorLib.Initialize(editor:FindFirstChild("Editor"), {
	Font = Enum.Font.Code,
	TextSize = 16;
	Language = "Lua",
	CaretBlinkingRate = 0.5
})

local function openScript(o)
	EditorGrid.Text = "";
	local id = GetDebugId(o);

	if cache[id] then
		ScriptEditor.SetContent(cache[id])
	else
		local decompile = decompile or getscriptbytecode or function()
			return "-- No function exists to load this script"
		end;

		local s, res = pcall(decompile, o);
		
		if s then
			cache[id] = res;
			task.wait()
			ScriptEditor.SetContent(cache[id])
		else
			decompile = getscriptbytecode or function()
				return "-- An error occurred while loading this script: " .. res
			end;
			s, res = pcall(decompile, o);			
			
			if s then
				cache[id] = res;
				task.wait()
				ScriptEditor.SetContent(
					"-- Function decompile failed to decompile this script, falling back to getscriptbytecode...\n\n"
						..
						res
				)
			else
				task.wait()
				ScriptEditor.SetContent("-- An error occurred while loading this script with getscriptbytecode: " .. res)
			end
		end
	end

	Title.Text = "[Script Viewer] Viewing: " .. o.Name;
end

local foldername = "TSDex"

if not isfolder(foldername) then
	makefolder(foldername)
end

bindable.Event:connect(function(object)
	script.Parent.Visible = true;
	openScript(object)
end)

SaveScript.MouseButton1Click:connect(function()
	if ScriptEditor.Content ~= "" then
		local fileName = foldername .. "/" .. FileName.Text;
		if fileName == "File Name" or FileName == "" then
			fileName = foldername .. "/" .. "LocalScript_" .. math.random(1, 5000)
		end

		fileName = fileName .. ".lua";
		writefile(fileName, ScriptEditor.Content);
	end
end)

CopyScript.MouseButton1Click:connect(function()
	local txt = ScriptEditor.Content;
	setclipboard(txt)
end)

ClearScript.MouseButton1Click:connect(function()
	--EditorGrid.Text = "";
	ScriptEditor.SetContent("")
	TxtArea.CanvasPosition = Vector2.new(0, 0);
	Title.Text = "[Script Viewer]";
	Clear();
end)

CloseEditor.MouseButton1Click:connect(function()
	script.Parent.Visible = false;
end)
