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


---------------------------------------------
----- BASE64 --------------------------------
---------------------------------------------

import rshift, lshift, bor, band from bit32 or bit
import byte, char from string
import concat from table
import floor from math


ENCODE_TABLE = {
	'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J',
	'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T',
	'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd',
	'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n',
	'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x',
	'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7',
	'8', '9', '+', '/', '='
}
DECODE_TABLE = {
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
    -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 62, -1, -1, -1,
    63, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, -1, -1, -1, -1, -1,
    -1, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,
    16, 17, 18, 19, 20, 21, 22, 23, 24, 25, -1, -1, -1, -1, -1, -1,
    26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41,
    42, 43, 44, 45, 46, 47, 48, 49, 50, 51, -1, -1, -1, -1, -1, -1
}

CHAR_TABLE = {}
for i=0, 255
    CHAR_TABLE[i+1] = char(i)


encode3bytes = (s, start) ->
    b1, b2, b3 = byte(s, start, start+2)
    c1 = rshift(b1, 2)
    c2 = bor(lshift(band(b1, 3), 4), rshift(b2, 4))
    c3 = bor(lshift(band(b2,15), 2), rshift(b3, 6))
    c4 = band(b3, 63)
    ENCODE_TABLE[c1+1], ENCODE_TABLE[c2+1], ENCODE_TABLE[c3+1], ENCODE_TABLE[c4+1]

encode3bytesTail = (s, start) ->
    b1, b2, b3 = byte(s, start, start+2)
    local c1, c2, c3, c4
    if b1
        c1 = rshift(b1, 2)
        c2 = bor(lshift(band(b1, 3), 4), rshift(b2 or 0, 4))
        if b2
            c3 = bor(lshift(band(b2,15), 2), rshift(b3 or 0, 6))
            if b3
                c4 = band(b3, 63)
            else
                c4 = 64
        else
            c3, c4 = 64, 64
    else
        c1, c2, c3, c4 = 64, 64, 64, 64
    ENCODE_TABLE[c1+1], ENCODE_TABLE[c2+1], ENCODE_TABLE[c3+1], ENCODE_TABLE[c4+1]


decode4bytes = (s, start) ->
    c1, c2, c3, c4 = byte(s, start, start+3)
    c1, c2, c3, c4 = DECODE_TABLE[c1], DECODE_TABLE[c2], DECODE_TABLE[c3], DECODE_TABLE[c4]
    b1 = bor(lshift(band(c1, 63), 2), rshift(c2, 4))
    b2 = bor(lshift(band(c2, 15), 4), rshift(c3, 2))
    b3 = bor(lshift(band(c3, 3), 6), c4)
    CHAR_TABLE[b1+1], CHAR_TABLE[b2+1], CHAR_TABLE[b3+1]

decode4bytesTail = (s, start) ->
    c1, c2, c3, c4 = byte(s, start, start+3)
    c1, c2, c3, c4 = DECODE_TABLE[c1], DECODE_TABLE[c2], DECODE_TABLE[c3], DECODE_TABLE[c4]
    if c1 == -1 then c1 = nil
    if c2 == -1 then c2 = nil
    if c3 == -1 then c3 = nil
    if c4 == -1 then c4 = nil
    local b1, b2, b3
    if c1 and c2
        b1 = bor(lshift(band(c1, 63), 2), rshift(c2, 4))
    if c2 and c3
        b2 = bor(lshift(band(c2, 15), 4), rshift(c3, 2))
    if c3 and c4
        b3 = bor(lshift(band(c3, 3), 6), c4)
    if b1 and b2 and b3
        CHAR_TABLE[b1+1], CHAR_TABLE[b2+1], CHAR_TABLE[b3+1]
    else if b1 and b2
        CHAR_TABLE[b1+1], CHAR_TABLE[b2+1]
    else if b1
        CHAR_TABLE[b1+1]
    else
        ""


base64enc = (bytes) ->
    t = {}
    len = floor(#bytes / 3) * 3
    for i=1, len, 3
        lt = #t
        t[lt+1], t[lt+2], t[lt+3], t[lt+4] = encode3bytes(bytes, i)
    if len < #bytes
        lt = #t
        t[lt+1], t[lt+2], t[lt+3], t[lt+4] = encode3bytesTail(bytes, len+1)
    concat(t)

base64dec = (str) ->
    t = {}
    len = floor((#str-1) / 4) * 4
    for i=1, len, 4
        lt = #t
        t[lt+1], t[lt+2], t[lt+3] = decode4bytes(str, i)
    lt = #t
    t[lt+1], t[lt+2], t[lt+3] = decode4bytesTail(str, len+1)
    concat(t)



---------------------------------------------
----- LSON ----------------------------------
---------------------------------------------

import load, type, ipairs, pairs, pcall, print, getmetatable, setmetatable from @
import byte, sub, dump, gsub from string

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
                if vstr == nil
                    vstr = "nil"
                if reconstructable
                    ret ..= "[#{kstr}] = #{vstr}"
                else
                    ret ..= "#{kstr} = #{vstr}"
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
                    "FUNCTION(\"#{base64enc(str)}\")"
                else
                    nil
            else
                "#{o}"
        else
            "#{o}"

parseEnv = {}
parseFunction = (s) ->
    load(base64dec(s))

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
    base64encode: base64enc
    base64decode: base64dec



LSON







