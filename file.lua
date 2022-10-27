
-- Palabra clave nil: Es el equivalente a un valor vacío o nulo.

-- Leer archivos.
local function ReadFile(Filename)
    local File = io.open(Filename, "rb")
    if not File then return nil end
    File:close()

    return File
end

-- Leer líneas de cada archivo, si el archivo se encuentra crea
-- una tabla donde cada linea va a ser almacenada en ella con un índice.
-- Por ejemplo: Linea[1] = hola

local function ReadLines(Filename)
    if not ReadFile(Filename) then return {} end
    local Lines = {}

    for Line in io.lines(Filename) do
        Lines[#Lines + 1] = Line
    end

    return Lines
end

--- Imprimir lineas basandose en la tabla.
local function PrintLines(FileLines)
    if not FileLines then return end

    for i = 1, #FileLines do
        local Line = FileLines[i]
        print(i, Line)
    end
end