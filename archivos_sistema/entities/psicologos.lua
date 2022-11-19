local SQL = require("../db_funcs")
local ADMIN = require("entities.admin")
local PSY = {}

PSY.Data = {
    ID = -1,
    Name = "",
    LastName = ""
}

function PSY:CreateAccount()
    ADMIN:RegisterUsers(true)
end

function PSY:ReadDiagnostics()

end

function PSY:CreateSurvey()
    if PSY.Data.ID == -1 then
        print("Por favor inicie sesion.")
        return
    end

    SQL:SetCurrentTable("SURVEYS")

    print("Introduzca un nombre para la encuesta.")
    local SurveyName = io.read()
    print("Introduzca una breve descripción de la encuesta a realizar para el paciente.")
    local DescSurv = io.read()

    if SurveyName:len() < 3 or DescSurv:len() < 4 then
        print("No se pudo crear la encuesta debido a que el nombre tiene menos de 3 caracteres \no la descripción tiene menos de 4 caracteres.")
        return
    end

    SQL:RunQuery(string.format([[INSERT INTO %s (name_svy, desc_svy) VALUES ('%s', '%s')]], SurveyName, DescSurv))
    print("Encuesta creada con exito.")

    self:CreateQuestions()
end

function PSY:Login()

end

function PSY:Logout()
    self.Data = {}
    print("Deslogeo exitoso.")
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
    SQL:SetCurrentTable("SURVEYS")

    local SurveyCount = SQL:RunQuery(string.format([[SELECT COUNT(*) FROM %s WHERE THERAPISTS_id_tp = %s]], SQL.CurrentTable, PSY.Data.ID))
    local Data = SurveyCount:fetch({}, "n")
    print("Encuestas totales creadas: ", Data[1])

    local Surveys = SQL:RunQuery(string.format([[SELECT id_svy AS 'COD_Encuesta', name_svy as 'Nombre Encuesta', 
    desc_svy AS "Descripcion encuesta" FROM %s WHERE THERAPISTS_id_tp = %s]], SQL.CurrentTable, PSY.Data.ID))
    Data = Surveys:fetch({}, "n")

    print("COD_Encuesta |\t Nombre de la encuesta |\t Descripcion de la encuesta.")

    while Data do
        local Survs = SQL:ConcatData(nil, Data, "\t\t")
        print(Survs)
        Data = Surveys:fetch(Data, "n")
    end
end

function PSY:SearchPatient(Mode)
    SQL:SetCurrentTable("Patients")


end


-- Soy ese.
PSY.Data.ID = 1

PSY:ShowCreatedSurveys()


--[[SQL:SetCurrentTable("SURVEYS")
local query = SQL:RunQuery(string.format(SELECT id_svy AS COD_Encuesta, name_svy as 'Nombre Encuesta', 
desc_svy as 'Descripcion Encuesta' FROM SURVEYS WHERE THERAPISTS_id_tp=%s, 1))
local test = query:fetch({}, "a")
--]]


function PSY:GetPatientDiags(RUN, VD)
    SQL:SetCurrentTable("Patients")


end

return PSY