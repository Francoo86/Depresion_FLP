-- Cargar el módulo de MySQL.
local Driver = require "luasql.mysql"
-- Crear el objeto del entorno.
local env = assert(Driver.mysql())

-- ALGUNAS ACLARACIONES PARA EVITAR CONFUSIONES:
-- Cuando me refiero a tablas en lua, estoy hablando de Hash Tables, que son estructuras de datos similares a los arrays.
-- Por ej: Si dice estoy buscando una tabla que me guarde las tablas SQL.
-- Estoy diciendo que estoy buscando un "arreglo" que me guarde las tablas SQL.
-- El operador ~= es lo mismo que !=.

-- La función fetch recibe dos parametros.
-- La tabla (es necesaria), y el modo de mostrarla.
-- "a" las muestra en modo alfanumerico (string) mientras que la "n" las muestra en modo numerico.

--- Tabla de funciones.
--- Login es una tabla que almacena los datos para logearse a la BD.
--- Entidades son las que se ocuparan para el sistema. (Usuario, Psicologo, Admin)
--- Conn es la conexión.
--- ColumnData son las datos de la columna que se está utilizando.
--- PrimaryKeys es una tabla que guarda las PK de las tablas.
local DBFuncs = {
    Login = {
        DBName = "",
        User = "",
        Password = ""
    },

    Entities = {},

    Conn = nil,
    CurrentTable = "",
    ColumnData = {},
    PrimaryKeys = {}
}

-- CRUD (CRD) => Hasta el momento. Falta el Update. 

