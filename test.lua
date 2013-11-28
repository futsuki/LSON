
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

-- ���ǂ�
local hoge2 = LSON.parse(ls)

-- �Ȃ�Ɗ֐������ǂ�I�����[
print("fun()", hoge2.fun())



-- ����2�͂قړ����Ӗ�
-- �����s�\�ȑ���ɏo�������l��\�����悤�Ƃ���
-- ���Ƃ��Ώz�Q�Ƃ�l�C�e�B�u�֐�
-- �l�Ԃ̖ڂɂ₳�����E�E�E�Ƃ����ڕW������
p("pretty", hoge)
print("pretty", LSON.stringify(hoge, false))



