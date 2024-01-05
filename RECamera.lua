-- Save to my_lua_mod/scripts/example/player.lua


local util = require('openmw.util')
local world = require('openmw.world')
local types = require('openmw.types')
local interfaces = require('openmw.interfaces')
local players = world.players
local activecell
local activecam
local targetcam
local lastcam
local lastcell
local MSK={}
local PointP
local L01=nil
local L12=nil
local L23=nil
local L30=nil
local L0P=nil
local L1P=nil
local L2P=nil
local L3P=nil
local BCG=nil
local ROOMS={}


local code ="return({"
for i,book in ipairs(types.Book.records) do
	if string.find(book.id,"_rdt_")~=nil then
		code = code..book.text..","
	end
end
code = code.."})"
ROOMS=util.loadCode(code,{util = require('openmw.util')})()


local function pushContainer(data)
	if data.startPos~=nil then
		data.Container:teleport(data.Container.cell,data.startPos)
	end
	if data.Way=="X+" then
		data.Container:teleport(activecell,util.transform.move(-1,0,0)*data.Container.position)
	end
	if data.Way=="X-" then
		data.Container:teleport(activecell,util.transform.move(1,0,0)*data.Container.position)
	end
	if data.Way=="Y+" then
		data.Container:teleport(activecell,util.transform.move(0,-1,0)*data.Container.position)
	end
	if data.Way=="Y-" then
		data.Container:teleport(activecell,util.transform.move(0,1,0)*data.Container.position)
	end
end


local function Teleport(data)
	if data.actor.parentContainer then
		data.actor:teleport(data.actor.parentContainer.cell,data.position,data.rotation)	
	else
		data.actor:teleport(data.actor.cell,data.position,data.rotation)
	end
end

local function MoveInto(data)

	if data.newItem then
		print(data.newItem)
		if data.actor then
			world.createObject(data.newItem):moveInto(types.Actor.inventory(data.actor))
		elseif data.container then
			world.createObject(data.newItem):moveInto(types.Container.content(data.container))
		end
	elseif data.Item then
		if data.actor then
			data.Item:moveInto(types.Actor.inventory(data.actor))
		elseif data.container then
			data.Item:moveInto(types.Container.content(data.container))
		end
	end
end

local function setCharge(data)
	--print("setcharge"..tostring(data.Item))
	--print("setcharge"..tostring(data.value))
	types.Item.setEnchantmentCharge(data.Item,data.value)
end

local function createAmmosinInventory(data)
	--print("createammo"..tostring(data.ammo))
	--print("createammo"..tostring(data.number))
	--print("createammo"..tostring(data.actor))
	world.createObject(data.ammo,data.number):moveInto(types.Actor.inventory(data.actor))
end


local function RemoveItem(data)
	print("removeditem"..tostring(data.Item))
	print("removeitem"..tostring(data.number))
	data.Item:remove(data.number)
end


---------Essaie pour activer le script des armes dans l'inventaire
--for i, player in ipairs(world.players) do
--	for j, weapon in ipairs(types.Actor.inventory(player):getAll(types.weapons)) do
--		weapon:activateBy(player)
--		--weapon:addScript("scripts/Weapon.lua") 
--	end
--end



