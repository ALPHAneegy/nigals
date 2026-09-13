-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

-- Configuration
local colourTable = {
	Green = Color3.fromRGB(0, 0, 0),
	Blue = Color3.fromRGB(0, 0, 0),
	Red = Color3.fromRGB(0, 0, 0),
	Yellow = Color3.fromRGB(0, 0, 0),
	Orange = Color3.fromRGB(0, 0, 0),
	Purple = Color3.fromRGB(0, 0, 0)
}

local colourChosen = colourTable.Red

-- ESP is always active
local espActive = true

-- Get player's character
local function getCharacter(player)
	return Workspace:FindFirstChild(player.Name)
end

-- Add highlight to a character
local function addHighlightToCharacter(player, character)
	if player == LocalPlayer then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and not humanoidRootPart:FindFirstChild("Highlight") then
		local highlightClone = Instance.new("Highlight")

		highlightClone.Name = "Highlight"
		highlightClone.Adornee = character
		highlightClone.Parent = humanoidRootPart

		highlightClone.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		highlightClone.FillColor = colourChosen
		highlightClone.OutlineColor = Color3.fromRGB(255, 255, 255)
		highlightClone.FillTransparency = 0.5
	end
end

-- Remove highlight from a character
local function removeHighlightFromCharacter(character)
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		local highlightInstance = humanoidRootPart:FindFirstChild("Highlight")

		if highlightInstance then
			highlightInstance:Destroy()
		end
	end
end

-- Update highlights
local function updateHighlights()
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			local character = getCharacter(player)

			if character then
				if espActive then
					addHighlightToCharacter(player, character)
				else
					removeHighlightFromCharacter(character)
				end
			end
		end
	end
end

-- Continuously update ESP
RunService.RenderStepped:Connect(function()
	updateHighlights()
end)

-- Handle players joining
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		if espActive then
			addHighlightToCharacter(player, character)
		end
	end)
end)

-- Handle players leaving
Players.PlayerRemoving:Connect(function(player)
	local character = player.Character

	if character then
		removeHighlightFromCharacter(character)
	end
end)

-- Handle characters that already exist
for _, player in ipairs(Players:GetPlayers()) do
	if player ~= LocalPlayer then
		local character = player.Character

		if character and espActive then
			addHighlightToCharacter(player, character)
		end

		player.CharacterAdded:Connect(function(newCharacter)
			if espActive then
				addHighlightToCharacter(player, newCharacter)
			end
		end)
	end
end
