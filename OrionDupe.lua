	local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
	local Player = game.Players.LocalPlayer
	local Window = OrionLib:MakeWindow({Name = "Key system!", HidePremium = false, SaveConfig = true, IntroText = "Dupe 1.0"})

	OrionLib:MakeNotification({
		Name = "Logged in!",
		Content = "You are logged in as "..Player.Name.."!",
		Image = "rbxassetid://4483345998",
		Time = 5
	})

	_G.Key = "Dupe"
	_G.KeyInput = "string"

	function onclick()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/OliwierIsTryHard/DupeScriptPSX/main/DupeScriptPSX.lua", true))()
	end


	function MakeScriptHub()
		local Window = OrionLib:MakeWindow({Name = "Dupe", HidePremium = false, SaveConfig = true, IntroText = "Dupe"})

		local Tab = Window:MakeTab({
			Name = "Dupe",
			Icon = "rbxassetid://4483345998",
			PremiumOnly = false
		})
		local Tab2 = Window:MakeTab({
			Name = "Credits",
			Icon = "rbxassetid://4483345998",
			PremiumOnly = false
		})
		Tab2:AddLabel("Credits to SznelaKapiszona#7936 <3")
		Tab2:AddButton({
			Name = "Join Discord",
			Callback = function()
				if setclipboard then
					setclipboard("https://discord.gg/njHeJDrQkP")
				else
					OrionLib:MakeNotification({
						Name = "Error!",
						Content = "Your executor doesn't support",
						Image = "rbxassetid://4483345998",
						Time = 5
					})
				end
			end    
		})

		Tab:AddButton({
			Name = "Start Dupe",
			Callback = function()
				loadstring(game:HttpGet("https://raw.githubusercontent.com/OliwierIsTryHard/DupeScriptPSX/main/DupeScriptPSX.lua", true))()
			end    
		})

	end

	function CorrectKeyNotification()
		OrionLib:MakeNotification({
			Name = "Correct Key!",
			Content = "You have entred the correct key!",
			Image = "rbxassetid://4483345998",
			Time = 5
		})
	end

	function IncorrectKeyNotification()
		OrionLib:MakeNotification({
			Name = "Incorrect Key!",
			Content = "You have entred the incorrect key!",
			Image = "rbxassetid://4483345998",
			Time = 5
		})
	end

	local Tab = Window:MakeTab({
		Name = "Key",
		Icon = "rbxassetid://4483345998",
		PremiumOnly = false
	})

	Tab:AddTextbox({
		Name = "Enter Key! (key: Dupe)",
		Default = "",
		TextDisappear = true,
		Callback = function(Value)
			_G.KeyInput = Value
		end	  
	})

	Tab:AddButton({
		Name = "Check key!",
		Callback = function()
			if _G.KeyInput == _G.Key then
				MakeScriptHub()
				CorrectKeyNotification()
			else
				IncorrectKeyNotification()
			end
		end    
	})
