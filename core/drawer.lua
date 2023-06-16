local inspect = require("inspect")
local interpreter = require "core.vm"
local grid = require "core.grid"
-- local matrix = require "libs.matrix"

local M = {}
local sz = 128

function M.init() grid.init_grid(sz) end

function M.render(file_name)

  local file = io.open(tostring(file_name) .. ".pbm", "w")

  file:write("P1\n# " .. file_name .. "\n" .. sz .. " " .. sz .. "\n")

  for y = 1, sz, 1 do
    for x = 1, sz, 1 do
      -- local code = "x y ^ 5 % !"
      local code = "x y + abs x y - abs 1 + ^ 2 << 5 % !"
      local opt = {}
      opt["x"] = x
      opt["y"] = y

      local val = interpreter.EXEC(code, opt)
      file:write(val)
      file:write(x == sz and "\n" or "")
    end
  end

  file:close()
end

return M
