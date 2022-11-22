local SQL = require("db_funcs")
local PSY = require("entities.psicologos")
local ADMIN = require("entities.admin")

local IsLogged = false
--Nombre de las tablas de la BD.

-- TODO: Needs to be refactorized.
local function SelectLoginType(Type, Data)
    if Type == 1 then
        return ADMIN:Login(Data)
    elseif Type == 2 then
        return PSY:Login(Data)
    end

    return false
end

local function InitLogin()
    -- I don't like the idea of nested ifs.
    SQL:SetCurrentTable("THERAPISTS")

    while not IsLogged do
        print("/**** SISTEMA DE MANEJO DE ENCUESTAS/PACIENTES ****/")
        print("1. Iniciar sesión.")
        print("2. Registrarse en el sistema.")
        print("3. Salir.")

        local Choice = tonumber(io.read()) or -1

        if Choice < 0 or Choice > 3 then
            print("Por favor seleccione una opción del menu.")
        elseif Choice == 1 then
            local Data = {}
            print("Por favor introduzca su correo electronico: ")
            local Mail = string.lower(io.read())
            Data[1] = Mail
            print("Por favor introduzca la contraseña:")
            local Password = io.read()
            Data[2] = Password
            print("Seleccione una opcion.")
            print("1. Iniciar sesion como admin.")
            print("2. Iniciar sesion como psicologo.")
            local SelectLogin = tonumber(io.read()) or nil

            if SelectLogin then
                IsLogged = SelectLoginType(SelectLogin, Data)
            end
        elseif Choice == 2 then
            PSY:CreateAccount()
            print("¡Pruebe logearse en el sistema!")
        else
            print("Saliendo...")
            break
        end
    end
end

InitLogin()