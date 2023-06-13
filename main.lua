local readline = require("readline")

-- GLOBAL
int_stack = {}
compile_flag = false
compile_words = ""
word_prefix = "::::"
word_suffix = ";;;;"

-- ------------------------------------------------------------------------------------
-- UTILS
-- ------------------------------------------------------------------------------------

-- plain string replace, extending Lua string standard library.
function string:replace(substring, replacement, n)
  return (self:gsub(substring:gsub("%p", "%%%0"),
                    replacement:gsub("%%", "%%%%"), n))
end

function string:last_index_of(target)
  local i = self:match(".*" .. target .. "()")
  if i == nil then
    return nil
  else
    return i - 1
  end
end

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
  -- print("pop: " .. tostring(top_word))
end

function start_compile()
  compile_flag = true
  compile_words = compile_words .. word_prefix
end

function compile(input) compile_words = compile_words .. " " .. input end

function end_compile()
  compile_words = compile_words .. " " .. word_suffix .. " "
  compile_flag = false
end

-- eg. :::: test_word_title 12 44 91 +  ;;;; :::: test_another 44 234 rrr + +  ;;;;
-- > run_word("test_word_title")
-- > 12 44 91 +

---@param word string
---@return integer
function run_word(word)
  local formatted_word = word_prefix .. " " .. word .. " "
  local full_definition = ""
  local definition = ""

  local start_index, end_index = string.find(compile_words, formatted_word)

  if end_index ~= nil then
    full_definition = string.sub(compile_words, end_index + 1)
  end

  local full_def_start, full_def_end = string.find(full_definition, ';')

  if full_def_end then
    definition = string.sub(full_definition, 1, full_def_end - 1)
  end

  local input_array = {}
  for s in string.gmatch(definition, "[^%s]+") do table.insert(input_array, s) end

  local return_code_rw = EVAL(input_array, true)

  if return_code_rw == 1 then
    return 1
  elseif return_code_rw == 2 then
    print("Error processing compiled word.")
    return 2
  elseif return_code_rw == 0 then
    print("Compiled were contains 'bye'. Ending flure.")
    return 0
  else
    print("Error processing compiled word.")
    return 2
  end
end

---@param word string
function clear_compile_word(word)
  local formatted_word = word_prefix .. " " .. word .. " "
  local full_definition = ""
  local definition = ""
  local to_delete = ""

  local start_index, end_index = string.find(compile_words, formatted_word)

  if end_index ~= nil then
    print("redefined " .. word .. ".")
    full_definition = string.sub(compile_words, end_index + 1)

    local full_def_start, full_def_end = string.find(full_definition, ';')

    if full_def_end then
      definition = string.sub(full_definition, 1, full_def_end - 1)
    end

    to_delete = formatted_word .. definition .. word_suffix .. " "
    local new_compiled_words = string.replace(compile_words, to_delete, "")
    compile_words = new_compiled_words
  end
end

-- :::: bob 20 20 + ;;;; :::: alice 1 1 + ;;;; :::: joe 4 5 + ;;;;
function last_compiled_word()
  local full_definition = ""
  local definition = ""
  local word_name_string = ""

  local word_index = compile_words:last_index_of("%:")

  if word_index then
    full_definition = string.sub(compile_words, word_index)

    local _, full_def_index_end = string.find(full_definition, "%: ")

    if full_def_index_end then
      definition = string.sub(full_definition, full_def_index_end + 1)
      local definition_array = {}
      for s in string.gmatch(definition, "[^%s]+") do
        table.insert(definition_array, s)
      end
      word_name_string = definition_array[1]
    end
  end

  return word_name_string
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
---@return integer
function EVAL(input_array, compiled)
  for i, v in ipairs(input_array) do
    if compile_flag then
      if v == "compiler" then
        print("compile_words: " .. compile_words)
      elseif v == ";" then
        end_compile()
      elseif v == ":" then
        print("Already in compile mode. Ignoring (:) operator.")
      else
        if input_array[i - 1] == ":" then
          if tonumber(v) ~= nil then
            print("Error: word name cannot be an integer.")
            compile_flag = false
            compile_words = compile_words:sub(0, -(#word_prefix + 1))
            return 2
          else
            clear_compile_word(v)
            compile(v)
          end
        else
          compile(v)
        end
      end
    else
      if tonumber(v) ~= nil then
        table.insert(int_stack, tonumber(v))
      else
        if v == "show" then
          print_r(int_stack)
        elseif v == "bye" then
          print("bye!")
          return 0
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
        elseif v == "immediate" then
          local word_to_run = last_compiled_word()
          local run_word_return_code = run_word(word_to_run)
          if run_word_return_code == 0 then
            return 0
          elseif run_word_return_code == 1 then
            return 1
          elseif run_word_return_code == 2 then
            print("Error running compiled word.")
            return 2
          else
            print("Error running compiled word.")
            return 2
          end
        elseif v == "compiler" then
          print("compile_words: " .. compile_words)
        elseif v == ";" then
          print("not in compile mode")
        elseif (compile_words:find(word_prefix .. " " .. v) and v ~= "" and
            compiled) then
          print("exists in dict")
        elseif compile_words:find(word_prefix .. " " .. v) and v ~= "" and
            not compiled then
          local run_word_return_code = run_word(v)
          if run_word_return_code == 0 then
            return 0
          elseif run_word_return_code == 1 then
            return 1
          elseif run_word_return_code == 2 then
            print("Error running compiled word.")
            return 2
          else
            print("Error running compiled word.")
            return 2
          end
        elseif v == "" then
        else
          print("no matching word in dictionaty for: " .. v)
        end
      end
    end
  end
  return 1
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
  local return_code = rep(line)
  if return_code == 1 and compile_flag == false then
    print("ok.")
  elseif return_code == 1 and compile_flag then
    print("compiled.")
  elseif return_code == 0 then
    break
  elseif return_code == 2 then
    print("Due to error, input was not processed.")
  end

end
