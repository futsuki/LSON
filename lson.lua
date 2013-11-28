local self = getfenv()
local loadstring, type, ipairs, pairs, pcall, print, getmetatable, setmetatable
loadstring, type, ipairs, pairs, pcall, print, getmetatable, setmetatable = self.loadstring, self.type, self.ipairs, self.pairs, self.pcall, self.print, self.getmetatable, self.setmetatable
local byte, sub
do
  local _obj_0 = string
  byte, sub = _obj_0.byte, _obj_0.sub
end
require("base64")
local toLSON
toLSON = function(o, reconstructable, circularCheckTable)
  if reconstructable == nil then
    reconstructable = true
  end
  if circularCheckTable == nil then
    circularCheckTable = { }
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
      else
        ret = ret .. ", "
      end
      local vstr = toLSON(v, reconstructable, circularCheckTable)
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
        else
          ret = ret .. ", "
        end
        local vstr = toLSON(v, reconstructable, circularCheckTable)
        local kstr = toLSON(k, reconstructable, circularCheckTable)
        if vstr ~= nil then
          if reconstructable then
            ret = ret .. "[" .. tostring(kstr) .. "] = " .. tostring(vstr)
          else
            ret = ret .. tostring(kstr) .. " = " .. tostring(vstr)
          end
        else
          ret = ret .. "[" .. tostring(kstr) .. "] = nil"
        end
        _continue_0 = true
      until true
      if not _continue_0 then
        break
      end
    end
    ret = ret .. "}"
    return ret
  elseif "string" == _exp_0 then
    if reconstructable then
      if o:byte(1) == 36 then
        return "\"$" .. tostring(o) .. "\""
      else
        return "\"" .. tostring(o) .. "\""
      end
    else
      return tostring(o)
    end
  elseif "function" == _exp_0 then
    if reconstructable then
      local stat, str = pcall(string.dump, o)
      if stat and str ~= nil then
        return "loadstring(base64.decode(\"" .. tostring(base64.encode(str)) .. "\"))"
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
local fromLSON
fromLSON = function(str)
  local chunk = loadstring("return (" .. tostring(str) .. ");")
  local stat, ret = pcall(chunk)
  if stat then
    return ret
  else
    return nil
  end
end
self.LSON = {
  stringify = toLSON,
  parse = fromLSON
}
self.p = function(...)
  local param = {
    ...
  }
  if #param == 1 then
    print(toLSON(param[1], false))
  else
    for i, v in ipairs(param) do
      print(toLSON(v, false))
    end
  end
  return ...
end