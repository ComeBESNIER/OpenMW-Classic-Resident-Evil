local self=require('openmw.self')
local types = require('openmw.types')
local nearby=require('openmw.nearby')
local util = require('openmw.util')
local core = require('openmw.core')


local function PelletsEffects(data)
    print(self)
    print(data.enchant)
    print(data.damages)
    types.Actor.stats.dynamic.health(self).current=types.Actor.stats.dynamic.health(self).current-data.damages
    if core.magic.enchantments[data.enchant].type==1 then  --onStrike enchantment
        for i, effect in ipairs(data.enchant.effects) do 
            print(effect)
            types.Actor.activeEffects(self):modify(effect.magnitudeMax,effect.effect)
        end
    end
end

return {
	eventHandlers = {PelletsEffects=PelletsEffects },
	engineHandlers = {
        onUpdate = function()
            
            


	end
    ,
	}
}