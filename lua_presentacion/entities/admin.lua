local SQL = require("../db_funcs")
local util = require("../util")

-- Libreria para encriptar contraseñas.
-- Source: https://github.com/Egor-Skriptunoff/pure_lua_SHA
local shalib = require("../sha2")

local ADMIN = {}
ADMIN.LoginData = {}

local SHA256 = shalib.sha256

function ADMIN:Menu()
    if not self.LoginData.User_ID then
        print("Por favor, inicie sesión.")
        return
    end

    local Choice = 0
    local CurrData = string.format([[ID: %s, Nombre: %s %s]], self.LoginData.User_ID, self.LoginData.Name, self.LoginData.LastName)

    while Choice ~= 6 do
        print("/*** SISTEMA DE ADMINISTRADOR ***/")
        print(CurrData)
        print("Por favor, seleccione una opción.")
        print("1. Mostrar usuarios.")
        print("2. Mostrar usuarios deshabilitados.")
        print("2. Borrar usuarios.")
        print("3. Insertar usuarios.")
        print("4. Resolver problemas de sesion de usuarios.")
        print("5. Exportar a txt todos los usuarios vigentes y sus datos.")
        print("6. Deslogearse.")

        Choice = tonumber(io.read()) or 0

        if Choice < 1 or Choice > 6 then
            print("Por favor introduzca una opción válida.")
        elseif Choice == 1 then
            print("Mostrando todos los usuarios.")
            self:ShowUsers()
        elseif Choice == 2 then
            self:DeleteUsers()
        elseif Choice == 3 then
            self:RegisterUsers(false)
        elseif Choice == 4 then
            self:UpdateUsers()
        elseif Choice == 5 then
            self:ExportToTXT()
        else
            self:Logout()
        end
    end
end

-- Should i create an inheritance table?
function ADMIN:Login(LoginData)
    if not SQL.CurrentTable or SQL.CurrentTable ~= "THERAPISTS" then return end

    local Query = SQL:RunQuery(string.format([[SELECT * FROM %s WHERE speciality_tp = 'admin' and email_tp = '%s' and pass_tp = '%s']], SQL.CurrentTable, LoginData[1], SHA256(LoginData[2])))
    local Data = Query:fetch({}, "a")

    if Data then
        self.LoginData.User_ID = Data[SQL.PrimaryKeys[SQL.CurrentTable]]
        self.LoginData.Name = Data["firstname_tp"]
        self.LoginData.LastName = Data["lastname_tp"]
        print("ADMIN: Logeo exitoso.")

        self:Menu()
        return true
    end

    return false
end

function ADMIN:Logout()
    self.LoginData = {}
    print("[ADMIN] Deslogeo exitoso!")
end

function ADMIN:RegisterUsers(IsTherapist)
    -- Este es un menu de prueba en realidad.
    if SQL.CurrentTable ~= "THERAPISTS" then return end

    local Phrases = {
        IntroRUT = "Por favor introduzca " .. (IsTherapist and "su" or "el") .. " RUT" .. ":",
        IntroFN = IsTherapist and "Introduzca sus nombres" or "Introduzca los nombres del psicologo" .. ":",
        IntroSN = IsTherapist and "Introduzca sus apellidos" or "Introduzca los apellidos del psicologo" .. ":"
    }

    print(Phrases.IntroRUT)
    -- El admin debería ingresar el RUT sin digito verificador.
    local RUT = io.read()
    local VD = util:GetVerifierDigit(RUT)
    -- No se encontró un RUT propiamente tal.
    if not VD then
        return false
    end
    -- Realizar operaciones para validar RUT.
    print(Phrases.IntroFN)
    local FirstName = io.read()
    print(Phrases.IntroSN)
    local LastNames = io.read()
    print("Introducir la specialidad: ")
    local Speciality = io.read()
    print("Introducir lo que estudio: ")

    if IsTherapist and string.lower(Speciality) == "admin" then
        print("[ERROR] Contacte con administrador para poder obtener ese permiso.")
        return
    end

    local Degree = io.read()
    print("Introducir email: ")
    local Email = io.read()
    if not util:IsValidEmail(Email) then
        print("El email introducido no es válido.")
        return false
    end

    print("Introducir password: ")
    local Pass = io.read()
    local Pass256 = SHA256(Pass)

    SQL:RunQuery(string.format([[INSERT INTO %s (run_tp, dv_tp, firstname_tp, lastname_tp, speciality_tp, degrees_tp, email_tp, pass_tp) VALUES(%s, '%s', '%s', '%s', '%s', '%s', '%s', '%s')]],
    SQL.CurrentTable, RUT, VD, FirstName, LastNames, Speciality, Degree, Email, Pass256))
    print("Usuario registrado con exito.")

    return true
