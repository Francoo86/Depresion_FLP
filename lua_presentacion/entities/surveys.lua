local SQL = require("../lib/db_funcs")
local util = require("../lib/util")

local SURV = {}

SURV.Data = {
    ID = -1,
    Name = "",
    Desc = "",
    TherapistID = -1,
}

--- Setear terapeuta.
--- @param NewID number El ID del terapeuta a asociar.
function SURV:SetTherapistID(NewID)
    if self.Data.TherapistID == NewID then
        return
    end

    self.Data.TherapistID = tonumber(NewID) or -1
end

--- Guardar datos de la encuesta obtenida en la memoria.
--- @param Data table La Tabla que tiene los siguientes atributos (por orden): ID, Nombre, Descripcion de la encuesta, y el ID del Terapeuta.
function SURV:SetData(Data)
    self.Data.ID = tonumber(Data[1]) or -1
    self.Data.Name = Data[2]
    self.Data.Desc = Data[3]
    self.Data.TherapistID = Data[4] or self.Data.TherapistID
end

--- Setea el ID de una encuesta para utilizarla.
--- @param NewID number El ID de la encuesta especificada.
function SURV:SetID(NewID)
    if self.Data.ID  == NewID then return end

    self.Data.ID = tonumber(NewID) or - 1
end

--- @return number SurvID El ID de la encuesta que se está utilizando.
function SURV:GetID()
    return self.Data.ID
end

--- @return number TherapistID El ID del terapeuta que está usando el sistema de encuestas.
function SURV:GetTherapistID()
    return self.Data.TherapistID
end

--- @return table Data Obtener los datos de una encuesta. (ID, Nombre, Descripción e ID de Terapeuta).
function SURV:GetData()
    return self.Data
end

--- Imprime datos básicos de una encuesta (ID, Nombre y Descripción).
function SURV:PrintBasicData()
    print(string.format("Encuesta encontrada con codigo %s, nombre: %s, desc: %s", self.Data.ID, self.Data.Name, self.Data.Desc))
end

--- Cambia datos basicos de una encuesta.
function SURV:ChangeBasicData(IsName)
    if not self.Data.ID or self.Data.ID < 0 then return end
    local DataChange = IsName and "name_svy" or "desc_svy"

    print(string.format("Por favor introduzca %s de la encuesta.", IsName and "el nombre" or " la descripcion"))
    local Change = io.read()
    print("[WARNING] Esta seguro de realizar ese cambio: [Y/N]. El cambio: ", Change)
    local Check = io.read()

    if string.lower(Check) ~= "y" then
        print("[INFO] Cambios no realizados.")
        return
    end

    local Query = SQL:RunQuery(string.format([[UPDATE SURVEYS SET %s = '%s' WHERE id_svy = %s AND disabled=false]], DataChange, Change, self.Data.ID))

    if Query == 0 then
        print("[ERROR] No se ha realizado ningún cambio, verifique que la encuesta existe.")
        return
    end

    print("[INFO] Cambios realizados exitosamente.")
    self:UpdateConsoleText()
end

function SURV:GetQuestions(ShowAnswers)
    if not self.Data.ID or self.Data.ID < 0 then return end

    local Query = SQL:RunQuery(string.format([[SELECT id_qtn, qtn_text FROM QUESTIONS WHERE disabled=false AND SURVEYS_id_svy = %s]], self.Data.ID))
    local Table = Query:fetch({}, "n")

    if not Table then return end
    print(string.format("COD_Pregunta | \t Texto de la pregunta"))

    while Table do
        local Data = SQL:ConcatData("", Table, "\t\t")
        print(Data)

        if ShowAnswers then
            local QtnID = tonumber(Table[1]) or -1
            print("-------------------------------")
            SURV:GetAnswers(QtnID)
            print("-------------------------------")
        end

        Table = Query:fetch(Table, "n")
    end
end

function SURV:ShowCreatedSurveys(PSY_ID)
    local SurveyCount = SQL:RunQuery(string.format([[SELECT COUNT(*) FROM SURVEYS WHERE THERAPISTS_id_tp = %s AND disabled=false]], PSY_ID))
    local Data = SurveyCount:fetch({}, "n")
    print("Encuestas totales creadas: ", Data[1])

    local Surveys = SQL:RunQuery(string.format([[SELECT id_svy AS 'COD_Encuesta', name_svy as 'Nombre Encuesta', 
    desc_svy AS "Descripcion encuesta" FROM SURVEYS WHERE THERAPISTS_id_tp = %s]], PSY_ID))
    Data = Surveys:fetch({}, "n")

    print(string.format("COD_Encuesta |\t Nombre de la encuesta |\t Descripcion de la encuesta."))

    while Data do
        local Survs = SQL:ConcatData(nil, Data, "\t\t")
        print(Survs)
        Data = Surveys:fetch(Data, "n")
    end
end

function SURV:GetAnswerCount(QtnID)
    if not QtnID then return end

    local Query = SQL:RunQuery(string.format([[SELECT COUNT(*) FROM `QUESTIONS` q 
    INNER JOIN `ANSWERS` a ON q.id_qtn = a.`QUESTIONS_id_qtn` WHERE q.`SURVEYS_id_svy`=%s AND q.id_qtn = %s;]], self.Data.ID, QtnID))
    local Count = Query:fetch({}, "n")

    return tonumber(Count) or -1
end

