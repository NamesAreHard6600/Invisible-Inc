-------------------------------------------------------------------------
-- Pawn Move Skill Library
-- v1.0
-------------------------------------------------------------------------
-- Contains helpers to make pilot skills compatible with pawn move skills
-------------------------------------------------------------------------

--- Library export
local pawnMove = {}

--- Recreate Move.GetTargetArea and Move.GetSkillEffect as weaponPreviewLib injects code into the functions
--- This extra code causes the weapon ID in the lib to be the inner move skill, so as a result any calls in the outer skill break
--- We also have some extra parameters we need
local defaultMove = {}

--[[--
  Custom GetTargetArea supporting a variable move speed

  @param p1    Pawn location
  @param move  Pawn move speed, defaults to Pawn:GetMoveSpeed()
  @return  Target area for this function
]]
function defaultMove:GetTargetAreaExt(p1, move)
  local move = move or Pawn:GetMoveSpeed()
  return Board:GetReachable(p1, move, Pawn:GetPathProf())
end

--[[--
  Custom GetSkillEffect supporting building off an existing skill effect

  @param p1    Pawn location
  @param p2    Target location
  @param ret   Skill effect instance, defaults to a new SkillEffect()
  @return  SkillEffect for this action
]]
function defaultMove:GetSkillEffectExt(p1, p2, ret)
  local ret = ret or SkillEffect()

  if Pawn:IsJumper() then
    local plist = PointList()
    plist:push_back(p1)
    plist:push_back(p2)
    ret:AddLeap(plist, FULL_DELAY)
  elseif Pawn:IsTeleporter() then
    ret:AddTeleport(p1, p2, FULL_DELAY)
  else
    ret:AddMove(Board:GetPath(p1, p2, Pawn:GetPathProf()), FULL_DELAY)
  end

  return ret
end

--[[--
  This function is simply a conveinent and safe way to call the vanilla Move:GetTargetArea

  @param p1   Starting position for the pawn
  @param move  Move speed, if unset defaults to Pawn:GetMoveSpeed()
  @return  PointList of valid move targets
]]
function pawnMove.GetDefaultTargetArea(p1, move)
  return defaultMove:GetTargetAreaExt(p1, move)
end

--[[--
  This function is simply a conveinent and safe way to call vanilla Move:GetSkillEffect

  @param p1   Starting position for the pawn
  @param p2   Target position for the pawn
  @param ret  Skill effect instance to build upon, if unset creates a new one
  @return  SkillEffect for this action
]]
function pawnMove.GetDefaultSkillEffect(p1, p2, ret)
  return defaultMove:GetSkillEffectExt(p1, p2, ret)
end

--[[--
  Common logic to call a vanilla function from move
  Will try the extended version, the move skill override, then default to vanilla logic
]]
local function callVanillaFunction(name, ...)
  local moveSkill = _G[Pawn:GetType()].MoveSkill
  local extName = name .. "Ext"
  -- GetTargetArea and GetSkillEffect have code injected into them by weaponPreview
  -- the extended version does not have those injections and is compatible with the parameters
  if moveSkill ~= nil then
    if moveSkill[extName] ~= nil then
      return moveSkill[extName](moveSkill, ...)
    -- fallback to the normal one, this won't work with weaponPreview
    elseif moveSkill[name] ~= nil then
      return moveSkill[name](moveSkill, ...)
    end
  end
  -- this should never happen
  return defaultMove[extName](defaultMove, ...)
end

--[[--
  Gets the target area for the current pawn's move skill.
  Will try the extended version, the regular, then default to vanilla logic
  If you need to use the move parameter, you should call HasTargetFunction() first to verify its present

  @param point  Pawn Location
  @param move   Pawn move speed, if unset uses Pawn:GetMoveSpeed()
  @return  PointList of move target area
]]
function pawnMove.GetTargetArea(point, move)
  return callVanillaFunction("GetTargetArea", point, move)
end

--[[--
  Gets the move skill effect for the relevant pawn move skill
  Will try the extended version, the regular, then default to vanilla logic
  If you need to use the ret parameter, you should call HasEffectFunction() first to verify its present

  @param p1   Pawn location
  @param p2   Target location
  @param ret  SkillEffect instance. If provided, appends skill effect to end
]]
function pawnMove.GetSkillEffect(p1, p2, ret)
  return callVanillaFunction("GetSkillEffect", p1, p2, ret)
end

--[[--
  Checks if the pawns overrides the given move function or has the given custom function

  @param name  Name of the function to check for
  @return true if the function exists and is overridden or if no move skill is set
]]
function pawnMove.HasFunction(name)
  local moveSkill = _G[Pawn:GetType()].MoveSkill
  return moveSkill ~= nil and moveSkill[name] ~= nil
end

--[[--
  Checks if the pawn has a move skill that overriddes GetTargetArea

  @return  True if the pawn overrides GetTargetArea
]]
function pawnMove.OverridesTargetArea()
  return pawnMove.HasFunction("GetTargetArea")
end

--[[--
  Checks if the pawn has a move skill that overriddes GetSkillEffect

  @return  True if the pawn overrides GetSkillEffect
]]
function pawnMove.OverridesSkillEffect()
  return pawnMove.HasFunction("GetSkillEffect")
end

--[[--
  Checks if pawnMove.GetTargetArea can be called safely and with the extra parameters.

  @return true if the pawn has no move skill (default extended logic) or has a custom extended logic
]]
function pawnMove.IsTargetAreaExt()
  return pawnMove.HasFunction("GetTargetAreaExt") or not pawnMove.OverridesTargetArea()
end

--[[--
  Checks if pawnMove.GetSkillEffect can be called safely and with the extra parameters.

  @return true if the pawn has no move skill (default extended logic) or has a custom extended logic
]]
function pawnMove.IsSkillEffectExt()
  return pawnMove.HasFunction("GetSkillEffectExt") or not pawnMove.OverridesSkillEffect()
end

--[[--
  Calls the given custom move function if present. If missing, calls default.
  You should generally call either HasTargetFunction() or HasEffectFunction() first to back out if not compatible

  @param name     Function to try calling
  @param default  If a function, then the function to use if the named function is missing
                  If not a function, value to return if the named function is missing
]]
function pawnMove.CallFunction(name, default, ...)
  -- get the pawns move skill or the default logic
  local moveSkill = _G[Pawn:GetType()].MoveSkill

  -- move skill overrides this? use their logic
  if moveSkill ~= nil and moveSkill[name] ~= nil then
    return moveSkill[name](moveSkill, ...)
  end

  -- if given a function, call it with the parameters
  if type(default) == "function" then
    return default(...)
  end

  -- if not a function, return default as a value
  return default
end

return pawnMove
