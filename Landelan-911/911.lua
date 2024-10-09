local postalData = {}

-- Function to load postal data from JSON file
local function loadPostalData()
    local file = LoadResourceFile(GetCurrentResourceName(), 'oulsen_satmap_postals.json')
    if file then
        postalData = json.decode(file)
        print('Postal data loaded successfully:', json.encode(postalData)) -- Debug print
    else
        print('Failed to load postal data.')
    end
end

-- Function to find the nearest postal code
local function getNearestPostal(coords)
    local nearestPostal = nil
    local minDistance = math.huge

    for _, postal in pairs(postalData) do
        local postalCoords = vector3(postal.x, postal.y, 0) -- Assuming z is 0
        local distance = #(coords - postalCoords)

        if distance < minDistance then
            minDistance = distance
            nearestPostal = postal.code
        end
    end

    return nearestPostal or "Unknown"
end

-- Load postal data when the resource starts
Citizen.CreateThread(function()
    loadPostalData()
end)

-- Create a command for /911
RegisterCommand("911", function(source, args, rawCommand)
    local playerPed = GetPlayerPed(-1) -- Get the player ped
    local coords = GetEntityCoords(playerPed) -- Get player coordinates

    -- Get nearest postal code
    local postalCode = getNearestPostal(coords)

    -- Concatenate all arguments into a single string for the details
    local details = table.concat(args, " ")
    
    -- Combine code and postal code
    local code = '911 | Postal: ' .. postalCode -- Code and postal code combined
    local info = {
        {
            label = 'Dispatch Alert', -- Static label for the alert
            icon = 'gender-bigender', -- Icon for the alert
        },
    }
    local offense = details -- Use the concatenated details as the offense
    local blip = 310 -- Blip ID for the alert

    -- Export the alert to bub-mdt
    exports['bub-mdt']:CustomAlert({
        coords = coords, -- Player coordinates
        info = info, -- Info table for the alert
        code = code, -- Alert code with postal
        offense = offense, -- Details of the call
        blip = blip, -- Blip ID
    })

    -- Notify the player that the alert has been sent
    TriggerEvent('chat:addMessage', {
        args = { 'Alert sent: ' .. details .. ' | Postal: ' .. postalCode } -- Feedback message
    })
end, false)

-- Create a command for /911
--RegisterCommand("911", function(source, args, rawCommand)
--    local coords = GetEntityCoords(GetPlayerPed(-1)) -- Get player coordinates
--
--    -- Concatenate all arguments into a single string for the details
--    local details = table.concat(args, " ")
--    
--    local info = {
--        {
--            label = 'Dispatch Alert',
--            icon = 'gender-bigender',
--        },
--    }
--    local code = '911' -- Code for the alert
--    local offense = details -- Use the concatenated details as the offense
--    local blip = 58 -- Blip ID
--
--    -- Export the alert to bub-mdt
--    exports['bub-mdt']:CustomAlert({
--        coords = coords,
--        info = info,
--        code = code,
--        offense = offense,
--        blip = blip,
--    })
--
--    -- Notify the player that the alert has been sent
--    TriggerEvent('chat:addMessage', {
--        args = { 'Alert sent: ' .. details }
--    })
--end, false)