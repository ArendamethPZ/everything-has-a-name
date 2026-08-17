require "ISUI/ISInventoryPage"
ISRenameEverything = ISRenameEverything or {}

local _ISInventoryPage_createChildren = ISInventoryPage.createChildren
local _ISInventoryPage_prerender = ISInventoryPage.prerender

local disallowedTypes = {
    ["floor"] = true,
    ["TruckBed"] = true,
    ["SeatFrontLeft"] = true,
    ["SeatFrontRight"] = true,
    ["SeatRearLeft"] = true,
    ["SeatRearRight"] = true,
    ["GloveBox"] = true
}

local function canRenameContainer(instance)
    if not instance then return false end
    if instance.onCharacter then return false end
    if not instance.inventory then return false end
    if disallowedTypes[instance.inventory:getType()] then return false end
    if not instance.inventory:getParent() then return false end
    return true
end

local function drawRenameBtn(page, btn, icon, disabled)
    local brightness = btn.mouseOver and 0.22 or 0.12
    if disabled then brightness = 0.06 end
    btn:drawTextureScaled(page.buttonTex.bg, 0, 0, btn.width, btn.height, 1, brightness, brightness, brightness)
    btn:drawTextureScaled(page.buttonTex.border, 0, 0, btn.width, btn.height, 1, 0.4, 0.4, 0.4)
    if icon then
        local iconSize = btn.width * 0.8
        local xy = (btn.width - iconSize) / 2
        local alpha = disabled and 0.35 or 0.85
        btn:drawTextureScaled(icon, xy, xy, iconSize, iconSize, alpha, 0.8, 0.8, 0.8)
    end
    if btn.updateTooltip then btn:updateTooltip() end
end

local function findTitleWidth(instance)
    local text = ""
    if not instance then return 0 end
    if not instance.inventoryPane then return 0 end

    if instance.title and not instance.onCharacter then
        text = instance.title
        if instance.inventoryPane.inventory and instance.inventoryPane.inventory:getParent() then
            local fireTile = instance.inventoryPane.inventory:getParent()
            local campfire = CCampfireSystem.instance:getLuaObjectOnSquare(fireTile:getSquare())
            if campfire then
                text = text .. ": " .. (ISCampingMenu.timeString(luautils.round(campfire.fuelAmt)))
            elseif fireTile and fireTile:isFireInteractionObject() then
                if fireTile:isPropaneBBQ() and not fireTile:hasPropaneTank() then
                    text = text .. ": " .. getText("IGUI_BBQ_NeedsPropaneTank")
                else
                    text = text .. ": " .. tostring(ISCampingMenu.timeString(fireTile:getFuelAmount()))
                end
            end
        end
        if instance.inventoryPane.inventory and instance.inventoryPane.inventory:isOccupiedVehicleSeat() then
            text = text .. " " .. getText("IGUI_invpage_Occupied")
        end
    end

    return getTextManager():MeasureStringX(UIFont.Small, text)
end

function ISInventoryPage:createChildren()
    _ISInventoryPage_createChildren(self)
    local vars = SandboxVars.EverythingHasAName
    if not vars.CanRenameContainers then return end

    -- Cache once instead of re-checking getActivatedMods()
    self.cleanUIActive = getActivatedMods():contains("CleanUI")

    if self.cleanUIActive then
        local renameBtnCleanUIIcon = getTexture("media/ui/Icon_Container_Rename.png")
        self.renameBtn = ISButton:new(
            0, 0, self.titleButtonSize, self.titleButtonSize, "", self, ISInventoryPage.OnRenameContainer
        )
        self.renameBtn:initialise()
        self.renameBtn.prerender = function (btn)
            if not btn:getIsVisible() then return end
            btn.tooltip = getText("ContextMenu_renameButton")
            drawRenameBtn(self, btn, renameBtnCleanUIIcon, false)
        end
        self:addChild(self.renameBtn)
        return
    end

    local weightWid = math.max(90, getTextManager():MeasureStringX(UIFont.Small, "99.99 / 99") + 10)
    self.titleButton = ISButton:new(
        self.width - 20 - weightWid, 0, 0, self:titleBarHeight(), "", self, ISInventoryPage.OnRenameContainer
    )
    self.titleButton:initialise()
    self.titleButton.borderColor.a = 0.0
    self.titleButton.backgroundColor.a = 0.0
    self.titleButton.backgroundColorMouseOver.a = 0.7
    self.titleButton:setTooltip(getText("ContextMenu_renameButton"))
    self:addChild(self.titleButton)
    self.titleButton:setVisible(false)
