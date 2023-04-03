local Library = require(game.ReplicatedStorage.Library)
Library.Load()

local localPlayer = game:GetService("Players").LocalPlayer
local CurrentWorld : string = ""
local CurrentPosition = nil

local DAYCARE_WORLD = "Spawn"
local DAYCARE_POSITION = Vector3.new(35, 110, 40)
local PetsToDaycare = {}

local DaycareGUI = Library.GUI.Daycare;

local DISCORD_EMOTES = {
	["Diamonds"] = "<:e:1062469796341497887>",
	["Triple Coins"] = "<:e:1082130777355079800>",
	["Triple Damage"] = "<:e:1082130816261443674>",
	["Super Lucky"] = "<:e:1082130793880621167>",
	["Ultra Lucky"] = "<:e:1082130805914079313>"
}

if not WEBHOOK_URL or WEBHOOK_URL == "" then
	game.Players.LocalPlayer:Kick("Give webhook!")
	  return end

local COIN_EMOTE = "<:e:1087199766401794168>"
local PET_EMOTE = "<:e:1083222082533462098>"
function SendWebhookInfo(quantity, loots)

	local gamemode = "[NORMAL]"
	if Library.Shared.IsHardcore then 
		gamemode = "[HARDCORE]"
	end
	
	local lootString = ""
	
	for _, loot in pairs(loots) do 
		local selectedEmote = ""
		if DISCORD_EMOTES[loot.Data] then 
			selectedEmote = DISCORD_EMOTES[loot.Data]
		elseif loot.Category == "Currency" then
			selectedEmote = COIN_EMOTE
		elseif loot.Category == "Pet" then
			selectedEmote = PET_EMOTE
		end
		
		lootString = lootString .. selectedEmote .. " " .. Library.Functions.NumberShorten(loot.Min) .. " **" .. loot.Data .. "**\n" 
	end
	

	local embed = {
			["title"] = "Daycare has been collected! " .. gamemode,
			["description"] = "Successfully collected **".. tostring(quantity) .."** pets from daycare!",
			["color"] = tonumber(0xFF00FF),

			["fields"] = {
				{
					["name"] = "Collected Loot",
					["value"] = lootString,
					["inline"] = false
				}
			},
			["footer"] = {
			    ["text"] = "Pinky Scripts! (Auto Daycare!)",
			    ["icon_url"] = "https://i.imgur.com/pWIzvzD.png"
			}
		}
		
	(syn and syn.request or http_request or http.request) {
		Url = WEBHOOK_URL;
		Method = 'POST';
		Headers = {
			['Content-Type'] = 'application/json';
		};
		Body = game:GetService('HttpService'):JSONEncode({
			username = "Daycare Update", 
			avatar_url = 'https://i.imgur.com/pWIzvzD.png',
			embeds = {embed} 
		})
	}
	


end


function TeleportToDaycare()
	CurrentWorld = Library.WorldCmds.Get()
	
	local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
	CurrentPosition = character:WaitForChild("HumanoidRootPart").CFrame
	task.wait()
	
	-- Go to Spawn World
	if CurrentWorld ~= DAYCARE_WORLD then
		Library.WorldCmds.Load(DAYCARE_WORLD)
	end

	humanoidRootPart.CFrame = CFrame.new(DAYCARE_POSITION) 
end

function SendNotification(msg, options)
	if not options then
		options = {
			time = 10,
			color = Color3.fromRGB(160, 30, 245),
			force = true
		}
	end

	Library.Signal.Fire("Notification", msg, options)
end

function ErrorNotification(msg) 
	SendNotification(msg, {
		time = 10, color = Color3.fromRGB(255, 60, 60), force = true
	})
end

local BoostIcons = {
	["Triple Coins"] = "rbxassetid://7402604552", 
	["Triple Damage"] = "rbxassetid://7402604431", 
	["Super Lucky"] = "rbxassetid://7402604677", 
	["Ultra Lucky"] = "rbxassetid://7402706511"
}

