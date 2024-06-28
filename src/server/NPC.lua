

-- 패스파인더 초기화
local PathfindingService = game:GetService("PathfindingService")
local path = PathfindingService:CreatePath({
	AgentRadius = 1,
	AgentHeight = 5,	
	AgentCanJump = false,
	AgentCanClimb = false,
	Costs = {
		Metal = math.huge,		
	}	
})

-- 네트워크 초기화
local ReplicatedStorage = game:GetService("ReplicatedStorage") 
local workEvent = ReplicatedStorage:WaitForChild("WorkEvent")

-- 플레이어 초기화
local Players = game:GetService("Players")
local character = script.Parent
local humanoid = character:WaitForChild("Humanoid")
local Workspace = game:GetService("Workspace")

-- NPC 스펙 초기화
local damage = 60
local cooldown = 1
local attackDistance = 3
local attackAnimationId = 913376220
local walkAnimationId = 913376220
local lookDistance = 50 

-- 애니메이션 초기화
local animationBaseUrl = "rbxassetid://"
local walkAnimation = Instance.new("Animation", character)
local attackAnimation = Instance.new("Animation", character)
walkAnimation.AnimationId = animationBaseUrl .. walkAnimationId
attackAnimation.AnimationId = animationBaseUrl .. attackAnimationId
local walkAnimTrack = humanoid:LoadAnimation(walkAnimation)
local attackAnimTrack = humanoid:LoadAnimation(attackAnimation)
local isAttackEnabled = true

-- 웨이포인트 불러오기
local waypointsFolder = Workspace:WaitForChild("WayPoints")
local destinations = {}
for _, waypoint in ipairs(waypointsFolder:GetChildren()) do
	if waypoint:IsA("BasePart") then
		table.insert(destinations, waypoint.Position)
	end
end

-- 플레이어가 근처에 있는지 확인하는 함수
local function findNearestPlayer()
	local npcPosition = character.HumanoidRootPart.Position
	local nearestDistance = math.huge
	local nearestPlayer = nil

	for _, player in ipairs(Players:GetPlayers()) do
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local playerPosition = player.Character.HumanoidRootPart.Position
			local distance = (playerPosition - npcPosition).Magnitude
			if distance < nearestDistance then
				nearestDistance = distance
				nearestPlayer = player
			end
		end
	end
	return nearestPlayer, nearestDistance
end

-- 시야에 플레이어가 있는지 확인하는 함수
local function isPlayerInView()
	local npcPosition = character.HumanoidRootPart.Position

	for _, player in ipairs(Players:GetPlayers()) do
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local playerPosition = player.Character.HumanoidRootPart.Position
			local directions = {}
			local npcForward = character.HumanoidRootPart.CFrame.LookVector
			local rightVector = character.HumanoidRootPart.CFrame.RightVector

			for i = -9, 9 do
				local angle = math.rad(i * 5) -- 90도 범위를 19개의 레이로 나눔
				local direction = (npcForward * math.cos(angle) + rightVector * math.sin(angle)).Unit
				table.insert(directions, direction)
			end

			for _, direction in ipairs(directions) do -- 레이 생성,충돌판정
				local ray = Ray.new(npcPosition, direction * lookDistance)
				local ignoreList = {character}
				local hitPart, hitPosition = Workspace:FindPartOnRayWithIgnoreList(ray, ignoreList)

				if hitPart and hitPart:IsDescendantOf(player.Character) then					
					return true
				end
			end
		end
	end
	return false
end

-- 페스파인더 기능
local function followPath(players,destination)
	local waypoints
	local nextWaypointIndex
	local blockedConnection

	local success, errorMessage = pcall(function()
		path:ComputeAsync(character.PrimaryPart.Position, destination)
	end)

	if success and path.Status == Enum.PathStatus.Success then
		waypoints = path:GetWaypoints()
		if not walkAnimTrack.IsPlaying then
			walkAnimTrack:Play()
		end

		blockedConnection = path.Blocked:Connect(function(blockedWaypointIndex)
			if blockedWaypointIndex >= nextWaypointIndex then
				blockedConnection:Disconnect()
				followPath(players,destination)
			end
		end)

		nextWaypointIndex = 2
		humanoid:MoveTo(waypoints[nextWaypointIndex].Position)

		humanoid.MoveToFinished:Wait()
		while nextWaypointIndex < #waypoints do
			nextWaypointIndex = nextWaypointIndex + 1
			local player, distance = findNearestPlayer()
			if  distance < 10 or isPlayerInView() then
				return
			end
			humanoid:MoveTo(waypoints[nextWaypointIndex].Position)
			humanoid.MoveToFinished:Wait()
		end

		walkAnimTrack:Stop()
	else
		warn("Path not computed!", errorMessage)
	end
end

-- body색 변경
local function changeBodyColor(color)
	for _, part in ipairs(character:GetChildren()) do
		if part:IsA("BasePart") then
			part.Color = color
		end
	end
end

--타이머
local followTimer = 5
spawn(function()
	while true do
		wait(1)
		if followTimer > 0 then
			followTimer = followTimer - 1
		end
	end
end)

-- 플레이어가 업무 중인거 발견
local isWorkFound = false
local function workFound(player,position)
	isWorkFound = true
	followPath(player,position)
	isWorkFound = false	
end


--	스크립트 시작
local isPlayerFound = false
workEvent.OnServerEvent:Connect(workFound) -- 엄무 추적
while wait(0.1) do
	local player, distance = findNearestPlayer()
	if distance < 10 or isPlayerInView() then
		isPlayerFound = true
		followTimer = 5
		changeBodyColor(Color3.new(1,0,0))
	end

	if isPlayerFound then -- 플레이어 발견시 플레이어 추적
		if distance > 10 and followTimer == 0 then
			isPlayerFound = false
			changeBodyColor(Color3.new(1,1,1))
		end
		if not walkAnimTrack.IsPlaying and distance > attackDistance then
			walkAnimTrack:Play()
		end
		if distance < attackDistance and isAttackEnabled then
			isAttackEnabled = false
			attackAnimTrack:Play()
			coroutine.wrap(function()
				wait(0.3)
				player.Character.Humanoid.Health -= damage
				wait(cooldown - 0.3)
				isAttackEnabled = true
			end)()
		end
		if player and distance > attackDistance then
			local temp = Vector3.new(0,0,0)
			followPath(temp,player.Character.HumanoidRootPart.Position)
		elseif player then
			if walkAnimTrack.IsPlaying then
				walkAnimTrack:Stop()
			end
		end
	else --평상시에는 웨이포인터 랜덤 선탱후 이동
		local nextDestinationIndex = math.random(1, #destinations)
		local temp = Vector3.new(0,0,0)
		followPath(temp,destinations[nextDestinationIndex])
		wait(1)
	end
end

