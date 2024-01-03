local self=require('openmw.self')
local nearby = require('openmw.nearby')
local input = require('openmw.input')
local ui = require('openmw.ui')
local util = require('openmw.util')
local types = require('openmw.types')
local I = require('openmw.interfaces')
local core = require('openmw.core')
local camera = require('openmw.camera')
local interfaces=require('openmw.interfaces')
local ambient=require('openmw.ambient')

local doOnce=nil
local activecam=nil
local activeBkg=nil

--{"Hand Gun Bullets", "Hand Gun Bullets Enhanced", "Shotgun Shells","Shotgun Shells Enhanced","Grenade Rounds","Acid Rounds","Flame Rounds","Freeze Rounds","Sponge Round","Assault Rifle Bullets","Magnum Bullets","Mine Thrower Rounds","Fuel"}
local AmmunitionTypes={}
local word=""
local EquippedWeapon
local ammosloadable
local StartingAmmo
local ammoscharged=false
local wrongammo=true
local instantammo=0
local ammochanged=false
local weaponcondition

local LooKUD=nil
local UseButton=0
local ToggleWeaponButton=0
local QuickTurnButton=0
local ToggleUseButton=false
local DodgeButton=0
local TargetedBOW={}
local changetarget=0
local BOWchecked=0
local CinematicBar=nil
local Menu=false
local shootTimer=0
local FrameRefresh=false


local Lifebare
local doOnceMenu=0
local path1
local path2=0
local path3
local lifebarTimer=0
local onFrameHealth

local equipped = types.Actor.equipment(self)


----- variables pour tire shotguns
local SShellRotX
local SShellRotZ
local SshellDamage
local SshellEnchant 
local Xshotshell
local Yshotshell
local Zshotshell
local ray

local ExaminedItems={}
local CombinedItems={}

---------- override  normal controls
interfaces.Controls.overrideMovementControls(true)
interfaces.Controls.overrideCombatControls(true)
interfaces.Controls.overrideUiControls(true)


-----------------bars cinematiques      
ui.create({layer = 'Console',  type = ui.TYPE.Image,  props = {relativeSize = util.vector2(1, 1/7),relativePosition=util.vector2(0, 1),anchor = util.vector2(0, 1),resource = ui.texture{path ='textures/cinematic_bar.dds'},},})
ui.create({layer = 'Console',  type = ui.TYPE.Image,  props = {relativeSize = util.vector2(1, 1/7),relativePosition=util.vector2(0, 0),anchor = util.vector2(0, 0),resource = ui.texture{path ='textures/cinematic_bar.dds'},},})


-------------examined items
for i, book in ipairs(types.Book.records) do
	if book.id=="examined items" then
		ExaminedItems=util.loadCode("return("..book.text..")",{})()
	end
end

-------------Combined items
for i, book in ipairs(types.Book.records) do
	if book.id=="combined items" then
		--CombinedItems=util.loadCode("return("..book.text..")",{})()
	end
end


local function PositionningCamera()
	 -------------Move camera and background
	 if input.isActionPressed(input.ACTION.QuickKey10)==true and input.isActionPressed(input.ACTION.QuickKey9)==true then
		if TurnLeft(-0.2)==true then
			camerapos({CamPos=util.transform.move(util.vector3(0,-1,0))*camera.getPosition(),CamAng=util.vector2(camera.getPitch(),camera.getYaw()),ActiveCam=activecam,ActiveBkg=activeBkg})
			TeleportBkg()
		elseif TurnRight(0.2)==true then
			camerapos({CamPos=util.transform.move(util.vector3(0,1,0))*camera.getPosition(),CamAng=util.vector2(camera.getPitch(),camera.getYaw()),ActiveCam=activecam,ActiveBkg=activeBkg})
			TeleportBkg()
		elseif MoveBackward(0.2)==true and input.isActionPressed(input.ACTION.QuickKey8)==true  then
			camerapos({CamPos=util.transform.move(util.vector3(0,0,1))*camera.getPosition(),CamAng=util.vector2(camera.getPitch(),camera.getYaw()),ActiveCam=activecam,ActiveBkg=activeBkg})
			TeleportBkg()
		elseif MoveForward(-0.2)==true and input.isActionPressed(input.ACTION.QuickKey8)==true  then
			camerapos({CamPos=util.transform.move(util.vector3(0,0,-1))*camera.getPosition(),CamAng=util.vector2(camera.getPitch(),camera.getYaw()),ActiveCam=activecam,ActiveBkg=activeBkg})
			TeleportBkg()
		elseif MoveBackward(0.2)==true then
			camerapos({CamPos=util.transform.move(util.vector3(1,0,0))*camera.getPosition(),CamAng=util.vector2(camera.getPitch(),camera.getYaw()),ActiveCam=activecam,ActiveBkg=activeBkg})
			TeleportBkg()
		elseif MoveForward(-0.2)==true then
			camerapos({CamPos=util.transform.move(util.vector3(-1,0,0))*camera.getPosition(),CamAng=util.vector2(camera.getPitch(),camera.getYaw()),ActiveCam=activecam,ActiveBkg=activeBkg})
			TeleportBkg()
		end	
	elseif input.isActionPressed(input.ACTION.QuickKey10)==true then
		if TurnLeft(-0.2)==true then
			camerapos({CamPos=camera.getPosition(),CamAng=util.vector2(camera.getPitch(),camera.getYaw()+0.005),ActiveCam=activecam,ActiveBkg=activeBkg})
			TeleportBkg()
		elseif TurnRight(0.2)==true then
			camerapos({CamPos=camera.getPosition(),CamAng=util.vector2(camera.getPitch(),camera.getYaw()-0.005),ActiveCam=activecam,ActiveBkg=activeBkg})
			TeleportBkg()
		elseif MoveBackward(0.2)==true then
			camerapos({CamPos=camera.getPosition(),CamAng=util.vector2(camera.getPitch()+0.005,camera.getYaw()),ActiveCam=activecam,ActiveBkg=activeBkg})
			TeleportBkg()
		elseif MoveForward(-0.2)==true then
			camerapos({CamPos=camera.getPosition(),CamAng=util.vector2(camera.getPitch()-0.005,camera.getYaw()),ActiveCam=activecam,ActiveBkg=activeBkg})
			TeleportBkg()
			end	
		end
end


function TeleportBkg()
	local position=camera.getPosition()+util.vector3(math.cos(camera:getPitch()) * math.sin(camera:getYaw())*4700, math.cos(camera:getPitch()) * math.cos(camera:getYaw())*4700,-math.sin(camera:getPitch())*4700)
	print("___________________")
	print("camera position : "..tostring(camera.getPosition()))
	print("Camera Rot X : "..tostring(camera:getPitch()))
	print("Camera Rot Z : "..tostring(camera:getYaw()))
	print("BKG position : "..tostring(position))
	core.sendGlobalEvent('Teleport', {actor=activeBkg, position=position, rotation=util.transform.rotateZ(camera:getYaw())*util.transform.rotateX(camera:getPitch())})
end

