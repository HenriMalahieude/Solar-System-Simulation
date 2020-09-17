local RunService = game:GetService("RunService")
local Settings = require(game.ReplicatedStorage.UniverseSettings)
local RunServiceWait = require(game.ReplicatedStorage.RunserviceTimer)

local Sun = workspace.CelestialBodies.Center
local CelestialBodies = workspace.CelestialBodies:GetChildren()
local GravitationalConst = Settings.GravitationalConstant

local RenderRate = 1/60 --I have to match the render rates of the planets and the predictor
local MaxRenderSteps = 11000 --How many steps are predicted, be careful of high numbers since they will lag the computer at deletion of the parts/instances

--Creates the path of the planet
local function visualizePath(LastPos, NewPos, BrickCol)
	local newPart = Instance.new("Part")
	newPart.Anchored = true
	newPart.CanCollide = false
	newPart.BrickColor = BrickCol
	newPart.Material = "Neon"
	newPart.Size = Vector3.new(1, 1, (LastPos - NewPos).Magnitude)
	newPart.CFrame = CFrame.new((LastPos - NewPos) / 2 + LastPos, NewPos)
	newPart.Parent = workspace.VisualizingNodes
end

--Deletes all paths
local function resetPath()
	for i, item in pairs(workspace.VisualizingNodes:GetChildren()) do
		item:Destroy()
		if i % math.floor(MaxRenderSteps/25) == 0 then
			RunService.Heartbeat:Wait() --This is used to make stuttering/freezing less of an issue
		end
	end
end

local BodyPhysics = {}

--si, senor [Looking back on my code, I baffle myself sometimes]
while not workspace.StartRendering.Value do --While the planets aren't moving
	resetPath()
	
	BodyPhysics = {} --reset the table
	
	for _, Body in pairs(CelestialBodies) do
		if Body ~= Sun then
			BodyPhysics[Body] = {Body.Position, Body.InitialVelocity.Value}
			--[[Format: 
			Dictionary[objectIndex] = {Position, Velocity}
			]]
		end
	end
	
	for i=1, MaxRenderSteps do
		if i % math.floor(MaxRenderSteps/100) == 0 then
			RunService.Heartbeat:Wait() --less freezing
		end
		
		--Basically we run the planet movement script internally and save each position
		for _, Body in pairs(CelestialBodies) do
			if BodyPhysics[Body] then --If it exists, then it isn't the Sun
				local lastPos1 = BodyPhysics[Body][1]
				local velocity1 = BodyPhysics[Body][2]
				
				for _, Body2 in pairs(CelestialBodies) do
					if Body ~= Body2 then
						local lastPos2
						if BodyPhysics[Body2] ~= nil then
							lastPos2 = BodyPhysics[Body2][1]
						else
							lastPos2 = Body2.Position
						end
						
						local Direction = (lastPos2 - lastPos1)
						local GravityForceVector = Direction.Unit * (GravitationalConst * Body2.CustomMass.Value * Body.CustomMass.Value) / math.pow(Direction.Magnitude, 2)
						local GravityAcceleration = GravityForceVector / Body.CustomMass.Value
						velocity1 = velocity1 + GravityAcceleration
					end
				end
				--Calculate new position for this planet
				newPos1 = lastPos1 + velocity1 * RenderRate
				
				--Visualize that position
				visualizePath(lastPos1, newPos1, Body.BrickColor)
				
				--Save this position + velocity
				lastPos1 = newPos1
				BodyPhysics[Body][1] = lastPos1
				BodyPhysics[Body][2] = velocity1
			end
		end
	end
	RunServiceWait.HeartWait(5)
end

resetPath()