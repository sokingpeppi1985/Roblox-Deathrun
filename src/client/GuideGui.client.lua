-- First-join tutorial modal, a "?" button to reopen it any time, and a
-- short non-blocking toast shown when this client becomes the Activator.
-- All text comes from Localization, picked by Player.LocaleId, so the
-- guide adapts to each player's language automatically.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Remotes = require(ReplicatedStorage:WaitForChild("Remotes"))
local Localization = require(ReplicatedStorage:WaitForChild("Localization"))

local player = Players.LocalPlayer
local strings = Localization.Get(player.LocaleId)

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DeathrunGuide"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 10
screenGui.Parent = player:WaitForChild("PlayerGui")

-- ===== Full-screen modal guide =====

local overlay = Instance.new("Frame")
overlay.Name = "Overlay"
overlay.Size = UDim2.new(1, 0, 1, 0)
overlay.BackgroundColor3 = Color3.new(0, 0, 0)
overlay.BackgroundTransparency = 0.4
overlay.Active = true
overlay.Visible = false
overlay.Parent = screenGui

local card = Instance.new("Frame")
card.Name = "Card"
card.AnchorPoint = Vector2.new(0.5, 0.5)
card.Position = UDim2.new(0.5, 0, 0.5, 0)
card.Size = UDim2.new(0, 480, 0, 380)
card.BackgroundColor3 = Color3.fromRGB(25, 25, 28)
card.BorderSizePixel = 0
card.Parent = overlay

local cardCorner = Instance.new("UICorner")
cardCorner.CornerRadius = UDim.new(0, 12)
cardCorner.Parent = card

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -40, 0, 36)
title.Position = UDim2.new(0, 20, 0, 16)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 22
title.TextColor3 = Color3.new(1, 1, 1)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Text = strings.GuideTitle
title.Parent = card

local body = Instance.new("TextLabel")
body.Name = "Body"
body.Size = UDim2.new(1, -40, 0, 270)
body.Position = UDim2.new(0, 20, 0, 58)
body.BackgroundTransparency = 1
body.Font = Enum.Font.Gotham
body.TextSize = 15
body.TextColor3 = Color3.fromRGB(220, 220, 220)
body.TextXAlignment = Enum.TextXAlignment.Left
body.TextYAlignment = Enum.TextYAlignment.Top
body.TextWrapped = true
body.Text = strings.GuideBody
body.Parent = card

local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 140, 0, 36)
closeButton.Position = UDim2.new(0.5, -70, 1, -52)
closeButton.BackgroundColor3 = Color3.fromRGB(160, 30, 30)
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 16
closeButton.Text = strings.CloseButton
closeButton.Parent = card

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeButton

local function openGuide()
	overlay.Visible = true
end

local function closeGuide()
	overlay.Visible = false
end

closeButton.Activated:Connect(closeGuide)

-- "?" button, always available to reopen the guide.
local helpButton = Instance.new("TextButton")
helpButton.Name = "HelpButton"
helpButton.Size = UDim2.new(0, 40, 0, 40)
helpButton.Position = UDim2.new(0, 20, 1, -60)
helpButton.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
helpButton.TextColor3 = Color3.new(1, 1, 1)
helpButton.Font = Enum.Font.GothamBold
helpButton.TextSize = 20
helpButton.Text = strings.HelpButtonLabel
helpButton.Parent = screenGui

local helpCorner = Instance.new("UICorner")
helpCorner.CornerRadius = UDim.new(1, 0)
helpCorner.Parent = helpButton

helpButton.Activated:Connect(openGuide)

openGuide() -- shown once automatically: this LocalScript runs once per session, not per respawn

-- ===== Short Activator tip (non-blocking toast) =====

Remotes.KillerAssigned.OnClientEvent:Connect(function(killerPlayer)
	if killerPlayer ~= player then
		return
	end

	local toast = Instance.new("Frame")
	toast.Name = "ActivatorTip"
	toast.Size = UDim2.new(0, 300, 0, 90)
	toast.Position = UDim2.new(0.5, -150, 0, 70)
	toast.BackgroundColor3 = Color3.fromRGB(25, 25, 28)
	toast.Parent = screenGui

	local toastCorner = Instance.new("UICorner")
	toastCorner.CornerRadius = UDim.new(0, 10)
	toastCorner.Parent = toast

	local toastTitle = Instance.new("TextLabel")
	toastTitle.Size = UDim2.new(1, -20, 0, 24)
	toastTitle.Position = UDim2.new(0, 10, 0, 8)
	toastTitle.BackgroundTransparency = 1
	toastTitle.Font = Enum.Font.GothamBold
	toastTitle.TextSize = 16
	toastTitle.TextColor3 = Color3.fromRGB(255, 90, 90)
	toastTitle.TextXAlignment = Enum.TextXAlignment.Left
	toastTitle.Text = strings.ActivatorTipTitle
	toastTitle.Parent = toast

	local toastBody = Instance.new("TextLabel")
	toastBody.Size = UDim2.new(1, -20, 0, 50)
	toastBody.Position = UDim2.new(0, 10, 0, 32)
	toastBody.BackgroundTransparency = 1
	toastBody.Font = Enum.Font.Gotham
	toastBody.TextSize = 13
	toastBody.TextColor3 = Color3.fromRGB(220, 220, 220)
	toastBody.TextWrapped = true
	toastBody.TextXAlignment = Enum.TextXAlignment.Left
	toastBody.TextYAlignment = Enum.TextYAlignment.Top
	toastBody.Text = strings.ActivatorTipBody
	toastBody.Parent = toast

	task.delay(6, function()
		local fadeOut = TweenService:Create(toast, TweenInfo.new(0.5), { BackgroundTransparency = 1 })
		fadeOut:Play()
		for _, child in ipairs(toast:GetChildren()) do
			if child:IsA("TextLabel") then
				TweenService:Create(child, TweenInfo.new(0.5), { TextTransparency = 1 }):Play()
			end
		end
		fadeOut.Completed:Wait()
		toast:Destroy()
	end)
end)