function camerapos(data)
	camera.setMode(0)
	camera.setStaticPosition(data.CamPos)
	camera.setFieldOfView(0.7)--FieldOfView de 40
	camera.setPitch(data.CamAng.x)
	camera.setYaw(data.CamAng.y)
	activecam=data.ActiveCam
	activeBkg=data.ActiveBkg
end




local function InFront(data)
	if ( ((self.rotation:getYaw()<=.785 and self.rotation:getYaw()>=-.785) and (data.position.y-self.position.y)>=0)
	or ((self.rotation:getYaw()<=2.355 and self.rotation:getYaw()>=.785) and (data.position.x-self.position.x)>=0)
	or ((self.rotation:getYaw()<=-2.355 or self.rotation:getYaw()>=2.355) and (data.position.y-self.position.y)<=0)
	or ((self.rotation:getYaw()<=-.785 and self.rotation:getYaw()>=-2.355) and (data.position.x-self.position.x)<=0) )	then
		return(true)
	end
end

function MoveForward(data)
	if input.isActionPressed(input.ACTION.MoveForward)==true or input.getAxisValue(input.CONTROLLER_AXIS.LeftY)<=data then
		return(true)
	end
end


function MoveBackward(data)
	if input.isActionPressed(input.ACTION.MoveBackward)==true or input.getAxisValue(input.CONTROLLER_AXIS.LeftY)>=data then
		return(true)
	end
end

function TurnRight(data)
	if input.isActionPressed(input.ACTION.QuickKey1)==true or input.getAxisValue(input.CONTROLLER_AXIS.LeftX)>=data then
		return(true)
	end
end

function TurnLeft(data)
	if input.isActionPressed(input.ACTION.QuickKey2)==true or input.getAxisValue(input.CONTROLLER_AXIS.LeftX)<=data then
		return(true)
	end
end


local MenuSelectStop
local iconpath
local InventoryItems
local InventoryItemSelected={}
local Inventory
local InventoryBkg
local PickUpItem={}
local PickUpItemIcon
local function ShowInventory()

	I.UI.setMode(I.UI.MODE.Interface, {windows = {I.UI.WINDOW.QuickKeys,}})
	local InventoryContent=ui.content{}
	local InventoryItems={}

	if not(Inventory==nil or InventoryBkg==nil) then
		Inventory:destroy()
		InventoryBkg:destroy()	
	end

	for i=1,20 do --20 is an arbitrary value
		if not(types.Actor.inventory(self):getAll()[i]==nil or types.Actor.inventory(self):getAll()[i].type==types.Book) then
			table.insert(InventoryItems,types.Actor.inventory(self):getAll()[i])
		end
	end
	
	
	for i, item in ipairs(InventoryItems) do
		local textLayout={}
		if  item.count>1 then --13 == Bolt
			textLayout={type = ui.TYPE.Text,props = {text = tostring(item.count),textSize=50,textColor=util.color.rgb(0.06,0.4,0.08),anchor = util.vector2(-1,-1.5),},}
		elseif item.type==types.Weapon and types.Weapon.record(item).type==10 then --10 == MarksmanCrossbow then
			textLayout={type = ui.TYPE.Text,props = {text = tostring(types.Item.getEnchantmentCharge(item)),textSize=50,textColor=util.color.rgb(0.09,0.38,0.54),anchor = util.vector2(-1,-1.5),},}
		else
			textLayout={type = ui.TYPE.Text,props = {text = nil,textSize=50,textColor=util.color.rgb(0.09,0.38,0.54),anchor = util.vector2(-1,-1.5),},}
		end
		if i%2==1 then
			_G["ContentInventoryLine"..i]=ui.content{}
			_G["ContentInventoryLine"..i]:add({type = ui.TYPE.Image,content=ui.content{textLayout}, props = {size = util.vector2(ui.screenSize().x/10, ui.screenSize().y/9),resource = ui.texture{path =item.type.record(item).icon},},})
			
			if InventoryItems[i+1]==nil then
	
				_G["InventoryLine"..(i)]={name="Line"..(i), layer="Windows", type = ui.TYPE.Flex, props = {position=util.vector2(ui.screenSize().x*5/6-ui.screenSize().x/10, ui.screenSize().y/2),anchor = util.vector2(0, 0),horizontal=true}, content=_G["ContentInventoryLine"..(i)]}
				InventoryContent:add(_G["InventoryLine"..(i)])
					
			end
				
		elseif i%2==0 then
			_G["ContentInventoryLine"..(i-1)]:add({type = ui.TYPE.Image,content=ui.content{textLayout},  props = {size = util.vector2(ui.screenSize().x/10, ui.screenSize().y/9),resource = ui.texture{path =item.type.record(item).icon},},})
				
			_G["InventoryLine"..(i-1)]={name="Line"..(i-1), layer="Windows", type = ui.TYPE.Flex, props = {position=util.vector2(ui.screenSize().x*5/6-ui.screenSize().x/10, ui.screenSize().y/2),anchor = util.vector2(0, 0),horizontal=true}, content=_G["ContentInventoryLine"..(i-1)]}
	
			InventoryContent:add(_G["InventoryLine"..(i-1)])
		end	
	end	
		
	InventoryLayout={name="Inventory", layer="Windows", type = ui.TYPE.Flex, props = {relativePosition=util.vector2(3/4, 1/3),anchor=(util.vector2(0,0))}, content=InventoryContent}
	InventoryBkg=ui.create({name="InventoryBkg",layer = 'Windows',  type = ui.TYPE.Image,  props = {relativeSize = util.vector2(2/10, types.NPC.getCapacity(self)/2/9),relativePosition=util.vector2(3/4, 1/3),anchor=(util.vector2(0,0)),resource = ui.texture{path ="textures/BkgInventory.dds"},},}) 
	Inventory=ui.create(InventoryLayout)
	return(InventoryItems)
end



function ShowItem (item,text)
	local ItemIcon={layer = 'Windows',  type = ui.TYPE.Image,  props = {relativeSize = util.vector2(2/3, 1/2),relativePosition=util.vector2(1/3, 1/2),anchor=(util.vector2(0,0)),resource = ui.texture{path =item.type.record(item).icon},},}
	local Text={layer = 'Windows',type = ui.TYPE.Text, props={text = text, autoSize=true, textSize=30,textColor=util.color.rgb(1,1,1),},}

	ShowItemIcon=ui.create({layer = 'Console',type = ui.TYPE.Flex, props={autoSize=false,relativeSize = util.vector2(1/2,1/2),relativePosition = util.vector2(1/3, 1/2),  anchor = util.vector2(0, 0),}, content=ui.content{ItemIcon,
	{layer = 'Windows',type = ui.TYPE.Text,props = {text=" ",textSize=120}},Text}})
	
end











