local SQL = require("../db_funcs")
local SURV = {}

SURV.Data = {
    ID = -1,
    Name = "",
    Desc = "",
}

function SURV:SetData(Data)
    self.Data.ID = tonumber(Data[1]) or -1
    self.Data.Name = Data[2]
    self.Data.Desc = Data[3]
    self.Data.TherapistID = Data[4]
end

function SURV:GetData()
    return self.Data
end

function SURV:PrintBasicData()
    print(string.format("Encuesta encontrada con codigo %s, nombre: %s, desc: %s", self.Data.ID, self.Data.Name, self.Data.Desc))
end

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

    print("Cambios realizados.")
    SQL:RunQuery(string.format([[UPDATE %s SET %s = '%s' WHERE id_svy = %s]], SQL.CurrentTable, DataChange, Change, self.Data.ID))
    self:UpdateConsoleText()
end

function SURV:ModifyAnswers()
    if not self.Data.ID or self.Data.ID < 0 then return end
end

function SURV:GetQuestions(ShowAnswers)
    if not self.Data.ID or self.Data.ID < 0 then return end
    SQL:SetCurrentTable("QUESTIONS")
    local Query = SQL:RunQuery(string.format([[SELECT id_qtn, qtn_text FROM %s WHERE disabled=false AND SURVEYS_id_svy = %s]], SQL.CurrentTable, self.Data.ID))
    local Table = Query:fetch({}, "n")

    if not Table then return end
    print(string.format("COD_Pregunta | \t Texto de la pregunta"))

    while Table do
        local Data = SQL:ConcatData("", Table, "\t\t")
        print(Data)
        Table = Query:fetch(Table, "n")
    end
end

-- Se veria mejor con un JOIN (pensando en colocar esa query).
function SURV:GetAnswers(Qtn_ID)
    if not self.Data.ID or self.Data.ID < 0 then return end
    if not Qtn_ID or Qtn_ID < 0 then return end

    SQL:SetCurrentTable("ANSWERS")
    local Query = SQL:RunQuery(string.format([[SELECT id_ans, text_ans, points_ans FROM %s WHERE QUESTIONS_id_qtn= %s]], SQL.CurrentTable, Qtn_ID))
    local Answers = Query:fetch({}, "n")

    if not Answers then
        print("No existen respuestas asociadas a esa pregunta.")
        return
    end

    print("Mostrando respuestas para esa pregunta:")
    print("Codigo pregunta: ", Qtn_ID)

    print("Codigo Respuesta | Texto respuesta | Puntos Respuesta")

    while Answers do
        local Data = SQL:ConcatData("", Answers, "\t\t")
        print(Data)
        Answers = Query:fetch(Answers, "n")
    end
end

function SURV:ModifyQuestions()
    if not self.Data.ID or self.Data.ID < 0 then return end
    SQL:SetCurrentTable("QUESTIONS")

    local Questions = SQL:RunQuery(string.format([[SELECT id_qtn as 'COD_Pregunta', qtn_text as 'Texto de la pregunta.' 
    FROM %s WHERE disabled=false and SURVEYS_id_svy = %s]], SQL.CurrentTable, self.Data.ID))


end

function SURV:UpdateConsoleText()
    SQL:SetCurrentTable("SURVEYS")
    local Query = SQL:RunQuery(string.format([[SELECT id_svy, name_svy, desc_svy FROM %s WHERE THERAPISTS_id_tp = %s AND id_svy = %s]], SQL.CurrentTable, self.Data.TherapistID, self.Data.ID))
    local Fetch = Query:fetch({}, "n")

    self:SetData(Fetch)
end

return SURV