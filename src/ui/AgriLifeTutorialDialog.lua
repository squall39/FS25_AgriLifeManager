-- Copyright (C) 2026 Chez_Squall. All rights reserved.
AgriLife = AgriLife or {}

AgriLife.TutorialDialog = {}
AgriLife.TutorialDialog_mt = Class(AgriLife.TutorialDialog, DialogElement)

-- FS25 1.21 compatibility: custom controllers are FrameElement descendants, but
-- some runtime builds do not expose registerControls through the custom dialog
-- metatable at constructor time. Call the FrameElement implementation directly
-- as a safe fallback so IDs are still exposed after g_gui:loadGui().
local function registerDialogControls(controller, controlIds)
    if controller ~= nil and type(controller.registerControls) == "function" then
        controller:registerControls(controlIds)
        return
    end
    if controller ~= nil and FrameElement ~= nil and type(FrameElement.registerControls) == "function" then
        controller.controlIDs = controller.controlIDs or {}
        FrameElement.registerControls(controller, controlIds)
        return
    end
    error("AgriLife dialog controller cannot register GUI controls")
end

function AgriLife.TutorialDialog.new()
    local self = DialogElement.new(nil, AgriLife.TutorialDialog_mt)
    registerDialogControls(self, {"dialogTitle", "pageText", "bodyText", "prevButton", "nextButton", "closeButton"})
    self.pages = {}
    self.pageIndex = 1
    self.finishCallback = nil
    self.finishTarget = nil
    self.finishArgs = nil
    self.finishRequested = false
    self.callbackInvoked = false
    return self
end

function AgriLife.TutorialDialog:setData(pages, callback, target, args)
    self.pages = {}
    for _, value in ipairs(type(pages) == "table" and pages or {}) do
        table.insert(self.pages, tostring(value or ""))
    end
    if #self.pages <= 0 then self.pages = {""} end
    self.pageIndex = 1
    self.finishCallback = callback
    self.finishTarget = target
    self.finishArgs = args
    self.finishRequested = false
    self.callbackInvoked = false
    self:refreshPage()
end

function AgriLife.TutorialDialog:refreshPage()
    local count = #self.pages
    self.pageIndex = math.max(1, math.min(count, tonumber(self.pageIndex) or 1))
    if self.dialogTitle ~= nil and self.dialogTitle.setText ~= nil then self.dialogTitle:setText(g_i18n:getText("agrilife_tutorial_dialog_title")) end
    if self.bodyText ~= nil and self.bodyText.setText ~= nil then self.bodyText:setText(self.pages[self.pageIndex] or "") end
    if self.pageText ~= nil and self.pageText.setText ~= nil then self.pageText:setText(string.format(g_i18n:getText("agrilife_tutorial_page_counter_fmt"), self.pageIndex, count)) end
    if self.prevButton ~= nil and self.prevButton.setDisabled ~= nil then self.prevButton:setDisabled(self.pageIndex <= 1) end
    if self.nextButton ~= nil and self.nextButton.setText ~= nil then
        self.nextButton:setText(g_i18n:getText(self.pageIndex >= count and "agrilife_tutorial_finish" or "agrilife_tutorial_next"))
    end
end

function AgriLife.TutorialDialog:onOpen()
    AgriLife.TutorialDialog:superClass().onOpen(self)
    self:refreshPage()
end

function AgriLife.TutorialDialog:onClickPrevious()
    if self.pageIndex > 1 then self.pageIndex = self.pageIndex - 1; self:refreshPage() end
end

function AgriLife.TutorialDialog:onClickNext()
    if self.pageIndex < #self.pages then
        self.pageIndex = self.pageIndex + 1
        self:refreshPage()
    else
        self:finish()
    end
end

function AgriLife.TutorialDialog:onClickClose()
    self:finish()
end

function AgriLife.TutorialDialog:finish()
    self.finishRequested = true
    self:close()
end

function AgriLife.TutorialDialog:invokeFinishCallback()
    if self.callbackInvoked then return end
    self.callbackInvoked = true
    local callback = self.finishCallback
    local target = self.finishTarget
    local args = self.finishArgs
    self.finishCallback = nil
    self.finishTarget = nil
    self.finishArgs = nil
    if type(callback) == "function" then
        if target ~= nil then callback(target, args) else callback(args) end
    end
end

function AgriLife.TutorialDialog:onClose()
    AgriLife.TutorialDialog:superClass().onClose(self)
    self:invokeFinishCallback()
end

function AgriLife.TutorialDialog:onClickBack(forceBack, usedMenuButton)
    if usedMenuButton then return true end
    self.finishRequested = true
    self:close()
    return false
end
