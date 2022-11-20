local SQL = require("../db_funcs")
local ADMIN = require("entities.admin")
local SURV = require("entities.surveys")
-- local PAT = require("entities.patients")
local PSY = {}

PSY.Data = {
    ID = -1,
    Name = "",
    LastName = ""
}

function PSY:Menu()
    print("/******* MENU PSICOLOGOS *******/")
    print("1. Administrar pacientes.")
    print("2. Administrar diagnosticos.")
    print("3. Administrar encuestas.")
    print("4. Deslogearse.")
end

function PSY:CreateAccount()
    ADMIN:RegisterUsers(true)
end

function PSY:ReadDiagnostics()

end

function PSY:SurveyMenu()
    local Choice = 0
    while Choice ~= 4 do
        print("/******* MENU ENCUESTAS DE PSICOLOGOS *******/")
        print("1. Crear Encuesta.")
        print("2. Modificar Encuestas")
        print("3. Mostrar encuestas creadas.")
        print("4. Salir de este menu.")

        Choice = tonumber(io.read()) or 0

        if Choice > 4 or Choice < 0 then
            print("Por favor, seleccione una opción del menu.")
        elseif Choice == 1 then
            PSY:CreateSurvey()
        elseif Choice == 2 then
            PSY:ModifySurvey()
        elseif Choice == 3 then
            PSY:ShowCreatedSurveys()
        elseif Choice == 4 then
            print("Volviendo hacia atrás.")
        end
    end
end

function PSY:ModifySurvey()
    SQL:SetCurrentTable("SURVEYS")

    print("Por favor, introduzca el codigo de la encuesta a modificar.")
    local SurvID = tonumber(io.read()) or nil

    if not SurvID then
        print("El dato introducido no es un numero.")
        return
    end

    local Query = SQL:RunQuery(string.format([[SELECT id_svy, name_svy, desc_svy FROM %s WHERE THERAPISTS_id_tp = %s AND id_svy = %s]], SQL.CurrentTable, self.Data.ID, SurvID))
    local Fetch = Query:fetch({}, "n")

    if not Fetch then
        print("Encuesta no encontrada en el sistema.")
        print("TIP: En el menu de opciones seleccione 'mostrar encuestas creadas', y seleccione el codigo de la misma para modificarla.")
        return
    end

    -- Guardar el dato del psicologo.
    Fetch[4] = self.Data.ID

    SURV:SetData(Fetch)
    local SurvData = SURV:GetData()
    SURV:PrintBasicData()

    local Choice = 0

    while Choice ~= 5 do
        print("Nombre encuesta: ", SurvData.Name)
        print("Descripcion de la encuestra: ", SurvData.Desc)

        print("Introduzca una opcion: ")
        print("1. Modificar nombre de la encuesta.")
        print("2. Modificar descripcion de la encuesta.")
        print("3. Modificar preguntas de la encuesta.")
        print("4. Modificar respuestas de las preguntas de la encuesta.")
        print("5. Salir de este menu.")

        Choice = tonumber(io.read()) or 0

        if Choice < 0 or Choice > 5 then
            print("Por favor escoja una de las opciones del menú.")
        elseif Choice == 1 then
            SURV:ChangeBasicData(true)
        elseif Choice == 2 then
            SURV:ChangeBasicData(false)
        elseif Choice == 3 then
            SURV:GetQuestions()
        elseif Choice == 4 then
            SURV:ModifyAnswers()
        elseif Choice == 5 then
            print("Volviendo hacia atrás.")
        end
    end
end

function PSY:CreateSurvey()
    if self.Data.ID == -1 then
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

    SQL:RunQuery(string.format([[INSERT INTO %s (name_svy, desc_svy, THERAPISTS_id_tp) VALUES ('%s', '%s', %s)]], SQL.CurrentTable, SurveyName, DescSurv, self.Data.ID))
    print("Encuesta creada con exito.")

    -- Deberia ser la ultima encuesta creada.
    local LastID = SQL:GetLastInsertedID()

    self:CreateQuestions(LastID)
end

function PSY:ModifyQuestions()

end

