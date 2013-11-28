
@ = getfenv()

import loadstring, type, ipairs, pairs, pcall, print, getmetatable, setmetatable from @
import byte, sub from string
require("base64")

-- lua script object notation
toLSON = (o, reconstructable=true, circularCheckTable={}) ->
    if type(o) == "table"
        if circularCheckTable[o] != nil
            if reconstructable
                error "Converting circular structure to LSON"
            else
                return "[circular reference]"
        else
            circularCheckTable[o] = true
    switch type(o)
        when "table"
            first = true
            ret = "{"
            processed = -1
            for i, v in ipairs o
                if first
                    first = false
                else
                    ret ..= ", "
                vstr = toLSON v, reconstructable, circularCheckTable
                ret ..= "#{vstr}"
                processed = i
            for k, v in pairs o
                if type(k) == "number"
                    if k >= 1 and k <= processed
                        continue
                if reconstructable and (type(v) == "thread" or type(v) == "userdata")
                    continue
                if first
                    first = false
                else
                    ret ..= ", "
                vstr = toLSON v, reconstructable, circularCheckTable
                kstr = toLSON k, reconstructable, circularCheckTable
                if vstr != nil
                    if reconstructable
                        ret ..= "[#{kstr}] = #{vstr}"
                    else
                        ret ..= "#{kstr} = #{vstr}"
                else
                    ret ..= "[#{kstr}] = nil"
            ret ..= "}"
            ret
        when "string"
            if reconstructable
                "\"#{o}\""
            else
                "#{o}"
        when "function"
            if reconstructable
                stat, str = pcall(string.dump, o)
                if stat and str != nil
                    "loadstring(base64.decode(\"#{base64.encode(str)}\"))"
                else
                    nil
            else
                "#{o}"
        else
            "#{o}"

fromLSON = (str) ->
    chunk = loadstring("return (#{str});")
    stat, ret = pcall(chunk)
    if stat
        ret
    else
        nil


@LSON = 
    stringify: toLSON
    parse: fromLSON

-- pretty print
@p = (...) ->
    param = {...}
    if #param == 1
        print toLSON(param[1], false)
    else
        for i, v in ipairs param
            print toLSON(v, false)
    ...








