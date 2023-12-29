local self=require('openmw.self')
local types = require('openmw.types')
local nearby=require('openmw.nearby')
local util = require('openmw.util')
local core = require('openmw.core')


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