function CollectDaycare()
	local saving = Library.Save.Get()
	if not saving then 
		ErrorNotification("Something went wrong! Try re-logging!")
		return
	end
	
	local success, errorMsg, pets, loots, queue = Library.Network.Invoke("Daycare: Claim", nil)
	if not success then
		return false, (errorMsg and "Can't claim, unknown error!")
	end
	
	print("Daycare has been collected!")
	if loots then 
		for _, loot in pairs(loots) do
		
		
			print (tostring(loot.Category) .. ": " .. tostring(loot.Min) .. "x " .. tostring(loot.Data) )
			-- Quantity: loot.Min
			if loot.Category == "Currency" then 
				-- CurrencyIcon: Library.Shared.Currency[loot.Data].tinyImage;	
			elseif loot.Category == "Boost" then
				-- BoostIcon = BoostIcon[loot.Data]
			elseif loot.Category == "Pet" then
				local petData = loot.Data;
				
				-- Open Huge Egg
				-- if petData.id ~= "1019" then
					-- Library.Signal.Fire("Open Egg", "Huge Machine Egg 1", { petData });
				-- end
			end
		end
	end
	
	if queue then
		if Library.Shared.IsHardcore then
			saving.DaycareHardcoreQueue = queue;
		else
			saving.DaycareQueue = queue;
		end
		
		-- Remove pets that isn't ready yet
		for _, pet in pairs(queue) do
			if pet["Pet"] and pet["Pet"].uid then
				local tablePos = table.find(PetsToDaycare, pet["Pet"].uid)
				if tablePos then
					print("A pet was not ready yet!")
					table.remove(PetsToDaycare, tablePos)
				end
			end
		end
	end
	
	SendWebhookInfo(#PetsToDaycare, loots)

	return true, nil
end

function PutPetsInDaycare()
	local saving = Library.Save.Get()
	local success, errorMsg, _ = Library.Network.Invoke("Daycare: Enroll", PetsToDaycare)
	if not success then
		return false, (errorMsg and "Can't enroll pets, unknown error!")
	end

	print(tostring(#PetsToDaycare) .. " pets have been put on daycare!")
	task.wait(1)
	
	Library.Signal.Fire("Stat Changed", "DaycareTier")
	Library.Signal.Fire("Window Closed", DaycareGUI.Gui)
	return true, nil
end

function CreateReminder()
	if getgenv().AutoDaycare then
		ErrorNotification("The auto-daycare is already working!")
		return 
	end
	
	
	local saving = Library.Save.Get()
	
	local queue = saving.DaycareQueue
	if Library.Shared.IsHardcore then
		queue = saving.DaycareHardcoreQueue
	end
	
	-- Check if queue isn't nil and queue lenght is more than 1 (pet)
	if queue ~= nil and #queue > 0 then	
	
		getgenv().AutoDaycare = true
		SendNotification("Automatic daycare started")
		coroutine.wrap(function() 
			while true do
				local allPetsAreReady = true
				for _, pet in pairs(queue) do
					local remainingTime = Library.Shared.DaycareComputeRemainingTime(saving, pet)

					if remainingTime > 0 then
						allPetsAreReady = false
						break
					end

				end
				
				if allPetsAreReady then break end
				
				task.wait(5)
			end
			
			getgenv().AutoDaycare = false
			
			--if reminder then Library.Message.New("Your pets in daycare are ready to collect!") end
			
			PetsToDaycare = {}
			for _, pet in pairs(queue) do	
				local remainingTime = Library.Shared.DaycareComputeRemainingTime(saving, pet)

				if remainingTime <= 0 and pet["Pet"] and pet["Pet"].uid then
					table.insert(PetsToDaycare, pet["Pet"].uid)
				end
			end
			
			TeleportToDaycare()
			task.wait(1)
			
			local collected, collectError = CollectDaycare()
			if not collected then		
				ErrorNotification(collectError)
				Reset()
				return
			end
			
			task.wait(3)
			
			local putSuccess, putError = PutPetsInDaycare()
			if not putSuccess then
				ErrorNotification(putError)
				Reset()
				return
			end

			SendNotification("Successfully put pets in daycare!")
			Reset()
		end)()
	end
end

function Reset()
	local currentMap = Library.WorldCmds.Get()
	local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	-- Go to Spawn World
	if CurrentWorld ~= "" and currentMap ~= CurrentWorld then
		Library.WorldCmds.Load(CurrentWorld)
	end
	CurrentWorld = ""

	humanoidRootPart.CFrame = CurrentPosition
	CurrentPosition = nil
	
	DaycareGUI.Categories.ViewPets.Frame.PetReady.Visible = false
	DaycareGUI.TitleRight.Visible = false;
	DaycareGUI.LootView.Visible = false;
	DaycareGUI.Categories.Visible = true;
	DaycareGUI.PetsAndLoot.Visible = false;
	DaycareGUI.View.Visible = false;
	DaycareGUI.Gui.Enabled = false;
	
	-- Open Huge Egg?
end

Library.Signal.Fired("Stat Changed"):Connect(function(stat)
	if stat == "DaycareQueue" then
		CreateReminder()
	end
end)

CreateReminder()
