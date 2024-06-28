local player = game.Players.LocalPlayer

-- WaitForChild를 사용하여 필요한 객체들이 존재할 때까지 대기
local interaction = workspace:WaitForChild("Interactions")

-- 필요한 부품들과 프롬프트들을 정의
local partsAndPrompts = {
	PrinterPart = interaction:WaitForChild("PrinterPart"):WaitForChild("ProximityPrompt"),
	BoxPart = interaction:WaitForChild("BoxPart"):WaitForChild("ProximityPrompt"),
	TrashCanPart = interaction:WaitForChild("TrashCanPart"):WaitForChild("ProximityPrompt"),
	HealthMachinePart = interaction:WaitForChild("HealthMachinePart"):WaitForChild("ProximityPrompt"),
	WhiteBoardPart = interaction:WaitForChild("WhiteBoardPart"):WaitForChild("ProximityPrompt"),
}

local function onPromptShown()
	-- 카메라 회전 비활성화
	print("hi")
	local camera = workspace.CurrentCamera
	camera.CameraType = Enum.CameraType.Scriptable
end

local function onPromptHidden()
	-- 카메라 회전 활성화
	local camera = workspace.CurrentCamera
	camera.CameraType = Enum.CameraType.Custom
end

-- 모든 프롬프트에 이벤트 연결
for _, prompt in pairs(partsAndPrompts) do
	prompt.PromptShown:Connect(onPromptShown)
	prompt.PromptHidden:Connect(onPromptHidden)
end


