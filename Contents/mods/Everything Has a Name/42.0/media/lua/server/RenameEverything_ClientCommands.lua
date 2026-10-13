local RenameEverythingClientCommands = {}

local MAX_NAME_LENGTH = 256
local MAX_STACK_SIZE = 500

-- The client UI already hides/disables renaming based on the sandbox options, but a
-- client can send these commands directly, so every rule is enforced here again.
local function getOptions()
    return SandboxVars and SandboxVars.EverythingHasAName or {}
end

local function isValidName(name)
    return type(name) == "string" and name ~= "" and #name <= MAX_NAME_LENGTH
end

local function isAdminPlayer(player)
    return player.getAccessLevel and player:getAccessLevel() == "admin"
end

local function canRenameItems(player)
    local vars = getOptions()
    if vars.CanRenameItems == false then return false end
    if vars.OnlyAdminCanRenameItems and not isAdminPlayer(player) then return false end
    return true
end

local function applyItemName(item, name)
    if instanceof(item, "Moveable") or instanceof(item, "Radio") then
        item:getModData().renameEverything_name = name
    else
        item:getModData().renameEverything_name = name
        item:setName(name)
    end
    item:setCustomName(true)
    item:syncItemFields()
end

function RenameEverythingClientCommands.renameVehicle(player, args)
    if not isValidName(args.name) or type(args.vehicleId) ~= "number" then return end

    local vars = getOptions()
    if vars.CanRenameVehicles == false then return end

    local isAdmin = isAdminPlayer(player)
    if vars.OnlyAdminCanRenameVehicles and not isAdmin then return end

    local vehicle = getVehicleById(args.vehicleId)
    if not vehicle then
        print("[RenameEverything] Could not find vehicle with ID: " .. tostring(args.vehicleId))
        return
    end

    -- Same rule as the client: keys in inventory, or keys left in the ignition
    if not vars.OnlyAdminCanRenameVehicles and vars.MustHaveKeys and not isAdmin then
        local hasKey = player:getInventory():haveThisKeyId(vehicle:getKeyId()) or vehicle:isKeysInIgnition()
        if not hasKey then return end
    end

    local part = vehicle:getPartById("GloveBox") -- We fetch an unremoveable part to store the vehicle name in, since vehicles do not have moddata to store the name
    if not part then return end

    part:getModData().renameEverything_vehicleName = args.name
    vehicle:transmitPartModData(part)
end

-- RenameEverything_ClientCommands.lua (server)
function RenameEverythingClientCommands.renameItem(player, args)
    if not canRenameItems(player) then return end
    if not isValidName(args.name) or type(args.itemId) ~= "number" then return end

    local inventory = player:getInventory()
    local item = inventory:getItemWithIDRecursiv(args.itemId)

    if not item then
        print("[RenameEverything] Could not find item with ID: " .. tostring(args.itemId))
        return
    end

    applyItemName(item, args.name)
end

function RenameEverythingClientCommands.renameStack(player, args)
    if not canRenameItems(player) then return end
    if not isValidName(args.name) or type(args.itemIds) ~= "table" then return end

    local inventory = player:getInventory()

    for i, itemId in ipairs(args.itemIds) do
        if i > MAX_STACK_SIZE then break end

        local item = type(itemId) == "number" and inventory:getItemWithIDRecursiv(itemId) or nil
        if item then
            applyItemName(item, args.name)
        else
            print("[RenameEverything] Could not find item with ID: " .. tostring(itemId))
        end
    end
end

local function OnClientCommand(module, command, player, args)
    if module ~= 'RenameEverything' then return end

    local handler = RenameEverythingClientCommands[command]
    if not handler or type(args) ~= "table" then return end

    handler(player, args)
end

Events.OnClientCommand.Add(OnClientCommand)
