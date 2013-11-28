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

@ = getfenv()

import loadstring, type, ipairs, pairs, pcall, print, getmetatable, setmetatable from @
import byte, sub from string
import encode, decode from require("base64")

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
                    "FUNCTION(\"#{base64.encode(str)}\")"
                else
                    nil
            else
                "#{o}"
        else
            "#{o}"

parseEnv = {}

fromLSON = (str, env=parseEnv) ->
    chunk = loadstring("return function() return (#{str}); end;")
    if chunk == nil
        return nil
    stat, f = pcall(chunk)
    if stat
        oldf = env.FUNCTION
        if env.FUNCTION == nil
            env.FUNCTION = (s) ->
                loadstring(decode(s))
        setfenv(f, env)
        ret = f()
        env.FUNCTION = oldf
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