--- Encuentra las columnas de la tabla que se está usando.
function DBFuncs:FindColumns()
    if self.CurrentTable == "" then return end
    if self.ColumnData[self.CurrentTable] then return end

    self.ColumnData[self.CurrentTable] = {}
    local Query = self:RunQuery(string.format([[SHOW COLUMNS FROM %s]], self.CurrentTable))
    local Columns = Query:fetch({}, "a")

    while Columns do
        self.ColumnData[self.CurrentTable][#self.ColumnData[self.CurrentTable] + 1] = Columns.Field
        Columns = Query:fetch(Columns, "a")
    end
end

--- Setea la tabla que se utilizará.
--- Este setter es especial ya que al momento de colocar una tabla,
--- empieza buscar las columnas y la PK de la misma.
--- @param Table? string Tabla a utilizar que está en la DB.
function DBFuncs:SetCurrentTable(Table)
    Table = Table or ""
    self.CurrentTable = Table
    self:FindColumns()
    self:GetPrimaryKey()
end

--- Obtiene la primary Key de la tabla actual.
function DBFuncs:GetPrimaryKey()
    -- Si existe la llave primaria para que vamos a realizar la query de nuevo.
    if self.PrimaryKeys[self.CurrentTable] then
        print("Primary Key: ", self.PrimaryKeys[self.CurrentTable])
        return
    end

    local Query = self:RunQuery(string.format("SHOW KEYS FROM %s WHERE Key_name = 'PRIMARY'", self.CurrentTable))
    local PrimaryKey = Query:fetch({}, "a")

    -- Retorna la ubicacion de la primary key.
    self.PrimaryKeys[self.CurrentTable] = PrimaryKey["Column_name"]
end

--Hace un insert a una determinada tabla. 
---@param Data table La tabla con los datos a insertar.
function DBFuncs:CreateData(Data)
    local Curr = self.CurrentTable

    if not Data then
        print("There is no data to insert!")
        return
    end

    local ConcatQuery = string.format([[INSERT INTO %s (]], Curr)
    local PK = self.PrimaryKeys[Curr]

    ConcatQuery = self:ConcatData(ConcatQuery, Data, ",", string.lower(PK))
    self:RunQuery(ConcatQuery)
end

--- Concatenar datos.
---@param String? string La string para concatenar o una string nueva.
---@param Data table Es la tabla a recorrer que contiene datos para concatenar.
---@param Chars string Caracteres especiales para concatenar.
---@param PK? string La primary key, pero es exclusivo de la función CreateData.
---@return string Temp La string concatenada.
function DBFuncs:ConcatData(String, Data, Chars, PK)
    local Temp = String or ""
    Chars = Chars or ""

    ---TODO: Necesita un poco de orden.
    if PK and PK ~= "" then
        local Columns = self.ColumnData[self.CurrentTable]

        for _, Value in ipairs(Columns) do
            if string.lower(Value) ~= PK and Value ~= "disabled" then
                Temp = Temp .. Value .. Chars
            end
        end

        Temp = Temp:sub(1, -2) .. ") VALUES ("
    end

    for Index, Value in ipairs(Data) do
        -- Si hay primary key sabemos que es de la función creating.
        if PK then
            Temp = string.format(Temp .. [['%s']] .. (Index == #Data and ")" or ","), Value)
        -- Si no es para puro concatenar.
        else
            Temp = Temp .. Value .. Chars
        end
    end

    return Temp
end

--- Hace un SELECT a todos los elementos a excepción de los que tengan borrado logico.
---@param LoginData? table Son los datos de inicio de sesión para un determinado usuario (opcional).
function DBFuncs:ReadData(LoginData)
    -- Si hay un datos de inicio de sesión entonces buscar elementos relacionados al login.
    local Select = ""

    if LoginData then
        Select = self:RunQuery(string.format([[SELECT * FROM %s WHERE Username='%s' AND Password='%s']], self.CurrentTable, LoginData.user, LoginData.pass))

        local Pass = Select:fetch({}, "a")

        -- Esto es exactamente lo mismo que escribir:
        --[[
            Sabiendo que Pass puede tomar valores nulos.
            Es como en C++ cuando tratamos de revisar si un puntero es nulo.

            if Pass ~= nil then
                print("Success! Logged on the system.")
            else 
                print("Invalid credentials.")
            end
        ]]--
        print(Pass and "Success! Logged on the system. " or "Invalid credentials.")
        return Pass
    end

    Select = self:RunQuery(string.format("SELECT * FROM %s WHERE disabled=false", self.CurrentTable))
    local Rows = Select:fetch({}, "n")
    local Data = self.ColumnData[self.CurrentTable]
    local GridName = self:ConcatData(nil, Data, "\t")

    print(GridName)

    while Rows do
        local RowData = self:ConcatData(nil, Rows, "\t\t")

        -- Imprimir cada fila.
        print(RowData)
        Rows = Select:fetch(Rows)
    end
end

---Pending.
function DBFuncs:UpdateData()

end

--- Funcion de borrado logico visto en clase.
--- @param PK number El ID a eliminar de la BD.
function DBFuncs:DeleteData(PK)
    local Table = self.CurrentTable
    print("Borrando de la tabla: ", Table, " con la ID: ", PK)
    self:RunQuery(string.format([[UPDATE %s SET disabled=true WHERE %s=%s]], Table, self.PrimaryKeys[Table], PK))
end

-- Conectarse a la base de datos.
function DBFuncs:ConnectDB()
    if self.Conn then
        print("[INFO] There is a connection already.")
        return
    end

    self.Conn = assert(env:connect(self.Login.DBName, self.Login.User, self.Login.Password))
end

---Realizar consultas.
---Si no existe una conexion, tendrá que realizarse.
---@param Query string La query a realizar.
function DBFuncs:RunQuery(Query)
    if not self.Conn then
        print("[WARNING] There is no connection. Trying again.")
        self:ConnectDB()
    end

    local Request = assert(self.Conn:execute(Query))
    return Request
end

DBFuncs.Login.DBName = "testflp123"
DBFuncs.Login.User = "root"
DBFuncs.Login.Password = "root"

DBFuncs:SetCurrentTable("Persons")
--- DBFuncs:CreateData({"Mario", "Bros", "Reino Champiñon", "Iquique"})
DBFuncs:ReadData()
-- DBFuncs:DeleteData(4)
-- DBFuncs:ReadData()
-- DBFuncs:CreateData()

return DBFuncs