return {
	eventHandlers = { PushContainer = pushContainer, Teleport=Teleport,MoveInto=MoveInto, setCharge=setCharge; RemoveItem=RemoveItem, createAmmosinInventory=createAmmosinInventory },
    engineHandlers = {
        onUpdate = function()

        	




			---actors drop objects on death
			for i, actor in ipairs(world.activeActors) do
				if types.Actor.isDead(actor)==true then
					if types.Actor.inventory(actor)~=nil then
						for j,object in ipairs(types.Actor.inventory(actor):getAll()) do
							--print(object)
							object:teleport(actor.cell.name,actor.position)
						end
					end
				end
			end
        	


        	
            for i, player in ipairs(players) do

        		PointP=util.vector2(player.position.x,player.position.y)
        		activecell=player.cell.name
				--print(activecell)

				for i , container in pairs(player.cell:getAll(types.Container)) do 
					if string.find(types.Container.record(container).mwscript,"climbable")~=nil then
						interfaces.Activation.addHandlerForObject(container,function(container,actor) return false end)
					end
				end


										
				---------transform ammunitions to ammunitions_
				for a, cell in pairs(world.cells) do
					if cell==player.cell then
						for b, ammo in pairs(cell:getAll(types.Weapon)) do
							for c, weapon in pairs(types.Weapon.records) do
								if (ammo.recordId.."_")==weapon.id then
									world.createObject(weapon.id,ammo.count):teleport(activecell,ammo.position)
									ammo:remove()
								end
							end
						end
					end
				end
				------------transform ammunitions_ to ammunitions in inventory
				for i,ammo in pairs(types.Actor.inventory(player):getAll(types.Weapon)) do
					for c, weapon in pairs(types.Weapon.records) do
						if ammo.recordId==(weapon.id.."_") then
							world.createObject(weapon.id,types.Actor.inventory(player):countOf(ammo.recordId)):moveInto(types.Actor.inventory(player))
							ammo:remove()
						end
					end
				end
				----------------------------

				for i,cam in pairs(ROOMS[activecell]) do
					if cam.StartingPoint==PointP then
						activecam=cam.name
					end
				end

				
				for i=0,12 do ------------changer camera depuis MWScript
					if world.mwscript.getGlobalVariables(player)["cam"..i] ==1 then
						activecam=tostring("Cam"..i)
						print(activecam)
					end
				end

				print(ROOMS[activecell][activecam])
				if ROOMS[activecell][activecam].SwitchZone then
					for f,zone in pairs(ROOMS[activecell][activecam].SwitchZone) do
							L01=(zone.Point0-zone.Point1):length()
							L12=(zone.Point1-zone.Point2):length()
							L23=(zone.Point2-zone.Point3):length()
							L30=(zone.Point3-zone.Point0):length()
							L0P=(zone.Point0-PointP):length()
							L1P=(zone.Point1-PointP):length()
							L2P=(zone.Point2-PointP):length()
							L3P=(zone.Point3-PointP):length()
							if (math.acos(((L01*L01-L1P*L1P-L0P*L0P)/(-2*L1P*L0P)))+math.acos(((L12*L12-L2P*L2P-L1P*L1P)/(-2*L2P*L1P)))+math.acos(((L23*L23-L3P*L3P-L2P*L2P)/(-2*L3P*L2P)))+math.acos(((L30*L30-L0P*L0P-L3P*L3P)/(-2*L0P*L3P)))>=6.27) and (math.acos(((L01*L01-L1P*L1P-L0P*L0P)/(-2*L1P*L0P)))+math.acos(((L12*L12-L2P*L2P-L1P*L1P)/(-2*L2P*L1P)))+math.acos(((L23*L23-L3P*L3P-L2P*L2P)/(-2*L3P*L2P)))+math.acos(((L30*L30-L0P*L0P-L3P*L3P)/(-2*L0P*L3P)))<=(2*math.pi))  then
								activecam=zone.Camera
							end
					end
				end



				--print(activecam)
				--print(activecell)
				if activecam~=lastcam or activecell~=lastcell then
					if BGD then
						BGD.enabled=false
					end
					BGD=world.createObject(world.createRecord(types.Activator.createRecordDraft({name=ROOMS[activecell][activecam].bgd.idname,model=('meshes/bgd/'..ROOMS[activecell][activecam].bgd.idname..'.nif')})).id,1)			
					BGD:teleport(activecell,ROOMS[activecell][activecam].bgd.Position,BGD.rotation*util.transform.rotateZ(ROOMS[activecell][activecam].bgd.Anglez)*util.transform.rotateX(ROOMS[activecell][activecam].bgd.Anglex))
					
					CamRotation=util.vector2(ROOMS[activecell][activecam].Pitch,ROOMS[activecell][activecam].Yaw)
					player:sendEvent('CameraPos', {source=player.object, CamPos=ROOMS[activecell][activecam].Position, CamAng=CamRotation,ActiveCam=activecam,ActiveBkg=BGD})
        							
					-------------- Creation des Masks
					--print(ROOMS[activecell][activecam].MASK.mask1.scale)
					for d, msk in pairs(ROOMS[activecell][activecam].MASK) do
						print(ROOMS[activecell][activecam].MASK[d].scale)
						if MSK['MSK'..d] then
							print(MSK['MSK'..d])
							MSK['MSK'..d].enabled=false
						end
						if ROOMS[activecell][activecam].MASK[d].scale~=0 then
							MSK['MSK'..d]=world.createObject(world.createRecord(types.Activator.createRecordDraft({name=ROOMS[activecell][activecam].MASK[d].idname,model=('meshes/Masks/'..ROOMS[activecell][activecam].MASK[d].idname..'.nif')})).id,1)
							--print(MSK['MSK'..d])
							MSK['MSK'..d]:teleport(activecell,ROOMS[activecell][activecam].MASK[d].position,MSK['MSK'..d].rotation*util.transform.rotateZ(ROOMS[activecell][activecam].bgd.Anglez)*util.transform.rotateX(ROOMS[activecell][activecam].bgd.Anglex))
							MSK['MSK'..d]:setScale(ROOMS[activecell][activecam].MASK[d].scale)
						end
					end
				end

				lastcam=activecam
				lastcell=activecell
			end		
		end
	}
}
