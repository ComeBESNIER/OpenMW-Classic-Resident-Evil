local self=require('openmw.self')
local types = require('openmw.types')
local nearby=require('openmw.nearby')
local util = require('openmw.util')
local core = require('openmw.core')



if core.magic.enchantments[types.Weapon.record(self).enchant]~=nil and types.Item.getEnchantmentCharge(self)==-1 then
                local munitions =tostring(core.magic.enchantments[types.Weapon.record(self).enchant].id)
                local startingmunitions=""
                for i = (string.find(munitions,"_")+1),(string.find(munitions,"_",string.find(munitions,"_")+1)-1) do
                    startingmunitions=startingmunitions..string.char(string.byte(munitions,i))
                end
                core.sendGlobalEvent('setCharge', {Item=self, value=tonumber(startingmunitions)})
                types.Item.itemData(self).condition=10001
end	

local function setCondition(data)
    --print(self)
    --print(data.value)
    types.Item.itemData(self).condition=data.value
    --print(types.Item.itemData(self).condition)
end

return {
	eventHandlers = {setCondition=setCondition },
	engineHandlers = {
        onUpdate = function()
            if self.recordId=="fuel" then
                print(self.cell)
            end

	end
    ,
	}
}