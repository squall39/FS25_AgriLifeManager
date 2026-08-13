-- Copyright (C) 2026 Chez_Squall. All rights reserved.
-- AgriLife Manager original code: official source repository and approved distribution channels.
AgriLife = AgriLife or {}

AgriLife.CareerTransportTracker = {}
AgriLife.CareerTransportTracker.__index = AgriLife.CareerTransportTracker
AgriLife.CareerTransportTracker.MIN_CARGO_TONNES = 0.05
AgriLife.CareerTransportTracker.MIN_UNLOAD_TONNES = 0.02
AgriLife.CareerTransportTracker.MAX_STEP_DISTANCE = 120
AgriLife.CareerTransportTracker.MAX_ROUTE_FACTOR = 1.75
AgriLife.CareerTransportTracker.MIN_ROUTE_CAP_KM = 2.0

local function safeNumber(value, default) value = tonumber(value); if value == nil or value ~= value or value == math.huge or value == -math.huge then return default or 0 end; return value end
local function distance(x1,z1,x2,z2) if x1==nil or z1==nil or x2==nil or z2==nil then return 0 end; local dx,dz=x2-x1,z2-z1; return math.sqrt(dx*dx+dz*dz) end
local function getPosition(vehicle) if vehicle==nil or vehicle.rootNode==nil or vehicle.rootNode==0 or getWorldTranslation==nil then return nil,nil end; local ok,x,_,z=pcall(getWorldTranslation,vehicle.rootNode); if ok then return tonumber(x),tonumber(z) end; return nil,nil end
local function getOwnerFarmId(vehicle) if vehicle==nil then return 0 end; if vehicle.getOwnerFarmId~=nil then local ok,v=pcall(vehicle.getOwnerFarmId,vehicle); if ok and tonumber(v)~=nil then return tonumber(v) end end; return tonumber(vehicle.ownerFarmId) or 0 end
local function getUniqueId(vehicle) if vehicle==nil then return nil end; if vehicle.getUniqueId~=nil then local ok,v=pcall(vehicle.getUniqueId,vehicle); if ok and v~=nil and tostring(v)~="" then return tostring(v) end end; return vehicle.uniqueId~=nil and tostring(vehicle.uniqueId) or tostring(vehicle) end
local function getIsAIActive(vehicle) if vehicle==nil or vehicle.getIsAIActive==nil then return false end; local ok,v=pcall(vehicle.getIsAIActive,vehicle); return ok and v==true end
local function isCargoContainer(vehicle) if vehicle==nil or vehicle.spec_fillUnit==nil then return false end; if vehicle.spec_sowingMachine~=nil or vehicle.spec_sprayer~=nil or vehicle.spec_fertilizingSowingMachine~=nil or vehicle.spec_combine~=nil then return false end; return vehicle.spec_trailer~=nil or vehicle.spec_dischargeable~=nil or vehicle.spec_forageWagon~=nil end
local function getFillTypeMassPerLiter(index) if g_fillTypeManager==nil or g_fillTypeManager.getFillTypeByIndex==nil then return 0 end; local ok,d=pcall(g_fillTypeManager.getFillTypeByIndex,g_fillTypeManager,index); if not ok or d==nil then return 0 end; return math.max(0,safeNumber(d.massPerLiter,0)) end
local function getVehicleCargoTonnes(vehicle)
    if not isCargoContainer(vehicle) or vehicle.getFillUnits==nil or vehicle.getFillUnitFillLevel==nil or vehicle.getFillUnitFillType==nil then return 0 end
    local ok,units=pcall(vehicle.getFillUnits,vehicle); if not ok or type(units)~="table" then return 0 end
    local tonnes=0
    for key,unit in pairs(units) do local index=tonumber(unit~=nil and unit.fillUnitIndex) or tonumber(key); if index~=nil then local okL,level=pcall(vehicle.getFillUnitFillLevel,vehicle,index); local okT,fillType=pcall(vehicle.getFillUnitFillType,vehicle,index); if okL and okT and safeNumber(level,0)>0 and tonumber(fillType)~=nil then tonnes=tonnes+safeNumber(level,0)*getFillTypeMassPerLiter(fillType) end end end
    return math.max(0,tonnes)
end
local function collectCargoTonnes(vehicle,visited)
    if vehicle==nil then return 0 end; visited=visited or {}; if visited[vehicle] then return 0 end; visited[vehicle]=true
    local tonnes=getVehicleCargoTonnes(vehicle)
    if vehicle.getAttachedImplements~=nil then local ok,implements=pcall(vehicle.getAttachedImplements,vehicle); if ok and type(implements)=="table" then for _,imp in pairs(implements) do local object=imp~=nil and (imp.object or imp) or nil; tonnes=tonnes+collectCargoTonnes(object,visited) end end end
    return tonnes
