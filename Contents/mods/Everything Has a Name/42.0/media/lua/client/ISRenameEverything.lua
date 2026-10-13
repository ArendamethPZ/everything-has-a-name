ISRenameEverything = ISRenameEverything or {}

require "ISInventoryPaneContextMenu"

ISRenameEverything.isRenameable = function (item)
	local isRenameable = true

	if instanceof(item, "MapItem") then
		isRenameable = false
	elseif instanceof(item, "InventoryContainer") then
		isRenameable = false
	end

	return isRenameable
end

-- Items on the ground (or otherwise outside a container) have no ItemContainer
ISRenameEverything.getSimilarItems = function (item)
	local container = item and item:getContainer()
	if not container then return nil end
	return container:getItemsFromType(item:getType())
end

ISRenameEverything.createMenu = function (player, context, items)
	local vars = SandboxVars.EverythingHasAName
	if not vars.CanRenameItems then return end

	local itemToRename = nil
	local playerObj = getSpecificPlayer(player)

	for i, v in ipairs(items) do
		local item = v

		if not instanceof(v, "InventoryItem") then
			item = v.items[1]
		end

		if ISRenameEverything.isRenameable(item) then
			itemToRename = item
		end
	end

	if itemToRename then
		if vars.OnlyAdminCanRenameItems then
			if isAdmin() or isDebugEnabled() then
				if not isClient() then -- The player is playing Solo
					context:addOption(
						getText("ContextMenu_renameButton"), itemToRename, ISRenameEverything.onRenameItem, player
					)

					-- Check if the item is a stack and if true, add option to rename whole stack
					local similarItems = ISRenameEverything.getSimilarItems(itemToRename)
					if similarItems and similarItems:size() > 1 then
						context:addOption(
							getText("ContextMenu_renameStackButton"), similarItems, ISRenameEverything.onRenameStack,
							player
						)
					end
				else -- The player is playing in multiplayer
					if itemToRename:getContainer() and itemToRename:getContainer() ~= playerObj:getInventory() then -- Player is trying to rename an item that is not in his inventory
						local renameButton = context:addOption(
							getText("ContextMenu_renameButton"), itemToRename, ISRenameEverything.onRenameItem, player
						)

						-- Check if the item is a stack and if true, add option to rename whole stack
						local similarItems = ISRenameEverything.getSimilarItems(itemToRename)

						if similarItems and similarItems:size() > 1 then
							local renameStackButton = context:addOption(
								getText("ContextMenu_renameStackButton"), similarItems, ISRenameEverything.onRenameStack, player
							)

							renameStackButton.notAvailable = true
							local renameStackButtontooltip = ISToolTip:new()
							renameStackButtontooltip:initialise()
							renameStackButtontooltip:setVisible(false)
							renameStackButtontooltip.description = "<RED>" .. getText("ContextMenu_renameMainInventoryOnly")
							renameStackButton.toolTip = renameStackButtontooltip
						end

						renameButton.notAvailable = true
						local renameButtonDesc = "<RED>" .. getText("ContextMenu_renameMainInventoryOnly")
						local renameButtontooltip = ISToolTip:new()
						renameButtontooltip:initialise()
						renameButtontooltip:setVisible(false)
						renameButtontooltip.description = renameButtonDesc
						renameButton.toolTip = renameButtontooltip
					else
						context:addOption(
							getText("ContextMenu_renameButton"), itemToRename, ISRenameEverything.onRenameItem, player
						)

						-- Check if the item is a stack and if true, add option to rename whole stack
						local similarItems = ISRenameEverything.getSimilarItems(itemToRename)
						if similarItems and similarItems:size() > 1 then
							context:addOption(getText("ContextMenu_renameStackButton"), similarItems, ISRenameEverything.onRenameStack, player)
						end
					end
				end
			end
		else
			if not isClient() then -- The player is playing Solo
				-- Rename Single item
				context:addOption(
					getText("ContextMenu_renameButton"), itemToRename, ISRenameEverything.onRenameItem, player
				)

				-- Check if the item is a stack and if true, add option to rename whole stack
				local similarItems = ISRenameEverything.getSimilarItems(itemToRename)
				if similarItems and similarItems:size() > 1 then
					context:addOption(getText("ContextMenu_renameStackButton"), similarItems, ISRenameEverything.onRenameStack, player)
				end
			else -- The player is playing multiplayer
				if itemToRename:getContainer() and itemToRename:getContainer() ~= playerObj:getInventory() then -- Player is trying to rename an item that is not in his inventory
					local renameButton = context:addOption(
						getText("ContextMenu_renameButton"), itemToRename, ISRenameEverything.onRenameItem, player
					)

					-- Check if the item is a stack and if true, add option to rename whole stack
					local similarItems = ISRenameEverything.getSimilarItems(itemToRename)

					if similarItems and similarItems:size() > 1 then
						local renameStackButton = context:addOption(
							getText("ContextMenu_renameStackButton"), similarItems, ISRenameEverything.onRenameStack, player
						)

						renameStackButton.notAvailable = true
						local renameStackButtontooltip = ISToolTip:new()
						renameStackButtontooltip:initialise()
						renameStackButtontooltip:setVisible(false)
						renameStackButtontooltip.description = "<RED>" .. getText("ContextMenu_renameMainInventoryOnly")
						renameStackButton.toolTip = renameStackButtontooltip
					end

					renameButton.notAvailable = true
					local renameButtonDesc = "<RED>" .. getText("ContextMenu_renameMainInventoryOnly")
					local renameButtontooltip = ISToolTip:new()
					renameButtontooltip:initialise()
					renameButtontooltip:setVisible(false)
					renameButtontooltip.description = renameButtonDesc
					renameButton.toolTip = renameButtontooltip
				else
					context:addOption(
						getText("ContextMenu_renameButton"), itemToRename, ISRenameEverything.onRenameItem, player
					)

					-- Check if the item is a stack and if true, add option to rename whole stack
					local similarItems = ISRenameEverything.getSimilarItems(itemToRename)
					if similarItems and similarItems:size() > 1 then
						context:addOption(getText("ContextMenu_renameStackButton"), similarItems, ISRenameEverything.onRenameStack, player)
					end
				end
			end
		end
	end