end

function ADMIN:DeleteUsers()
    print("Por favor introduzca el RUT del terapeuta a borrar.")
    local RUT = io.read()
    local VD = util:GetVerifierDigit(RUT)

    if not VD then return end
    SQL:RunQuery(string.format([[UPDATE FROM %s SET disabled=true WHERE run_tp = %s and disabled=false and not id_tp = %s]], SQL.CurrentTable, RUT, self.LoginData.User_ID))
    print(string.format("Usuario %s borrado con exito. Si se borro por error activelo en una opcion del menu.", RUT))
end

function ADMIN:ReactivateUsers()
    print("Por favor introduzca el RUT del terapeuta a reactivar.")
    local RUT = io.read()
    local VD = util:GetVerifierDigit(RUT)

    if not VD then return end
    local Query = SQL:RunQuery(string.format([[UPDATE FROM %s SET disabled=false WHERE run_tp = %s AND dv_tp = '%s' and disabled=true]], SQL.CurrentTable, RUT, VD))

    if not Query then
        print("El usuario no se pudo actualizar debido a que no existe o está activado.")
        return
    end

    print(string.format("Usuario %s reactivado con exito.", RUT))
end

local PSYUpdateChoices = {
    ["especialidad"] = {
        Query = "speciality_tp",
        Phrase = "Ponga la nueva especialida del psicologo."
    },

    ["estudios"] = {
        Query = "degrees_tp",
        Phrase = "Ponga los nuevos grados academicos del psicologo."
    },

    ["mail"] = {
        Query = "email_tp",
        Phrase = "Ponga el nuevo mail del psicologo."
    },

    ["contraseña"] = {
        Query = "pass_tp",
        Phrase = "Ponga la contraseña TEMPORAL para el psicologo. (SOLAMENTE con fines de recuperar la contraseña).",
    },

    ["nombre"] = {
        Query = "firstname_tp",
        Phrase = "Ponga los nuevos nombres del psicologo."
    },

    ["apellido"] = {
        Query = "lastname_tp",
        Phrase = "Ponga los nuevos apellidos del psicologo."
    },
}

function ADMIN:UpdateUsers()
    print("¿Que datos desea actualizar?")
    print("Introduzca tal cual el nombre de lo que desea actualizar: (nombre, apellido, estudios, mail, especialidad, contraseña).")
    print("Si va a actualizar la contraseña es para una TEMPORAL.")

    local DataUpdate = string.lower(io.read())
    local Final = PSYUpdateChoices[DataUpdate] or nil

    if not Final then
        print("La eleccion no existe dentro de lo solicitado.")
        return
    end

    print(Final.Phrase)
    local Update = io.read()

    print("Introduzca el RUT del psicologo: ")
    local IntroRUT = tonumber(io.read()) or 0
    local VD = util:GetVerifierDigit(IntroRUT)
    if not VD then return end

    SQL:RunQuery(string.format([[UPDATE %s SET %s='%s' WHERE run_tp=%s AND dv_tp = '%s']], SQL.CurrentTable, Final.Query, Update, IntroRUT, VD))
end

function ADMIN:ShowUsers(Writing)
    local Show = SQL:RunQuery(string.format([[SELECT run_tp as 'RUT Psicologo', dv_tp AS 'Digito Verificador' 
    ,firstname_tp AS 'Nombres', lastname_tp AS 'Apellidos', speciality_tp as "Especialidad", degrees_tp as "Estudios" FROM %s WHERE disabled=false]], SQL.CurrentTable))
    local ShowTable = Show:fetch({}, "a")

    if Writing then return {Show, ShowTable} end

    while ShowTable do
        print("/***************************************************/")
        for Names, Value in pairs(ShowTable) do
            print(Names, "\t=\t", Value)
        end
        ShowTable = Show:fetch(ShowTable, "a")
    end

    return true
end

function ADMIN:ExportToTXT()
    local Filename = "users.txt"
    local File = io.open(Filename, "w")
    if not File then return end
    local Data = self:ShowUsers(true)
    local Query = Data[1]
    local Rows = Data[2]

    -- Retornar fecha actual + horas.
    local ActualDate = util:GetActualTime()

    File:write("DATOS DE PSICOLOGOS.\n")
    File:write("INFORME GENERADO EL: ", ActualDate, "\n")

    -- I don't like double loops but well.
    while Rows do
        File:write("/***************************************************/\n")
        for Names, Value in pairs(Rows) do
            File:write(Names, "\t=\t", Value, "\n")
        end
        Rows = Query:fetch(Rows, "a")
    end

    File:close()
end

function ADMIN:PassToSHA256(Pass)
    return SHA256(Pass)
end

return ADMIN