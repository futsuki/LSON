# LSON

Lua Script Object Notation

JavascriptのJSON風のインターフェース

LuaJIT2.0.2 と Lua5.2.1 で動作確認しています。動かないLua環境があったら教えて下さい。


## License
Public Domain (unlicense)


## Example

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
```

***

## Function Reference
### LSON.stringify()
擬似関数型
* `string stringify(object v, table option={pretty=false, reconstructable=true})`

`v` はLuaの値ならば何でも受け付けます。これが文字列化して返されます。

`option` には追加の属性テーブルを渡します。指定できる属性は以下のとおりです。
* `pretty` --- `true`にした場合、字下げを行って見やすくします。デフォルトは`false`。
* `reconstructable` --- 動作の詳細は下に書いてあります。デフォルトは`true`。

#### `reconstructable=true` を指定した場合の動作
* 循環参照があるとエラーを出します。
* ネイティブ関数を`nil`扱いします。（それがテーブルの値だった場合、値とキーもまとめて無視されるでしょう）

#### `reconstructable=false` を指定した場合の動作
* 循環参照が出現してもエラーを出さずに、循環参照であることを示す文字列を出力します。
* ネイティブ関数を無視せずにとりあえず識別用のアドレスだけでも表示します。

### LSON.parse()
擬似関数型
* `object parse(string lsonstr)`

`lsonstr`には`stringify()`によって作られたLSON文字列を渡します。これが解釈されてオブジェクトになって返されます。


