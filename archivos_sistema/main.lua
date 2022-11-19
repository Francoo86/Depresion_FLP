local SQL = require("db_funcs")
local PSY = require("entities.psicologos")
local ADMIN = require("entities.admin")

--TODO: La DB de Users y todo eso.
local LoginData = {}
--Nombre de las tablas de la BD.
local ChoiceTable  = {
    ["1"] = {
        TableName = "THERAPISTS",
        Login = ADMIN.Login,
        LIB = ADMIN,
    },

    ["2"] = {
        TableName = "THERAPISTS",
        Login = PSY.CheckAccount,
    },
}

local function InitLogin()
    -- I don't like the idea of nested ifs.
    while not LoginData.WasLogged do
        print("/**** SISTEMA DE MANEJO DE ENCUESTAS ****/")
        print("Iniciar sesión psicologo o admin: ")
        print("1. Admin.")
        print("2. Psicologo.")

        local Choice = string.lower(io.read())
        local Selected = ChoiceTable[Choice]

        SQL:SetCurrentTable(Selected.TableName)

        if not Selected then
            print("Por favor seleccione una opcion correcta.")
        else
            print("Por favor logeese.")

            local Data = {}
            print("Por favor introduzca su correo electronico: ")
            local Mail = string.lower(io.read())
            Data[1] = Mail
            print("Por favor introduzca la contraseña:")
            local Password = io.read()
            Data[2] = Password
            local CanLogin = Selected.Login(Selected.LIB, Data)

            if CanLogin then
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