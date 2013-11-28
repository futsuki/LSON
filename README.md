Lson
====

Lua script object notation

License
-------

インターフェースはJavascriptのJSON風

これらは PUBLIC DOMAIN
* test.lua
* lson.moon
* lson.lua
* base64.moon
* base64.lua


## Example

> test.lua

```lua
require("lson")

local hoge = {
    1, 2, 3, 4, 5,
    foo = 3,
    bar = 5,
    foobar = 42,
    str = "abcdefg",
    arr = {5,6,7,8,9},
    fun = function()
        return 10
    end
}

-- LSON化
local ls = LSON.stringify(hoge)
print("lson", ls)
--> lson    {1, 2, 3, 4, 5, ["foobar"] = 42, ["foo"] = 3, ["str"] = "abcdefg",
--   ["fun"] = FUNCTION("G0xKAQAJQHRlc3QubHVhFQAAAQAAAAIDCwInAAoASAACAAEBAAA="),
--   ["arr"] = {5, 6, 7, 8, 9}, ["bar"] = 5}

-- もどす
local hoge2 = LSON.parse(ls)

-- なんと関数ももどる！すげー
print("fun()", hoge2.fun())
--> fun()   10


-- この2つはほぼ同じ意味
-- 復元不可能な代わりに出来る限り値をわかりやすく表現しようとする・・・たぶん
p("pretty", hoge)
print("pretty", LSON.stringify(hoge, false))
--> pretty  {1, 2, 3, 4, 5, foobar = 42, foo = 3, str = abcdefg,
--  fun = function: 0x003df8a0, arr = {5, 6, 7, 8, 9}, bar = 5}

```
