-- Copyright (C) 2026 Chez_Squall. All rights reserved.
AgriLife = AgriLife or {}

if AgriLife.Workshop6Service ~= nil then
    local Workshop = AgriLife.Workshop6Service
    Workshop.PART_HUD_ICON_VERSION = "0.9.3.19"
    Workshop.PART_HUD_ICONS = {
        engineLongBlock = "gui/icons/sys_engine.dds",
        oilLine = "gui/icons/oil.dds",
        oilPump = "gui/icons/oil.dds",
        fuelLine = "gui/icons/sys_engine.dds",
        fuelPump = "gui/icons/sys_engine.dds",
        fuelFilter = "gui/icons/sys_engine.dds",
        airFilter = "gui/icons/sys_engine.dds",
        turbocharger = "gui/icons/sys_engine.dds",
        radiator = "gui/icons/sys_engine.dds",
        coolantHose = "gui/icons/sys_engine.dds",
        alternator = "gui/icons/sys_electrical.dds",
        battery = "gui/icons/sys_electrical.dds",
        clutch = "gui/ui6icons/workshop.dds",
        transmission = "gui/ui6icons/workshop.dds",
        driveShaft = "gui/ui6icons/workshop.dds",
        ptoShaft = "gui/ui6icons/workshop.dds",
        hydraulicHose = "gui/icons/sys_hydraulic.dds",
        hydraulicPump = "gui/icons/sys_hydraulic.dds",
        brakeKit = "gui/ui6icons/workshop.dds",
        steeringJoint = "gui/ui6icons/workshop.dds",
        spring = "gui/ui6icons/workshop.dds",
        tyre = "gui/icons/vehicle.dds",
        wheelBearing = "gui/ui6icons/workshop.dds",
        windscreen = "gui/icons/vehicle.dds",
        lightUnit = "gui/icons/sys_electrical.dds",
        chainBelt = "gui/ui6icons/workshop.dds",
        dosingUnit = "gui/ui6icons/workshop.dds",
        electronicController = "gui/icons/sys_electrical.dds",
        hitchJoint = "gui/ui6icons/workshop.dds",
        axleHub = "gui/ui6icons/workshop.dds",
        annualServiceKit = "gui/icons/calendar.dds",
        bodywork = "gui/icons/vehicle.dds",
        exhaust = "gui/icons/sys_engine.dds"
    }

    function Workshop:getPartHudIcon(partFamily)
        local key = tostring(partFamily or "")
        local relative = self.PART_HUD_ICONS[key] or "gui/ui6icons/workshop.dds"
        local prefix = AgriLife.Version ~= nil and AgriLife.Version.MOD_DIR or (g_currentModDirectory or "")
        return tostring(prefix or "") .. relative
    end

    function Workshop:decoratePartRowWithHudIcon(row)
        if type(row) == "table" then
            row.hudIcon = self:getPartHudIcon(row.partFamily)
        end
        return row
    end
end
