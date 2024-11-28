-- Function to generate a new SID for users with null SID
function fixUsersWithNullSID()
    -- Query to get users whose sid is null
    MySQL.Async.fetchAll('SELECT * FROM users WHERE sid IS NULL', {}, function(usersWithNullSID)
        -- Loop through the result and fix the SID for each user
        for _, user in ipairs(usersWithNullSID) do
            local identifier = user.identifier

            -- Generate a new unique SID
            local newSID = generateUniqueSID()

            -- Update the user's SID in the database
            MySQL.Async.execute('UPDATE users SET sid = @sid WHERE identifier = @identifier', {
                ['@sid'] = newSID,
                ['@identifier'] = identifier
            }, function(rowsChanged)
                if rowsChanged > 0 then
                    print(("[^2INFO^0] User ^5%s^0 had their SID fixed with new SID: ^5%s^0"):format(identifier, newSID))
                else
                    print(("[^1ERROR^0] Failed to update SID for user: ^5%s^0"):format(identifier))
                end
            end)

            -- Wait for a short period to avoid locking the server
            Citizen.Wait(100)  -- Wait 100 milliseconds between updates
        end
        print("[^2INFO^0] Finished fixing all users with null SIDs.")
    end)
end

-- Function to generate a new unique SID
function generateUniqueSID()
    local function RandomLetters(num)
        local letters = {}
        for char = 65, 90 do -- ASCII values for uppercase letters
            table.insert(letters, string.char(char))
        end
        local result = ""
        for i = 1, num do
            result = result .. letters[math.random(1, #letters)]
        end
        return result
    end

    local num = math.random(1, 10)
    local sid_new = ""

    if num == 1 then
        sid_new = math.random(1, 9) .. RandomLetters(1) .. math.random(111, 999)
    elseif num == 2 then
        sid_new = math.random(111, 999) .. RandomLetters(1) .. math.random(1, 9)
    elseif num == 3 or num == 4 then
        sid_new = math.random(11, 99) .. RandomLetters(2) .. math.random(1, 9)
    elseif num == 5 then
        sid_new = RandomLetters(1) .. math.random(111, 999) .. math.random(1, 9)
    elseif num == 6 then
        sid_new = math.random(111, 999) .. math.random(1, 9) .. RandomLetters(1)
    elseif num == 7 then
        sid_new = math.random(1111, 9999) .. RandomLetters(1)
    elseif num == 8 then
        sid_new = RandomLetters(1) .. math.random(1111, 9999)
    elseif num == 9 then
        sid_new = RandomLetters(1) .. math.random(111, 999) .. RandomLetters(1)
    elseif num == 10 then
        sid_new = math.random(11111, 99999)
    end

    -- Check if SID is already in use
    if isSIDInUse(sid_new) then
        return generateUniqueSID()
    else
        return sid_new
    end
end

-- Function to check if SID is already in use
function isSIDInUse(sid)
    local query = MySQL.Sync.fetchAll('SELECT * FROM users WHERE sid = @sid', {
        ['@sid'] = sid
    })

    return #query > 0
end

-- Event handler for when the resource starts
AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        print("Resource started: Fixing users with null SIDs...")
        fixUsersWithNullSID()
    end
end)
