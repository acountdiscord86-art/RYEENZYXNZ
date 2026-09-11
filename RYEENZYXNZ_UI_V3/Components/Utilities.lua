--[[
    RYEENZYXNZ UI V3 — Utilities Module
    General purpose helpers used across the library.
]]

local HttpService      = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

local Utilities = {}

-- ─── Type Helpers ───────────────────────────────────────────────
function Utilities.IsColor3(v)
    return typeof(v) == "Color3"
end

function Utilities.IsEnumItem(v)
    return typeof(v) == "EnumItem"
end

function Utilities.IsTable(v)
    return type(v) == "table"
end

-- ─── Math ───────────────────────────────────────────────────────
function Utilities.Round(n, step)
    if not step or step == 0 then return n end
    return math.round(n / step) * step
end

function Utilities.Lerp(a, b, t)
    return a + (b - a) * t
end

function Utilities.Clamp(v, min, max)
    return math.max(min, math.min(max, v))
end

function Utilities.Map(v, inMin, inMax, outMin, outMax)
    return outMin + (v - inMin) / (inMax - inMin) * (outMax - outMin)
end

-- ─── Color ──────────────────────────────────────────────────────
function Utilities.Color3ToRGB(c)
    return
        math.round(c.R * 255),
        math.round(c.G * 255),
        math.round(c.B * 255)
end

function Utilities.Color3ToHex(c)
    local r, g, b = Utilities.Color3ToRGB(c)
    return string.format("#%02X%02X%02X", r, g, b)
end

function Utilities.HexToColor3(hex)
    hex = hex:gsub("#", "")
    local r = tonumber(hex:sub(1, 2), 16) or 0
    local g = tonumber(hex:sub(3, 4), 16) or 0
    local b = tonumber(hex:sub(5, 6), 16) or 0
    return Color3.fromRGB(r, g, b)
end

function Utilities.LightenColor3(c, amount)
    amount = amount or 0.1
    return Color3.new(
        Utilities.Clamp(c.R + amount, 0, 1),
        Utilities.Clamp(c.G + amount, 0, 1),
        Utilities.Clamp(c.B + amount, 0, 1)
    )
end

function Utilities.DarkenColor3(c, amount)
    amount = amount or 0.1
    return Color3.new(
        Utilities.Clamp(c.R - amount, 0, 1),
        Utilities.Clamp(c.G - amount, 0, 1),
        Utilities.Clamp(c.B - amount, 0, 1)
    )
end

-- ─── String ─────────────────────────────────────────────────────
function Utilities.Trim(s)
    return s:gsub("^%s*(.-)%s*$", "%1")
end

function Utilities.StartsWith(s, prefix)
    return s:sub(1, #prefix) == prefix
end

function Utilities.Split(s, sep)
    local result = {}
    local pattern = "([^" .. sep .. "]+)"
    for part in s:gmatch(pattern) do
        table.insert(result, part)
    end
    return result
end

-- ─── Table ──────────────────────────────────────────────────────
function Utilities.Contains(tbl, value)
    for _, v in ipairs(tbl) do
        if v == value then return true end
    end
    return false
end

function Utilities.Keys(tbl)
    local keys = {}
    for k in pairs(tbl) do
        table.insert(keys, k)
    end
    return keys
end

function Utilities.Values(tbl)
    local values = {}
    for _, v in pairs(tbl) do
        table.insert(values, v)
    end
    return values
end

function Utilities.Count(tbl)
    local n = 0
    for _ in pairs(tbl) do n += 1 end
    return n
end

function Utilities.DeepCopy(orig)
    local copy
    if type(orig) == "table" then
        copy = {}
        for k, v in pairs(orig) do
            copy[Utilities.DeepCopy(k)] = Utilities.DeepCopy(v)
        end
        setmetatable(copy, getmetatable(orig))
    else
        copy = orig
    end
    return copy
end

-- ─── Config Encoding ────────────────────────────────────────────
function Utilities.Encode(value)
    local t = typeof(value)
    if t == "boolean" or t == "number" or t == "string" then
        return value
    elseif t == "Color3" then
        return { __type = "Color3", R = value.R, G = value.G, B = value.B }
    elseif t == "EnumItem" then
        return { __type = "EnumItem", Name = value.Name }
    elseif t == "table" then
        local encoded = {}
        for k, v in pairs(value) do
            encoded[k] = Utilities.Encode(v)
        end
        return encoded
    end
    return tostring(value)
end

function Utilities.Decode(value)
    if type(value) == "table" then
        if value.__type == "Color3" then
            return Color3.new(value.R or 0, value.G or 0, value.B or 0)
        elseif value.__type == "EnumItem" then
            return value.Name
        else
            local decoded = {}
            for k, v in pairs(value) do
                decoded[k] = Utilities.Decode(v)
            end
            return decoded
        end
    end
    return value
end

-- ─── File System (executor-safe) ────────────────────────────────
function Utilities.SafeWrite(path, content)
    if writefile then
        local ok, err = pcall(writefile, path, content)
        if not ok then warn("[RYEENZYXNZ] writefile error:", err) end
        return ok
    end
    warn("[RYEENZYXNZ] writefile not available in this executor.")
    return false
end

function Utilities.SafeRead(path)
    if isfile and readfile then
        if not isfile(path) then return nil end
        local ok, content = pcall(readfile, path)
        return ok and content or nil
    end
    return nil
end

function Utilities.SafeDelete(path)
    if isfile and delfile then
        if isfile(path) then pcall(delfile, path) end
    end
end

function Utilities.EnsureFolder(folder)
    if isfolder and makefolder then
        if not isfolder(folder) then pcall(makefolder, folder) end
    end
end

-- ─── Input Helpers ──────────────────────────────────────────────
function Utilities.IsMobile()
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

function Utilities.GetMousePosition()
    return UserInputService:GetMouseLocation()
end

-- ─── Screen Helpers ─────────────────────────────────────────────
function Utilities.GetScreenSize()
    return workspace.CurrentCamera.ViewportSize
end

function Utilities.ClampToScreen(pos, size)
    local screen = Utilities.GetScreenSize()
    local x = Utilities.Clamp(pos.X, 0, screen.X - size.X)
    local y = Utilities.Clamp(pos.Y, 0, screen.Y - size.Y)
    return Vector2.new(x, y)
end

-- ─── JSON ───────────────────────────────────────────────────────
function Utilities.JSONEncode(data)
    local ok, result = pcall(HttpService.JSONEncode, HttpService, data)
    if ok then return result end
    warn("[RYEENZYXNZ] JSON encode error:", result)
    return nil
end

function Utilities.JSONDecode(str)
    local ok, result = pcall(HttpService.JSONDecode, HttpService, str)
    if ok then return result end
    warn("[RYEENZYXNZ] JSON decode error:", result)
    return nil
end

return Utilities