--- Obtener las respuesta de una determinada pregunta.
--- @param Qtn_ID number El ID de la pregunta.
--- @param IsAnswering? boolean No mostrar los codigos de las respuestas mientras se realiza una encuesta a un paciente.
function SURV:GetAnswers(Qtn_ID, IsAnswering)
    if not self.Data.ID or self.Data.ID < 0 then return end
    if not Qtn_ID or Qtn_ID < 0 then return end

    local Query = SQL:RunQuery(string.format([[SELECT id_ans, text_ans, points_ans FROM ANSWERS WHERE QUESTIONS_id_qtn= %s]], Qtn_ID))
    local Answers = Query:fetch({}, "n")

    if not Answers then
        print("No existen respuestas asociadas a esa pregunta.")
        return
    end

    print(IsAnswering and "Respuestas disponibles para la pregunta: " or string.format("Mostrando respuestas para esa pregunta. COD_Pregunta: %s", Qtn_ID))
    print((IsAnswering and "" or "Codigo respuesta") .. " | Texto respuesta | Puntos Respuesta")

    local i = 0
    while Answers do
        -- There are no continues.
        local Concat = (IsAnswering and "" or Answers[1]) .. "\t\t" .. Answers[2] .. "\t\t" .. Answers[3] .. "\t\t"
        print(Concat)

        Answers = Query:fetch(Answers, "n")
        i = i + 1
    end
end

function SURV:GetQuestionCount(ID)
    ID = ID or self.Data.ID
    if not self.Data.ID or self.Data.ID < 0 then return end
    print(self:GetTherapistID())
    -- Mostrar cantidad de preguntas de esa encuesta donde solamente pueda ver las del mismo terapeuta.
    local Query = SQL:RunQuery(string.format([[SELECT COUNT(*) FROM QUESTIONS q INNER JOIN SURVEYS s ON 
    s.id_svy = q.SURVEYS_id_svy and s.THERAPISTS_id_tp =%s AND q.SURVEYS_id_svy=%s and q.disabled=false]], self:GetTherapistID(), ID))
    local Num = Query:fetch({}, "n")[1]

    return tonumber(Num) or -1
end

local AnswersUpdate = {
    ["puntos"] = {
        Query = "points_ans",
        Check = true
    },

    ["texto"] = {
        Query = "text_ans"
    }
}

-- Modificar preguntas.
--- @param ModifyAnswers? boolean Modificar respuestas solamente.
function SURV:ModifyQuestions(ModifyAnswers)
    if not self.Data.ID or self.Data.ID < 0 then return end

    local Text = "Introduzca el codigo de la pregunta " .. (ModifyAnswers and "para modificar sus respuestas." or  "a modificar.")
    print(Text)
    local Modify = tonumber(io.read()) or nil

    if not Modify then
        print("Lo introducido no es un ID numerico.")
        return
    end

    local Query = nil

    if ModifyAnswers then
        Query = SQL:RunQuery(string.format([[SELECT a.id_ans AS 'COD_Respuesta', a.text_ans AS 'Texto de Respuesta', a.points_ans AS 'Puntos Respuesta' FROM ANSWERS a INNER JOIN `QUESTIONS` q ON a.`QUESTIONS_id_qtn` = q.id_qtn AND q.id_qtn=%s AND q.`SURVEYS_id_svy`=%s;]], Modify, self:GetID()))
        local Fetch = Query:fetch({}, "a")

        if not Fetch then
            print("No se ha encontrado esa pregunta en el sistema.")
        end

        print("RESPUESTAS DE LA PREGUNTA DE CODIGO: ", Modify)

        while Fetch do
            print("\n/************************************************/")
            util:PrintSQLData(Fetch, "\t")
            Fetch = Query:fetch(Fetch, "a")
            print("/*************************************************/\n")
        end

        print("introduzca el ID de una de las respuestas.")
        local AnsID = tonumber(io.read()) or nil

        if not AnsID then print("La respuesta ingresada no es un ID.") return end

        print("Seleccione que atributo modificar de la respuesta. (puntos, texto).")
        print("De la misma manera en que está escrito.")

        local AnsModify = string.lower(io.read())
        local Selection = AnswersUpdate[AnsModify]

        if not Selection then
            print("La opcion seleccionada no existe.")
            return
        end

        local Change = nil

        if Selection.Check then
            print("Modificar el puntaje, introduzca el nuevo puntaje.")
            Change = tonumber(io.read()) or -1
            print("¿Esta seguro de que ese sea el nuevo puntaje para esa respuesta? [Y/N]. Puntaje: ", Change)

            if Change < 0 or Change > 10 then
                print("Por favor introduzca numeros entre 0 a 10.")
                return
            end

        else
            print("Modificar el texto de la respuesta. Introduzca el nuevo texto.")
            Change = io.read()
            print("¿Esta seguro de que esa sea la nueva respuesta para esa respuesta? [Y/N]. Puntaje: ", Change)
        end

        Query = SQL:RunQuery(string.format([[UPDATE ANSWERS a SET a.%s='%s' WHERE a.QUESTIONS_id_qtn = %s AND a.id_ans = %s]], Selection.Query, Change, Modify, AnsID))

        print(Query == 1 and "Actualizacion realizada con exito." or  "La respuesta no existe.")
    else
        print("Introduzca el nuevo texto de la pregunta.")
        local QtnText = io.read()
        Query = SQL:RunQuery(string.format([[UPDATE QUESTIONS SET qtn_text='%s' WHERE id_qtn=%s AND SURVEYS_id_svy=%s]], QtnText, Modify, self:GetID()))

        if Query == 0 then
            print("Esa pregunta no existe en la base de datos.")
            return
        end

        print("Pregunta actualizada.")
    end
end

function SURV:UpdateConsoleText()
    local Query = SQL:RunQuery(string.format([[SELECT id_svy, name_svy, desc_svy FROM SURVEYS WHERE THERAPISTS_id_tp = %s AND id_svy = %s]], self:GetTherapistID(), self.Data.ID))
    local Fetch = Query:fetch({}, "n")

    self:SetData(Fetch)
end

return SURV