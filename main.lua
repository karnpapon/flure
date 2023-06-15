local readline = require("readline")
local vm = require "vm"

if #arg > 0 and arg[1] == "--raw" then readline.raw = true end

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
