---@enum Position
local positions = {
    left = 'left-center',
    right = 'right-center',
    top = 'top-center'
}

---@deprecated use ox_lib showTextUI calls directly
local function hideText()
    lib.hideTextUI()
end

---@deprecated use ox_lib showTextUI calls directly
---@param text string
---@param position Position
local function drawText(text, position)
    -- Force position to always be top-left
    lib.showTextUI(text, {
        position = 'top-left'
    })
end

---@deprecated use ox_lib showTextUI calls directly
---@param text string
---@param position Position
local function changeText(text, position)
    -- Force position to always be top-left
    lib.hideTextUI()
    lib.showTextUI(text, {
        position = 'top-left'
    })
end

---@deprecated use ox_lib showTextUI calls directly
local function keyPressed()
    CreateThread(function()
        Wait(500)
        lib.hideTextUI()
    end)
end

---@deprecated use ox_lib showTextUI calls directly
RegisterNetEvent('qb-core:client:DrawText', function(text, position)
    drawText(text, position)
end)

---@deprecated use ox_lib showTextUI calls directly
RegisterNetEvent('qb-core:client:ChangeText', function(text, position)
    changeText(text, position)
end)

---@deprecated use ox_lib showTextUI calls directly
RegisterNetEvent('qb-core:client:HideText', function()
    hideText()
end)

---@deprecated use ox_lib showTextUI calls directly
RegisterNetEvent('qb-core:client:KeyPressed', function()
    keyPressed()
end)

local createQbExport = require 'bridge.qb.shared.export-function'

---@deprecated use ox_lib showTextUI calls directly
createQbExport('DrawText', drawText)
---@deprecated use ox_lib showTextUI calls directly
createQbExport('ChangeText', changeText)
---@deprecated use ox_lib showTextUI calls directly
createQbExport('HideText', hideText)
---@deprecated use ox_lib showTextUI calls directly
createQbExport('KeyPressed', keyPressed)
