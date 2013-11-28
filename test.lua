
LSON = require("lson")

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

-- もどす
local hoge2 = LSON.parse(ls)

-- なんと関数ももどる！すげー
print("fun()", hoge2.fun())



-- この2つはほぼ同じ意味
-- 復元不可能な代わりに出来る限り値を表現しようとする
-- たとえば循環参照やネイティブ関数
-- 人間の目にやさしい・・・という目標がある
p("pretty", hoge)
print("pretty", LSON.stringify(hoge, false))



