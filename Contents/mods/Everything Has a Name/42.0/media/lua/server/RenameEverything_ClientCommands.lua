local RenameEverythingClientCommands = {}

function RenameEverythingClientCommands.renameVehicle(player, args)
    local vehicle = getVehicleById(args.vehicleId)
    local part = vehicle:getPartById("GloveBox") -- We fetch an unremoveable part to store the vehicle name in, since vehicles do not have moddata to store the name

    part:getModData().renameEverything_vehicleName = args.name
    vehicle:transmitPartModData(part)
end

-- RenameEverything_ClientCommands.lua (server)
function RenameEverythingClientCommands.renameItem(player, args)
    local inventory = player:getInventory()
    local item = inventory:getItemWithIDRecursiv(args.itemId)

    if not item then
        print("[RenameEverything] Could not find item with ID: " .. tostring(args.itemId))
        return
    end

    if instanceof(item, "Moveable") or instanceof(item, "Radio") then
        item:getModData().renameEverything_name = args.name
    else
        item:getModData().renameEverything_name = args.name
        item:setName(args.name)
    end
    item:setCustomName(true)
    item:syncItemFields()
end

function RenameEverythingClientCommands.renameStack(player, args)
    local inventory = player:getInventory()

    for _, itemId in ipairs(args.itemIds) do
        local item = inventory:getItemWithIDRecursiv(itemId)
        if item then
            if instanceof(item, "Moveable") or instanceof(item, "Radio") then
                item:getModData().renameEverything_name = args.name
            else
                item:getModData().renameEverything_name = args.name
                item:setName(args.name)
            end
            item:setCustomName(true)
            item:syncItemFields()
        else
            print("[RenameEverything] Could not find item with ID: " .. tostring(itemId))
        end
    end
end

local function OnClientCommand(module, command, player, args)
    if module == 'RenameEverything' then
        RenameEverythingClientCommands[command](player, args)
    end
end

Events.OnClientCommand.Add(OnClientCommand)
