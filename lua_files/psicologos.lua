local SQL = require("db_funcs")
local PSY = {}

function PSY:ReadDiagnostics()

end

function PSY:CreateSurvey()

end

function PSY:CreateQuestions()
    print("Por favor ingrese la cantidad de preguntas para la encuesta.")
    print("Minimo 5, Máximo 30.")
    local Input = tonumber(io.read())

    if not Input or Input <= 4 or Input >= 30 then
        print(Input and "Por favor introduzca más de 6 preguntas o menos de 30." or "El dato ingresado no es un numero.")
        return
    end

end

function PSY:ShowCreatedSurveys()
    SQL:SetCurrentTable("Surveys")
end

function PSY:SearchPatient(Mode)
    SQL:SetCurrentTable("Patients")


end

function PSY:GetPatientDiags(ID)
    SQL:SetCurrentTable("Diagnostics")


end

return PSY