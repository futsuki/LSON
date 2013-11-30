-- This is free and unencumbered software released into the public domain.
-- 
-- Anyone is free to copy, modify, publish, use, compile, sell, or
-- distribute this software, either in source code form or as a compiled
-- binary , for any purpose, commercial or non-commercial, and by any
-- means.
-- 
-- In jurisdictions that recognize copyright laws, the author or authors
-- of this software dedicate any and all copyright interest in the
-- software to the public domain. We make this dedication for the benefit
-- of the public at large and to the detriment of our heirs and
-- successors. We intend this dedication to be an overt act of
-- relinquishment in perpetuity of all present and future rights to this
-- software under copyright law.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
-- EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
-- MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
-- IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
-- OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
-- ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
-- OTHER DEALINGS IN THE SOFTWARE.
-- 
-- For more information, please refer to <http://unlicense.org>

local self = _ENV or getfenv()
local isLua52 = getfenv == nil
local rshift, lshift, bor, band
do
  local _obj_0 = bit32 or bit
  rshift, lshift, bor, band = _obj_0.rshift, _obj_0.lshift, _obj_0.bor, _obj_0.band
end
local byte, char
do
  local _obj_0 = string
  byte, char = _obj_0.byte, _obj_0.char
end
local concat
do
  local _obj_0 = table
  concat = _obj_0.concat
end
local floor
do
  local _obj_0 = math
  floor = _obj_0.floor
end
local ENCODE_TABLE = {
  'A',
  'B',
  'C',
  'D',
  'E',
  'F',
  'G',
  'H',
  'I',
  'J',
  'K',
  'L',
  'M',
  'N',
  'O',
  'P',
  'Q',
  'R',
  'S',
  'T',
  'U',
  'V',
  'W',
  'X',
  'Y',
  'Z',
  'a',
  'b',
  'c',
  'd',
  'e',
  'f',
  'g',
  'h',
  'i',
  'j',
  'k',
  'l',
  'm',
  'n',
  'o',
  'p',
  'q',
  'r',
  's',
  't',
  'u',
  'v',
  'w',
  'x',
  'y',
  'z',
  '0',
  '1',
  '2',
  '3',
  '4',
  '5',
  '6',
  '7',
  '8',
  '9',
  '+',
  '/',
  '='
}
local DECODE_TABLE = {
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  62,
  -1,
  -1,
  -1,
  63,
  52,
  53,
  54,
  55,
  56,
  57,
  58,
  59,
  60,
  61,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  0,
  1,
  2,
  3,
  4,
  5,
  6,
  7,
  8,
  9,
  10,
  11,
  12,
  13,
  14,
  15,
  16,
  17,
  18,
  19,
  20,
  21,
  22,
  23,
  24,
  25,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  26,
  27,
  28,
  29,
  30,
  31,
  32,
  33,
  34,
  35,
  36,
  37,
  38,
  39,
  40,
  41,
  42,
  43,
  44,
  45,
  46,
  47,
  48,
  49,
  50,
  51,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1
}
local CHAR_TABLE = { }
for i = 0, 255 do
  CHAR_TABLE[i + 1] = char(i)
end
local encode3bytes
encode3bytes = function(s, start)
  local b1, b2, b3 = byte(s, start, start + 2)
  local c1 = rshift(b1, 2)
  local c2 = bor(lshift(band(b1, 3), 4), rshift(b2, 4))
  local c3 = bor(lshift(band(b2, 15), 2), rshift(b3, 6))
  local c4 = band(b3, 63)
  return ENCODE_TABLE[c1 + 1], ENCODE_TABLE[c2 + 1], ENCODE_TABLE[c3 + 1], ENCODE_TABLE[c4 + 1]
end
local encode3bytesTail
encode3bytesTail = function(s, start)
  local b1, b2, b3 = byte(s, start, start + 2)
  local c1, c2, c3, c4
  if b1 then
    c1 = rshift(b1, 2)
    c2 = bor(lshift(band(b1, 3), 4), rshift(b2 or 0, 4))
    if b2 then
      c3 = bor(lshift(band(b2, 15), 2), rshift(b3 or 0, 6))
      if b3 then
        c4 = band(b3, 63)
      else
        c4 = 64
      end
    else
      c3, c4 = 64, 64
    end
  else
    c1, c2, c3, c4 = 64, 64, 64, 64
  end
  return ENCODE_TABLE[c1 + 1], ENCODE_TABLE[c2 + 1], ENCODE_TABLE[c3 + 1], ENCODE_TABLE[c4 + 1]