local function onUpdate()
	------- picking items 1/2
	if PickUpItem[2]==true and PickUpItem[3]==nil then
		ShowInventory()
		InventoryItemSelected[2]=nil
		PickUpItem[3]=true
		ShowItem(PickUpItem[1],'You Pickup '..PickUpItem[1].recordId)
	elseif PickUpItem[2]==false and PickUpItem[3]==nil then	
		ShowInventory()
		InventoryItemSelected[2]=nil
		PickUpItem[3]=true
		ShowItem(PickUpItem[1],"You can't pickup "..PickUpItem[1].recordId..'. Your Inventory is full.')
	end
		
           	
        ---------------Activate near -> ajouter animation de ramasser un objet
	if input.isActionPressed(input.ACTION.Use)==true and types.Actor.getStance(self)==0 and UseButton==0 and I.UI.getMode()==nil then
		UseButton=1
		for i, items in ipairs(nearby.items) do
			local dist = (util.vector2(self.position.x,self.position.y)-util.vector2(items.position.x,items.position.y)):length()
			if dist<40 and ((items.position.z-self.position.z)<=150) and InFront(items)==true then
				local nbritems=0
				for i, item in ipairs(types.Actor.inventory(self):getAll()) do
					if item.type~=types.Book then
							nbritems=nbritems+1
					end
				end
				print(nbritems)
				if nbritems<=(types.NPC.getCapacity(self)-1) and PickUpItem[1]==nil then
					items:activateBy(self)
					for i, item in ipairs(types.Actor.inventory(self):getAll()) do print(item) end
					PickUpItem[1]=items
					PickUpItem[2]=true
					--break
				elseif PickUpItem[1]==nil then
					PickUpItem[1]=items
					PickUpItem[2]=false
					--break
				end
			end
		end
		for i, doors in ipairs(nearby.doors) do
			local dist = (self.position-doors.position):length()
			if dist<80 and ((doors.position.z-self.position.z)<=150) and InFront(doors)==true then
				doors:activateBy(self)
				break
			end
		end
		for i, container in ipairs(nearby.containers) do
			local dist = (self.position-container.position):length()
			if dist<100 and ((container.position.z-self.position.z)<=150) and InFront(container)==true then
				container:activateBy(self)
				break
			end
		end
		for i, actors in ipairs(nearby.actors) do
			local dist = (self.position-actors.position):length()
			if dist<50 and ((actors.position.z-self.position.z)<=150) and types.Actor.stats.dynamic.health(actors).current>0 and InFront(actors)==true and actors.type~=types.Player then
				actors:activateBy(self)
				break
			end
		end		
	elseif input.isActionPressed(input.ACTION.Use)==false then
		UseButton=0
	end







	--print("X "..input.getAxisValue(input.CONTROLLER_AXIS.LeftX))
	--print("Y "..input.getAxisValue(input.CONTROLLER_AXIS.LeftY))
		------test marcher/courrir  ->ok
		if MoveForward(-0.2)==true and input.isActionPressed(input.ACTION.AutoMove)==true and input.isActionPressed(input.ACTION.TogglePOV)==false then
			self.controls.movement=1
			self.controls.run=true
		elseif MoveForward(-0.2)==true and input.isActionPressed(input.ACTION.TogglePOV)==false then
			self.controls.movement=1
			self.controls.run=false
		elseif MoveBackward(0.2)==true and input.isActionPressed(input.ACTION.TogglePOV)==false then
			self.controls.movement=-1
			self.controls.run=false
		else 
			self.controls.movement=0
		end			
		------------- test rotation sans souris->ok
		if TurnRight(0.2)==true and input.isActionPressed(input.ACTION.TogglePOV)==false then
			self.controls.yawChange=0.03
		elseif  TurnLeft(-0.2)==true and input.isActionPressed(input.ACTION.TogglePOV)==false then
			self.controls.yawChange=-0.03
		end	
		------------- test visée Y fixe  -ok
		if  MoveForward(-0.5)==true  and types.Actor.getStance(self)==1 and LooKUD~=-1 then
			self.controls.pitchChange=-0.5
			LooKUD=-1
		elseif  not(MoveForward(-0.5)==true) and LooKUD==-1 then
			self.controls.pitchChange=0.5
			LooKUD=nil
		elseif  MoveBackward(0.5)==true and types.Actor.getStance(self)==1 and LooKUD~=1 then
			self.controls.pitchChange=0.5
			LooKUD=1
		elseif not( MoveBackward(0.5)==true) and LooKUD==1 then
			self.controls.pitchChange=-0.5
			LooKUD=nil
		end
		--------------Test Quick rotate -> un peu vite mais ok
		if  MoveBackward(0.2)==true and types.Actor.getStance(self)==0 and input.isActionPressed(input.ACTION.AutoMove)==true and QuickTurnButton==0 then
			self.controls.yawChange=math.pi
			QuickTurnButton=1
		elseif not( MoveBackward(0.2)==true) and input.isActionPressed(input.ACTION.AutoMove)==false then
			QuickTurnButton=0
		end	
		--------Test dodge  -> ajouter les animations
		if input.isActionPressed(input.ACTION.TogglePOV)==true and  MoveBackward(0.2)==true and DodgeButton==0 then
			ui.showMessage('Dodge Back')
			self.controls.jump=true
			self.controls.movement=-1
			DodgeButton=1
		elseif input.isActionPressed(input.ACTION.TogglePOV)==true and  MoveForward(-0.2)==true  and DodgeButton==0 then
			ui.showMessage('Dodge Front')
			self.controls.jump=true
			self.controls.movement=1
			DodgeButton=1
		elseif input.isActionPressed(input.ACTION.TogglePOV)==true and TurnRight(0.2)==true and DodgeButton==0 then
			ui.showMessage('Dodge Right')
			self.controls.jump=true
			self.controls.sideMovement=1
			DodgeButton=1
		elseif input.isActionPressed(input.ACTION.TogglePOV)==true and  TurnLeft(-0.2)==true and DodgeButton==0 then
			ui.showMessage('Dodge Left')
			self.controls.jump=true
			self.controls.sideMovement=-1
			DodgeButton=1
		elseif input.isActionPressed(input.ACTION.TogglePOV)==false and DodgeButton==1 then 
			DodgeButton=0
			self.controls.sideMovement=0
			self.controls.movement=0
			self.controls.jump=false
		end			
	
		
	---------------test viser uniquement sur pression bouton ->ok 

    if types.Actor.getEquipment(self,16) then       
		types.Actor.getEquipment(self,16):sendEvent('setCondition',{value=weaponcondition})
	end

	if input.isActionPressed(input.ACTION.ToggleWeapon)==false and instantammo~=0 then
		instantammo=0
		types.Actor.setEquipment(self,{[types.Actor.EQUIPMENT_SLOT.CarriedRight]=types.Actor.getEquipment(self,16)})
		if types.Actor.inventory(self):findAll(AmmunitionTypes[types.Item.itemData(types.Actor.getEquipment(self,16)).condition-10000].id)[2]==nil then
			core.sendGlobalEvent('RemoveItem', {Item=types.Actor.inventory(self):findAll(AmmunitionTypes[types.Item.itemData(types.Actor.getEquipment(self,16)).condition-10000].id)[1], number=types.Item.getEnchantmentCharge(types.Actor.getEquipment(self,16))})
		else
			core.sendGlobalEvent('RemoveItem', {Item=types.Actor.inventory(self):findAll(AmmunitionTypes[types.Item.itemData(types.Actor.getEquipment(self,16)).condition-10000].id)[2], number=types.Item.getEnchantmentCharge(types.Actor.getEquipment(self,16))})
		end
	end		  

	if input.isActionPressed(input.ACTION.ToggleWeapon)==true and types.Actor.getEquipment(self,16) then  ----degainer l'arme
		types.Actor.setStance(self,1)
		self.controls.use=1

		if types.Weapon.record(types.Actor.getEquipment(self,16)).type==10 then
			if instantammo==0 and types.Actor.inventory(self):find(AmmunitionTypes[types.Item.itemData(types.Actor.getEquipment(self,16)).condition-10000].id) then
				core.sendGlobalEvent('createAmmosinInventory', {ammo=AmmunitionTypes[types.Item.itemData(types.Actor.getEquipment(self,16)).condition-10000].id, number=types.Item.getEnchantmentCharge(types.Actor.getEquipment(self,16)), actor=self})
				equipped[types.Actor.EQUIPMENT_SLOT.Ammunition]=types.Actor.inventory(self):find(AmmunitionTypes[types.Item.itemData(types.Actor.getEquipment(self,16)).condition-10000].id)
				equipped[types.Actor.EQUIPMENT_SLOT.CarriedRight]=EquippedWeapon
				types.Actor.setEquipment(self,equipped)
				instantammo=1
			elseif instantammo==0 and types.Actor.inventory(self):find(AmmunitionTypes[types.Item.itemData(types.Actor.getEquipment(self,16)).condition-10000].id)==nil then
				core.sendGlobalEvent('createAmmosinInventory', {ammo=AmmunitionTypes[types.Item.itemData(types.Actor.getEquipment(self,16)).condition-10000].id, number=types.Item.getEnchantmentCharge(types.Actor.getEquipment(self,16)), actor=self})
				instantammo=1
			elseif instantammo==1 then
				instantammo=2
			elseif instantammo==2 then
				instantammo=3
				print(types.Actor.inventory(self):find(AmmunitionTypes[types.Item.itemData(types.Actor.getEquipment(self,16)).condition-10000].id))
				equipped[types.Actor.EQUIPMENT_SLOT.Ammunition]=types.Actor.inventory(self):find(AmmunitionTypes[types.Item.itemData(types.Actor.getEquipment(self,16)).condition-10000].id)
				equipped[types.Actor.EQUIPMENT_SLOT.CarriedRight]=EquippedWeapon
				types.Actor.setEquipment(self,equipped)
			end  
		end


		

		----------------------------------------
			local actionbasetime = 4
		
		if input.isActionPressed(input.ACTION.Use)==true and (types.Item.getEnchantmentCharge(types.Actor.getEquipment(self,16))>0 or types.Weapon.record(types.Actor.getEquipment(self,16)).type~=10) and (core.getRealTime()-shootTimer)>(actionbasetime/types.Weapon.record(types.Actor.getEquipment(self,16)).speed) then -- Fire!!
			self.controls.use=0
			shootTimer=(core.getRealTime())
			if types.Weapon.record(types.Actor.getEquipment(self,16)).type==10 then
				types.Actor.getEquipment(self,16):sendEvent('setCondition',{value=weaponcondition})
				core.sendGlobalEvent('setCharge', {Item=types.Actor.getEquipment(self,16), value=types.Item.getEnchantmentCharge(types.Actor.getEquipment(self,16))-1})
			end






				---------------------------shotshell -----------en cours
				if types.Weapon.record(types.Actor.getEquipment(self,18)) and core.magic.enchantments[types.Weapon.record(types.Actor.getEquipment(self,18)).enchant] and string.find(core.magic.enchantments[types.Weapon.record(types.Actor.getEquipment(self,18)).enchant].id,"shotshell") then 
					print("self  "..tostring(self.position))
					local shelldistance = 1000
					local pellets=9 --multiple de trois
					local r= 10
					SshellDamage=types.Weapon.record(types.Actor.getEquipment(self,18)).thrustMinDamage
					SshellEnchant=core.magic.enchantments[types.Weapon.record(types.Actor.getEquipment(self,18)).enchant]
					for a = 1,pellets do
	
						print(a)
						if a<=pellets/3 then
							--SShellPos=util.transform.move(0,0,70)*self.position+ util.transform.rotate(1,util.vector3(0,0,math.pi/2))self.rotation*util.vector3(0,1,0)*100
							SShellRotX = self.rotation:getYaw()+math.pi/4*math.cos(a*math.pi/(pellets/3))
							SShellRotZ = self.rotation:getPitch()+math.pi/4*math.cos(a*math.pi/(pellets/3))
							ray=nearby.castRay(util.vector3(0,0,80)+self.position, util.vector3(0,0,80)+self.position+util.vector3(math.cos(SShellRotZ) * math.sin(SShellRotX), math.cos(SShellRotZ) * math.cos(SShellRotX),-math.sin(SShellRotZ))*shelldistance,{ignore=self})
							print(ray.hitPos)
							print(ray.hitObject)
							if ray.hitObject and ray.hitObject.type==types.Creature then
								ray.hitObject:sendEvent('PelletsEffects',{damages=SshellDamage})--,enchant=SshellEnchant})
							end
						elseif a>pellets/3 then
							--SShellRotX = self.rotation:getYaw()+math.pi/2*math.cos(a*math.pi/pellets)
							SShellRotZ = self.rotation:getPitch()+math.pi/2*math.cos(a*math.pi/pellets)
							ray=nearby.castRay(util.vector3(0,0,80)+self.position, util.vector3(0,0,80)+self.position+util.vector3(math.cos(SShellRotZ) * math.sin(SShellRotX), math.cos(SShellRotZ) * math.cos(SShellRotX),-math.sin(SShellRotZ))*shelldistance,{ignore=self})
							print(ray.hitPos)
							print(ray.hitObject)
							if ray.hitObject and ray.hitObject.type==types.Creature then
								ray.hitObject:sendEvent('PelletsEffects',{damages=SshellDamage})--,enchant=SshellEnchant})
							end
						end
					end
				end
				----------------------------------------------------------------------------------------------







		elseif input.isActionPressed(input.ACTION.Use)==true and types.Item.getEnchantmentCharge(types.Actor.getEquipment(self,16))==0 and (core.getRealTime()-shootTimer)>(actionbasetime/types.Weapon.record(types.Actor.getEquipment(self,16)).speed) then
			ui.showMessage("Weapon empty")	
			shootTimer=(core.getRealTime())	
			ambient.playSound("ClipEmpty")
			types.Actor.setEquipment(self,{[types.Actor.EQUIPMENT_SLOT.CarriedRight]=types.Actor.getEquipment(self,16)})

		elseif input.isActionPressed(input.ACTION.AutoMove)==true and (core.getRealTime()-shootTimer)>(actionbasetime/types.Weapon.record(types.Actor.getEquipment(self,16)).speed) then
			shootTimer=(core.getRealTime())	
			
			if (types.Actor.inventory(self):countOf(AmmunitionTypes[types.Item.itemData(types.Actor.getEquipment(self,16)).condition-10000].id)-types.Item.getEnchantmentCharge(types.Actor.getEquipment(self,16)))==0 then
				ambient.playSound("ClipEmpty")
				ui.showMessage("No more ammo")
			elseif types.Item.getEnchantmentCharge(types.Actor.getEquipment(self,16))==core.magic.enchantments[types.Weapon.record(types.Actor.getEquipment(self,16)).enchant].charge then
				ui.showMessage("Weapon full")
			elseif  (types.Actor.inventory(self):countOf(AmmunitionTypes[types.Item.itemData(types.Actor.getEquipment(self,16)).condition-10000].id)-types.Item.getEnchantmentCharge(types.Actor.getEquipment(self,16)))>=(core.magic.enchantments[types.Weapon.record(types.Actor.getEquipment(self,16)).enchant].charge-types.Item.getEnchantmentCharge(types.Actor.getEquipment(self,16))) then
				ammosloadable=core.magic.enchantments[types.Weapon.record(types.Actor.getEquipment(self,16)).enchant].charge-types.Item.getEnchantmentCharge(types.Actor.getEquipment(self,16))
				print("ammosload"..tostring(ammosloadable))
				ui.showMessage("reload")	
				core.sendGlobalEvent('setCharge', {Item=types.Actor.getEquipment(self,16), value=core.magic.enchantments[types.Weapon.record(types.Actor.getEquipment(self,16)).enchant].charge})
				instantammo=1
			elseif (types.Actor.inventory(self):countOf(AmmunitionTypes[types.Item.itemData(types.Actor.getEquipment(self,16)).condition-10000].id)-types.Item.getEnchantmentCharge(types.Actor.getEquipment(self,16)))<(core.magic.enchantments[types.Weapon.record(types.Actor.getEquipment(self,16)).enchant].charge-types.Item.getEnchantmentCharge(types.Actor.getEquipment(self,16))) then
				print("low ammo")
				ammosloadable=types.Actor.inventory(self):countOf(AmmunitionTypes[types.Item.itemData(types.Actor.getEquipment(self,16)).condition-10000].id)-types.Item.getEnchantmentCharge(types.Actor.getEquipment(self,16))
				ui.showMessage("reload")	
				core.sendGlobalEvent('setCharge', {Item=types.Actor.getEquipment(self,16), value=ammosloadable+types.Item.getEnchantmentCharge(types.Actor.getEquipment(self,16))})
				instantammo=1
			end



		elseif ToggleWeaponButton==0 then  -------first autotarget
			ToggleWeaponButton=1
			TargetBOW={position=util.vector3(1000000*math.cos(self.rotation:getYaw()),1000000*math.sin(self.rotation:getYaw()),0)} --essayer de modifier pour que le point soit devant le Player
			--print(TargetBOW.position)
			for i, actors in pairs(nearby.actors) do
				if actors.type == types.Creature and (self.position-TargetBOW.position):length()>(self.position-actors.position):length() and types.Actor.stats.dynamic.health(actors).current>0 then
					TargetBOW = actors
					table.insert(TargetedBOW,TargetBOW)
					--print((self.position-TargetBOW.position):length())
					--print(TargetBOW)
				end
			end
			
				
				
			ui.showMessage(tostring(TargetBOW))
			if self.position.x<TargetBOW.position.x then
				if self.position.y<TargetBOW.position.y then--ok
					AngleTarget=-self.rotation:getYaw()+math.acos((TargetBOW.position.y-self.position.y)/(self.position-TargetBOW.position):length())
				elseif self.position.y>TargetBOW.position.y then
					AngleTarget=-self.rotation:getYaw()-math.acos((self.position.y-TargetBOW.position.y)/(self.position-TargetBOW.position):length())-math.pi
				end
			elseif self.position.x>TargetBOW.position.x then--ok
				if self.position.y<TargetBOW.position.y then
					AngleTarget=-self.rotation:getYaw()+math.acos((self.position.y-TargetBOW.position.y)/(self.position-TargetBOW.position):length())-math.pi
				elseif self.position.y>TargetBOW.position.y then
					AngleTarget=-self.rotation:getYaw()-math.acos((TargetBOW.position.y-self.position.y)/(self.position-TargetBOW.position):length())
				end
			end
			self.controls.yawChange=AngleTarget
				
				
				
		elseif input.isActionPressed(input.ACTION.Sneak)==true and changetarget==0 then  --------Change target
			--print("ok")
			changetarget=1

			for i, actors in pairs(nearby.actors) do
				BOWchecked=0
				if actors.type==types.Creature and types.Actor.stats.dynamic.health(actors).current>0 then
					for j,BOW in pairs (TargetedBOW) do
						if actors==BOW then
							BOWchecked=1
						end
					end
					if BOWchecked ==0 then
						TargetBOW = actors
						table.insert(TargetedBOW,TargetBOW)
						break
					end
				end
			end
			if TargetedBOW[#TargetedBOW]==TargetBOW and BOWchecked==1 then
				TargetedBOW={}
			end
				

				
				
			ui.showMessage(tostring(TargetBOW))
			if self.position.x<TargetBOW.position.x then
				if self.position.y<TargetBOW.position.y then--ok
					AngleTarget=-self.rotation:getYaw()+math.acos((TargetBOW.position.y-self.position.y)/(self.position-TargetBOW.position):length())
				elseif self.position.y>TargetBOW.position.y then
					AngleTarget=-self.rotation:getYaw()-math.acos((self.position.y-TargetBOW.position.y)/(self.position-TargetBOW.position):length())-math.pi
				end
			elseif self.position.x>TargetBOW.position.x then--ok
				if self.position.y<TargetBOW.position.y then
					AngleTarget=-self.rotation:getYaw()+math.acos((self.position.y-TargetBOW.position.y)/(self.position-TargetBOW.position):length())-math.pi
				elseif self.position.y>TargetBOW.position.y then
					AngleTarget=-self.rotation:getYaw()-math.acos((TargetBOW.position.y-self.position.y)/(self.position-TargetBOW.position):length())
				end
				
			end
			self.controls.yawChange=AngleTarget
			
		elseif input.isActionPressed(input.ACTION.Sneak)==false then
			changetarget=0	
			
		end
	else
		types.Actor.setStance(self,0)
		ToggleWeaponButton=0
		TargetedBOW={}
	end

	if onFrameHealth~=types.Actor.stats.dynamic.health(self).current then
		onFrameHealth=types.Actor.stats.dynamic.health(self).current
	end		

end		
	









function Framewait(frametowait)
	if frame==nil then
		frame=0
	elseif frame==frametowait then
		frame=0
		print("ok")
		return(true)
	else 
		frame=frame+1
	end
end






local function onFrame(dt)

	--if Framewait(10)==true then
		--print("ok")
	--end


	PositionningCamera()

	---- picking item 2/2
	if PickUpItem[3]==true and PickUpItem[4]~=true and (input.isActionPressed(input.ACTION.Use)==true or input.isActionPressed(input.ACTION.Inventory)==true)  then
		ShowInventory()
		InventoryItemSelected[2]=nil
		PickUpItem[4]=true
	end
	if PickUpItem[4]==true and PickUpItem[5]~=true and input.isActionPressed(input.ACTION.Use)==false and input.isActionPressed(input.ACTION.Inventory)==false  then
		PickUpItem[5]=true
	end
	if PickUpItem[2]==true and PickUpItem[5]==true and PickUpItem[6]~=true and (input.isActionPressed(input.ACTION.Use)==true or input.isActionPressed(input.ACTION.Inventory)==true)  then
		ShowInventory()
		InventoryItemSelected[2]=nil
		PickUpItem[6]=true
	end
	if PickUpItem[6]==true and PickUpItem[7]~=true and input.isActionPressed(input.ACTION.Use)==false and input.isActionPressed(input.ACTION.Inventory)==false  then
		PickUpItem[7]=true
	end
	if (PickUpItem[7]==true or (PickUpItem[2]==false and PickUpItem[5]==true)) and (input.isActionPressed(input.ACTION.Use)==true or input.isActionPressed(input.ACTION.Inventory)==true)  then
		Inventory:destroy()
		InventoryBkg:destroy()
		ShowItemIcon:destroy()
		PickUpItem={}
		I.UI.removeMode(I.UI.MODE.Interface)
	end


	----------- Inventaire
	if I.UI.getMode()=="Interface" then

	
		if doOnceMenu == 0 then
			doOnceMenu=1
			MenuSelectStop=false
			SelectedItemLayout = {layer = 'Windows',type = ui.TYPE.Image,props = {size = util.vector2(ui.screenSize().x/10, ui.screenSize().y/9),
			relativePosition = util.vector2(3/4, 1/3),
			anchor = util.vector2(0, 0),
			resource = ui.texture{path = "textures/SelectedItem.dds"},},}
			if InventoryItemSelected[2] then
				SelectedItem=ui.create(SelectedItemLayout)
			end


			if types.Actor.getEquipment(self,16) then
				iconpath=types.Weapon.record(types.Actor.getEquipment(self,16)).icon
			else
				iconpath="icons/No Item.dds"
			end
			EquippedWeaponDisplay= ui.create({name="EquippedWeapon",layer = 'Windows',  type = ui.TYPE.Image,  props = {relativeSize = util.vector2(1/6, 1/6),relativePosition=util.vector2(1/2, 1/4),anchor = util.vector2(0.5, 0.5),resource = ui.texture{path =iconpath},},}) 
			
			Portrait=ui.create({name="Portrait",layer = 'Windows',  type = ui.TYPE.Image,  props = {relativeSize = util.vector2(1/7, 1/5),relativePosition=util.vector2(1/8, 1/4),anchor = util.vector2(0.5, 0.5),resource = ui.texture{path ='textures/Portrait/'..tostring(types.NPC.record(self).race)..'.jpg'},},}) 
			if types.Actor.activeEffects(self):getEffect("poison") and types.Actor.activeEffects(self):getEffect("poison").magnitude>0 then 
				path1='textures/Lifebar/Poison/'
			elseif (onFrameHealth/types.Actor.stats.dynamic.health(self).base) >= 0.8 then
				path1='textures/Lifebar/Fine/'
			elseif (onFrameHealth/types.Actor.stats.dynamic.health(self).base) <= 0.3 then
				path1='textures/Lifebar/Danger/'
			else 
				path1='textures/Lifebar/Caution/'
			end
			
			path3=path1..'1.jpg'
			Lifebare=ui.create({name="LifeBare",layer = 'Windows',  type = ui.TYPE.Image,  props = {relativeSize = util.vector2(1/5, 1/6),relativePosition=util.vector2(1/6, 1/4),anchor = util.vector2(0.5, 0.5),resource = ui.texture{path =path3},},})
		end
		if (core.getRealTime()-lifebarTimer)>0.04 then
			path2=path2+1
			lifebarTimer=core.getRealTime()
			if path2==55 then 
				path2=1 
				if types.Actor.activeEffects(self):getEffect("poison") and types.Actor.activeEffects(self):getEffect("poison").magnitude>0 then 
					path1='textures/Lifebar/Poison/'
				elseif (onFrameHealth/types.Actor.stats.dynamic.health(self).base) >= 0.8 then
					path1='textures/Lifebar/Fine/'
				elseif (onFrameHealth/types.Actor.stats.dynamic.health(self).base) <= 0.3 then
					path1='textures/Lifebar/Danger/'
				else 
					path1='textures/Lifebar/Caution/'
				end
			end
	
			path3=path1..path2..".jpg"
			Lifebare.layout.props = {relativeSize = util.vector2(1/5, 1/6),relativePosition=util.vector2(0, 0),anchor = util.vector2(-1, -1),resource = ui.texture{path =path3},}				
			if Lifebare then
				Lifebare:update()
			end
		end



		----------Naviguer dans inventaire

		if InventoryItemSelected[2] and TurnLeft(-0.2)==true and InventoryItemSelected[3]==nil and InventoryItemSelected[2]~=1 and MenuSelectStop==false then
			InventoryItemSelected[2]=InventoryItemSelected[2]-1
			MenuSelectStop=true 
			ui.showMessage(tostring(InventoryItems[InventoryItemSelected[2]]))
		elseif InventoryItemSelected[2] and  TurnRight(0.2)==true and InventoryItemSelected[3]==nil and InventoryItemSelected[2]~=types.NPC.getCapacity(self) and MenuSelectStop==false  then
			InventoryItemSelected[2]=InventoryItemSelected[2]+1
			MenuSelectStop=true 
			ui.showMessage(tostring(InventoryItems[InventoryItemSelected[2]]))
		elseif InventoryItemSelected[2] and  MoveBackward(0.2)==true and InventoryItemSelected[3]==nil and InventoryItemSelected[2]<=(types.NPC.getCapacity(self)-2) and MenuSelectStop==false   then
			InventoryItemSelected[2]=InventoryItemSelected[2]+2
			MenuSelectStop=true 
			ui.showMessage(tostring(InventoryItems[InventoryItemSelected[2]]))
		elseif InventoryItemSelected[2] and  MoveForward(-0.2)==true and InventoryItemSelected[3]==nil  and InventoryItemSelected[2]>=3 and MenuSelectStop==false  then
			InventoryItemSelected[2]=InventoryItemSelected[2]-2
			MenuSelectStop=true 
			ui.showMessage(tostring(InventoryItems[InventoryItemSelected[2]]))
		elseif InventoryItemSelected[2] and InventoryItemSelected[3]==nil and input.isActionPressed(input.ACTION.Use)==true and ToggleUseButton==true then
			print("here")
			InventoryItemSelected[3]=1
			ToggleUseButton=false
			
			SubInventoryBkgLayout = {layer = 'Windows',type = ui.TYPE.Image,props = {size = util.vector2(ui.screenSize().x/5, ui.screenSize().y/3),
			relativePosition = util.vector2(13/24, 1/2),
			anchor = util.vector2(0, 0),
			resource = ui.texture{path = "textures/Sub Menu Inventory.dds"},},}

			SubInventoryBkg=ui.create(SubInventoryBkgLayout)

			SubInventoryText1={layer = 'Windows',type = ui.TYPE.Text, props={text = "Equip",textSize=50,textColor=util.color.rgb(0.5,0.5,0.5)},}
			SubInventoryText2={layer = 'Windows',type = ui.TYPE.Text, props={text = "Check",textSize=50,textColor=util.color.rgb(1,1,1)},}
			SubInventoryText3={layer = 'Windows',type = ui.TYPE.Text, props={text = "Combine",textSize=50,textColor=util.color.rgb(1,1,1)},}
			SubInventoryText4={layer = 'Windows',type = ui.TYPE.Text, props={text = "Drop",textSize=50,textColor=util.color.rgb(1,1,1)},}

			SubInventoryTexts={layer = 'Windows',type = ui.TYPE.Flex, props={autoSize=false,relativeSize = util.vector2(1/5,1/2),
				relativePosition = util.vector2(14/24, 1/2),  anchor = util.vector2(0, 0),}, content=ui.content{SubInventoryText1,
				{layer = 'Windows',type = ui.TYPE.Text,props = {text=" ",textSize=35}},SubInventoryText2,
				{layer = 'Windows',type = ui.TYPE.Text,props = {text=" ",textSize=35}},SubInventoryText3,
				{layer = 'Windows',type = ui.TYPE.Text,props = {text=" ",textSize=35}},SubInventoryText4}}

			SubInventory=ui.create(SubInventoryTexts)

		elseif TurnLeft(-0.2)==nil and TurnRight(0.2)==nil and MoveBackward(0.2)==nil and MoveForward(-0.2)==nil and ToggleUseButton==true then
			MenuSelectStop=false 			
		end	

		if InventoryItemSelected[2] and SelectedItem then
			SelectedItemLayout.props.relativePosition=util.vector2(3/4+1/10-(InventoryItemSelected[2]%2)*1/10,1/3+(InventoryItemSelected[2]+InventoryItemSelected[2]%2)/2*1/9-1/9)
			SelectedItem:update()
		end

		if InventoryItemSelected[3] then
			if MoveForward(-0.2)==true and InventoryItemSelected[3]>=3 and MenuSelectStop==false  then
				SubInventoryTexts.content[InventoryItemSelected[3]].props.textColor=util.color.rgb(1,1,1)
				SubInventory:update()
				InventoryItemSelected[3]=InventoryItemSelected[3]-2
				MenuSelectStop=true 
				SubInventoryTexts.content[InventoryItemSelected[3]].props.textColor=util.color.rgb(0.5,0.5,0.5)
				SubInventory:update()
			elseif MoveBackward(0.2)==true and InventoryItemSelected[3]<=5 and MenuSelectStop==false   then
				SubInventoryTexts.content[InventoryItemSelected[3]].props.textColor=util.color.rgb(1,1,1)
				SubInventory:update()
				InventoryItemSelected[3]=InventoryItemSelected[3]+2
				MenuSelectStop=true 
				SubInventoryTexts.content[InventoryItemSelected[3]].props.textColor=util.color.rgb(0.5,0.5,0.5)
				SubInventory:update()
			elseif FrameRefresh==true and Framewait(3) then
				ToggleUseButton=false
				FrameRefresh=false
				doOnceMenu=0
				if ShowItemIcon then
					ShowItemIcon:destroy()
					ShowItemIcon=nil
				end
				EquippedWeaponDisplay:destroy()
				Portrait:destroy()
				Lifebare:destroy()
				SelectedItem:destroy()
				if SubInventoryBkg then
					SubInventoryBkg:destroy()
				end
				if SubInventory then
					SubInventory:destroy()
				end
				InventoryItemSelected[2]=1
				InventoryItemSelected[3]=nil
				InventoryItems=ShowInventory()

			elseif input.isActionPressed(input.ACTION.Use)==true and ToggleUseButton==true and FrameRefresh==false then
					if InventoryItemSelected[3]==1 then
						core.sendGlobalEvent('UseItem',{object=InventoryItems[InventoryItemSelected[2]],actor=self,force=true})
						if InventoryItems[InventoryItemSelected[2]].type == types.Potion then
							for i, effect in ipairs(types.Potion.record(InventoryItems[InventoryItemSelected[2]]).effects) do
								print(effect.effect.id)
								print(core.magic.EFFECT_TYPE.RestoreHealth )
								if effect.effect.id == core.magic.EFFECT_TYPE.RestoreHealth then
									onFrameHealth=types.Actor.stats.dynamic.health(self).current+(effect.magnitudeMin+effect.magnitudeMin)/2
									if onFrameHealth>types.Actor.stats.dynamic.health(self).base then
										onFrameHealth=types.Actor.stats.dynamic.health(self).base
									end
									print(onFrameHealth)

								end
							end
						end

						FrameRefresh=true

					elseif InventoryItemSelected[3]==3 then

						if input.isActionPressed(input.ACTION.Use)==true and ToggleUseButton==true and ShowItemIcon then
							FrameRefresh=true
							print("refresh")
							for i, item in ipairs(ExaminedItems) do
								print("test")
								if InventoryItems[InventoryItemSelected[2]].type.record(InventoryItems[InventoryItemSelected[2]]).id==string.lower(ExaminedItems[i][1]) then
									core.sendGlobalEvent('RemoveItem', {Item=InventoryItems[InventoryItemSelected[2]], number=1})
									core.sendGlobalEvent('MoveInto', {Item=nil, container=nil, actor= self, newItem=ExaminedItems[i][2]})
								end
							end
						end			

						if ShowItemIcon==nil then
							ShowItem(InventoryItems[InventoryItemSelected[2]],tostring(InventoryItems[InventoryItemSelected[2]]))
							SubInventoryBkg:destroy()
							SubInventory:destroy()
						end

						ToggleUseButton=false

					elseif InventoryItemSelected[3]==5 then
						print("Combine")
						FrameRefresh=true

					elseif InventoryItemSelected[3]==7 then
						core.sendGlobalEvent('Teleport', {actor=InventoryItems[InventoryItemSelected[2]], position=self.position, rotation=nil})
						FrameRefresh=true
					end
					ToggleUseButton=false
			elseif MoveBackward(0.2)==nil and MoveForward(-0.2)==nil and ToggleUseButton==true then
				MenuSelectStop=false 
			end
			--print(InventoryItemSelected[3])
		end
		
		--print(InventoryItemSelected[2])
		--print(InventoryItems[InventoryItemSelected[2]])
		if ToggleUseButton==false and input.isActionPressed(input.ACTION.Use)==false then
			ToggleUseButton=true
		end





	elseif I.UI.getMode()==nil and doOnceMenu==1 then
		EquippedWeaponDisplay:destroy()
		Portrait:destroy()
		Lifebare:destroy()
		Inventory:destroy()
		InventoryBkg:destroy()
		if SelectedItem then
			SelectedItem:destroy()
		end
		if InventoryItemSelected[3] then
			SubInventoryBkg:destroy()
			SubInventory:destroy()
		end
		InventoryItemSelected[2]=nil
		InventoryItemSelected[3]=nil
		doOnceMenu=0
	end
	
	-----------ouvrir le menu inventaire
	if input.isActionPressed(input.ACTION.Inventory)==true and I.UI.getMode()==nil and Menu==false and types.Actor.getStance(self)==0 then-- and PickUpItem[1]==nil then
		I.UI.setMode(I.UI.MODE.Interface, {windows = {I.UI.WINDOW.QuickKeys,}})
		InventoryItems=ShowInventory()
		InventoryItemSelected[2]=1
		ui.showMessage(tostring(InventoryItems[InventoryItemSelected[2]]))
	elseif input.isActionPressed(input.ACTION.Inventory)==true and I.UI.getMode() and Menu==true then
		I.UI.removeMode(I.UI.MODE.Interface)
	elseif input.isActionPressed(input.ACTION.Inventory)==false and I.UI.getMode() then
		Menu=true
	elseif input.isActionPressed(input.ACTION.Inventory)==false and I.UI.getMode()==nil then
		Menu=false
	end
	
	




   		
   	-------------Equiper une arme       		
    if types.Actor.getEquipment(self,16) and types.Weapon.record(types.Actor.getEquipment(self,16)).type==10 and types.Actor.getEquipment(self,16)~=EquippedWeapon then ---define ammo an auto equip basic ammos
       	EquippedWeapon=types.Actor.getEquipment(self,16)
		AmmunitionTypes={}
		ammoscharged=false
           	-----------déterminer les types de munitions
   		if core.magic.enchantments[types.Weapon.record(types.Actor.getEquipment(self,16)).enchant] ~= nil then
			for c in tostring(core.magic.enchantments[types.Weapon.record(types.Actor.getEquipment(self,16)).enchant].id):gmatch"." do
				if not(c=="_") then
        			word=word..c
    			elseif c=="_" then
					--print("1"..tostring(AmmunitionTypes[1]))
					--print("2"..tostring(AmmunitionTypes[2]))
					--print("3"..tostring(types.Item.itemData(types.Actor.getEquipment(self,16)).condition))
					--print("4"..tostring(types.Item.getEnchantmentCharge(types.Actor.getEquipment(self,16))))
					if AmmunitionTypes[1] and AmmunitionTypes[2]==nil then
						weaponcondition=10001


					elseif word~="_" and word and word~="" then
						for a, ammo in ipairs(types.Weapon.records) do
							if ammo.id==word then
	    	  					table.insert(AmmunitionTypes, ammo)
	    	  					--print(word)
							end
						end
					end
        			word=""
    			end    
			end	
			--for i, ammo in pairs(AmmunitionTypes) do
				--print(ammo)
			--end
		end
    end



	---------------------change Ammos
    if wrongammo==false then
		wrongammo=true
	end

	if ammochanged==true then
		ammochanged=false
		I.UI.removeMode(I.UI.MODE.Interface)
		I.UI.setMode(I.UI.MODE.Interface, {windows = {I.UI.WINDOW.QuickKeys,}})
	end

	if types.Actor.getEquipment(self,18) and (types.Actor.getEquipment(self,16)==nil or types.Weapon.record(types.Actor.getEquipment(self,16)).type~=10) then
		ui.showMessage("You need a weapon to use ammo")
		types.Actor.setEquipment(self,{[types.Actor.EQUIPMENT_SLOT.CarriedRight]=types.Actor.getEquipment(self,16)})
		I.UI.removeMode(I.UI.MODE.Interface)
		I.UI.setMode(I.UI.MODE.Interface, {windows = {I.UI.WINDOW.QuickKeys,}})
	elseif I.UI.getMode()=="Interface" and types.Actor.getEquipment(self,18) and types.Actor.getEquipment(self,16) and types.Weapon.record(types.Actor.getEquipment(self,16)).type==10 and core.magic.enchantments[types.Weapon.record(types.Actor.getEquipment(self,16)).enchant].charge==types.Item.getEnchantmentCharge(types.Actor.getEquipment(self,16)) and types.Actor.getEquipment(self,18).recordId==AmmunitionTypes[types.Item.itemData(types.Actor.getEquipment(self,16)).condition-10000].id then
		ui.showMessage("Weapon full")
		types.Actor.setEquipment(self,{[types.Actor.EQUIPMENT_SLOT.CarriedRight]=types.Actor.getEquipment(self,16)})
		I.UI.removeMode(I.UI.MODE.Interface)
		I.UI.setMode(I.UI.MODE.Interface, {windows = {I.UI.WINDOW.QuickKeys,}})
 	elseif I.UI.getMode()=="Interface" and types.Actor.getEquipment(self,18) and types.Actor.getEquipment(self,16) and types.Weapon.record(types.Actor.getEquipment(self,16)).type==10 then
		for i, ammo in pairs(AmmunitionTypes) do

			if types.Actor.getEquipment(self,18).recordId==ammo.id then

				if  types.Actor.inventory(self):countOf(AmmunitionTypes[i].id)>=core.magic.enchantments[types.Weapon.record(types.Actor.getEquipment(self,16)).enchant].charge then
					ammosloadable=core.magic.enchantments[types.Weapon.record(types.Actor.getEquipment(self,16)).enchant].charge
					--print(ammosloadable)
				else
					ammosloadable=types.Actor.inventory(self):countOf(AmmunitionTypes[i].id)
				end
				--print(AmmunitionTypes[i])
				--print(types.Actor.inventory(self):find(AmmunitionTypes[i].id))
				print(ammosloadable)
				core.sendGlobalEvent('setCharge', {Item=types.Actor.getEquipment(self,16), value=ammosloadable})
				if types.Actor.getEquipment(self,18).recordId ~=AmmunitionTypes[types.Item.itemData(types.Actor.getEquipment(self,16)).condition-10000].id then
					core.sendGlobalEvent('createAmmosinInventory', {ammo=AmmunitionTypes[types.Item.itemData(types.Actor.getEquipment(self,16)).condition-10000].id, number=types.Item.getEnchantmentCharge(types.Actor.getEquipment(self,16)), actor=self})
				end
				weaponcondition=10000+i
				types.Actor.getEquipment(self,16):sendEvent('setCondition',{value=weaponcondition})
				core.sendGlobalEvent('RemoveItem', {Item=types.Actor.inventory(self):find(AmmunitionTypes[i].id), number=ammosloadable})
				wrongammo=false
				ammochanged=true
				
				types.Actor.setEquipment(self,{[types.Actor.EQUIPMENT_SLOT.CarriedRight]=types.Actor.getEquipment(self,16)})
				I.UI.removeMode(I.UI.MODE.Interface)
				I.UI.setMode(I.UI.MODE.Interface, {windows = {I.UI.WINDOW.QuickKeys,}})

			end
		end
	 if wrongammo==true then
		 ui.showMessage("Wrong ammo")
		 types.Actor.setEquipment(self,{[types.Actor.EQUIPMENT_SLOT.CarriedRight]=types.Actor.getEquipment(self,16)})
		 I.UI.removeMode(I.UI.MODE.Interface)
		 I.UI.setMode(I.UI.MODE.Interface, {windows = {I.UI.WINDOW.QuickKeys,}})
	 end






	end
end




return {
	eventHandlers = {CameraPos = camerapos },
	engineHandlers = {

        onFrame = onFrame,
        onUpdate = onUpdate

	}
}


