local readline = require("readline")
local inspect = require("inspect")
local vm = require "core.vm"
local drawer = require 'core.drawer'

local build_mode = false

if #arg > 0 then
  if arg[1] == "--raw" then
    readline.raw = true
  elseif arg[1] == "--build" then
    build_mode = true
    drawer.render(arg[2] or "output_img")
  end
end

if not build_mode then
  while true do
    local line = readline.readline("user> ")
    if not line then break end
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
  end
end
