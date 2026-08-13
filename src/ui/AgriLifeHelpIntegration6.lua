-- Copyright (C) 2026 Chez_Squall. All rights reserved.
-- AgriLife Manager original code: official source repository and approved distribution channels.
AgriLife = AgriLife or {}
AgriLife.HelpIntegration6={installed=false,loaded=false,iconsRegistered=false}

function AgriLife.HelpIntegration6:registerIcons()
    if self.iconsRegistered then return true end
    if g_overlayManager==nil or g_overlayManager.addTextureConfigFile==nil then return false end
    local filename=Utils.getFilename("gui/helpicons.xml",AgriLife.Version.MOD_DIR)
    local ok,result=pcall(g_overlayManager.addTextureConfigFile,g_overlayManager,filename,"agriLifeHelpIcons")
    if not ok or result==false then AgriLife.Logger.warning("Help","Assistance icon atlas registration failed: %s",tostring(result)); return false end
    self.iconsRegistered=true; AgriLife.Logger.info("Help","Assistance icon atlas registered"); return true
end

function AgriLife.HelpIntegration6.loadAdditionalHelp(manager,superFunc,...)
    local result=superFunc(manager,...)
    local integration=AgriLife.HelpIntegration6
    integration:registerIcons()
    if not integration.loaded and manager~=nil and manager.loadFromXML~=nil then
        local filename=Utils.getFilename("gui/helpLine.xml",AgriLife.Version.MOD_DIR)
        local exists=fileExists==nil or fileExists(filename)==true
        if exists then
            local ok,errorValue=pcall(manager.loadFromXML,manager,filename)
            if ok then integration.loaded=true; AgriLife.Logger.info("Help","AgriLife 6 Assistance pages loaded") else AgriLife.Logger.error("Help","Assistance pages failed to load: %s",tostring(errorValue)) end
        else AgriLife.Logger.error("Help","Assistance file missing: %s",tostring(filename)) end
    end
    return result
end

function AgriLife.HelpIntegration6:install()
    if self.installed then return true end
    self:registerIcons()
    if HelpLineManager==nil or HelpLineManager.loadMapData==nil or Utils==nil or Utils.overwrittenFunction==nil then return false end
    HelpLineManager.loadMapData=Utils.overwrittenFunction(HelpLineManager.loadMapData,AgriLife.HelpIntegration6.loadAdditionalHelp)
    self.installed=true; AgriLife.Logger.info("Help","Native Assistance integration installed"); return true
end

function AgriLife.HelpIntegration6:loadMap() self:install() end
function AgriLife.HelpIntegration6:deleteMap() self.loaded=false end
AgriLife.HelpIntegration6:install()
if addModEventListener~=nil then addModEventListener(AgriLife.HelpIntegration6) end
