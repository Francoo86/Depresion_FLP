local SQL = require("../db_funcs")
local util = require("../util")

local ADMIN = {}
ADMIN.LoginData = {}

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
        print("2. Borrar usuarios.")
        print("3. Insertar usuarios.") 
        print("4. Resolver problemas de sesion de usuarios.")
        print("5. Exportar a txt todos los usuarios y sus datos.")
        print("6. Deslogearse.")

        Choice = tonumber(io.read()) or 0

        if Choice < 1 or Choice > 6 then
            print("Por favor introduzca una opción válida.")
        elseif Choice == 1 then
            print("Mostrando todos los usuarios.")
            self:ShowUsers()
        elseif Choice == 2 then
            print("Introduzca el rut del usuario que desea borrar (sin digito verificador): ")
            RUN = io.read()
            self.DeleteUser({{disable = "1"}}, RUN) --disabled = "1"?--
        elseif Choice == 3 then
        elseif Choice == 4 then    
        elseif Choice == 6 then --end?--
            self:Logout()
            break
        end
    end
end

function ADMIN:Login(LoginData)
    if not SQL.CurrentTable or SQL.CurrentTable ~= "THERAPISTS" then return end

    local Query = SQL:RunQuery(string.format([[SELECT * FROM %s WHERE speciality_tp = 'admin' and email_tp = '%s' and pass_tp = '%s']], SQL.CurrentTable, LoginData[1], LoginData[2]))
    local Data = Query:fetch({}, "a")

    if Data then
        self.LoginData.User_ID = Data[SQL.PrimaryKeys[SQL.CurrentTable]]
        self.LoginData.Name = Data["firstname_tp"]
        self.LoginData.LastName = Data["lastname_tp"]
        print("ADMIN: Logeo exitoso.")

        SQL.CurrentTable = "THERAPISTS"
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
    local Degree = io.read()
    print("Introducir email: ")
    local Email = io.read()
    if not util:IsValidEmail(Email) then
        print("El email introducido no es válido.")
        return false
    end
    print("Introducir password: ")
    local Pass = io.read()

    SQL:RunQuery(string.format([[INSERT INTO %s (run_tp, dv_tp, firstname_tp, lastname_tp, speciality_tp, degrees_tp, email_tp, pass_tp) VALUES(%s, %s, '%s', '%s', '%s', '%s', '%s', '%s')]],
    SQL.CurrentTable, RUT, VD, FirstName, LastNames, Speciality, Degree, Email, Pass))

    return true
end

SQL:SetCurrentTable("THERAPISTS")
-- ADMIN:RegisterUsers(true)

function ADMIN:DeleteUsers(Bool, RUN)
    
    if SQL.CurrentTable ~= "THERAPISTS" then return end
    
    PrintData(SQL.CurrentTable)
    
    --Revisar si existe ese el run.
     local Check = SQL:RunQuery(string.format([[SELECT COUNT(1) FROM %s WHERE run_tp=%s]], SQL.CurrentTable, RUN))
     Check = Check:fetch({}, "a")
    
      if Check["COUNT(1)"] == "0" then
        print("Este RUN no existe en la base de datos.")
        return
    end
    
    print("Run encontrado, borrando...")

    for _, Values in pairs(Data) do ----Disabled = true----
        SQL:RunQuery(string.format([[UPDATE %s SET disabled='%s', WHERE id_tp=%s]], SQL.CurrentTable, Values.disabled, RUN))
    end
    
     print("Updated table: \n")

    PrintData(SQL.CurrentTable)
    
end

function ADMIN:UpdateUsers(Data, RUN) --actualizar usuarios--
    
    if SQL.CurrentTable ~= "THERAPISTS" then return end
        
    PrintData(SQL.CurrentTable) ----imprimir para verificar----

    --Revisar si existe ese el run.
    local Check = SQL:RunQuery(string.format([[SELECT COUNT(1) FROM %s WHERE run_tp=%s]], SQL.CurrentTable, RUN))
    Check = Check:fetch({}, "a")

    --No existe entonces terminamos de ejecutar esta función.
    if Check["COUNT(1)"] == "0" then
        print("Este run no existe en la base de datos.")
        return
    end

    print("Run encontrado, modificando...") ---solo modificar nombres, email, especialidad y degreee---
                                            ---quiza agregar mas atributos modificables---
    for _, Values in pairs(Data) do
        SQL:RunQuery(string.format([[UPDATE %s SET firstname_tp='%s', lastname_tp='%s', email_tp='%s', speciality_tp = '%s', degrees_tp = '$s' WHERE run_tp=%s]], 
                SQL.CurrentTable, Values.firstname_tp,Values.lastname_tp, Values.email_tp, Values.speciality_tp ,Values.degrees_tp, RUN))
    end

    print("Updated table: \n")

    PrintData(SQL.CurrentTable) ----imprimir para verificar----
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
    local ActualDate = os.date("%x %X")

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

ADMIN:ExportToTXT()

return ADMIN
