local SQL = require("../db_funcs")
local ADMIN = require("entities.admin")
local SURV = require("entities.surveys")
local PAT = require("entities.patients")

local PSY = {}

PSY.Data = {
    ID = -1,
    Name = "",
    LastName = ""
}

function PSY:GetID()
    return self.Data.ID
end

-- Crear cuenta para el psicologo si no tiene una.
function PSY:CreateAccount()
    ADMIN:RegisterUsers(true)
end

-- Menu de encuestas.
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
            -- Buscar encuestas creadas por el psicologo.
            SURV:ShowCreatedSurveys(self:GetID())
        elseif Choice == 4 then
            print("Volviendo hacia atrás.")
        end
    end
end

function PSY:ModifySurvey()
    print("Por favor, introduzca el codigo de la encuesta a modificar.")
    local SurvID = tonumber(io.read()) or nil

    if not SurvID then
        print("El dato introducido no es un numero.")
        return
    end

    local Query = SQL:RunQuery(string.format([[SELECT id_svy, name_svy, desc_svy FROM SURVEYS WHERE THERAPISTS_id_tp = %s AND id_svy = %s]], self.Data.ID, SurvID))
    local Fetch = Query:fetch({}, "n")

    if not Fetch then
        print("Encuesta no encontrada en el sistema.")
        print("TIP: En el menu de opciones seleccione 'mostrar encuestas creadas', y seleccione el codigo de la misma para modificarla.")
        return
    end

    -- Guardar el dato del psicologo.
    SURV:SetData(Fetch)
    local SurvData = SURV:GetData()
    SURV:PrintBasicData()

    local Choice = 0

    while Choice ~= 7 do
        print("Nombre encuesta: ", SurvData.Name)
        print("Descripcion de la encuestra: ", SurvData.Desc)
        print("Cantidad de preguntas de la encuesta: ", SURV:GetQuestionCount())

        print("Introduzca una opcion: ")
        print("1. Modificar nombre de la encuesta.")
        print("2. Modificar descripcion de la encuesta.")
        print("3. Modificar preguntas de la encuesta.")
        print("4. Modificar respuestas de las preguntas de la encuesta.")
        print("5. Agregar preguntas.")
        print("6. Mostrar la encuesta con sus preguntas y respuestas.")
        print("7. Salir de este menu.")

        Choice = tonumber(io.read()) or 0

        if Choice < 0 or Choice > 7 then
            print("Por favor escoja una de las opciones del menú.")
        elseif Choice == 1 then
            SURV:ChangeBasicData(true)
        elseif Choice == 2 then
            SURV:ChangeBasicData(false)
        elseif Choice == 3 then
            SURV:GetQuestions()
            SURV:ModifyQuestions()
        elseif Choice == 4 then
            SURV:GetQuestions(true)
            SURV:ModifyQuestions(true)
        elseif Choice == 5 then
            PSY:CreateQuestions(SURV:GetID(), true)
        elseif Choice == 6 then
            SURV:GetQuestions(true)
        elseif Choice == 7 then
            print("Volviendo hacia atrás.")
        end
    end
end

function PSY:CreateSurvey()
    if self.Data.ID == -1 then
        print("Por favor inicie sesion.")
        return
    end

    print("Introduzca un nombre para la encuesta.")
    local SurveyName = io.read()
    print("Introduzca una breve descripción de la encuesta a realizar para el paciente.")
    local DescSurv = io.read()

    if SurveyName:len() < 3 or DescSurv:len() < 4 then
        print("No se pudo crear la encuesta debido a que el nombre tiene menos de 3 caracteres \no la descripción tiene menos de 4 caracteres.")
        return
    end

    SQL:RunQuery(string.format([[INSERT INTO SURVEYS (name_svy, desc_svy, THERAPISTS_id_tp) VALUES ('%s', '%s', %s)]], SurveyName, DescSurv, self.Data.ID))
    print("Encuesta creada con exito.")

    -- Deberia ser la ultima encuesta creada.
    local LastID = SQL:GetLastInsertedID()
    self:CreateQuestions(LastID)
