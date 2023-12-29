-- Save to my_lua_mod/scripts/example/player.lua


local util = require('openmw.util')
local world = require('openmw.world')
local types = require('openmw.types')
local interfaces = require('openmw.interfaces')
local players = world.players
local Player
local activecell=nil
local activecam=nil
local targetcam=nil
local CamRotation=nil
local MSK={}
local PointP=nil
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



for i,book in ipairs(types.Book.records) do
	if string.find(book.id,"_rdt_")~=nil then
		local code = "ROOMS[\""..string.upper(string.gsub(book.id,"_rdt_","")).."\"]="..book.text
		util.loadCode(code,{ROOMS = ROOMS,util = require('openmw.util')})()
	end
end


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
	eventHandlers = { PushContainer = pushContainer, Teleport=Teleport, setCharge=setCharge; RemoveItem=RemoveItem, createAmmosinInventory=createAmmosinInventory },
    engineHandlers = {
        onUpdate = function()




			



        	
        	
            for i, player in pairs(players) do
        		if player.type == types.Player then
        			Player=player
        			PointP=util.vector2(Player.position.x,Player.position.y)
        			activecell=Player.cell.name
        		end
        	end
        	
			for i , container in ipairs(Player.cell:getAll(types.Container)) do 
				if string.find(types.Container.record(container).mwscript,"climbable")~=nil then
					interfaces.Activation.addHandlerForObject(container,function(container,actor) return false end)
				end
			end



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
        	
        	        	
        	---------transform ammunitions to ammunitions_
        	for a, cell in pairs(world.cells) do
        		if cell==Player.cell then
        			for b, ammo in pairs(cell:getAll(types.Weapon)) do
            			for c, weapon in pairs(types.Weapon.records) do
							if (ammo.recordId.."_")==weapon.id then
								world.createObject(weapon.id,ammo.count):teleport(activecell,ammo.position)
								ammo:remove()
							end
							
							---transform les "recordId_X" en X "recordId_"
							if string.find(ammo.recordId,"_")~=nil and string.find(ammo.recordId,"_")<string.len(ammo.recordId) and string.sub(ammo.recordId,1,string.find(ammo.recordId,"_"))==weapon.id then
								world.createObject(weapon.id,tonumber(string.sub(ammo.recordId,string.find(ammo.recordId,"_")+1,string.len(ammo.recordId)))):teleport(activecell,ammo.position)
								ammo:remove()
							end

        				end
        			end
        		end
        	end
        	------------transform ammunitions_ to ammunitions in inventory
        	for i,ammo in pairs(types.Actor.inventory(Player):getAll(types.Weapon)) do
        		for c, weapon in pairs(types.Weapon.records) do
	        		if ammo.recordId==(weapon.id.."_") then
      					world.createObject(weapon.id,types.Actor.inventory(Player):countOf(ammo.recordId)):moveInto(types.Actor.inventory(Player))
        				ammo:remove()
		    		end
		   		end
	    	end
        	----------------------------
        	
        	


			----Test projection
			local activateRecord={id="Id",model="Meshes/Blue Herb.nif",name="Name"}
			local bloodGrazeRecordDraft= types.Activator.createRecordDraft(activateRecord)
			local bloodGrazeRecord=world.createRecord(bloodGrazeRecordDraft)
			local blood=world.createObject(bloodGrazeRecord.id,1)
			--local position=util.transform.move(0,0,70)*Player.position+Player.rotation*util.vector3(0,1,0)*100
			--local position=Player.rotation*(Player.position+util.vector3(100,0,0)) --nop : move on X do whatever on Z
			--local position=Player.rotation*util.vector3(100,0,0)+Player.position -- nop : point at -pi/4 on Z and don't move on X
			--local position=Player.rotation*util.transform.move(util.vector3(100,0,0))*Player.position -- nop
			--local position=util.vector3(0,0,100)+Player.position+util.vector3(math.cos(Player.rotation:getPitch()) * math.sin(Player.rotation:getYaw()), math.cos(Player.rotation:getPitch()) * math.cos(Player.rotation:getYaw()),-math.sin(Player.rotation:getPitch()))*100
			--util.vector3(0,0,100)+self.position+util.vector3(math.cos(self.rotation:getPitch()) * math.sin(self.rotation:getYaw()), math.cos(self.rotation:getPitch()) * math.cos(self.rotation:getYaw()),-math.sin(self.rotation:getPitch()))*100
			--blood : teleport(Player.cell, position)




        	
        	
        	--print(activecam)
        	for a, room in pairs(ROOMS) do
        		--print(a)
        		--print(activecell)
        		if a==activecell then
	        		for b, cam in pairs(ROOMS[a].CAMERA) do
	        			--print(b)
	        			for c,numcam in pairs(ROOMS[a].CAMERA[b]) do
	        				--print(c)
        					if c=='StartingPoint' then
        						if PointP.x==ROOMS[a].CAMERA[b].StartingPoint.x and PointP.y==ROOMS[a].CAMERA[b].StartingPoint.y then
            							if BGD==nil then
            								--print(bgd.id)
            								--print(BGD.model)
            								
											BGD=world.createObject(world.createRecord(types.Activator.createRecordDraft({name=ROOMS[a].CAMERA[b].bgd.idname,model=('meshes/bgd/'..ROOMS[a].CAMERA[b].bgd.idname..'.nif')})).id,1)
            								BGD:teleport(activecell,ROOMS[a].CAMERA[b].bgd.Position,BGD.rotation*util.transform.rotateZ(ROOMS[a].CAMERA[b].bgd.Anglez)*util.transform.rotateX(ROOMS[a].CAMERA[b].bgd.Anglex))
            								
            								--------------Creation des Masks
            								for d, msk in pairs(ROOMS[a].CAMERA[b].MASK) do
            									--print(ROOMS[a].CAMERA[b].MASK[d].idname)
            									--print(ROOMS[a].CAMERA[b].MASK[d].position)
            									--print(ROOMS[a].CAMERA[b].MASK[d].scale)
            									if ROOMS[a].CAMERA[b].MASK[d].scale~=0 then
													MSK['MSK'..d]=world.createObject(world.createRecord(types.Activator.createRecordDraft({id=ROOMS[a].CAMERA[b].MASK[d].idname,model=('meshes/Masks/'..ROOMS[a].CAMERA[b].MASK[d].idname..'.nif')})).id,1)
													--print(MSK['MSK'..d])
													MSK['MSK'..d]:teleport(activecell,ROOMS[a].CAMERA[b].MASK[d].position,MSK['MSK'..d].rotation*util.transform.rotateZ(ROOMS[a].CAMERA[b].bgd.Anglez)*util.transform.rotateX(ROOMS[a].CAMERA[b].bgd.Anglex))
													MSK['MSK'..d]:setScale(ROOMS[a].CAMERA[b].MASK[d].scale)
            									end
            								end
									---------------------
            								
            								
            								
            							elseif BGD.cell.name ~= activecell then				
            								BGD.enabled=false
            								BGD=world.createObject(world.createRecord(types.Activator.createRecordDraft({id=ROOMS[a].CAMERA[b].bgd.idname,model=('meshes/bgd/'..ROOMS[a].CAMERA[b].bgd.idname..'.nif')})).id,1)
            								BGD:teleport(activecell,ROOMS[a].CAMERA[b].bgd.Position,BGD.rotation*util.transform.rotateZ(ROOMS[a].CAMERA[b].bgd.Anglez)*util.transform.rotateX(ROOMS[a].CAMERA[b].bgd.Anglex))
            							       
            							       -------------- Creation des Masks
            								for d, msk in pairs(MSK) do
            									if MSK[d]~=false then
													MSK[d].enabled=false
												end
											end
            								
            								for d, msk in pairs(ROOMS[a].CAMERA[b].MASK) do
            									--print(ROOMS[a].CAMERA[b].MASK[d].idname)
            									--print(ROOMS[a].CAMERA[b].MASK[d].position)
            									--print(ROOMS[a].CAMERA[b].MASK[d].scale)
            									if ROOMS[a].CAMERA[b].MASK[d].scale~=0 then
            										MSK['MSK'..d]=world.createObject(world.createRecord(types.Activator.createRecordDraft({id=ROOMS[a].CAMERA[b].MASK[d].idname,model=('meshes/Masks/'..ROOMS[a].CAMERA[b].MASK[d].idname..'.nif')})).id,1)
            										--print(MSK['MSK'..d])
            										MSK['MSK'..d]:teleport(activecell,ROOMS[a].CAMERA[b].MASK[d].position,MSK['MSK'..d].rotation*util.transform.rotateZ(ROOMS[a].CAMERA[b].bgd.Anglez)*util.transform.rotateX(ROOMS[a].CAMERA[b].bgd.Anglex))
            										MSK['MSK'..d]:setScale(ROOMS[a].CAMERA[b].MASK[d].scale)
            									end
            								end
									---------------------
 
            							 end
            							----------------------------------------
            							
            							activecam=(ROOMS[a].CAMERA[b].Name)
            							CamRotation=util.vector2(ROOMS[a].CAMERA[b].Pitch,ROOMS[a].CAMERA[b].Yaw)
            							--print(CamRotation)
										Player:sendEvent('CameraPos', {source=Player.object, CamPos=ROOMS[a].CAMERA[b].Position, CamAng=CamRotation,ActiveCam=activecam,ActiveBkg=BGD})
        							
            							--print(ROOMS[a].CAMERA[b].Name)
            							--print(activecam)
            							--print('ici')
            						end
            					elseif ROOMS[a].CAMERA[b].Name==activecam then
            						--print('la')
            						for e, switch in pairs(ROOMS[a].CAMERA[b]) do
            							--print(d)
            							if e=='SwitchZone' then
            								for f,zone in pairs(ROOMS[a].CAMERA[b].SwitchZone) do
            									--print(e)
            									--print(PointP)
            									L01=(ROOMS[a].CAMERA[b].SwitchZone[f].Point0-ROOMS[a].CAMERA[b].SwitchZone[f].Point1):length()
												L12=(ROOMS[a].CAMERA[b].SwitchZone[f].Point1-ROOMS[a].CAMERA[b].SwitchZone[f].Point2):length()
												L23=(ROOMS[a].CAMERA[b].SwitchZone[f].Point2-ROOMS[a].CAMERA[b].SwitchZone[f].Point3):length()
												L30=(ROOMS[a].CAMERA[b].SwitchZone[f].Point3-ROOMS[a].CAMERA[b].SwitchZone[f].Point0):length()
												L0P=(ROOMS[a].CAMERA[b].SwitchZone[f].Point0-PointP):length()
												L1P=(ROOMS[a].CAMERA[b].SwitchZone[f].Point1-PointP):length()
												L2P=(ROOMS[a].CAMERA[b].SwitchZone[f].Point2-PointP):length()
												L3P=(ROOMS[a].CAMERA[b].SwitchZone[f].Point3-PointP):length()
												--print(math.acos(((L01*L01-L1P*L1P-L0P*L0P)/(-2*L1P*L0P)))+math.acos(((L12*L12-L2P*L2P-L1P*L1P)/(-2*L2P*L1P)))+math.acos(((L23*L23-L3P*L3P-L2P*L2P)/(-2*L3P*L2P)))+math.acos(((L30*L30-L0P*L0P-L3P*L3P)/(-2*L0P*L3P))))
																					
            									
            									if (math.acos(((L01*L01-L1P*L1P-L0P*L0P)/(-2*L1P*L0P)))+math.acos(((L12*L12-L2P*L2P-L1P*L1P)/(-2*L2P*L1P)))+math.acos(((L23*L23-L3P*L3P-L2P*L2P)/(-2*L3P*L2P)))+math.acos(((L30*L30-L0P*L0P-L3P*L3P)/(-2*L0P*L3P)))>=6.27) and (math.acos(((L01*L01-L1P*L1P-L0P*L0P)/(-2*L1P*L0P)))+math.acos(((L12*L12-L2P*L2P-L1P*L1P)/(-2*L2P*L1P)))+math.acos(((L23*L23-L3P*L3P-L2P*L2P)/(-2*L3P*L2P)))+math.acos(((L30*L30-L0P*L0P-L3P*L3P)/(-2*L0P*L3P)))<=(2*math.pi))  then
            										--print(a)
            										--print(b)
            										--print(e)
            										targetcam=ROOMS[a].CAMERA[b].SwitchZone[f].Camera
            										--print(targetcam)
            										--print(activecam)
            										CamRotation=util.vector2(ROOMS[a].CAMERA[targetcam].Pitch,ROOMS[a].CAMERA[targetcam].Yaw)
            										print(CamRotation)
													Player:sendEvent('CameraPos', {source=Player.object, CamPos=ROOMS[a].CAMERA[targetcam].Position,CamAng=CamRotation})

        										
            										activecam=ROOMS[a].CAMERA[targetcam].Name
			            							--print(activecam)
			            							BGD.enabled= false
			            							BGD=world.createObject(world.createRecord(types.Activator.createRecordDraft({id=ROOMS[a].CAMERA[targetcam].bgd.idname,model=('meshes/bgd/'..ROOMS[a].CAMERA[targetcam].bgd.idname..'.nif')})).id,1)
													BGD:teleport(activecell,ROOMS[a].CAMERA[targetcam].bgd.Position,BGD.rotation*util.transform.rotateZ(ROOMS[a].CAMERA[targetcam].bgd.Anglez)*util.transform.rotateX(ROOMS[a].CAMERA[targetcam].bgd.Anglex))
            									
            									            							       
            							       -------------- Creation des Masks
            										for d, msk in pairs(MSK) do
            											if MSK[d]~=false then
															MSK[d].enabled=false
														end
													end
            										--print(ROOMS[a].CAMERA[targetcam].MASK)
            										for d, msk in pairs(ROOMS[a].CAMERA[targetcam].MASK) do
            											--print(ROOMS[a].CAMERA[targetcam].MASK[d].idname)
            											--print(ROOMS[a].CAMERA[targetcam].MASK[d].position)
            											--print(ROOMS[a].CAMERA[targetcam].MASK[d].scale)
            											if ROOMS[a].CAMERA[targetcam].MASK[d].scale~=0 then
            									            MSK['MSK'..d]=world.createObject(world.createRecord(types.Activator.createRecordDraft({id=ROOMS[a].CAMERA[targetcam].MASK[d].idname,model=('meshes/Masks/'..ROOMS[a].CAMERA[targetcam].MASK[d].idname..'.nif')})).id,1)
            												--print(MSK['MSK'..d])
            												MSK['MSK'..d]:teleport(activecell,ROOMS[a].CAMERA[targetcam].MASK[d].position,MSK['MSK'..d].rotation*util.transform.rotateZ(ROOMS[a].CAMERA[targetcam].bgd.Anglez)*util.transform.rotateX(ROOMS[a].CAMERA[targetcam].bgd.Anglex))
            												MSK['MSK'..d]:setScale(ROOMS[a].CAMERA[targetcam].MASK[d].scale)
            											end
            										end
									---------------------
									
 
            									end
		            						end
		            					end
		            				end
		            			end
		            		end           										
            									
            			end
            		end          		
            	end
	end
	}
}
