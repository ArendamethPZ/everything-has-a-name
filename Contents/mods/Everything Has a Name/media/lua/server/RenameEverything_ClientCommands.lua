local RenameEverythingClientCommands = {}

function RenameEverythingClientCommands.renameVehicle(args)
    local vehicle = getVehicleById(args.vehicleId)
    local part = vehicle:getPartById("GloveBox") --We fetch an unremoveable part to store the vehicle name in, since vehicles do not have moddata to store the name

    part:getModData().renameEverything_vehicleName = args.name
    vehicle:transmitPartModData(part)
end

local function OnClientCommand(module, command, player, args)
    if module == 'RenameEverything' then
        RenameEverythingClientCommands[command](args)
    end
end

Events.OnClientCommand.Add(OnClientCommand)
