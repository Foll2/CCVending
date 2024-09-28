---@diagnostic disable: undefined-global
computerside = "left"
inputside = "front"

local input = peripheral.wrap(inputside)
local comput = peripheral.wrap(computerside)

--[[if fs.exists("settings.txt") then
    main()
else
    --Setup
    setup()
end


function setup()
    --First get the item
    --Second get the price

    --Print instructions

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
            term.write("Enter the item that you want to sell then the price")
            
            term.setCursorPos(1, 2)
            term.write('Then write "Done" do complete the setup') 
            input = read()
            if tostring(input) == "Done" then
                redstone.setAnalogOutput(computerside, 13)
                sleep(2)
                redstone.setAnalogOutput(computerside, 0)
                break
            end
        end
    end


    --parallel.waitForAny(instructions,

end]]--

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



--[[

function getItemIndex(itemName)
	for slot = 1, 16, 1 do
		local item = turtle.getItemDetail(slot)
		if(item ~= nil) then
			if(item["name"] == itemName) then
				return slot
			end
		end
	end
end

-- Gets a list of stored items by name with the amount
function getInputItems(item_name)
    local contents = input.list()
    local items = {}
    local count = 0
    for index, item in ipairs(contents) do
        if item.name == item_name then
            count = count + item.count
            table.insert(items, { index = index, amount = item.count, name = item.name })
        end
    end
    return count, items
end


function inventoryItems()
    local result = {}
    for i=1,16 do
      local item = turtle.getItemDetail(i)
      if item then
        local itemCount = turtle.getItemCount(i)
        table.insert(result, { index = i, amount = item.count, name = item.name })
      end
    end
    return result
end

]]--