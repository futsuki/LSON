# LSON

Lua Script Object Notation

JavascriptのJSON風のインターフェース

LuaJIT2.0.2 と Lua5.2.1 で動作確認しています。動かないLua環境があったら教えて下さい。


## License
Public Domain (unlicense)

## Document
[Reference](./LSON/wiki)


## Example

> test.lua

```lua
LSON = require("lson")

local hoge = {
    1, 2, 3, 4, 5,
    foo = 3,
    bar = 5,
    foobar = 42,
    natfun = table.concat,
    
    str = "abcdefg",
    arr = {5,6,7,8,9},
    fun = function()
        return table.concat({1,2,3,4,"abc",5})
    end
}

-- LSON化
local ls = LSON.stringify(hoge)
print("lson", ls)
-->lson    {1, 2, 3, 4, 5, ["foobar"] = 42, ["foo"] = 3, ["str"] = "abcdefg", ["fun
-- "] = FUNCTION("G0xKAQAJQHRlc3QubHVhPgAAAgADAAQFJQI0AAAANwABADMBAgBAAAIAAQcAAAMBA
-- wIDAwMECGFiYwMFC2NvbmNhdAp0YWJsZQEBAQEAAA=="), ["natfun"] = nil, ["arr"] = {5, 6
-- , 7, 8, 9}, ["bar"] = 5}

-- もどす
local hoge2 = LSON.parse(ls)

-- なんと関数ももどる！すげー
print("fun()", hoge2.fun())
--> fun()   1234abc5



-- reconstructable=false にすると、たとえ再生成不可能になってもデータを表示しようとし、かつエラーを出さない。
--
-- 再生成不可能なもの(カッコ内は reconstructable=false のとき)
-- エラー
--   循環参照(かわりに [circular reference] と表示される)
-- 無視
--   ネイティブ関数(dumpできないのでアドレスが表示される)
--
-- pretty=true にすると、インデントを使った人間の目に優しい風味の文字列が返される。


p("pretty", hoge)
-->pretty  {
--   1, 2, 3, 4, 5,
--   foobar = 42,
--   foo = 3,
--   str = abcdefg,
--   fun = function: 0x00239b18,
--   natfun = function: builtin#98,
--   arr = {
--     5, 6, 7, 8, 9
--   },
--   bar = 5
-- }

-- p(hoge)
-- は、次のコードとほぼ同じ。
-- print(LSON.stringify(hoge, {pretty=true, reconstructable=false}))

-- ただし、p関数の引数をそのまま返すので、値のトレース代わりに挟むことも出来る。
result = p(math.pow(10, 10))
-->10000000000
print(result)
-->10000000000
```
