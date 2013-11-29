
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

@ = _ENV or getfenv()

isLua52 = getfenv == nil

import load, type, ipairs, pairs, pcall, print, getmetatable, setmetatable from @
import byte, sub, dump, gsub from string
import encode, decode from require("base64")

escaper = (c) ->
    if c == '\a' then "\\a"
    else if c == '\b' then "\\b"
    else if c == '\f' then "\\f"
    else if c == '\n' then "\\n"
    else if c == '\r' then "\\r"
    else if c == '\t' then "\\t"
    else if c == '\v' then "\\v"
    else if c == '\\' then "\\\\"
    else if c == '"' then "\\\""
    else c

escapeString = (s) ->
    gsub s, "[\a\b\f\n\r\t\v\\\"]", escaper
    
-- lua script object notation
toLSON = (o, reconstructable=true, pretty=false, circularCheckTable={}, indent=0) ->
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
                    if pretty
                        ret ..= "\n" .. string.rep(" ", indent+2)
                else
                    ret ..= ", "
                vstr = toLSON v, reconstructable, pretty, circularCheckTable, indent+2
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
                    if pretty
                        ret ..= "\n" .. string.rep(" ", indent+2)
                else
                    ret ..= ", "
                    if pretty
                        ret ..= "\n" .. string.rep(" ", indent+2)
                vstr = toLSON v, reconstructable, pretty, circularCheckTable, indent+2
                kstr = toLSON k, reconstructable, pretty, circularCheckTable, indent+2
                if vstr != nil
                    if reconstructable
                        ret ..= "[#{kstr}] = #{vstr}"
                    else
                        ret ..= "#{kstr} = #{vstr}"
                else
                    ret ..= "[#{kstr}] = nil"
            if pretty
                ret ..= "\n" .. string.rep(" ", indent)
            ret ..= "}"
            ret
        when "string"
            if reconstructable
                "\"#{escapeString o}\""
            else
                "#{o}"
        when "function"
            if reconstructable
                stat, str = pcall(dump, o)
                if stat and str != nil
                    "FUNCTION(\"#{encode(str)}\")"
                else
                    nil
            else
                "#{o}"
        else
            "#{o}"

parseEnv = {}
parseFunction = (s) ->
    load(decode(s))

fromLSON = (str, env=parseEnv) ->
    if isLua52
        oldf = env.FUNCTION
        if env.FUNCTION == nil
            env.FUNCTION = parseFunction
        chunk = load("return function() return (#{str}); end;", str, "t", env)
        if chunk == nil
            return nil
        stat, f = pcall(chunk)
        ret = if stat and type(f) == 'function'
            f()
        else
            nil
        env.FUNCTION = oldf
        ret
    else
        chunk = load("return function() return (#{str}); end;")
        if chunk == nil
            return nil
        stat, f = pcall(chunk)
        if stat and type(f) == 'function'
            oldf = env.FUNCTION
            if env.FUNCTION == nil
                env.FUNCTION = parseFunction
            setfenv(f, env)
            ret = f()
            env.FUNCTION = oldf
            ret
        else
            nil
        


-- pretty print
if @p == nil
    @p = (...) ->
        param = {...}
        arr = {}
        for i, v in ipairs param
            arr[#arr+1] = toLSON(v, false, true)
        print unpack(arr)
        ...


LSON = 
    stringify: (o, t) ->
        {:reconstructable, :pretty} = t or {}
        toLSON(o, reconstructable, pretty)
    parse: (s, t) ->
        {:env} = t or {}
        fromLSON s, env
    p: p


LSON







