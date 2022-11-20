-- PATIENTS MANAGEMENT.

local PATIENTS = {}
local SQL = require("../db_funcs")
local util = require("../util")
local SURV = require("entities.surveys")
local PSY = require("entities.psicologos")

PATIENTS.Options = {}

function PATIENTS:SetTherapist(TherapistID)
    self.Options.Therapist = tonumber(TherapistID) or -1
end

function PATIENTS:GetTherapistID()
    return self.Options.Therapist
end

function PATIENTS:GetData()
    self.Data = self.Data or {}
end

-- Puede que la tabla "RESPONSES" este sujeta a cambios (ojalá que no).
-- Esta parte es la que más me costó pensar, por eso puede tener errores.
-- De todo el sistema esta es la parte más complicada.
function PATIENTS:DoSurvey()
    local Therapist = self:GetTherapistID()
    SQL:SetCurrentTable("PATIENTS")

    if not Therapist or Therapist < 0 then return end
    -- Cargar encuesta para que la realice el paciente.
    -- Se selecciona al paciente y el psicologo le hace preguntas al paciente.
    -- De acuerdo a las respuestas del paciente elaboramos un diagnostico.
    -- Buscamos al paciente por RUT.
    -- La pregunta se contesta con puntos (sujeto a cambios).
    print("Ingrese RUT del paciente.")
    local RUNPat = tonumber(io.read()) or 0

    local Query = SQL:RunQuery(string.format([[SELECT id_pat FROM %s WHERE THERAPISTS_id_tp=%s and run_pat=%s]], SQL.CurrentTable
    , Therapist, RUNPat))
    local PatientID = Query:fetch({}, "n")

    if not PatientID then
        print("El paciente no existe o el RUT es inválido")
        return
    end

    -- Lo más probable es que se tenga que hacer necesidad de un JOIN.
    local ID = PatientID[1]

    print("Mostrando encuestas disponibles.")
    PSY:ShowCreatedSurveys()
    print("Introduzca el codigo de la encuesta para realizar al paciente.")
    local SurvID = tonumber(io.read()) or 0

    if SurvID == 0 then
        print("El codigo introducido no es válido.")
        return
    end

    SQL:SetCurrentTable("SURVEYS")

    -- Muchos JOIN son malos (?)
    Query = SQL:RunQuery(string.format([[SELECT q.id_qtn, q.qtn_text FROM %s sv INNER JOIN `QUESTIONS`
    q on q.`SURVEYS_id_svy` = sv.id_svy WHERE sv.THERAPISTS_id_tp = %s AND sv.id_svy = %s AND q.disabled = false]], SQL.CurrentTable, Therapist, SurvID))
    local Questions = Query:fetch({}, "n")

    if not Questions then
        print("La encuesta solicitada no tiene preguntas.")
        return
    end

    SURV.Data.ID = SurvID

    -- Probando JOINS.
    print("Mostrando preguntas de la encuesta seleccionada: ")
    print(string.format("Codigo Pregunta | \t Texto de la Pregunta \t |"))

    while Questions do
        local Data = SQL:ConcatData("", Questions, "\t\t")
        print(Data)
        print("-------------------------------")
        SURV:GetAnswers(tonumber(Questions[1]) or -1)
        print("-------------------------------")
        Questions = Query:fetch(Questions, "n")
    end
end

function PATIENTS:ShowDiagnostics()
    local Therapist = self:GetTherapistID()

    if not Therapist or Therapist < 0 then return end
    SQL:SetCurrentTable("DIAGNOSTICS")
end

function PATIENTS:ShowSurveysInfo()

end

function PATIENTS:ShowAssociated()
    local Therapist = self:GetTherapistID()

    if not Therapist or Therapist < 0 then return end
    SQL:SetCurrentTable("PATIENTS")
    local Query = SQL:RunQuery(string.format([[SELECT run_pat, firstname_pat, lastname_pat, birthdate_pat FROM %s WHERE THERAPISTS_id_tp=%s]], SQL.CurrentTable, Therapist))
    local Patients = Query:fetch({}, "n")

    if not Patients then
        print("No hay pacientes registrados actualmente.")
        return
    end

    print("RUT Paciente | \t Nombre Paciente | \t Apellidos Paciente | \t Fecha Nac. de Paciente.")

    while Patients do
        local Data = SQL:ConcatData("", Patients, "\t\t")
        print(Data)
        Patients = Query:fetch(Patients, "n")
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
    firstname_pat AS 'Nombres', lastname_pat AS 'Apellidos', passport_pat AS 'Num. Pasaporte', address_pat AS 'Direccion', prof_pat as 'Ocupacion' FROM %s WHERE run_pat=%s and dv_pat=%s]], SQL.CurrentTable, RUTPatient, VD))
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
    File:close()

    return true
end

function PATIENTS:Register()
    local Therapist = self:GetTherapistID()

    if not Therapist or Therapist < 0 then return end
    SQL:SetCurrentTable("PATIENTS")

    print("[MENU] REGISTRO PACIENTES.")
    print("Registrar paciente para atención.")
    print("Introduzca el RUT del paciente (sin digito verificador).")
    local RUTPat = tonumber(io.read()) or nil
    local VD = util:GetVerifierDigit(RUTPat)
    if not VD then return false end

    print("Introduzca los nombres del paciente.")
    local Names = io.read()
    print("Introduzca los apellidos del paciente.")
    local LastNames = io.read()
    print("Introduzca la direccion del paciente.")
    local Address = io.read()
    print("Introduzca la fecha de nacimiento. En formato Mes/Dia/Año")
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

    SQL:RunQuery(string.format([[INSERT INTO %s (run_pat, dv_pat, firstname_pat, lastname_pat, address_pat, birthdate_pat, passport_pat, THERAPISTS_id_tp, prof_pat) 
    VALUES (%s, '%s','%s','%s','%s', STR_TO_DATE('%s', "%%m/%%d/%%Y"),'%s', %s, '%s')]], SQL.CurrentTable, RUTPat, VD, Names, LastNames, Address, BirthDate, PassportNum, Therapist, Profession))

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
    SQL:SetCurrentTable("PATIENTS")

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

    SQL:RunQuery(string.format([[UPDATE %s SET %s='%s' WHERE run_pat=%s AND THERAPISTS_id_tp=%s]], SQL.CurrentTable, Final.Query, Update, IntroRUT, Therapist))
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
PATIENTS:Menu()


return PATIENTS