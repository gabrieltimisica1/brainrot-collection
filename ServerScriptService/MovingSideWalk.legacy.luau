local Players = game:GetService("Players")

local PART_NAME = "MovingSideWalk"
local MULTIPLIER = 2
local OFF_DELAY = 0.05

local active = {}

local function getHumanoid(hit)
	local character = hit:FindFirstAncestorOfClass("Model")
	if not character then return nil end
	return character:FindFirstChildOfClass("Humanoid")
end

local function recompute(hum)
	local st = active[hum]
	if not st then return end
	if st.on then
		hum.WalkSpeed = st.baseSpeed * MULTIPLIER
	else
		hum.WalkSpeed = st.baseSpeed
	end
end

local function onWalkSpeedChanged(hum)
	local st = active[hum]
	if not st then return end
	local ws = hum.WalkSpeed
	if st.on then
		local base = ws / MULTIPLIER
		if base > 0 then st.baseSpeed = base end
	else
		st.baseSpeed = ws
	end
end

local function applyBoost(hum)
	local st = active[hum]
	if not st then
		st = {
			baseSpeed = hum.WalkSpeed,
			count = 0,
			on = false,
			pending = false,
			conn = nil,
			lastTouch = os.clock()
		}
		st.conn = hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
			onWalkSpeedChanged(hum)
		end)
		active[hum] = st
	end

	st.count += 1
	st.on = true
	st.lastTouch = os.clock()
	recompute(hum)
end

local function cleanup(hum, st)
	if st.conn then
		st.conn:Disconnect()
		st.conn = nil
	end
	active[hum] = nil
end

local function scheduleOff(hum)
	local st = active[hum]
	if not st or st.pending then return end
	st.pending = true
	local offRequestedAt = os.clock()

	task.delay(OFF_DELAY, function()
		local cur = active[hum]
		if not cur then return end
		cur.pending = false
		if cur.count > 0 then return end
		if (os.clock() - cur.lastTouch) < OFF_DELAY then return end
		if hum.Parent then
			cur.on = false
			recompute(hum)
		end
		cleanup(hum, cur)
	end)
end

local function removeBoost(hum)
	local st = active[hum]
	if not st then return end
	st.count -= 1
	if st.count < 0 then st.count = 0 end
	if st.count == 0 then
		scheduleOff(hum)
	end
end

local function hook(part)
	if not part:IsA("BasePart") then return end
	if part.Name ~= PART_NAME then return end

	part.Touched:Connect(function(hit)
		local hum = getHumanoid(hit)
		if hum and hum.Parent and hum.Health > 0 then
			applyBoost(hum)
		end
	end)

	part.TouchEnded:Connect(function(hit)
		local hum = getHumanoid(hit)
		if hum and hum.Parent then
			removeBoost(hum)
		end
	end)
end

for _, d in ipairs(workspace:GetDescendants()) do
	hook(d)
end

workspace.DescendantAdded:Connect(hook)

Players.PlayerRemoving:Connect(function(plr)
	if not plr.Character then return end
	local hum = plr.Character:FindFirstChildOfClass("Humanoid")
	if not hum then return end
	local st = active[hum]
	if not st then return end
	hum.WalkSpeed = st.baseSpeed
	cleanup(hum, st)
end)
