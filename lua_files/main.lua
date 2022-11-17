local SQL = require("db_funcs")

--TODO: La DB de Users y todo eso.
local LoginData = {}
--Nombre de las tablas de la BD.
local ChoiceTable  = {
    ["1"] = {
        TableName = "Admin",
        Menu = "pholder"
    },

    ["2"] = {
        TableName = "Psychologists",
        Menu = "pholder"
    },

    ["3"] = {
        TableName = "Patients",
        Menu = "pholder"
    }
}

local function InitLogin()
    -- I don't like the idea of nested ifs.
    while not LoginData.WasLogged do
        print("Iniciar sesión como paciente, psicologo o admin: ")
        print("1. Admin.")
        print("2. Psicologo.")
        print("3. Paciente.")

        local Choice = string.lower(io.read())
        local Selected = ChoiceTable[Choice]

        if not Selected then
            print("Por favor seleccione una opcion correcta.")
        else
            print("Por favor logeese: ")
            SQL:SetCurrentTable(Selected.TableName)

            local Data = {}
            print("Por favor introduzca su usuario: ")
            local Name = string.lower(io.read())
            Data.Username = Name
            local Password = string.lower(io.read())
            Data.Password = Password
            local Query = SQL:ReadData(Data)

            if Query then
                LoginData.WasLogged = true
                print("¡Logeo exitoso!")
            else
                print("Por favor, intente logearse de nuevo.")
                print("[ERROR] Credenciales incorrectas o no existen.")
            end
        end
    end
end

local function DoActions()
    if not LoginData.WasLogged then return end


end

InitLogin()