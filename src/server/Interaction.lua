local tool = script.Parent

local ReplicatedStorage = game:GetService("ReplicatedStorage") 
local useItemEvent = ReplicatedStorage:WaitForChild("UseItemEvent")


tool.Activated:Connect(function()
	useItemEvent:FireServer()
	local player = game.Players:GetPlayerFromCharacter(tool.Parent)
	if player then
		tool.Parent = nil
	end
end)



