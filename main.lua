local readline = require("readline")

int_stack = {}

-- ------------------------------------------------------------------------------------
-- UTILS
-- ------------------------------------------------------------------------------------

-- taken from: https://stackoverflow.com/a/13398936
function print_r(arr, indentLevel)
  local str = ""
  local indentStr = "#"

  if (indentLevel == nil) then
    print(print_r(arr, 0))
    return
  end

  for i = 0, indentLevel do indentStr = indentStr .. "\t" end

  -- handle nested table (compound type)
  for index, value in pairs(arr) do
    if type(value) == "table" then
      str = str .. indentStr .. index .. ": \n" ..
                print_r(value, (indentLevel + 1))
    else
      -- otherwise, just print scalar type
      str = str .. indentStr .. index .. ": " .. value .. "\n"
    end
  end
  return str
end

function add()
  local top_word = table.remove(int_stack, #int_stack)
  local second_word = table.remove(int_stack, #int_stack)
  local sum = top_word + second_word
  table.insert(int_stack, sum)
  print("add: " .. tostring(sum))
end
-- ------------------------------------------------------------------------------------
-- MAIN READ/EVAL/PRINT
-- ------------------------------------------------------------------------------------

-- "[^%s]+", match all non-empty string between space character.
function READ(str)
  local input_array = {}
  for s in string.gmatch(str, "[^%s]+") do table.insert(input_array, s) end
  return input_array
end

function EVAL(input_array)
  for i, v in ipairs(input_array) do
    if tonumber(v) ~= nil then
      table.insert(int_stack, tonumber(v))
    else
      if v == "show" then
        print_r(int_stack)
      elseif v == "bye" then
        print("bye!")
        return false
      elseif v == "+" then
        add()
      end
    end
  end
  return true
end

function PRINT() print_r(int_stack) end

local function rep(str)
  local read = READ(str)
  return EVAL(read)
  -- PRINT()
end

if #arg > 0 and arg[1] == "--raw" then readline.raw = true end

while true do
  local line = readline.readline("user>")
  if not line then break end
  local res = rep(line)
  if res == false then break end
end
