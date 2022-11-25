-- PATIENTS MANAGEMENT.
-- TODO: Apply the DRY principle correctly.

local PATIENTS = {}
local SQL = require("../lib/db_funcs")
local util = require("../lib/util")
local SURV = require("entities.surveys")

PATIENTS.Results = {
    ID = -1,
}

PATIENTS.Options = {}

function PATIENTS:GetResultsID()
    return self.Results.ID
end

function PATIENTS:SetResultsID(NewID)
    self.Results.ID = NewID
end

function PATIENTS:SetTherapist(TherapistID)
    self.Options.Therapist = tonumber(TherapistID) or -1
end

function PATIENTS:GetTherapistID()
    return self.Options.Therapist
end

function PATIENTS:GetData()
    self.Data = self.Data or {}
    return self.Data
end

function PATIENTS:DoSurvey()
    local Therapist = self:GetTherapistID()
    if not Therapist or Therapist < 0 then return end

    print("Ingrese RUT del paciente.")
    local RUNPat = tonumber(io.read()) or 0
    local PatID = self:SearchID(RUNPat, Therapist)

    if not PatID then return end

    print("Mostrando encuestas disponibles.")
    SURV:ShowCreatedSurveys(Therapist)
    print("Introduzca el codigo de la encuesta para realizar al paciente.")
    local SurvID = tonumber(io.read()) or 0

    if SurvID == 0 then
        print("El codigo introducido no es válido.")
        return
    end

    -- Muchos JOIN son malos (?)
    local Query = SQL:RunQuery(string.format([[SELECT q.id_qtn, q.qtn_text FROM SURVEYS sv INNER JOIN `QUESTIONS`
    q on q.`SURVEYS_id_svy` = sv.id_svy WHERE sv.THERAPISTS_id_tp = %s AND sv.id_svy = %s AND q.disabled = false]], Therapist, SurvID))
    local Questions = Query:fetch({}, "n")

    if not Questions then
        print("La encuesta solicitada no tiene preguntas.")
        return
    end

    -- Cargar la encuesta.
    SURV:SetID(SurvID)
    SURV:SetTherapistID(Therapist)

    if SURV:GetQuestionCount() < 1 then
        print("Esta encuesta no es válida.")
        return
    end

    -- Crear una tabla donde almacene los resultados.
    self:CreateResults(SurvID)

    print("Mostrando preguntas de la encuesta seleccionada: ")
    print(string.format("Num. Pregunta | \t Texto de la Pregunta \t |"))

    local i = 0
    while Questions do
        print("-------------------------------")
        for Index, Value in ipairs(Questions) do
            if Index ~= 1 then
                print("Pregunta ", i + 1, Value, "\t\t")
            end
        end
        --local Data = SQL:ConcatData("", Questions, "\t\t")
        --print(Data)
        local QtnID = tonumber(Questions[1]) or -1
        print("-------------------------------")
        SURV:GetAnswers(QtnID, true)
        print("-------------------------------")

        --Aca le pregunta al usuario sobre los datos de la encuesta.
        self:AskData(SurvID, PatID, QtnID)
        Questions = Query:fetch(Questions, "n")
        i = i + 1
    end

    local Points = self:ObtainPoints(SurvID, PatID)
    local TextForDiag = "Puntos obtenidos en la encuesta realizada: " ..  Points
    print(TextForDiag)
    print("Este puntaje se ingresará automaticamente al diagnostico.")
    self:CreateDiagnostics(TextForDiag, PatID, Therapist)
end

function PATIENTS:CreateDiagnostics(PointsData, PatID, TherapistID)
    local Diagnosticed = false

    while not Diagnosticed do
        print("Ingrese el diagnostico del paciente: ")
        local Diag = io.read()

        if Diag:len() < 5 then
            print("Ese diagnostico no es válido.")
        else
            local FinalText = PointsData .. "\n" .. Diag
            print(FinalText)
            print("Insertando diagnostico en el sistema.")

            SQL:RunQuery(string.format([[INSERT INTO DIAGNOSTICS (obs_diag, PATIENTS_id_pat, THERAPISTS_id_tp, RESULTS_id_res)
            VALUES ('%s', %s, %s, %s)]], FinalText, PatID, TherapistID, self:GetResultsID()))

            print("Diagnostico registrado exitosamente.")
            Diagnosticed = true
        end
    end
