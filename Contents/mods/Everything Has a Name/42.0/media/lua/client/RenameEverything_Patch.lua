do -- simple injection
    local m = __classmetatables[zombie.inventory.types.Moveable.class].__index
    local r = __classmetatables[zombie.inventory.types.Radio.class].__index

    local m_old_fn = m.getName
    local r_old_fn = r.getName

    m.getName = function(self, ...)
        -- check custom name here
        if self:hasModData() then
            local itemModData = self:getModData()
            if itemModData.renameEverything_name then
                return itemModData.renameEverything_name
            end
        end
        return m_old_fn(self, ...)
    end

    r.getName = function(self, ...)
        -- check custom name here
        if self:hasModData() then
            local itemModData = self:getModData()
            if itemModData.renameEverything_name then
                return itemModData.renameEverything_name
            end
        end
        return r_old_fn(self, ...)
    end
end