end

function ISInventoryPage:prerender()
    if canRenameContainer(self) then
        local modData = self.inventory:getParent():getModData()
        if modData.renameEverything_name and modData.renameEverything_name ~= "" then
            self.title = modData.renameEverything_name
        end
    end

    if self.cleanUIActive then
        return _ISInventoryPage_prerender(self)
    end

    _ISInventoryPage_prerender(self)

    if canRenameContainer(self) and self.title then
        local weightWid = getTextManager():MeasureStringX(UIFont.Small, "9999.99 / 9999") + 30

        local fullTextWidth = findTitleWidth(self)
        local titleWidth = getTextManager():MeasureStringX(UIFont.Small, self.title)

        local textRightEdge = self.width - 20 - weightWid
        local textLeftEdge = textRightEdge - fullTextWidth

        local btnX = textLeftEdge
        local btnW = math.min(titleWidth, fullTextWidth)

        local leftMargin = self.infoButton:getRight() + 4
        if btnX < leftMargin then
            btnW = btnW - (leftMargin - btnX)
            btnX = leftMargin
        end

        if btnW > 0 then
            self.titleButton:setVisible(true)
            self.titleButton:setX(btnX)
            self.titleButton:setY(0)
            self.titleButton:setWidth(btnW)
            self.titleButton:setTitle(self.title)
        else
            self.titleButton:setVisible(false)
        end
    else
        self.titleButton:setVisible(false)
    end
end

function ISInventoryPage:OnRenameContainer()
    if not canRenameContainer(self) then return end

    -- create a modal dialog box with a text input field
    local modal = ISTextBox:new(
        0, 0, 280, 180, getText("ContextMenu_label_containers"), self.title, nil, ISInventoryPage.onRenameContainerClick,
        self.player, self.inventory
    )
    modal:initialise()
    modal:addToUIManager()

    modal.entry:focus()
end

function ISInventoryPage:onRenameContainerClick(button, inventory)
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

-- ----------------------------------------------------------------------------------------------------- --
-- CleanUI split-transfer-button layout hook
-- ----------------------------------------------------------------------------------------------------- --
local function ISRenameEverything_attachCleanUILayoutHook()
    local vars = SandboxVars.EverythingHasAName
    if not vars.CanRenameContainers then return end

    if ISInventoryPage.__renameEverythingLayoutPatched then return end
    if not ISInventoryPage.updateCleanUITransferButtonLayout then return end

    ISInventoryPage.__renameEverythingLayoutPatched = true
    local orig_updateLayout = ISInventoryPage.updateCleanUITransferButtonLayout

    function ISInventoryPage:updateCleanUITransferButtonLayout(titleBarHeight)
        orig_updateLayout(self, titleBarHeight)

        if not self.renameBtn then return end

        local useSplitButtons = CleanUI_getTransferButtonLayout() == "2"
        local shouldShow = useSplitButtons and canRenameContainer(self)

        self.renameBtn:setVisible(shouldShow)
        if not shouldShow then return end

        -- self.cleanUITransferButtonsLeftX was just set by the original function
        -- to the x of the current leftmost button (normally transferMethodButton).
        local y = (titleBarHeight - self.titleButtonSize) / 2
        local x = self.cleanUITransferButtonsLeftX - self.padding - self.renameBtn.width

        self.renameBtn:setX(x)
        self.renameBtn:setY(y)

        -- keep the tracker accurate in case another mod patches after this one
        self.cleanUITransferButtonsLeftX = x
    end
end

Events.OnGameStart.Add(ISRenameEverything_attachCleanUILayoutHook)
