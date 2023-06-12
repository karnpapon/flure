local readline = require("readline")

-- GLOBAL

int_stack = {}
compile_flag = false
compile_words = ""

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

function subtract()
  local top_word = table.remove(int_stack, #int_stack)
  local second_word = table.remove(int_stack, #int_stack)
  local diff = second_word - top_word
  table.insert(int_stack, diff)
  print("diff: " .. tostring(diff))
end

function multiply()
  local top_word = table.remove(int_stack, #int_stack)
  local second_word = table.remove(int_stack, #int_stack)
  local product = top_word * second_word
  table.insert(int_stack, product)
  print("product: " .. tostring(product))
end

function divide()
  local top_word = table.remove(int_stack, #int_stack)
  local second_word = table.remove(int_stack, #int_stack)
  local divisor = second_word / top_word
  table.insert(int_stack, divisor)
  print("divisor: " .. tostring(divisor))
end

function pop()
  local top_word = table.remove(int_stack, #int_stack)
  print("pop: " .. tostring(top_word))
end

function start_compile()
  compile_flag = true
  compile_words = compile_words .. "::::"
end

function compile(input) compile_words = compile_words .. " " .. input end

function end_compile()
  compile_words = compile_words .. " ;;;; "
  compile_flag = false
end

-- eg. :::: test_word_title 12 44 91 +  ;;;; :::: test_another 44 234 rrr + +  ;;;;
-- > run_word("test_word_title")
-- > 12 44 91 +

---@param word string
---@return boolean
function run_word(word)
  local formatted_word = ":::: " .. word .. " "
  local full_definition = ""
  local definition = ""

  local str_len = string.len(formatted_word)
  local word_index_start = str_len

  if word_index_start ~= nil then
    full_definition = string.sub(compile_words, word_index_start + 1)
  end

  local word_index_end = string.find(full_definition, ';')

  if word_index_end then
    definition = string.sub(full_definition, 1, word_index_end - 1)
  end

  print("definition:" .. definition)

  local input_array = {}
  for s in string.gmatch(definition, "[^%s]+") do table.insert(input_array, s) end

  -- print_r(input_array)

  if EVAL(input_array, true) then
    print("ok.")
  else
    print("Error processing compiled word.")
    return false
  end
  return true
end

-- ------------------------------------------------------------------------------------
-- MAIN READ/EVAL/PRINT
-- ------------------------------------------------------------------------------------

---@param str string
---@return table
function READ(str)
  local input_array = {}
  -- "[^%s]+", match all non-empty string between space character.
  for s in string.gmatch(str, "[^%s]+") do table.insert(input_array, s) end
  return input_array
end

---@param input_array table
---@param compiled boolean
---@return boolean
function EVAL(input_array, compiled)
  for i, v in ipairs(input_array) do
    if compile_flag then
      if v == "compiler" then
        print("compile_words: " .. compile_words)
      elseif v == ";" then
        end_compile()
      else
        compile(v)
      end
    else
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
        elseif v == "-" then
          subtract()
        elseif v == "*" then
          multiply()
        elseif v == "/" then
          divide()
        elseif v == "pop" then
          pop()
        elseif v == ":" then
          start_compile()
        elseif v == "compiler" then
          print("compile_words: " .. compile_words)
        elseif v == ";" then
          print("not in compile mode")
        elseif (compile_words:find(":::: " .. v) and compiled) then
          print("exists in dict")
        elseif compile_words:find(":::: " .. v) and not compiled then
          print("exists in dict")
          if run_word(v) then
            break
          else
            print("Error running compiled word.")
          end
        end
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