end

function PATIENTS:ObtainPoints(SurvID, PatID, ResultID)
    ResultID = ResultID or self:GetResultsID()

    local Query = SQL:RunQuery(string.format([[SELECT SUM(res.choice_resp) FROM `RESPONSES` res INNER JOIN `RESULTS` 
    final ON res.`RESULTS_id_res` = final.id_res AND res.`SURVEYS_id_svy` = %s AND final.id_res = %s AND res.`PATIENTS_id_pat` = %s]], SurvID, ResultID, PatID))

    local Points = Query:fetch({}, "n")

    return Points[1]
end

-- Esto solo se debe ejecutar una sola vez.
function PATIENTS:CreateResults(SurvID)
    if self:GetResultsID() ~= -1 then return end

    print("Inserte algun comentario adicional para los resultados. (Opcional).")
    local Comment = io.read()
    print("Creando un lugar para guardar los resultados...")
    SQL:RunQuery(string.format([[INSERT INTO RESULTS (comment_res, SURVEYS_id_svy) VALUES ('%s', %s)]], Comment, SurvID))
    -- Deberia funcionar.
    self:SetResultsID(SQL:GetLastInsertedID())
end

function PATIENTS:InsertResponse(SurvID, PatID, QtnID, AnsID, PatChoice)
    print("Introduzca alguna observacion de la respuesta. (Opcional).")
    local Observation = io.read()
    print("Guardando en resultados...")

    SQL:RunQuery(string.format([[INSERT INTO RESPONSES
    (choice_resp, comments_resp, SURVEYS_id_svy, PATIENTS_id_pat, ANSWERS_id_ans, QUESTIONS_id_qtn, RESULTS_id_res)
    VALUES (%s, '%s', %s, %s, %s, %s, %s)]], PatChoice, Observation, SurvID, PatID, AnsID, QtnID, self:GetResultsID()))

    print("Guardado exitosamente.")
end
-- Otro bucle más JOJO.
function PATIENTS:AskData(SurvID, PatID, QtnID)
    local Answered = false

    while not Answered do
        print("Seleccione el puntaje de la respuesta que le dio o dará a conocer el paciente.")
        local Answers = tonumber(io.read()) or -1
        print("¿Esta seguro de la respuesta? [Y/N] Puntaje: ", Answers)
        local Confirm = io.read()

        if Answers < 0 or string.lower(Confirm) ~= "y" then
            print((Answers < 0) and "Esa no es una respuesta valida." or "Inserte nuevamente la respuesta.")
        else
            local Query = SQL:RunQuery(string.format([[
                SELECT a.id_ans, a.points_ans FROM `QUESTIONS` q INNER JOIN `ANSWERS` a 
                ON q.id_qtn = a.`QUESTIONS_id_qtn` WHERE q.`SURVEYS_id_svy` = %s AND q.id_qtn = %s AND a.points_ans = %s;]]
                ,SurvID, QtnID, Answers))
            local Check = Query:fetch({}, "n")

            if Check then
                print("Respuesta encontrada.")
                local IDAns = Check[1]
                self:InsertResponse(SurvID, PatID, QtnID, IDAns, Answers)
                Answered = true
            else
                print("La respuesta digitada no está en la seleccion.")
            end
        end
    end
end

function PATIENTS:SearchID(RUNPat, Therapist)
    local Query = SQL:RunQuery(string.format([[SELECT id_pat FROM PATIENTS WHERE THERAPISTS_id_tp=%s and run_pat=%s]], Therapist, RUNPat))
    local PatientID = Query:fetch({}, "n")

    if not PatientID then
        print("El paciente no existe o el RUT es inválido")
        return nil
    end

    -- Lo más probable es que se tenga que hacer necesidad de un JOIN.
    local PatID = PatientID[1]
    return PatID or -1
end

