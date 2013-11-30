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
-- "] = FUNCTION("G0xKAQAJQHRlc3QubHVhFQAAAQAAAAIDCwInAAoASAACAAEBAAA="), ["arr"] =
--  {5, 6, 7, 8, 9}, ["bar"] = 5}

-- もどす
local hoge2 = LSON.parse(ls)

-- なんと関数ももどる！すげー
print("fun()", hoge2.fun())
--> fun()   10



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
--   fun = function: 0x00238bd0,
--   arr = {
--     5, 6, 7, 8, 9
--   },
--   bar = 5
-- }

-- p関数は、下のコードと等価。
-- print(LSON.stringify(hoge, {pretty=true, reconstructable=false}))

-- p関数の返値は引数自身なので、値のトレース代わりに挟むことも出来る。



