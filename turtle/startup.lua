---@diagnostic disable: undefined-global
computerside = "left"
inputside = "front"

local input = peripheral.wrap(inputside)
local comput = peripheral.wrap(computerside)

function sendPulse(Strength, Time)
    redstone.setAnalogOutput(computerside, Strength)
    sleep(Time)
    redstone.setAnalogOutput(computerside, 0)
end


function suckAllItems()
    while true do
        if table.getn(input.list()) > 0 then
            turtle.suck()
            sleep(0.1)
            sendPulse(9, 2)
        else
            sleep(0.7)
        end
    end
end

function listenForCommands()
    while true do
        --May be used for something later

        local strength = redstone.getAnalogInput(computerside)

        sleep(0.3)
    end
end


parallel.waitForAny(suckAllItems, listenForCommands)