function PATIENTS:ShowDiagnostics()
    local Therapist = self:GetTherapistID()

    if not Therapist or Therapist < 0 then return end

    print("Introduzca el RUT del paciente para obtener sus diagnosticos. ")
    local RUT = tonumber(io.read()) or -1

    if RUT < 0 then
        print("Por favor introduzca un RUT valido.")
        return
    end

    local PatID = self:SearchID(RUT, Therapist)
    if not PatID then return end

    local Query = SQL:RunQuery(string.format([[SELECT id_diag AS 'Codigo Diagnostico: ', obs_diag AS 'Diagnostico: ', RESULTS_id_res AS 'Codigo Resultado: ' FROM DIAGNOSTICS WHERE PATIENTS_id_pat = %s AND THERAPISTS_id_tp = %s]], PatID, Therapist))
    local Rows = Query:fetch({}, "a")

    if not Rows then
        print("Actualmente ese paciente no lleva ningún diagnostico.")
        return
    end

    print("DIAGNOSTICOS DE PACIENTE.")
    print("\n/******************************************/")

    while Rows do
        util:PrintSQLData(Rows)
        Rows = Query:fetch(Rows, "a")
    end

    print("/******************************************/\n")
end

-- TODO: Este es el JOIN más largo de todo el programa.
function PATIENTS:ShowSurveysResults()
    local Therapist = self:GetTherapistID()

    if not Therapist or Therapist < 0 then return end

    print("Introduzca el código del resultado del diagnostico.")
    local IDRes = tonumber(io.read()) or nil

    if not IDRes then
        print("[ERROR] El ID introducido no corresponde a un número.")
        return
    end

    print(string.format("El codigo introducido es %s", IDRes))

    local Query = SQL:RunQuery(string.format([[
        SELECT q.SURVEYS_id_svy AS "SurvCode", q.qtn_text AS 'Texto Pregunta', a.text_ans AS 'Respuesta seleccionada', 
        rps.choice_resp AS 'Puntos obtenidos', pat.run_pat as 'RUT Paciente' FROM RESPONSES rps 
        INNER JOIN QUESTIONS q ON rps.QUESTIONS_id_qtn = q.id_qtn 
        INNER JOIN ANSWERS a ON a.QUESTIONS_id_qtn = q.id_qtn AND rps.ANSWERS_id_ans = a.id_ans 
        INNER JOIN PATIENTS pat ON pat.id_pat = rps.PATIENTS_id_pat AND pat.THERAPISTS_id_tp = %s AND rps.RESULTS_id_res = %s;
    ]], Therapist, IDRes))

    local Fetch = Query:fetch({}, "a")

    if not Fetch then
        print("[ERROR] No existe ningún codigo de resultado asociado a ese.")
        return
    end

    print(string.format("RUT Paciente: %s", Fetch["RUT Paciente"]))
    local IDSurv = tonumber(Fetch["SurvCode"])

    -- El ID de la encuesta debería existir en la BD.
    local SurvQuery = SQL:RunQuery(string.format([[SELECT name_svy, desc_svy FROM SURVEYS WHERE id_svy = %s AND disabled = false]], IDSurv))
    local SurvFetch = SurvQuery:fetch({}, "n")
    print(string.format("Nombre de la encuesta: '%s'\nDescripción de la encuesta: '%s'", SurvFetch[1], SurvFetch[2]))

    print("IMPRIMIENDO RESULTADOS...")

    local NotPrint = {}
    NotPrint["RUT Paciente"] = true
    NotPrint["SurvCode"] = true

    while Fetch do
        print("/**************************************************/")
        for Name, Value in pairs(Fetch) do
            if not NotPrint[Name] then
                print(Name, ":", Value)
            end
        end

        Fetch = Query:fetch(Fetch, "a")
    end
    -- print("Esta en fase BETA (Es un programa piloto).")
    -- if not TerminarJoins then return end
    --print("Ingrese el RUT del paciente")

   --  local Query = SQL:RunQuery(string.format([[SELECT SUM(res.choice_resp) FROM `RESPONSES` res INNER JOIN `RESULTS` final ON res.`RESULTS_id_res` = final.id_res AND res.`SURVEYS_id_svy` = 1 AND final.id_res = 2 AND res.`PATIENTS_id_pat` = 1 INNER JOIN `PATIENTS` p ON res.`PATIENTS_id_pat` = p.id_pat WHERE p.`THERAPISTS_id_tp` = 1;]]))
end

