-- ------------------------------------------------------------------------------------
-- GLOBAL
-- ------------------------------------------------------------------------------------
M = {}
int_stack = {}
control_flow_stack = {}
int_stack_idx = 1
M.compile_flag = false
comment_flag = false
compile_words = ""
word_prefix = "::::"
word_suffix = ";;;;"

-- ------------------------------------------------------------------------------------
-- EXTENDS STANDARD LIBRARY
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

  -- for i = 0, indentLevel do indentStr = indentStr end

  -- handle nested table (compound type)
  for index, value in pairs(arr) do
    if type(value) == "table" then
      str = str .. indentStr .. index .. ": \n" ..
                print_r(value, (indentLevel + 1))
    else
      -- otherwise, just print scalar type
      str = str .. tostring(value) .. (index < #arr and ", " or "")
    end
  end
  return "[ " .. str .. " ]"
end

function get_entry_from_end(table, entry)
  local count = (table and #table or false)
  if (count) then return table[count - entry]; end
  return false;
end

-- ------------------------------------------------------------------------------------
-- STACK OPS
-- ------------------------------------------------------------------------------------

function push(val)
  int_stack_idx = int_stack_idx + 1
  table.insert(int_stack, val)
end

function pop()
  local top_word = table.remove(int_stack, #int_stack)
  return top_word
end
function pop_unmut()
  int_stack_idx = int_stack_idx - 1
  return int_stack[int_stack_idx]
end

-- ------------------------------------------------------------------------------------
-- BASIC ARITHIMATIC
-- ------------------------------------------------------------------------------------

function add()
  local top_word = table.remove(int_stack, #int_stack)
  local second_word = table.remove(int_stack, #int_stack)
  local sum = top_word + second_word
  push(sum)
  -- print("add: " .. tostring(sum))
end

function subtract()
  local top_word = table.remove(int_stack, #int_stack)
  local second_word = table.remove(int_stack, #int_stack)
  local diff = second_word - top_word
  push(diff)
  -- print("sub: " .. tostring(diff))
end

function multiply()
  local top_word = table.remove(int_stack, #int_stack)
  local second_word = table.remove(int_stack, #int_stack)
  local product = top_word * second_word
  push(product)
  -- print("product: " .. tostring(product))
end

function divide()
  local top_word = table.remove(int_stack, #int_stack)
  local second_word = table.remove(int_stack, #int_stack)
  local divisor = second_word / top_word
  push(divisor)
  -- print("divisor: " .. tostring(divisor))
end

-- ------------------------------------------------------------------------------------
-- RUNNER
-- ------------------------------------------------------------------------------------

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

function start_comment() comment_flag = true end

function end_comment() comment_flag = false end

-- ------------------------------------------------------------------------------------
-- OPS
--  0 = false
-- -1 = true
-- ------------------------------------------------------------------------------------

-- num: 128 num: 129 num: 128 num: 129 num: 129 num: 130 num: 135

function op_num(num)
  -- num = num & 0x7f;
  -- print("OPop_num--------------: " .. tostring(num))
  push(num)
end

function op_equal()
  local top_word = table.remove(int_stack, #int_stack)
  local second_word = table.remove(int_stack, #int_stack)
  if top_word == second_word then
    push(-1)
  else
    push(0)
  end
end

function op_not_equal()
  local top_word = table.remove(int_stack, #int_stack)
  local second_word = table.remove(int_stack, #int_stack)
  if top_word ~= second_word then
    push(-1)
  else
    push(0)
  end
end

function op_and()
  local top_word = table.remove(int_stack, #int_stack)
  local second_word = table.remove(int_stack, #int_stack)
  if top_word == second_word then
    push(-1)
  else
    push(0)
  end
end

function op_or()
  local top_word = table.remove(int_stack, #int_stack)
  local second_word = table.remove(int_stack, #int_stack)
  if top_word == -1 or second_word == -1 then
    push(-1)
  else
    push(0)
  end
end

function op_greater_than()
  local top_word = table.remove(int_stack, #int_stack)
  local second_word = table.remove(int_stack, #int_stack)
  if second_word > top_word then
    push(-1)
  else
    push(0)
  end
end

function op_less_than()
  local top_word = table.remove(int_stack, #int_stack)
  local second_word = table.remove(int_stack, #int_stack)
  if second_word < top_word then
    push(-1)
  else
    push(0)
  end
end

function op_dup()
  local top_word = table.remove(int_stack, #int_stack)
  push(top_word)
  push(top_word)
end

function op_swap()
  local top_word = table.remove(int_stack, #int_stack)
  local second_word = table.remove(int_stack, #int_stack)
  push(top_word)
  push(second_word)
end

function op_two_dup()
  local top_word = table.remove(int_stack, #int_stack)
  local second_word = table.remove(int_stack, #int_stack)
  push(second_word)
  push(top_word)
  push(second_word)
  push(top_word)
end

function op_rot()
  local top_word = table.remove(int_stack, #int_stack)
  local second_word = table.remove(int_stack, #int_stack)
  local third_word = table.remove(int_stack, #int_stack)
  push(second_word)
  push(top_word)
  push(third_word)
end

function op_abs()
  local top_word = table.remove(int_stack, #int_stack)
  if not tonumber(top_word) then
    print("Error: abs should be number")
    return
  end
  push(math.abs(top_word))
end

function op_lnot()
  local top_word = table.remove(int_stack, #int_stack)
  push(top_word == 0 and 0 or 1)
end

function op_mod()
  local top_word = table.remove(int_stack, #int_stack)
  local second_word = table.remove(int_stack, #int_stack)
  push(top_word == 0 and 0 or second_word % top_word)
end

function op_bit_xor()
  local top_word = table.remove(int_stack, #int_stack)
  local second_word = table.remove(int_stack, #int_stack)
  push(second_word ~ top_word)
end

function op_bit_lshift()
  local top_word = table.remove(int_stack, #int_stack)
  local second_word = table.remove(int_stack, #int_stack)
  push(second_word << top_word)
end

function op_special_x() op_num(0) end

function op_special_y() op_num(1) end

function op_special_get()
  -- local top_word = table.remove(int_stack, #int_stack)
  -- if (top_word < 0 or top_word >= 8) then return 1; end -- TODO
  -- rc = op_push(vm, vm->reg[rp]);
  -- table.insert(int_stack)
end

-- EXAMPLE : loop 1 - dup 0 = if else loop then ;
-- EXAMPLE : bob 0 if 0 if 10 else 30 then else 40 then ;

-- non-zero = true
function op_if_if()
  local condition_bool
  local current_nest_is_readable

  if #control_flow_stack > 0 then
    local x = control_flow_stack[#control_flow_stack]
    if x ~= nil then
      current_nest_is_readable = x
    else
      print("Error with control flow stack value checking on IF.")
      return
    end

    if current_nest_is_readable then
      if #int_stack > 0 then
        local condition_value = table.remove(int_stack, #int_stack)
        if condition_value > -1 then
          condition_bool = false
        else
          condition_bool = true
        end
      else
        print("No value on integer stack. Using value of current nest.")
        condition_bool = current_nest_is_readable
      end
    else
      condition_bool = false
    end
  else
    if #int_stack > 0 then
      local condition_value = table.remove(int_stack, #int_stack)
      if condition_value > -1 then
        condition_bool = false
      else
        condition_bool = true
      end
    else
      print("No value on integer stack. Assuming -1 (TRUE).")
      condition_bool = true
    end
  end
  table.insert(control_flow_stack, condition_bool)
end

function op_if_else()
  -- print("else")
  local current_nest_is_readable
  local parent_nest_is_readable
  if #control_flow_stack > 0 then
    local x = control_flow_stack[#control_flow_stack]
    if x ~= nil then
      current_nest_is_readable = x
      if current_nest_is_readable then
        if x == true then
          table.remove(control_flow_stack, #control_flow_stack)
          table.insert(control_flow_stack, false)
        else
          table.remove(control_flow_stack, #control_flow_stack)
          table.insert(control_flow_stack, true)
        end
      else
        if #control_flow_stack > 1 then
          local second_to_last = #control_flow_stack - 1
          if control_flow_stack[second_to_last] == true then
            parent_nest_is_readable = true
          else
            parent_nest_is_readable = false
          end

          if parent_nest_is_readable == true then
            table.remove(control_flow_stack, #control_flow_stack)
            table.insert(control_flow_stack, true)
          else

          end
        else
          table.remove(control_flow_stack, #control_flow_stack)
          table.insert(control_flow_stack, true)
        end
      end
    else
      print("Error: unable to read last value on control flow stack")
      return
    end
  else
    print("Error: no value on control flow stack. ELSE should preceded by IF.")
  end
end

function op_if_then()
  if #control_flow_stack > 0 then
    table.remove(control_flow_stack, #control_flow_stack)
  else
    print(
        "Error: control flow stack is empty, THEN should be preceded by IF or ELSE.")
  end
end

-- ------------------------------------------------------------------------------------
-- MAIN READ/EVAL
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
  local current_nest_is_readable = true

  for i, v in ipairs(input_array) do
    local x = control_flow_stack[#control_flow_stack]
    if x ~= nil then current_nest_is_readable = x end

    if current_nest_is_readable == true then
      -- main eval
      if compile_flag and not comment_flag then
        if v == "compiler" then
          print("compile_words: " .. compile_words)
        elseif v == ";" then
          end_compile()
        elseif v == ":" then
          print("Already in compile mode. Ignoring (:) operator.")
        elseif v == "(" then
          start_comment()
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
      elseif compile_flag and comment_flag then
        if v == ")" then end_comment() end
      else
        if tonumber(v) ~= nil then
          op_num(tonumber(v))
        else
          if v == "show" then
            print_r(int_stack)
          elseif v == "bye" then
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
          elseif v == "=" then
            op_equal()
          elseif v == "<>" then
            op_not_equal()
          elseif v == "and" then
            op_and()
          elseif v == "or" then
            op_or()
          elseif v == ">" then
            op_greater_than()
          elseif v == "<" then
            op_less_than()
          elseif v == "dup" then
            op_dup()
          elseif v == "swap" then
            op_swap()
          elseif v == "2dup" then
            op_two_dup()
          elseif v == "rot" then
            op_rot()
          elseif v == "abs" then
            op_abs()
          elseif v == "!" then
            op_lnot()
          elseif v == "%" then
            op_mod()
          elseif v == "^" then
            op_bit_xor()
          elseif v == "<<" then
            op_bit_lshift()
          elseif v == "x" then
            op_special_x()
            op_special_get()
          elseif v == "y" then
            op_special_y()
            op_special_get()
          elseif v == "if" then
            op_if_if()
          elseif v == "else" then
            op_if_else()
          elseif v == "then" then
            op_if_then()
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
            local run_word_return_code = run_word(v)
            if run_word_return_code == 0 then
              return 0
            elseif run_word_return_code == 1 then
            elseif run_word_return_code == 2 then
              print("Error running compiled word.")
              return 2
            else
              print("Error running compiled word.")
              return 2
            end
          elseif compile_words:find(word_prefix .. " " .. v) and v ~= "" and
              not compiled then
            local run_word_return_code = run_word(v)
            if run_word_return_code == 0 then
              return 0
            elseif run_word_return_code == 1 then
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
    else
      if comment_flag == false then
        if v == "if" then
          op_if_if()
        elseif v == "else" then
          op_if_else()
        elseif v == "then" then
          op_if_then()
        elseif v == "bye" then
          return 0
        elseif v == "show" then
          print_r(int_stack)
        end
      end
    end

  end
  return 1
end

function PRINT() print_r(int_stack) end

function M.REPL(str)
  local read = READ(str)
  return EVAL(read)
end

function M.exec(line)
  local return_code = M.REPL(line)
  if return_code == 1 and M.compile_flag == false then
    -- print("ok.")
    return pop(int_stack)
  elseif return_code == 1 and M.compile_flag then
    print("compiled.")
  elseif return_code == 0 then
  elseif return_code == 2 then
    print("Due to error, input was not processed.")
  end
end

-- function M.exe_draw(st)
--   local pos = 0;
--   local sz;
--   local bytes;

--   sz = st.sz;
--   bytes = st.bytes;

--   while (pos < sz) do
--     -- 
--   end
-- end

return M