function PSY:Login(Data)
    if self.Data.ID ~= -1 then return end

    local Query = SQL:RunQuery(string.format([[SELECT id_tp, firstname_tp, secondname_tp FROM %s WHERE NOT speciality_tp = 'admin' AND NOT disabled=true and email_tp = '%s', and pass_tp = '%s']],
    SQL.CurrentTable, Data[1], Data[2]))
    local Fetch = Query:fetch({}, "n")

    if not Fetch then
        print("Datos incorrectos o no existen en el sistema.")
        return false
    end

    PSY.Data.ID = Fetch[1]
    PSY.Data.Name = Fetch[2]
    PSY.Data.LastName = Fetch[3]

    print("Bienvenid@ ", PSY.Data.Name, PSY.Data.LastName)
    return true
end

function PSY:Logout()
    self.Data = {}
    print("Deslogeo exitoso.")
end

function PSY:CreateQuestions(Surv_ID)
    if not Surv_ID then return end

    print("Por favor ingrese la cantidad de preguntas para la encuesta.")
    print("Minimo 5, Máximo 15.")
    local Input = tonumber(io.read())

    if not Input or Input < 5 or Input >= 15 then
        print(Input and "Por favor introduzca más de 6 preguntas o menos de 15." or "El dato ingresado no es un numero.")
        print("Ajustando a la cantidad default de preguntas: 10.")
        Input = 10
    end

    local Iterator = 0

    while Iterator ~= Input do
        print(string.format("Pregunta %s de %s", Iterator + 1, Input))
        SQL:SetCurrentTable("QUESTIONS")
        print("Introduzca la pregunta: ")
        local QtnText = io.read()
        print(string.format("Confirmar pregunta: %s [Y/N].", QtnText))
        print("Coloque Y para sí, N para no.")
        local Check = io.read()

        -- There are no continues in Lua.
        if string.lower(Check) ~= "y" then
            print("Cancelando pregunta.")
        else
            SQL:RunQuery(string.format([[INSERT INTO %s (qtn_text, SURVEYS_id_svy) VALUES ('%s', %s)]], SQL.CurrentTable, QtnText, Surv_ID))
            local LastQtnID = SQL:GetLastInsertedID()
            self:CreateAnswers(LastQtnID)
            Iterator = Iterator + 1
        end
    end
end

function PSY:CreateAnswers(Qtn_ID)
    if not Qtn_ID then return end

    local i = 0
    local MAX_ANS = 3

    while i ~= MAX_ANS do
        print(string.format("Por favor introduzca la respuesta %s de %s", i + 1, MAX_ANS))
        local Answer = io.read()
        print("Por favor introduzca los puntos para esa respuesta.")
        local Points = tonumber(io.read()) or -1
        print(string.format("Confirmar respuesta: %s Puntos: %s [Y/N].", Answer, Points))
        local Confirm = io.read()
        local PointCheck = (Points < 0 or Points > 10)

        if PointCheck or string.lower(Confirm) ~= "y" then
            print("Cancelando respuesta.")
            print(string.format("Razon: %s", PointCheck and "Los puntos no pueden ser menores a 0 o mayores a 10." or "Cancelacion de usuario."))
        else
            SQL:RunQuery(string.format([[INSERT INTO ANSWERS (text_ans, points_ans, QUESTIONS_id_qtn) VALUES ('%s', %s, %s)]], Answer, Points, Qtn_ID))
            i = i + 1
        end
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

    print(string.format("COD_Encuesta |\t Nombre de la encuesta |\t Descripcion de la encuesta."))

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

-- PSY:SurveyMenu()
-- PSY:ShowCreatedSurveys()
-- PSY:CreateSurvey()
-- PSY:ModifySurvey()

--[[SQL:SetCurrentTable("SURVEYS")
local query = SQL:RunQuery(string.format(SELECT id_svy AS COD_Encuesta, name_svy as 'Nombre Encuesta', 
desc_svy as 'Descripcion Encuesta' FROM SURVEYS WHERE THERAPISTS_id_tp=%s, 1))
local test = query:fetch({}, "a")
--]]


function PSY:GetPatientDiags(RUN, VD)
    SQL:SetCurrentTable("PATIENTS")


end

return PSY