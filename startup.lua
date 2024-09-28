---@diagnostic disable: undefined-global

local monitor = peripheral.wrap("back")
local dropper = peripheral.wrap("bottom")
local storage = peripheral.wrap("top")
turtleside = "right"
local turtl = peripheral.wrap(turtleside)
monitor.setTextScale(0.5)
 
local screenWidth, screenHeight = monitor.getSize()
 
Dispensing = false
items = {}
-- This is a temporary example on how items table looks like
--local items = {
 --   { name = "Diamond", nbt_name = "minecraft:diamond", price = 2, amount = 5 }
--}


function sendPulse(Strength, Time)
    redstone.setAnalogOutput(turtleside, Strength)
    sleep(Time)
    redstone.setAnalogOutput(turtleside, 0)
end

function getItems()
    local items = {}
    local file = io.open("items.txt", "r")
    if file then
        local lines = file:read("*a")
        items = textutils.unserialise(lines)
        file:close()
    end
    return items
end


function getMoney(type)
    local contents = storage.list()
    local money = 0
    for index, item in pairs(contents) do
        if item.name == items[2].nbt_name then
            money = money + item.count
        end
    end
    if type == 1 then
        return money - profit
    else
        return money
    end
end

function redDisp(index, amount)
    sleep(0.1)
    dropper.pullItems(storage, index, amount)

    -- for i = 1, amount do
    while dropper.list() ~= nil do
        redstone.setOutput("bottom", true)
        sleep(0.1)
        redstone.setOutput("bottom", false)
        sleep(0.1)
    end
end

function dispenseBalance()
    if not Dispensing then
        local balance = getMoney(1)
        if balance > 0  then
            local contents = storage.list()
            for index, item in ipairs(contents) do
                if item.name == items[2].nbt_name and balance > 0 then
                    Dispensing = true
                    balance = balance - item.count
                    redDisp(index, item.count)
                end
            end
            Dispensing = false
        else
            balance = 0
            profit = getMoney()
            print("Balance reset")
        end
    end
end

function dontTouch()
    term.clear()
    --term.setTextScale(2)
    term.setCursorPos(1, 1)
    term.setTextColour(colours.red)
    term.write("Coded by Foll")
    term.setCursorPos(1, 2)
    term.write("DONT TOUCH!")
    --term.setTextScale(0.5)
    term.setCursorPos(1, 4)
end

function getStoredItems(item_name)
    local contents = storage.list()
    local items = {}
    local count = 0
    for index, item in ipairs(contents) do
        if item.name == item_name then
            count = count + item.count
            table.insert(items, { index = index, amount = item.count })
        end
    end
    return count, items
end

function dispenseItem(itemIndex)
    local selected = items[itemIndex]
    if selected then
        local balance = getMoney(1)
        local count, items_stored = getStoredItems(selected.nbt_name)
        if count >= selected.amount then
            if balance >= selected.price then
                local needDrop = selected.amount
                -- balance = balance - selected.price
                profit = profit + selected.price
                for index, item in ipairs(items_stored) do
                    redDisp(item.index, math.max(math.min(64, needDrop)))
                    needDrop = needDrop - item.amount
                end
                print("Dispensed "..selected.amount.." " .. selected.name .. " for $" .. selected.price)
            else
                print("Not enough money")
            end
        else
            print("Not enough items")
        end
    else
        print("Invalid selection!")
    end
end

function displayItems()
    while true do
        local balance = getMoney(1)

        monitor.setTextScale(0.5)
        monitor.clear()
        monitor.setCursorPos(1, 1)
        monitor.write("Balance: $" .. balance)
        for index, item in ipairs(items) do
            monitor.setCursorPos(1, index+1)
            -- monitor.write(index .. ". " .. item.name .. " - $" .. item.price)
            monitor.write("$" .. item.price .. " - " .. item.name)
        end

        --Dispense money button
        monitor.setCursorPos(1, screenHeight-1)
        monitor.write("Dispense $"..balance)

    end
end

function getTouch()
    while true do
        local event, side, xPos, yPos = os.pullEvent("monitor_touch")
        local items = getItems()
        if xPos <= screenWidth and yPos <= #items+1 then
            --local balance = getMoney(1)
            dispenseItem(yPos-1)
        elseif xPos <= screenWidth and yPos >= screenHeight-2 then
            dispenseBalance()
        end
    end
end

function listenForCommands()
    while true do
        local strength = redstone.getAnalogInput(turtleside)

        if strength == 9 then
            transferItems()
        end

        sleep(0.3)
    end
end

function transferItems()
    while true do
        for i=1, 16 do
            status = storage.pullItems(turtleside, i)
        end
        sleep(0.3)
    end
end


function setup()
    term.clear()
    term.setCursorPos(1, 1)
    term.setTextColour(colours.red)
    term.write("Warning!")
    term.setCursorPos(1, 2)
    term.write("Uses stack size as price and quantity")
    sleep(2)
    
    local function instructions()
        while true do
            term.clear()
            term.setCursorPos(1, 1)
            term.setTextColour(colours.white)
            term.write("Enter the item that you want to sell, then the price")
            term.setCursorPos(1, 2)
            term.write("The first price sets the entire machines currency")
            term.setCursorPos(1, 3)
            term.write('Then write "Done" to complete the setup') 
            local input = read()
            if tostring(input) == "Done" then
                sendPulse(13, 2)
                dontTouch()
                break
            end
        end
    end

    local function toTitleCase(str)
        return str:match(":(.*)"):gsub("(%a)([%w_]*)", function(a, b) return a:upper() .. b:gsub("_", " ") end)
    end

    local function gettingItems()
        local items = {}
        local blacklist = 0
        while true do

            for i=1, 16 do
                local status = storage.pullItems(turtleside, i)
                sleep(0.3)
            end

            local contents = storage.list()
            if #contents > 0 then
                for index, item in ipairs(contents) do
                    if (index % 2 == 1) and blacklist < index and contents[index + 1]then
                        table.insert(items, {name=toTitleCase(item.name), nbt_name = item.name, amount=item.count, price_nbt=contents[index+1].name, price=contents[index+1].count})
                        blacklist = index + 1
                    end
                end
            end

            if #items > 0 then
                fs.delete("items.txt")
                local file = fs.open("items.txt", "w")
                file.write(textutils.serialize(items))
                file.close()
            end

            sleep(0.3)
        end
    end

    parallel.waitForAny(instructions, gettingItems)
end



if fs.exists("items.txt") then
    items = getItems()
    dontTouch()
else
    setup()
    items = getItems()
end

profit = getMoney()
    
parallel.waitForAny(displayItems, getTouch, transferItems)


