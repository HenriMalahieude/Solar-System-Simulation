local module = {}
local rs = game:GetService("RunService")

function module.StepWait(w)
	local tim = w or (1/60)
	for i=1, tim*60 do
		rs.Stepped:Wait()
	end
end

function module.HeartWait(w)
	local tim = w or (1/60)
	for i=1, tim*60 do
		rs.Heartbeat:Wait()
	end
end

return module
