local function ReadFile(Filename)
    local File = io.open(Filename, "rb")
    if not File then return nil end
    File:close()

    return File
end

local function ReadLines(Filename)
    if not ReadFile(Filename) then return {} end
    local Lines = {}

    for Line in io.lines(Filename) do
        Lines[#Lines + 1] = Line
    end

    return Lines
end

local function PrintLines(FileLines)
    if not FileLines then return end

    for i = 1, #FileLines do
        local Line = FileLines[i]
        print(i, Line)
    end
end