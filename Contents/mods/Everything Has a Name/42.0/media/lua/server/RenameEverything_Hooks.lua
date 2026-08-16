-- -- local _ISDropWorldItemAction_complete = ISDropWorldItemAction.complete
-- -- function ISDropWorldItemAction:complete()
-- --     local item_name = nil
-- --     if instanceof(self.item, "Moveable") or instanceof(self.item, "Radio") then
-- --         local modData = self.item:getModData()
-- --         item_name = modData and modData.renameEverything_name
-- --     end

-- --     local result = _ISDropWorldItemAction_complete(self)

-- --     if item_name and self.item then
-- --         self.item:getModData().renameEverything_name = item_name
-- --         if isServer() or isClient() then
-- --             self.item:transmitModData()
-- --         end
-- --     end

-- --     return result
-- -- end
-- function ISDropWorldItemAction:complete()
--     if self.item:getType() == "CandleLit" then
--         local candle = instanceItem("Base.Candle")
--         self.character:getInventory():AddItem(candle)

--         candle:setUsedDelta(self.item:getCurrentUsesFloat())
--         candle:setCondition(self.item:getCondition())
--         candle:setFavorite(self.item:isFavorite())

--         sendAddItemToContainer(self.character:getInventory(), candle)

--         self.character:getInventory():Remove(self.item)
--         sendRemoveItemFromContainer(self.character:getInventory(), self.item)

--         self.item = candle
--     end

--     if self.item:getType() == "Lantern_HurricaneLit" then
--         local candle = instanceItem("Base.Lantern_Hurricane")
--         self.character:getInventory():AddItem(candle)

--         candle:setUsedDelta(self.item:getCurrentUsesFloat())
--         candle:setCondition(self.item:getCondition())
--         candle:setFavorite(self.item:isFavorite())

--         sendAddItemToContainer(self.character:getInventory(), candle)

--         self.character:getInventory():Remove(self.item)
--         sendRemoveItemFromContainer(self.character:getInventory(), self.item)
--         self.item = candle
--     end

--     local worldItem = self.sq:AddWorldInventoryItem(self.item, self.xoffset, self.yoffset, self.zoffset, false)
--     if worldItem then
--         worldItem:setWorldZRotation(self.rotation)
--         local modData = self.item:getModData()
--         local item_name = modData and modData.renameEverything_name
--         if item_name then
--             if instanceof(worldItem, "Moveable") then
--                 worldItem:getModData().renameEverything_name = item_name
--             elseif instanceof(worldItem, "Radio") then
--                 worldItem:getModData().renameEverything_name = item_name
--             else
--                 worldItem:getModData().renameEverything_name = item_name
--                 worldItem:setName(item_name)
--             end
--             worldItem:setCustomName(true)
--         end
--         if worldItem:getWorldItem() then
--             worldItem:getWorldItem():setIgnoreRemoveSandbox(true) -- avoid the item to be removed by the SandboxOption WorldItemRemovalList
--             worldItem:getWorldItem():setExtendedPlacement(false)
--             worldItem:getWorldItem():transmitCompleteItemToClients()
--         end
--     end
--     self.character:getInventory():Remove(self.item)
--     sendRemoveItemFromContainer(self.character:getInventory(), self.item)

--     if instanceof(worldItem, "Radio") then
--         local square = worldItem:getWorldItem():getSquare()
--         local _obj = IsoRadio.new(getCell(), square, nil)
--         local deviceData = worldItem:getDeviceData()
--         if deviceData then
--             _obj:setDeviceData(deviceData)
--         end

--         _obj:getModData().RadioItemID = worldItem:getID()
--         square:AddSpecialObject(_obj, square:getObjects():size())

--         _obj:transmitCompleteItemToClients()
--         _obj:transmitModData()

--         triggerEvent("OnObjectAdded", _obj)
--         square:RecalcProperties()
--         square:RecalcAllWithNeighbours(true)
--     end

--     return true
-- end
