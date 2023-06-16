local L = require('linenoise')
local inspect = require("inspect")
-- local colors = require('term.colors')
local vm = require "core.vm"
local drawer = require 'core.drawer'

local build_mode = false

if #arg > 0 then
  if arg[1] == "--raw" then
    -- readline.raw = true
  elseif arg[1] == "--build" then
    build_mode = true
    vm.build_mode = build_mode
    drawer.init()
    drawer.render(arg[2] or "output_img")
  else
    vm.build_mode = false
  end
end

-- setup prompt
local prompt, history = 'flure> ', 'history.txt'

L.historyload(history)

L.setcompletion(function(completion, str)
  if str == 'a' then
    completion:add('and')
  elseif str == 'b' then
    completion:add('bye')
  elseif str == 'd' then
    completion:add('dup')
  elseif str == 'e' then
    completion:add('else')
  elseif str == 's' then
    completion:add('swap')
  elseif str == 'r' then
    completion:add('rot')
  elseif str == 'p' then
    completion:add('pop')
  elseif str == 't' then
    completion:add('then')
  elseif str == 'i' then
    completion:add('immediate')
    completion:add('if')
  end
end)
L.sethints(function(str)
  -- red = 31
  -- green = 32
  -- yellow = 33
  -- blue = 34
  -- magenta = 35
  -- cyan = 36
  -- white = 37;
  local hint_msg = ""
  if str == 'a' then
    hint_msg = 'nd'
  elseif str == 'b' then
    hint_msg = 'ye'
  elseif str == 'd' then
    hint_msg = 'up'
  elseif str == 'e' then
    hint_msg = 'else'
  elseif str == 's' then
    hint_msg = 'wap'
  elseif str == 'r' then
    hint_msg = 'ot'
  elseif str == 'p' then
    hint_msg = 'op'
  elseif str == 't' then
    hint_msg = 'hen'
  elseif str == 'i' then
    hint_msg = 'mmediate | if '
  end

  if hint_msg ~= "" then return hint_msg, {color = 30, bold = true} end
end)

L.enableutf8()

if not build_mode then
  local line, err = L.linenoise(prompt)
  while line do
    if #line > 0 then
      local return_code = vm.REPL(line)
      if return_code == 1 and vm.compile_flag == false then
        print("ok.")
      elseif return_code == 1 and vm.compile_flag then
        print("compiled.")
      elseif return_code == 0 then
        break
      elseif return_code == 2 then
        print("Due to error, input was not processed.")
      end

      L.historyadd(line)
      L.historysave(history)
    end
    line, err = L.linenoise(prompt)
  end
  if err then print('An error occurred: ' .. err) end
end
