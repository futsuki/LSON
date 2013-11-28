LSON
====

Lua Script Object Notation

Javascript��JSON���̃C���^�[�t�F�[�X

LuaJIT2.0.2 �� Lua5.2.1 �œ���m�F���Ă��܂��B���ɂ��Ή������ق����悳������Lua�����������狳���ĉ������B

License
-------
PUBLIC DOMAIN


## Example

> test.lua

```lua
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

-- LSON��
local ls = LSON.stringify(hoge)
print("lson", ls)
--> lson    {1, 2, 3, 4, 5, ["foobar"] = 42, ["foo"] = 3, ["str"] = "abcdefg",
--   ["fun"] = FUNCTION("G0xKAQAJQHRlc3QubHVhFQAAAQAAAAIDCwInAAoASAACAAEBAAA="),
--   ["arr"] = {5, 6, 7, 8, 9}, ["bar"] = 5}

-- ���ǂ�
local hoge2 = LSON.parse(ls)

-- �Ȃ�Ɗ֐������ǂ�I�����[
print("fun()", hoge2.fun())
--> fun()   10


-- ����2�͂قړ����Ӗ�
-- �����s�\�ȑ���ɏo�������l���킩��₷���\�����悤�Ƃ���E�E�E���Ԃ�
p("pretty", hoge)
print("pretty", LSON.stringify(hoge, false))
--> pretty  {1, 2, 3, 4, 5, foobar = 42, foo = 3, str = abcdefg,
--  fun = function: 0x003df8a0, arr = {5, 6, 7, 8, 9}, bar = 5}

```