end
local decode4bytes
decode4bytes = function(s, start)
  local c1, c2, c3, c4 = byte(s, start, start + 4)
  c1, c2, c3, c4 = DECODE_TABLE[c1], DECODE_TABLE[c2], DECODE_TABLE[c3], DECODE_TABLE[c4]
  local b1 = bor(lshift(band(c1, 63), 2), rshift(c2, 4))
  local b2 = bor(lshift(band(c2, 15), 4), rshift(c3, 2))
  local b3 = bor(lshift(band(c3, 3), 6), c4)
  return CHAR_TABLE[b1 + 1], CHAR_TABLE[b2 + 1], CHAR_TABLE[b3 + 1]
end
local decode4bytesTail
decode4bytesTail = function(s, start)
  local c1, c2, c3, c4 = byte(s, start, start + 4)
  c1, c2, c3, c4 = DECODE_TABLE[c1], DECODE_TABLE[c2], DECODE_TABLE[c3], DECODE_TABLE[c4]
  if c1 == -1 then
    c1 = nil
  end
  if c2 == -1 then
    c2 = nil
  end
  if c3 == -1 then
    c3 = nil
  end
  if c4 == -1 then
    c4 = nil
  end
  local b1, b2, b3
  if c1 and c2 then
    b1 = bor(lshift(band(c1, 63), 2), rshift(c2, 4))
  end
  if c2 and c3 then
    b2 = bor(lshift(band(c2, 15), 4), rshift(c3, 2))
  end
  if c3 and c4 then
    b3 = bor(lshift(band(c3, 3), 6), c4)
  end
  if b1 and b2 and b3 then
    return CHAR_TABLE[b1 + 1], CHAR_TABLE[b2 + 1], CHAR_TABLE[b3 + 1]
  else
    if b1 and b2 then
      return CHAR_TABLE[b1 + 1], CHAR_TABLE[b2 + 1]
    else
      if b1 then
        return CHAR_TABLE[b1 + 1]
      else
        return ""
      end
    end
  end
