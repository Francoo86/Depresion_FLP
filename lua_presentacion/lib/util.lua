local util = {}

function util:ClearRUT(RUT)
    return RUT:gsub()
end

function util:GetNumLength(Num)
    if not Num or not tonumber(Num) then return nil end

    return tostring(Num):len()
end

function util:ValidateRUT(RUT, DV)
    if not tonumber(RUT) then return false end

    return true
end

-- Sin digito verificador.
function util:CheckRUT(RUT)
    if not tonumber(RUT) then return false end
    return true
end

-- Clampear numeros, retorna el valor que no sobrepase al max, ni tampoco sea menor que min.
function util:Clamp(x, Min, Max)
    if x > Max then return Max end
    if x < Min then return Min end

    return x
end

-- Realizar lo mismo pero para el Test de Beck.
function util:BeckClamp(x)
    return self:Clamp(x, 0, 3)
end

-- Obtener fecha + hora actual para los informes.
-- La x pequeña devuelve la fecha actual mientras que la mayuscula devuelve la hora.
function util:GetActualTime()
    return os.date("%x %X")
end

-- Obtener digito verificador para la base de datos.
-- Source en C: https://github.com/fariascl/digito-verificador-c/blob/master/dv.c
function util:GetVerifierDigit(RUT)
    local Len = util:GetNumLength(RUT)

    if not Len or (Len > 8 and Len < 8) then
        print("El RUT ingresado no es valido.")
        return nil
    end

    local Res, Resta, Mod, Mod_F
    local Temp = {}
    local Cont = 2
    local Sum = 0

    for i = 1, Len do
        Temp[i] = RUT % 10 * Cont
        Cont = Cont + 1
        if (Cont == 8) then
            Cont = 2
        end
        RUT = math.floor(RUT / 10)
    end

    for i = 1, Len do
        Sum = Sum + Temp[i]
    end

    Mod = math.floor(Sum / 11)
    Mod_F = Mod * 11
    Resta = Sum - Mod_F
    Res = 11 - Resta
    return (Res == 10) and "K" or Res
end

function util:IsValidRUT(RUT)
    local Temp  = RUT:gsub("%.", "")
    local Sep = Temp:gsub("%-", "")

    -- Tomar digito verificador.
    local VD = string.sub(Sep, -1)
    -- Tomar RUT.
    local FinalRUT = string.sub(Sep, 1, -2)

    if not self:CheckRUT(FinalRUT) or FinalRUT:len() > 8 or FinalRUT:len() < 1 then
        print("El RUT solicitado no es valido.")
        return false
    end

    if VD ~= tostring(self:GetVerifierDigit(FinalRUT)) then
        print("El digito verificador no coincide.")
        return false
    end

    return true
end

-- Validar fechas.
-- Source: https://stackoverflow.com/questions/12542853/how-to-validate-if-a-string-is-a-valid-date-or-not-in-lua
-- Respuesta del usuario: gabriel_agm.
function util:IsValidDate(Date)
    local m, d, Y = Date:match("(%d+)/(%d+)/(%d+)")
    if not (m or d or Y) then return false end
    local epoch = os.time{year = Y, month = m, day = d}
    local zeromdy = string.format("%02d/%02d/%04d", m, d, Y)
    return zeromdy == os.date("%m/%d/%Y", epoch)
end

-- Validar correos electronicos.
-- Source: https://ohdoylerules.com/snippets/validate-email-with-lua/
function util:IsValidEmail(str)
    if str == nil or str:len() == 0 then return nil end

    if (type(str) ~= "string") then
      error("Expected string")
      return nil
    end

    local lastAt = str:find("[^%@]+$")
    local localPart = str:sub(1, lastAt - 2) -- Returns the substring before "@" symbol
    local domainPart = str:sub(lastAt, #str) -- Returns the substring after "@" symbol
    -- we werent able to split the email properly
    if localPart == nil then
        return nil, "Local name is invalid"
    end

    if domainPart == nil or not domainPart:find("%.") then
        return nil, "Domain is invalid"
    end

    if string.sub(domainPart, 1, 1) == "." then
        return nil, "First character in domain cannot be a dot"
    end

    -- local part is maxed at 64 characters
    if #localPart > 64 then
        return nil, "Local name must be less than 64 characters"
    end

    -- domains are maxed at 253 characters
    if #domainPart > 253 then
        return nil, "Domain must be less than 253 characters"
    end

    -- somthing is wrong
    if lastAt >= 65 then
        return nil, "Invalid @ symbol usage"
    end

    -- quotes are only allowed at the beginning of a the local name
    local quotes = localPart:find("[\"]")
    if type(quotes) == "number" and quotes > 1 then
        return nil, "Invalid usage of quotes"
    end
    -- no @ symbols allowed outside quotes
    if localPart:find("%@+") and quotes == nil then
        return nil, "Invalid @ symbol usage in local part"
    end
    -- no dot found in domain name
    if not domainPart:find("%.") then
        return nil, "No TLD found in domain"
    end
    -- only 1 period in succession allowed
    if domainPart:find("%.%.") then
        return nil, "Too many periods in domain"
    end
    if localPart:find("%.%.") then
        return nil, "Too many periods in local part"
    end
    -- just a general match
    if not str:match("[%w]*[%p]*%@+[%w]*[%.]?[%w]*") then
        return nil, "Email pattern test failed"
    end
    -- all our tests passed, so we are ok
    return true
end

function util:PrintSQLData(Data, SpecialChars)
    SpecialChars = SpecialChars or ""
    for Type, Value in pairs(Data) do
        print(Type, SpecialChars, Value)
    end
end

return util