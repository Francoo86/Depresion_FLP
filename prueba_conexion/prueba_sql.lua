-- El ejemplo utilizado para la tabla personas es el siguiente.
-- https://www.w3schools.com/mysql/mysql_create_table.asp

-- Cargar el módulo de MySQL.
local Driver = require "luasql.mysql"
-- Crear el objeto del entorno.
local env = assert(Driver.mysql())

--Conectar con la base de datos.
--Syntax = env:connect("nombre_bd", "nombre_user", "contraseña_user")
local Conn = assert(env:connect("nombre_bd", "nombre_user", "contraseña_user"))

-- Realizar consultas.
local function ExecQuery(Query)
    local Request = assert(Conn:execute(Query))
    return Request
end

-- El ID lo he configurado como auto-incrementable así que no usaremos el mismo como parametro.
local function InsertPerson(Data)
    if not Data then return end

    for _, Values in pairs (Data) do
        ExecQuery(string.format([[
           INSERT INTO Persons (LastName, FirstName, Address, City) VALUES ('%s', '%s', '%s', '%s') 
        ]], Values.LastName, Values.FirstName, Values.Address, Values.City))
    end
end

--Realizar una consulta de tipo select.
--Imprimir datos de las Personas.
local function PrintData(TableName)
    -- Si no hay input colocamos Persons por default.
    TableName = TableName or "Persons"
    local Data = ExecQuery(string.format("SELECT * FROM %s", TableName))
    -- Separamos las filas como tablas lua.
    local Rows = Data:fetch({}, "a")

    while Rows do
        print("ID: ", Rows.PersonID, "LastName: ", Rows.LastName, "FirstName: ", Rows.FirstName, "Address: ", Rows.Address, "City: ", Rows.City)
        Rows = Data:fetch(Rows, "a")
    end
end

--Actualizar datos de las personas.
local function UpdateData(TableName, Data, ID)
    TableName = TableName or "Persons"

    --Revisar si existe ese ID.
    local Check = ExecQuery(string.format([[SELECT COUNT(1) FROM %s WHERE PersonID=%s]], TableName, ID))
    Check = Check:fetch({}, "a")

    --No existe entonces terminamos de ejecutar esta función.
    if Check["COUNT(1)"] == "0" then
        print("That ID doesn't exist on the database.")
        return
    end

    print("ID Found, modifying it...")

    for _, Values in pairs(Data) do
        ExecQuery(string.format([[UPDATE %s SET FirstName='%s', LastName='%s' WHERE PersonID=%s]], TableName, Values.FirstName, Values.LastName, ID))
    end

    print("Updated table: \n")

    PrintData(TableName)
end

-- Datos de ejemplos para insertar en la personas.
local PersonData = {
    {LastName = "Perez", FirstName = "Juanito", Address = "Av. Cerro Dragon", City = "Iquique"},
    {LastName = "Prat", FirstName = "Arturo", Address = "Av. Arturo Prat", City = "Iquique"}
}

-- InsertPerson(PersonData)
PrintData("Persons")
UpdateData("Persons", {{FirstName = "Alexis", LastName = "Sanchez"}}, 4)

-- Cerramos la conexion.
Conn:close()
env:close()
-- USERS = PSYCHOLOGISTS, PATIENTS = INTERVIEWED, SUSPECT_CASES = POLL.

