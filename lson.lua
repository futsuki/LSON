local self = _ENV or getfenv()
local isLua52 = getfenv == nil
local load, type, ipairs, pairs, pcall, print, getmetatable, setmetatable
load, type, ipairs, pairs, pcall, print, getmetatable, setmetatable = self.load, self.type, self.ipairs, self.pairs, self.pcall, self.print, self.getmetatable, self.setmetatable
local byte, sub, dump, gsub
do
  local _obj_0 = string
  byte, sub, dump, gsub = _obj_0.byte, _obj_0.sub, _obj_0.dump, _obj_0.gsub
end
local encode, decode
do
  local _obj_0 = require("base64")
  encode, decode = _obj_0.encode, _obj_0.decode
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
        return "FUNCTION(\"" .. tostring(encode(str)) .. "\")"
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
  return load(decode(s))
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
  p = p
}
return LSON