end

function PSY:Login(Data)
    if self.Data.ID ~= -1 then return end

    local Query = SQL:RunQuery(string.format([[SELECT id_tp, firstname_tp, lastname_tp FROM %s WHERE NOT disabled=true and email_tp = '%s' and pass_tp = '%s']],
    SQL.CurrentTable, Data[1], ADMIN:PassToSHA256(Data[2])))
    local Fetch = Query:fetch({}, "n")

    if not Fetch then
        print("Datos incorrectos o no existen en el sistema.")
        return false
    end

    self.Data.ID = Fetch[1]
    self.Data.Name = Fetch[2]
    self.Data.LastName = Fetch[3]

    print("Bienvenid@ ", self.Data.Name, self.Data.LastName)
    self:Menu()
    return true
end

function PSY:Logout()
    self.Data = {}
    print("Deslogeo exitoso.")
end

function PSY:CreateQuestions(Surv_ID, Adding)
    if not Surv_ID then return end

    -- Me da errores así que haremos la manera clásica.
    print("Por favor ingrese la cantidad de preguntas para la encuesta.")
    local Input = nil

    -- Puede refactorizarse pero consume mucho tiempo.
    if Adding then
        -- Cuando se añaden preguntas a una encuesta existente.
        local Count = SURV:GetQuestionCount()

        if Count and Count == 30 then
            print("[ERROR] La encuesta seleccionada tiene la cantidad máxima de preguntas.")
            return
        end

        local MaxCount = 30 - Count
        print(string.format("Max de preguntas insertables: %s.", MaxCount))

        Input = tonumber(io.read()) or nil

        if not Input or Input >= MaxCount then
            print("Por favor ingrese una cantidad de preguntas considerables.")
            return
        end
    else
        -- Esta condicion se ejecuta cuando se añaden preguntas a una nueva encuesta.
        print("Min 5. Max 30.")
        Input = tonumber(io.read()) or nil

        if not Input or (Input < 5 or Input >= 30) then
            print(Input and "Por favor introduzca más de 6 preguntas o menos de 15." or "El dato ingresado no es un numero.")
            print("Ajustando a la cantidad default de preguntas: 10.")
            Input = 10
        end
    end

    local Iterator = 0

    while Iterator ~= Input do
        if Adding and SURV:GetQuestionCount() >= 30 then
            print("Finalizada el ingreso de preguntas.")
            break
        end

        print(string.format("Pregunta %s de %s", Iterator + 1, Input))
        print("Introduzca la pregunta: ")
        local QtnText = io.read()
        print(string.format("Confirmar pregunta: %s [Y/N].", QtnText))
        print("Coloque Y para sí, N para no.")
        local Check = io.read()

        -- There are no continues in Lua.
        if string.lower(Check) ~= "y" then
            print("Cancelando pregunta.")
        else
            SQL:RunQuery(string.format([[INSERT INTO QUESTIONS (qtn_text, SURVEYS_id_svy) VALUES ('%s', %s)]], QtnText, Surv_ID))
            local LastQtnID = SQL:GetLastInsertedID()
            self:CreateAnswers(LastQtnID)
            Iterator = Iterator + 1
        end
    end
end

function PSY:CreateAnswers(Qtn_ID)
    if not Qtn_ID then return end

    local i = 0
    local MAX_ANS = 4

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

function PSY:Menu()
    if self.Data.ID == -1 then return end
    local Choice = 0

    while Choice ~= 3 do
        print("/******* MENU PSICOLOGOS *******/")
        print("1. Administrar pacientes.")
        print("2. Administrar encuestas.")
        print("3. Deslogearse.")

        Choice = tonumber(io.read()) or 0

        if Choice > 3 or Choice < 0 then
            print("Por favor seleccione una opción del menu.")
        elseif Choice == 1 then
            PAT:SetTherapist(self.Data.ID)
            PAT:Menu()
        elseif Choice == 2 then
            SURV:SetTherapistID(self.Data.ID)
            self:SurveyMenu()
        else
            self:Logout()
        end
    end
end

return PSY