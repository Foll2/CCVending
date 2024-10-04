---@diagnostic disable: undefined-global

local monitor = peripheral.wrap("back")
dropperside = "bottom"
local dropper = peripheral.wrap(dropperside)
storageside = "top"
local storage = peripheral.wrap(storageside)

-- "Turtle" is just input storage
inputStorage = true -- Change to false if you don't want input storage
turtleinv = 16
turtleside = "right"
local turtl = peripheral.wrap(turtleside)

monitor.setTextScale(0.5)
 
local screenWidth, screenHeight = monitor.getSize()

max_length = math.max(screenWidth - 11, 7)
 
Dispensing = false
-- This is a temporary example on how items table looks like
--local items = {
--   { name = "Diamond", nbt_name = "minecraft:diamond", price = 2, amount = 5 }
--}

function scroll_name(name, step)
    if #name <= max_length then
        return name
    end
    local start_index = step % (#name - max_length + 1) + 1
    return name:sub(start_index, start_index + max_length - 1)
end

function toTitleCase(str)
    return str:match(":(.*)"):gsub("(%a)([%w_]*)", function(a, b) return a:upper() .. b:gsub("_", " ") end)
end

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
    local items = getItems()
    local contents = storage.list()
    local money = 0
    for index, item in pairs(contents) do
        if item.name == items[1].price_nbt then
            money = money + item.count
        end
    end
    if type == 1 then
        return money - profit
    else
        return money
    end
end

function redDisp(index, amount, side)
    sleep(0.1)
    dropper.pullItems(side, index, amount)

    -- for i = 1, amount do
    while next(dropper.list()) do
        redstone.setOutput(dropperside, true)
        sleep(0.1)
        redstone.setOutput(dropperside, false)
        sleep(0.1)
    end
end

function dispenseBalance()
    if not Dispensing then
        local balance = getMoney(1)
        if balance > 0  then
            local contents = storage.list()
            local items = getItems()
            for index, item in ipairs(contents) do
                if item.name == items[1].price_nbt and balance > 0 then
                    Dispensing = true
                    local stackDisp = math.min(64, balance, item.count)
                    balance = balance - stackDisp
                    redDisp(index, stackDisp, storageside)
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
    local items = getItems()
    local selected = items[itemIndex]
    if selected then
        local balance = getMoney(1)
        local count, items_stored = getStoredItems(selected.nbt_name)
        if count >= selected.amount then
            if balance >= selected.price then
                local needDrop = selected.amount
                profit = profit + selected.price
                for index, item in ipairs(items_stored) do
                    redDisp(item.index, math.min(64, needDrop), storageside)
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
    local items = getItems()
    local step = 0
    while true do
        local balance = getMoney(1)

        monitor.setTextScale(0.5)
        monitor.clear()
        monitor.setCursorPos(1, 1)
        monitor.write("Price: " .. toTitleCase(items[1].price_nbt))
        -- monitor.write("Balance: $" .. balance)
        if step == 120 then
            step = 0
        end
        step = step + 1
        for index, item in ipairs(items) do
            monitor.setCursorPos(1, index+2)
            -- monitor.write("$" .. item.price .. " " .. item.name)
            monitor.write(string.format("$%3d %-" .. max_length .. "s %2dpcs", item.price, scroll_name(item.name, math.floor(os.epoch("utc")/1000)), item.amount))
        end

        --Dispense money button
        monitor.setCursorPos(1, screenHeight-2)
        monitor.write("Balance: $" .. balance)
        monitor.setCursorPos(1, screenHeight-1)
        monitor.write("Dispense")

        -- monitor.write("Dispense $"..balance)

    end
end

function getTouch()
    local items = getItems()
    while true do
        local event, side, xPos, yPos = os.pullEvent("monitor_touch")
        if xPos <= screenWidth and yPos <= #items+2 then
            --local balance = getMoney(1)
            dispenseItem(yPos-2)
        elseif xPos <= screenWidth and yPos >= screenHeight-2 then
            dispenseBalance()
        end
    end
end

function transferItems()
    while true do
        for i=1, turtleinv do
            status = storage.pullItems(turtleside, i)
        end
        sleep(0.3)
    end
end

function dropShit()
    while true do
        local content = storage.list()
        local whitelist = getItems()
        for index, item in pairs(content) do
            -- for index, item in pairs(peripheral.wrap("top").list()) do print(item) end
            local inlist = false
            for i, wItem in ipairs(whitelist) do
                if item.name == wItem.nbt_name or item.name == wItem.price_nbt then
                    inlist = true
                    break
                end
            end
            if not inlist then
                redDisp(index, item.count, storageside)
            end
        end

        sleep(2)
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

    local function gettingItems()
        local items = {}
        local blacklist = 0
        while true do

            if inputStorage then
                for i=1, turtleinv do
                    local status = storage.pullItems(turtleside, i)
                    sleep(0.3)
                end
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
    dontTouch()
else
    setup()
end

if fs.exists("items.txt") then
    profit = getMoney()
    if inputStorage then
        parallel.waitForAny(displayItems, getTouch, transferItems, dropShit)
    else
        parallel.waitForAny(displayItems, getTouch, dropShit)
    end
else
    print("No items found")
end