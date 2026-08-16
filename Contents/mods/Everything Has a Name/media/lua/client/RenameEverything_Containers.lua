ISRenameEverything = ISRenameEverything or {};

-- Save the original createChildren function for later use
local originalCreateChildren = ISInventoryPage.createChildren

-- Override the ISInventoryPage.createChildren function
function ISInventoryPage:createChildren()
    -- Call the original createChildren function first
    originalCreateChildren(self)

    -- Create a button to rename the container
    local weightWid = math.max(90, getTextManager():MeasureStringX(UIFont.Small, "99.99 / 99") + 10)
    self.titleButton = ISButton:new(self.width - 20 - weightWid, 0, 0, self:titleBarHeight(), "", self,
        ISInventoryPage.OnRenameContainer)
    self.titleButton:initialise()
    self.titleButton.borderColor.a = 0.0
    self.titleButton.backgroundColor.a = 0.0
    self.titleButton.backgroundColorMouseOver.a = 0.7
    self.titleButton:setTooltip(getText("ContextMenu_renameButton"))
    self:addChild(self.titleButton)
    self.titleButton:setVisible(false)
end

local originalPrerender = ISInventoryPage.prerender


local disallowedTypes = { "floor", "TruckBed", "SeatFrontLeft", "SeatFrontRight", "SeatRearLeft", "SeatRearRight",
    "GloveBox" }

function isItemTypeNotAllowed(itemType)
    for _, disallowedType in ipairs(disallowedTypes) do
        if itemType == disallowedType then
            return false -- The itemType is in the disallowedTypes list
        end
    end
    return true -- The itemType is not in the disallowedTypes list
end

function ISInventoryPage:prerender()
    -- check if the inventory has a parent and modData for custom name exists
    if self.title and not self.onCharacter and isItemTypeNotAllowed(self.inventory:getType()) and self.inventory:getParent() then
        local modData = self.inventory:getParent():getModData()
        if modData.renameEverything_name and modData.renameEverything_name ~= "" then
            -- if custom name exists, use it as the new title
            self.title = modData.renameEverything_name
        end
    end

    -- call the original prerender function
    originalPrerender(self)

    -- check if the conditions for a custom title are still met
    if self.title and not self.onCharacter and isItemTypeNotAllowed(self.inventory:getType()) and self.inventory:getParent() then
        local weightWid = getTextManager():MeasureStringX(UIFont.Small, "99.99 / 99")
        weightWid = math.max(90, weightWid + 10)
        local textWidth = getTextManager():MeasureStringX(UIFont.Small, self.title)
        local x = self.width - 25 - weightWid - textWidth;

        -- render title bar texture over the default text to hide it
        self:drawTextureScaled(self.titlebarbkg, x, 1, textWidth + 10, self:titleBarHeight() - 2, 1, 1, 1, 1);

        -- update button
        self.titleButton:setVisible(true)
        self.titleButton:setX(x)
        self.titleButton:setTitle(self.title)
        self.titleButton:setWidthToTitle()
    else
        -- if custom title not applicable, hide the button
        self.titleButton:setVisible(false)
    end
end

function ISInventoryPage:OnRenameContainer()
    -- create a modal dialog box with a text input field
    local modal = ISTextBox:new(0, 0, 280, 180, getText("ContextMenu_label_containers"), self.title, nil,
        ISInventoryPage.onRenameContainerClick, self.player, self.inventory)
    modal:initialise()
    modal:addToUIManager()

    -- set the focus to the text input field so the player can start typing right away
    modal.entry:focus()
end

function ISInventoryPage:onRenameContainerClick(button, inventory)
    -- Check if the OK button was clicked
    if button.internal == "OK" then
        -- Check if the textbox input is not empty
        if button.parent.entry:getText() and button.parent.entry:getText() ~= "" then
            -- Set the custom name for the container in the parent's mod data to the input text
            inventory:getParent():getModData().renameEverything_name = button.parent.entry:getText()
            -- Transmit the mod data to synchronize it for multiplayer
            inventory:getParent():transmitModData()
        end
    end
end