end
local base64enc
base64enc = function(bytes)
  local t = { }
  local len = floor(#bytes / 3) * 3
  for i = 1, len, 3 do
    local lt = #t
    t[lt + 1], t[lt + 2], t[lt + 3], t[lt + 4] = encode3bytes(bytes, i)
  end
  if len < #bytes then
    local lt = #t
    t[lt + 1], t[lt + 2], t[lt + 3], t[lt + 4] = encode3bytesTail(bytes, len + 1)
  end
  return concat(t)
end
local base64dec
base64dec = function(str)
  local t = { }
  local len = floor((#str - 1) / 4) * 4
  for i = 1, len, 4 do
    local lt = #t
    t[lt + 1], t[lt + 2], t[lt + 3] = decode4bytes(str, i)
  end
  local lt = #t
  t[lt + 1], t[lt + 2], t[lt + 3] = decode4bytesTail(str, len + 1)
  return concat(t)
end
local load, type, ipairs, pairs, pcall, print, getmetatable, setmetatable
load, type, ipairs, pairs, pcall, print, getmetatable, setmetatable = self.load, self.type, self.ipairs, self.pairs, self.pcall, self.print, self.getmetatable, self.setmetatable
local sub, dump, gsub
do
  local _obj_0 = string
  byte, sub, dump, gsub = _obj_0.byte, _obj_0.sub, _obj_0.dump, _obj_0.gsub
end
local escaper
escaper = function(c)
  if c == '\a' then
    return "\\a"
  else
    if c == '\b' then
      return "\\b"
    else
      if c == '\f' then
        return "\\f"
      else
        if c == '\n' then
          return "\\n"
        else
          if c == '\r' then
            return "\\r"
          else
            if c == '\t' then
              return "\\t"
            else
              if c == '\v' then
                return "\\v"
              else
                if c == '\\' then
                  return "\\\\"
                else
                  if c == '"' then
                    return "\\\""
                  else
                    return c
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
local escapeString
escapeString = function(s)
  return gsub(s, "[\a\b\f\n\r\t\v\\\"]", escaper)
end
local toLSON
toLSON = function(o, reconstructable, pretty, circularCheckTable, indent)
  if reconstructable == nil then
    reconstructable = true
  end
  if pretty == nil then
    pretty = false
  end
  if circularCheckTable == nil then
    circularCheckTable = { }
  end
  if indent == nil then
    indent = 0
  end
  if type(o) == "table" then
    if circularCheckTable[o] ~= nil then
      if reconstructable then
        error("Converting circular structure to LSON")
      else
        return "[circular reference]"
      end
    else
      circularCheckTable[o] = true
    end
  end
  local _exp_0 = type(o)
  if "table" == _exp_0 then
    local first = true
    local ret = "{"
    local processed = -1
    for i, v in ipairs(o) do
      if first then
        first = false
        if pretty then
          ret = ret .. ("\n" .. string.rep(" ", indent + 2))
        end
      else
        ret = ret .. ", "
      end
      local vstr = toLSON(v, reconstructable, pretty, circularCheckTable, indent + 2)
      ret = ret .. tostring(vstr)
      processed = i
    end
    for k, v in pairs(o) do
      local _continue_0 = false
      repeat
        if type(k) == "number" then
          if k >= 1 and k <= processed then
            _continue_0 = true
            break
          end
        end
        if reconstructable and (type(v) == "thread" or type(v) == "userdata") then
          _continue_0 = true
          break
        end
        if first then
          first = false
          if pretty then
            ret = ret .. ("\n" .. string.rep(" ", indent + 2))
          end
        else
          ret = ret .. ", "
          if pretty then
            ret = ret .. ("\n" .. string.rep(" ", indent + 2))
          end
        end
        local vstr = toLSON(v, reconstructable, pretty, circularCheckTable, indent + 2)
        local kstr = toLSON(k, reconstructable, pretty, circularCheckTable, indent + 2)
        if vstr == nil then
          vstr = "nil"
        end
        if reconstructable then
          ret = ret .. "[" .. tostring(kstr) .. "] = " .. tostring(vstr)
        else
          ret = ret .. tostring(kstr) .. " = " .. tostring(vstr)
        end
        _continue_0 = true
      until true
      if not _continue_0 then
        break
      end
    end
    if pretty then
      ret = ret .. ("\n" .. string.rep(" ", indent))
    end
    ret = ret .. "}"
    return ret
  elseif "string" == _exp_0 then
    if reconstructable then
      return "\"" .. tostring(escapeString(o)) .. "\""
    else
      return tostring(o)
    end
  elseif "function" == _exp_0 then
    if reconstructable then
      local stat, str = pcall(dump, o)
      if stat and str ~= nil then
        return "FUNCTION(\"" .. tostring(base64enc(str)) .. "\")"
      else
        return nil
      end
    else
      return tostring(o)
    end
  else
    return tostring(o)
  end
end
local parseEnv = { }
local parseFunction
parseFunction = function(s)
  return load(base64dec(s))
end
local fromLSON
fromLSON = function(str, env)
  if env == nil then
    env = parseEnv
  end
  if isLua52 then
    local oldf = env.FUNCTION
    if env.FUNCTION == nil then
      env.FUNCTION = parseFunction
    end
    local chunk = load("return function() return (" .. tostring(str) .. "); end;", str, "t", env)
    if chunk == nil then
      return nil
    end
    local stat, f = pcall(chunk)
    local ret
    if stat and type(f) == 'function' then
      ret = f()
    else
      ret = nil
    end
    env.FUNCTION = oldf
    return ret
  else
    local chunk = load("return function() return (" .. tostring(str) .. "); end;")
    if chunk == nil then
      return nil
    end
    local stat, f = pcall(chunk)
    if stat and type(f) == 'function' then
      local oldf = env.FUNCTION
      if env.FUNCTION == nil then
        env.FUNCTION = parseFunction
      end
      setfenv(f, env)
      local ret = f()
      env.FUNCTION = oldf
      return ret
    else
      return nil
    end
  end
end
if self.p == nil then
  self.p = function(...)
    local param = {
      ...
    }
    local arr = { }
    for i, v in ipairs(param) do
      arr[#arr + 1] = toLSON(v, false, true)
    end
    print(unpack(arr))
    return ...
  end
end
local LSON = {
  stringify = function(o, t)
    local reconstructable, pretty
    do
      local _obj_0 = t or { }
      reconstructable, pretty = _obj_0.reconstructable, _obj_0.pretty
    end
    return toLSON(o, reconstructable, pretty)
  end,
  parse = function(s, t)
    local env
    do
      local _obj_0 = t or { }
      env = _obj_0.env
    end
    return fromLSON(s, env)
  end,
  p = p,
  base64encode = base64enc,
  base64decode = base64dec
}
return LSON
