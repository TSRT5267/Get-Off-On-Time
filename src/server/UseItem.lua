local character = script.Parent
local humanoid = character:WaitForChild("Humanoid")

local ReplicatedStorage = game:GetService("ReplicatedStorage") 
local useItemEvent = ReplicatedStorage:WaitForChild("UseItemEvent")

function stopNPC()	
	humanoid.WalkSpeed = 0
	wait(5)
	humanoid.WalkSpeed = 13	
end



useItemEvent.OnServerEvent:Connect(stopNPC)
