local self = _ENV or getfenv()
local rshift, lshift, bor, band
do
  local _obj_0 = bit32 or bit
  rshift, lshift, bor, band = _obj_0.rshift, _obj_0.lshift, _obj_0.bor, _obj_0.band
end
local byte, char
do
  local _obj_0 = string
  byte, char = _obj_0.byte, _obj_0.char
end
local concat
do
  local _obj_0 = table
  concat = _obj_0.concat
end
local floor
do
  local _obj_0 = math
  floor = _obj_0.floor
end
local ENCODE_TABLE = {
  'A',
  'B',
  'C',
  'D',
  'E',
  'F',
  'G',
  'H',
  'I',
  'J',
  'K',
  'L',
  'M',
  'N',
  'O',
  'P',
  'Q',
  'R',
  'S',
  'T',
  'U',
  'V',
  'W',
  'X',
  'Y',
  'Z',
  'a',
  'b',
  'c',
  'd',
  'e',
  'f',
  'g',
  'h',
  'i',
  'j',
  'k',
  'l',
  'm',
  'n',
  'o',
  'p',
  'q',
  'r',
  's',
  't',
  'u',
  'v',
  'w',
  'x',
  'y',
  'z',
  '0',
  '1',
  '2',
  '3',
  '4',
  '5',
  '6',
  '7',
  '8',
  '9',
  '+',
  '/',
  '='
}
local DECODE_TABLE = {
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  62,
  -1,
  -1,
  -1,
  63,
  52,
  53,
  54,
  55,
  56,
  57,
  58,
  59,
  60,
  61,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  0,
  1,
  2,
  3,
  4,
  5,
  6,
  7,
  8,
  9,
  10,
  11,
  12,
  13,
  14,
  15,
  16,
  17,
  18,
  19,
  20,
  21,
  22,
  23,
  24,
  25,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1,
  26,
  27,
  28,
  29,
  30,
  31,
  32,
  33,
  34,
  35,
  36,
  37,
  38,
  39,
  40,
  41,
  42,
  43,
  44,
  45,
  46,
  47,
  48,
  49,
  50,
  51,
  -1,
  -1,
  -1,
  -1,
  -1,
  -1
}
local CHAR_TABLE = { }
for i = 0, 255 do
  CHAR_TABLE[i + 1] = char(i)
end
local encode3bytes
encode3bytes = function(s, start)
  local b1, b2, b3 = byte(s, start, start + 2)
  local c1 = rshift(b1, 2)
  local c2 = bor(lshift(band(b1, 3), 4), rshift(b2, 4))
  local c3 = bor(lshift(band(b2, 15), 2), rshift(b3, 6))
  local c4 = band(b3, 63)
  return ENCODE_TABLE[c1 + 1], ENCODE_TABLE[c2 + 1], ENCODE_TABLE[c3 + 1], ENCODE_TABLE[c4 + 1]
end
local encode3bytesTail
encode3bytesTail = function(s, start)
  local b1, b2, b3 = byte(s, start, start + 2)
  local c1, c2, c3, c4
  if b1 then
    c1 = rshift(b1, 2)
    c2 = bor(lshift(band(b1, 3), 4), rshift(b2 or 0, 4))
    if b2 then
      c3 = bor(lshift(band(b2, 15), 2), rshift(b3 or 0, 6))
      if b3 then
        c4 = band(b3, 63)
      else
        c4 = 64
      end
    else
      c3, c4 = 64, 64
    end
  else
    c1, c2, c3, c4 = 64, 64, 64, 64
  end
  return ENCODE_TABLE[c1 + 1], ENCODE_TABLE[c2 + 1], ENCODE_TABLE[c3 + 1], ENCODE_TABLE[c4 + 1]
end
local decode4bytes
decode4bytes = function(s, start)
  local c1, c2, c3, c4 = byte(s, start, start + 4)
  c1, c2, c3, c4 = DECODE_TABLE[c1], DECODE_TABLE[c2], DECODE_TABLE[c3], DECODE_TABLE[c4]
  local b1 = bor(lshift(band(c1, 63), 2), rshift(c2, 4))
  local b2 = bor(lshift(band(c2, 15), 4), rshift(c3, 2))
  local b3 = bor(lshift(band(c3, 3), 6), c4)
  return CHAR_TABLE[b1 + 1], CHAR_TABLE[b2 + 1], CHAR_TABLE[b3 + 1]
end
local decode4bytesTail
decode4bytesTail = function(s, start)
  local c1, c2, c3, c4 = byte(s, start, start + 4)
  c1, c2, c3, c4 = DECODE_TABLE[c1], DECODE_TABLE[c2], DECODE_TABLE[c3], DECODE_TABLE[c4]
  if c1 == -1 then
    c1 = nil
  end
  if c2 == -1 then
    c2 = nil
  end
  if c3 == -1 then
    c3 = nil
  end
  if c4 == -1 then
    c4 = nil
  end
  local b1, b2, b3
  if c1 and c2 then
    b1 = bor(lshift(band(c1, 63), 2), rshift(c2, 4))
  end
  if c2 and c3 then
    b2 = bor(lshift(band(c2, 15), 4), rshift(c3, 2))
  end
  if c3 and c4 then
    b3 = bor(lshift(band(c3, 3), 6), c4)
  end
  if b1 and b2 and b3 then
    return CHAR_TABLE[b1 + 1], CHAR_TABLE[b2 + 1], CHAR_TABLE[b3 + 1]
  else
    if b1 and b2 then
      return CHAR_TABLE[b1 + 1], CHAR_TABLE[b2 + 1]
    else
      if b1 then
        return CHAR_TABLE[b1 + 1]
      else
        return ""
      end
    end
  end
end
local base64enc
base64enc = function(bytes)
  local t = { }
  local len = floor(#bytes / 3) * 3
  for i = 1, len, 3 do
    local lt = #t
    t[lt + 1], t[lt + 2], t[lt + 3], t[lt + 4] = encode3bytes(bytes, i)
  end
  if len < #bytes then
    local lt = #t
    t[lt + 1], t[lt + 2], t[lt + 3], t[lt + 4] = encode3bytesTail(bytes, len + 1)
  end
  return concat(t)
end
local base64dec
base64dec = function(str)
  local t = { }
  local len = floor((#str - 1) / 4) * 4
  for i = 1, len, 4 do
    local lt = #t
    t[lt + 1], t[lt + 2], t[lt + 3] = decode4bytes(str, i)
  end
  local lt = #t
  t[lt + 1], t[lt + 2], t[lt + 3] = decode4bytesTail(str, len + 1)
  return concat(t)
end
local base64 = {
  encode = base64enc,
  decode = base64dec
}
return base64
