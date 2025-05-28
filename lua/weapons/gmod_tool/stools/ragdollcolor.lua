TOOL.Category = "Render"
TOOL.Name = "#tool.ragdollcolor.name"
TOOL.Information = {
	{name = "left"},
	{name = "right"},
	{name = "reload"}
}

TOOL.ClientConVar["r"] = 255
TOOL.ClientConVar["g"] = 255
TOOL.ClientConVar["b"] = 255

local function SetRagdollColor(ply, ent, data)
	-- Double check to prevent exploits
	if ent:GetClass() == "prop_ragdoll" then
		if isnumber(data.r) and isnumber(data.g) and isnumber(data.b) then
			local color = Color(data.r, data.g, data.b)
			ent.RagdollColor = color
			ent:SetNW2Vector("RagdollColor", color:ToVector())
			duplicator.StoreEntityModifier(ent, "ragdolcolor", data)
		else
			ent.RagdollColor = nil
			ent:SetNW2Vector("RagdollColor", nil)
			duplicator.ClearEntityModifier(ent, "ragdolcolor")
		end
	end
end

if SERVER then
	-- The mistake in the name was made intentionally for compatibility
	duplicator.RegisterEntityModifier("ragdolcolor", SetRagdollColor)
else
	language.Add("tool.ragdollcolor.name", "Ragdoll Color")
	language.Add("tool.ragdollcolor.desc", "Recolor ragdolls")
	language.Add("tool.ragdollcolor.left", "Apply color to a ragdoll")
	language.Add("tool.ragdollcolor.right", "Copy the color of a ragdoll")
	language.Add("tool.ragdollcolor.reload", "Reset the color of a ragdoll")

	hook.Add("EntityNetworkedVarChanged", "RagdollColor", function(ent, name, old, new)
		if name == "RagdollColor" then
			if new then
				function ent:GetPlayerColor()
					return new
				end
			else
				ent.GetPlayerColor = nil
			end
		end
	end)
end

function TOOL:LeftClick(trace)
	local ent = trace.Entity
	if not ent:IsValid() or ent:GetClass() ~= "prop_ragdoll" then return false end
	if CLIENT then return true end

	SetRagdollColor(self:GetOwner(), ent, {r = self:GetClientNumber("r", 0), g = self:GetClientNumber("g", 0), b = self:GetClientNumber("b", 0)})

	return true
end

function TOOL:RightClick(trace)
	local ent = trace.Entity
	if not ent:IsValid() or ent:GetClass() ~= "prop_ragdoll" then return false end
	if CLIENT then return true end

	local color = ent.RagdollColor or color_white
	self:GetOwner():ConCommand("ragdollcolor_r " .. color.r)
	self:GetOwner():ConCommand("ragdollcolor_g " .. color.g)
	self:GetOwner():ConCommand("ragdollcolor_b " .. color.b)

	return true
end

function TOOL:Reload(trace)
	local ent = trace.Entity
	if not ent:IsValid() or ent:GetClass() ~= "prop_ragdoll" then return false end
	if CLIENT then return true end

	SetRagdollColor(self:GetOwner(), ent, {})

	return true
end

local convars = TOOL:BuildConVarList()

function TOOL.BuildCPanel(panel)
	panel:Help("#tool.ragdollcolor.desc")
	panel:ToolPresets("ragdollcolour", convars)
	panel:ColorPicker("#tool.colour.color", "ragdollcolor_r", "ragdollcolor_g", "ragdollcolor_b")
end