local servicesToCheck = {
	game:GetService("Workspace"),
	game:GetService("ReplicatedStorage"),
	game:GetService("ServerStorage"),
	game:GetService("Lighting"),
	game:GetService("StarterGui"),
	game:GetService("StarterPack"),
	game:GetService("Teams")
}

local function isDangerousScript(scriptObj)
	if scriptObj:IsA("Script") or scriptObj:IsA("LocalScript") then
		local src = scriptObj.Source
		local dangerousPatterns = {
			"TakeDamage",
			"Humanoid%.Health%s*=",
			"Humanoid%.Died",
			":TakeDamage",
			":BreakJoints",
			"%.Touched"
		}
		for _, pattern in ipairs(dangerousPatterns) do
			if src:find(pattern) then
				return true
			end
		end
	end
	return false
end

local function destroyEverythingThatHurts()
	for _, service in ipairs(servicesToCheck) do
		for _, obj in ipairs(service:GetDescendants()) do
			local name = string.lower(obj.Name)

			-- Wenn es wie etwas Gefährliches klingt
			local dangerousNames = {
				"kill", "lava", "spike", "trap", "monster", "enemy", "zombie", "boss", "demon", "harm", "damage", "npc"
			}
			for _, word in ipairs(dangerousNames) do
				if name:find(word) then
					pcall(function()
						obj:Destroy()
					end)
					break
				end
			end

			-- Wenn es ein gefährliches Skript ist
			if isDangerousScript(obj) then
				pcall(function()
					obj:Destroy()
				end)
			end

			-- NPCs mit Humanoids (die Schaden machen könnten)
			if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and not obj:FindFirstChildWhichIsA("Player") then
				pcall(function()
					obj:Destroy()
				end)
			end
		end
	end
end

-- Fall Damage deaktivieren (für alle Spieler die da sind)
local function disableFallDamageFor(player)
	player.CharacterAdded:Connect(function(char)
		local humanoid = char:WaitForChild("Humanoid")
		humanoid.StateChanged:Connect(function(old, new)
			if new == Enum.HumanoidStateType.Freefall then
				humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
			elseif new == Enum.HumanoidStateType.FallingDown then
				humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
			end
		end)
	end)
end

-- Setup für alle Spieler
game.Players.PlayerAdded:Connect(disableFallDamageFor)
for _, player in ipairs(game.Players:GetPlayers()) do
	disableFallDamageFor(player)
end

-- Loop zur Zerstörung gefährlicher Elemente
while true do
	destroyEverythingThatHurts()
	task.wait(0.5)
end