end

function AgriLife.CareerTransportTracker.new(service) return setmetatable({service=service,runtimes={},requestSerial=0},AgriLife.CareerTransportTracker) end
function AgriLife.CareerTransportTracker:reset(profileKey) if profileKey~=nil then self.runtimes[profileKey]=nil else self.runtimes={} end end
function AgriLife.CareerTransportTracker:startRuntime(profileKey,profileId,vehicle,farmId,cargoTonnes,x,z)
    self.runtimes[profileKey]={profileId=profileId,vehicleId=getUniqueId(vehicle),farmId=farmId,x=x,z=z,originX=x,originZ=z,lastCargoTonnes=cargoTonnes,peakCargoTonnes=cargoTonnes,routeMeters=0,tonneKm=0}
end
function AgriLife.CareerTransportTracker:processContext(context,seen)
    local farmId=tonumber(context.farmId) or 0; local profileId=tostring(context.profileId or "")
    if farmId<=0 or profileId=="" then return end
    local profileKey=tostring(farmId)..":"..profileId; seen[profileKey]=true
    local vehicle=context.vehicle
    if vehicle==nil or getOwnerFarmId(vehicle)~=farmId or getIsAIActive(vehicle) then self.runtimes[profileKey]=nil; return end
    local x,z=getPosition(vehicle); if x==nil or z==nil then self.runtimes[profileKey]=nil; return end
    local cargoTonnes=collectCargoTonnes(vehicle); local vehicleId=getUniqueId(vehicle); local runtime=self.runtimes[profileKey]
    if self.service.isExamRunning~=nil and self.service:isExamRunning(farmId,profileId) then
        -- Reset the route anchor throughout the exam. Cargo distance covered
        -- for the licence can therefore never be credited on a later unload.
        self:startRuntime(profileKey,profileId,vehicle,farmId,cargoTonnes,x,z)
        return
    end
    if runtime==nil or runtime.vehicleId~=vehicleId or runtime.farmId~=farmId then self:startRuntime(profileKey,profileId,vehicle,farmId,cargoTonnes,x,z); return end
    local step=distance(runtime.x,runtime.z,x,z); runtime.x,runtime.z=x,z
    if step>0 and step<=self.MAX_STEP_DISTANCE and runtime.lastCargoTonnes>self.MIN_CARGO_TONNES then runtime.routeMeters=runtime.routeMeters+step; runtime.tonneKm=runtime.tonneKm+runtime.lastCargoTonnes*(step/1000) end
    if cargoTonnes>runtime.peakCargoTonnes then if runtime.lastCargoTonnes<=self.MIN_CARGO_TONNES then runtime.originX,runtime.originZ=x,z; runtime.routeMeters=0; runtime.tonneKm=0 end; runtime.peakCargoTonnes=cargoTonnes end
    local unloaded=runtime.lastCargoTonnes-cargoTonnes
    if unloaded>=self.MIN_UNLOAD_TONNES and runtime.tonneKm>0 then
        local denominator=math.max(runtime.lastCargoTonnes,unloaded,self.MIN_CARGO_TONNES); local share=math.min(1,unloaded/denominator); local attributable=runtime.tonneKm*share; local rawKm=attributable/math.max(unloaded,self.MIN_UNLOAD_TONNES); local straightKm=distance(runtime.originX,runtime.originZ,x,z)/1000
        local routeCapKm=math.max(self.MIN_ROUTE_CAP_KM,straightKm*self.MAX_ROUTE_FACTOR); local creditedKm=math.min(rawKm,routeCapKm)
        if creditedKm>0.01 then local efficiency=rawKm>0 and math.min(1,straightKm/rawKm) or 1; local quality=math.max(0.75,0.75+0.25*efficiency); self.requestSerial=self.requestSerial+1; self.service:awardTransport(farmId,unloaded,creditedKm,quality,string.format("delivery:%s:%d",tostring(vehicleId),self.requestSerial),profileId) end
        runtime.tonneKm=math.max(0,runtime.tonneKm-attributable)
        if cargoTonnes<=self.MIN_CARGO_TONNES then runtime.originX,runtime.originZ=x,z; runtime.routeMeters=0; runtime.tonneKm=0; runtime.peakCargoTonnes=cargoTonnes end
    end
    runtime.lastCargoTonnes=cargoTonnes
end
function AgriLife.CareerTransportTracker:update(dt)
    if self.service==nil or self.service.core==nil or self.service.core.context==nil or not self.service.core.context.isServer then return end
    local seen={}
    for _,context in ipairs(self.service:getConnectedPlayerContexts()) do self:processContext(context,seen) end
    for key,_ in pairs(self.runtimes) do if not seen[key] then self.runtimes[key]=nil end end
end
function AgriLife.CareerTransportTracker:delete() self:reset(); self.service=nil end
