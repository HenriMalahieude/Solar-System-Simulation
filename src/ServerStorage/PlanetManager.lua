--Required by every planet, makes batch changes easier
local module = function(script)
	--Dependencies
	local RunService = game:GetService("RunService")
	local Settings = require(game.ReplicatedStorage.UniverseSettings)
	
	--External
	local GravitationalConst = Settings.GravitationalConstant
	local CelestialBodies = workspace.CelestialBodies:GetChildren()
	local StartRendering = workspace.StartRendering
	local Planet = script.Parent
	
	--Internal 
	local Velocity = Planet.InitialVelocity.Value
	local Position = Planet.InitialPosition.Value
	
	Planet.Anchored = true
	
	--Wait until the Visualization script has stopped visualizing
	repeat wait() until StartRendering.Value
	
	Planet.Anchored = false
	
	--Runs during the Physics Frame of the Game Engine, ~60 fps
	RunService.Heartbeat:Connect(function()
		for _, Body in pairs(CelestialBodies) do
			if Body ~= Planet then --Why would the planet exert any force on itself?
				local Direction = (Body.Position - Planet.Position)
				local GravityForce = Direction.Unit * (GravitationalConst * Body.CustomMass.Value * Planet.CustomMass.Value) / math.pow(Direction.Magnitude, 2)
				local GravityAcceleration = GravityForce / Planet.CustomMass.Value
				
				Velocity = Velocity + GravityAcceleration
			end
		end
		
		Position = Position + Velocity*(1/60) --Match render rate with Visualizer program
		Planet.Orientation = Vector3.new(0, 0, 0)
		Planet.Position = Position
	end)
end

return module
