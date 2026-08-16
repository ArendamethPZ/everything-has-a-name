ISRenameEverything = ISRenameEverything or {};

local original_ISMoveableSpriteProps_getInfoPanelFlagsGeneral = ISMoveableSpriteProps.getInfoPanelFlagsGeneral

function ISMoveableSpriteProps:getInfoPanelFlagsGeneral(square, object, ...)
  if instanceof(item, "Moveable") or instanceof(item, "Radio") then
    local obj_name = object:getModData().renameEverything_name
  end

  -- pre stuff
  local result = original_ISMoveableSpriteProps_getInfoPanelFlagsGeneral(self, square, object, ...)
  -- post stuff

  if instanceof(item, "Moveable") or instanceof(item, "Radio") then
    if obj_name then
      InfoPanelFlags.name = obj_name
    end
  end

  return result
end

local original_ISMoveableSpriteProps_placeMoveable = ISMoveableSpriteProps.placeMoveable

function ISMoveableSpriteProps:placeMoveable(character, square, origSpriteName, ...)
  local item = self:findInInventory(character, origSpriteName);
  local item_name = nil

  if instanceof(item, "Moveable") or instanceof(item, "Radio") then
    item_name = item:getModData().renameEverything_name
  end

  -- pre stuff
  local result = original_ISMoveableSpriteProps_placeMoveable(self, character, square, origSpriteName, ...)
  -- post stuff

  if instanceof(item, "Moveable") or instanceof(item, "Radio") then
    local worldObj = self:findOnSquare(square, self.spriteName);


    if item_name then
      worldObj:getModData().renameEverything_name = item_name
    end
  end
  return result
end

local original_ISMoveableSpriteProps_pickUpMoveable = ISMoveableSpriteProps.pickUpMoveable
local created_item

function ISMoveableSpriteProps:pickUpMoveable(character, square, ...)
  local worldObj = self:findOnSquare(square, self.spriteName);

  -- pre stuff
  local result = original_ISMoveableSpriteProps_pickUpMoveable(self, character, square, ...)
  -- post stuff

  local worldObj_name = worldObj:getModData().renameEverything_name

  if worldObj_name then
    created_item:getModData().renameEverything_name = worldObj_name
  end
  return result
end

ArendamethUtils.patchClassMethod(zombie.inventory.ItemContainer.class, "AddItem", function(original_fn)
  return function(self, item, ...)
    if instanceof(item, "Moveable") or instanceof(item, "Radio") then
      created_item = item
    end

    --pre stuff
    local result = original_fn(self, item, ...)
    -- post stuff

    return result
  end
end)