function PATIENTS:ShowAssociated()
    local Therapist = self:GetTherapistID()

    if not Therapist or Therapist < 0 then return end
    local Query = SQL:RunQuery(string.format([[SELECT run_pat AS 'RUT Paciente', firstname_pat as 'Nombres Paciente', lastname_pat AS 'Apellidos Paciente', birthdate_pat AS 'Fecha Nac. Paciente' FROM PATIENTS WHERE THERAPISTS_id_tp=%s]], Therapist))
    local Patients = Query:fetch({}, "a")

    if not Patients then
        print("No hay pacientes registrados actualmente.")
        return
    end

    while Patients do
        print("/********************************************************/")
        util:PrintSQLData(Patients, ":")
        print("/********************************************************/")
        Patients = Query:fetch(Patients, "a")
    end
end

-- Crear una 'ficha' que muestre la informacion del paciente.
function PATIENTS:CreateFile()
    local TherapistID = self:GetTherapistID()
    if not TherapistID or TherapistID < 0 then return end

    print("Introduzca el RUT del paciente para obtener su ficha.")
    print("Sin el dígito verificador.")
    local RUTPatient = tonumber(io.read()) or nil
    local VD = util:GetVerifierDigit(RUTPatient)

    if not VD then
        print("El RUT ingresado no es valido.")
        return false
    end

    local Query = SQL:RunQuery(string.format([[SELECT id_pat AS 'Codigo Paciente', birthdate_pat AS 'Fecha Nac', run_pat AS 'RUT',
    firstname_pat AS 'Nombres', lastname_pat AS 'Apellidos', passport_pat AS 'Num. Pasaporte', address_pat AS 'Direccion', prof_pat as 'Ocupacion' FROM PATIENTS WHERE run_pat=%s and dv_pat='%s']], RUTPatient, VD))
    local Fetch = Query:fetch({}, "a")

    if not Query then
        print("No existe un paciente con ese RUT asociado a usted.")
        return false
    end

    local File = io.open(string.format("%s.txt", RUTPatient), "w")
    local ActualDate = util:GetActualTime()
    if not File then return false end

    -- Asociaremos la ficha del paciente con el ID del mismo.
    File:write(string.format("FICHA DE PACIENTE \t COD: %s \n", Fetch["Codigo Paciente"]))
    File:write("Fecha de creación: ", ActualDate, "\n")

    while Fetch do
        for Names, Values in pairs(Fetch) do
            File:write(Names, "\t=\t", Values, "\n")
        end
        Fetch = Query:fetch(Fetch, "a")
    end

    local PatID = self:SearchID(RUTPatient, TherapistID)

    print("Guardando diagnosticos de paciente en el archivo.")
    File:write("/******************************************/\n")
    File:write("DIAGNOSTICOS DE PACIENTE.\n")
    Query = SQL:RunQuery(string.format([[SELECT id_diag AS 'Codigo Diagnostico: ', obs_diag AS 'Diagnostico: ', RESULTS_id_res AS 'Codigo Resultado: ' FROM DIAGNOSTICS WHERE PATIENTS_id_pat = %s AND THERAPISTS_id_tp = %s]], PatID, TherapistID))
    Fetch =  Query:fetch({}, "a")

    while Fetch do
        for Names, Values in pairs(Fetch) do
            File:write(Names, "\t=\t", Values, "\n")
        end
        Fetch = Query:fetch(Fetch, "a")
    end

    File:write("/***********************************/")

    File:close()

    return true
end

function PATIENTS:Register()
    local Therapist = self:GetTherapistID()

    if not Therapist or Therapist < 0 then return end

    print("[MENU] REGISTRO PACIENTES.")
    print("Registrar paciente para atención.")
    print("Introduzca el RUT del paciente (sin digito verificador y sin puntos).")
    local RUTPat = tonumber(io.read()) or nil
    local VD = util:GetVerifierDigit(RUTPat)
    if not VD then return false end

    print("Introduzca los nombres del paciente.")
    local Names = io.read()
    print("Introduzca los apellidos del paciente.")
    local LastNames = io.read()
    print("Introduzca la direccion del paciente.")
    local Address = io.read()
    print("Introduzca la fecha de nacimiento. En formato Mes/Dia/Año. Ejemplo => 04/12/1996")
    local BirthDate = io.read()

    if not util:IsValidDate(BirthDate) then
        print("No es una fecha válida, intente usar los slash para colocarla.")
        return false
    end

    -- Si fuese un programa real le pondría un JSON para cada paciente.
    print("Introduzca el numero del pasaporte del paciente.")
    local PassportNum = io.read()
    print("Introduzca la ocupación del paciente. (Deje vacio si el paciente es estudiante).")
    local Profession = string.lower(io.read())

    -- Checks de seguridad.
    if Profession == "" or string.find(Profession, "estudiante") then
        print("El paciente es un estudiante.")
        Profession = "estudiante"
    end

    SQL:RunQuery(string.format([[INSERT INTO PATIENTS (run_pat, dv_pat, firstname_pat, lastname_pat, address_pat, birthdate_pat, passport_pat, THERAPISTS_id_tp, prof_pat) 
    VALUES (%s, '%s','%s','%s','%s', STR_TO_DATE('%s', "%%m/%%d/%%Y"),'%s', %s, '%s')]], RUTPat, VD, Names, LastNames, Address, BirthDate, PassportNum, Therapist, Profession))

    print("Paciente ingresado con exito.")
    return true
