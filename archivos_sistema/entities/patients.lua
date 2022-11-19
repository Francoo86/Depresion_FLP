local PATIENTS = {}
local SQL = require("db_funcs")

PATIENTS.Options = {
}

function PATIENTS:GetData()
    self.Data = self.Data or {}

    print(self.Data.Username)
    print(self.Data.Email)
end

function PATIENTS:DoSurvey()

end

function PATIENTS:ShowSurveysInfo()

end

function PATIENTS:Register()

end

function PATIENTS:Menu()
    local Choice = 0

    -- Deberia mostrar nombres.
    local Credentials = {}

    while Choice ~= 3 do
        Choice = tonumber(io.read()) or 0

        print("Por favor seleccione una de las siguientes opciones:")
        print("1. Realizar encuesta.")
        print("2. Mostrar encuestas realizadas y sus resultados.")
        print("3. Salir.")
    end
end