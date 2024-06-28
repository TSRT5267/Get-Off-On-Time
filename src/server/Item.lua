local Prompt = script.Parent.ProximityPrompt

Prompt.Triggered:Connect(function(Player)
	-- 게임의 저장소에서 iPhone을 찾아 복사합니다.
	local iPhoneClone = game.ReplicatedStorage.iPhone:Clone()
	-- 복사한 iPhone을 플레이어의 가방에 넣습니다.
	iPhoneClone.Parent = Player.Backpack
	-- 프롬프트 오브젝트를 삭제합니다.
	script.Parent:Destroy()
end)
