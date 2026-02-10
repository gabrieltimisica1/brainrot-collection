--!strict
local WorkspaceUtils = {}

function WorkspaceUtils.GetBaseModel(baseIndex: number): Instance
	local baseModel = workspace:FindFirstChild("Base" .. baseIndex)
	if not baseModel then
		error("WorkspaceUtils: Base " .. baseIndex .. " doesn't exist in Workspace")
	end
	return baseModel
end

function WorkspaceUtils.GetSpawnerPart(baseIndex: number): BasePart
	local baseModel = WorkspaceUtils.GetBaseModel(baseIndex)
	local pipeline = baseModel:FindFirstChild("Pipeline")
	if not pipeline then
		error("WorkspaceUtils: Pipeline folder not found for Base " .. baseIndex)
	end
	local spawner = pipeline:FindFirstChild("Spawner")
	if not spawner or not spawner:IsA("BasePart") then
		error("WorkspaceUtils: Spawner part not found for Base " .. baseIndex)
	end
	return spawner
end

function WorkspaceUtils.GetDespawnerPart(baseIndex: number): BasePart
	local baseModel = WorkspaceUtils.GetBaseModel(baseIndex)
	local pipeline = baseModel:FindFirstChild("Pipeline")
	if not pipeline then
		error("WorkspaceUtils: Pipeline folder not found for Base " .. baseIndex)
	end
	local despawner = pipeline:FindFirstChild("Despawner")
	if not despawner or not despawner:IsA("BasePart") then
		error("WorkspaceUtils: Despawner part not found for Base " .. baseIndex)
	end
	return despawner
end

function WorkspaceUtils.GetPlayerSpawnPoint(baseIndex: number): BasePart
	local baseModel = WorkspaceUtils.GetBaseModel(baseIndex)
	local spawnPoint = baseModel:FindFirstChild("PlayerSpawnPoint")
	if not spawnPoint or not spawnPoint:IsA("BasePart") then
		error("WorkspaceUtils: PlayerSpawnPoint not found for Base " .. baseIndex)
	end
	return spawnPoint
end

return WorkspaceUtils