end


local UpdateChoices = {
    ["nombre"] = {
        Query = "firstname_pat",
        Phrase = "Ponga los nuevos nombres del paciente."
    },

    ["apellido"] = {
        Query = "lastname_pat",
        Phrase = "Ponga los nuevos apellidos del paciente."
    },

    ["direccion"] = {
        Query = "address_pat",
        Phrase = "Ponga la nueva direccion del paciente."
    },

    ["fechanacimiento"] = {
        Query = "birthdate_pat",
        Phrase = "Ponga la nueva fecha de nacimiento del paciente.",
        Check = true,
    },

    ["profesion"] = {
        Query = "prof_pat",
        Phrase = "Ponga la nueva profesion/ocupación del paciente."
    },
}

function PATIENTS:Update()
    local Therapist = self:GetTherapistID()

    if not Therapist or Therapist < 0 then return end

    -- RUT, DV, ID, ID Terapeuta no se deben actualizar.
    print("¿Que datos desea actualizar?")
    print("Introduzca tal cual el nombre de lo que desea actualizar: (nombre, apellido, direccion, fechanacimiento, profesion).")
    local DataUpdate = string.lower(io.read())
    local Final = UpdateChoices[DataUpdate] or nil

    if not Final then
        print("La eleccion no existe dentro de lo solicitado.")
        return
    end

    print(Final.Phrase)
    local Update = io.read()

    if Final.Check and not util:IsValidDate(Update) then
        print("La fecha introducida no es válida.")
        return
    end

    print("Introduzca el RUT del paciente ")
    local IntroRUT = tonumber(io.read()) or 0
    local VD = util:GetVerifierDigit(IntroRUT)
    if not VD then return end

    local Query = SQL:RunQuery(string.format([[UPDATE PATIENTS SET %s='%s' WHERE run_pat=%s AND THERAPISTS_id_tp=%s]], Final.Query, Update, IntroRUT, Therapist))

    print(Query == 1 and "Paciente correctamente actualizado." or  "[ERROR] Paciente no existe en la BD o no está asociado.")
end

function PATIENTS:Menu()
    local Choice = 0

    while Choice ~= 8 do
        print("Por favor seleccione una de las siguientes opciones:")
        print("1. Realizar encuesta para un paciente.")
        print("2. Mostrar diagnosticos de paciente.")
        print("3. Ver resultados de encuesta de un paciente.")
        print("4. Mostrar pacientes asociados.")
        print("5. Registrar paciente.")
        print("6. Descargar ficha paciente. (BETA)")
        print("7. Actualizar datos paciente.")
        print("8. Volver al menu anterior.")

        Choice = tonumber(io.read()) or 0

        if Choice < 0 or Choice > 8 then
            print("Por favor Introduzca una opcion del menú.")
        elseif Choice == 1 then
            PATIENTS:DoSurvey()
        elseif Choice == 2 then
            PATIENTS:ShowDiagnostics()
        -- Se puede hacer pero dado que esto es un programa piloto, se mostrará que hacer con el a medida que pase el tiempo.
        elseif Choice == 3 then
            PATIENTS:ShowSurveysResults()
        elseif Choice == 4 then
            PATIENTS:ShowAssociated()
        elseif Choice == 5 then
            PATIENTS:Register()
        elseif Choice == 6 then
            PATIENTS:CreateFile()
        elseif Choice == 7 then
            PATIENTS:Update()
        end
    end
end

return PATIENTS