end

-- Logic for renaming one single item
ISRenameEverything.onRenameItem = function (item, player)
	local modal = ISTextBox:new(
		0, 0, 280, 180, getText("ContextMenu_label_items"), item:getName(), nil, ISRenameEverything.onRenameItemClick,
		player, getSpecificPlayer(player), item
	)
	modal:initialise()
	modal:addToUIManager()
	modal.entry:focus()
end

function ISRenameEverything:onRenameItemClick(button, player, item)
	if button.internal == "OK" then
		if button.parent.entry:getText() and button.parent.entry:getText() ~= "" then
			local newName = button.parent.entry:getText()
			if isClient() then
				sendClientCommand(player, "RenameEverything", "renameItem", { name = newName, itemId = item:getID() })
				return
			end

			if instanceof(item, "Moveable") then
				item:getModData().renameEverything_name = newName
			elseif instanceof(item, "Radio") then
				item:getModData().renameEverything_name = newName
			else
				item:getModData().renameEverything_name = newName
				item:setName(button.parent.entry:getText())
			end
			item:setCustomName(true)

			local pdata = getPlayerData(player:getPlayerNum())
			pdata.playerInventory:refreshBackpacks()
			pdata.lootInventory:refreshBackpacks()
		end
	end
end

-- Logic for renaming a stack
ISRenameEverything.onRenameStack = function (items, player)
	local firstItemName

	for j = 1, items:size() do
		local item = items:get(j - 1)
		firstItemName = item:getName()
		break
	end

	local modal = ISTextBox:new(
		0, 0, 280, 180, getText("ContextMenu_renameStackButton"), firstItemName, nil,
		ISRenameEverything
			.onRenameStackClick,
		player, getSpecificPlayer(player), items
	)
	modal:initialise()
	modal:addToUIManager()
	modal.entry:focus()
end

function ISRenameEverything:onRenameStackClick(button, player, items)
	if button.internal == "OK" then
		if button.parent.entry:getText() and button.parent.entry:getText() ~= "" then
			local newName = button.parent.entry:getText()
			if isClient() then
				local itemIds = {}
				for j = 1, items:size() do
					local item = items:get(j - 1)
					table.insert(itemIds, item:getID())
				end

				sendClientCommand(player, "RenameEverything", "renameStack", { name = newName, itemIds = itemIds })
				return
			else
				for j = 1, items:size() do
					local item = items:get(j - 1)
					if instanceof(item, "Moveable") then
						item:getModData().renameEverything_name = newName
					elseif instanceof(item, "Radio") then
						item:getModData().renameEverything_name = newName
					else
						item:setName(button.parent.entry:getText())
					end
					item:setCustomName(true)
				end
				local pdata = getPlayerData(player:getPlayerNum())
				pdata.playerInventory:refreshBackpacks()
				pdata.lootInventory:refreshBackpacks()
			end
		end
	end
end

Events.OnFillInventoryObjectContextMenu.Add(ISRenameEverything.createMenu)
