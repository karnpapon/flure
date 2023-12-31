-- local inspect = require("inspect")
local interpreter = require "core.vm"
local grid = require "core.grid"
-- local matrix = require "libs.matrix"

local M = {}
local sz = 128

function M.init() grid.init_grid(sz) end

function M.render(file_name)

  local w = sz
  local h = sz

  local file = io.open(tostring(file_name) .. ".pbm", "w")

  file:write("P1\n# " .. file_name .. "\n" .. math.floor(w) .. " " ..
                 math.floor(h) .. "\n")

  for y = 1, w, 1 do
    for x = 1, h, 1 do

      -- [EXAMPLE CODES]: try uncomment to see different results.
      -- local code = "x y ^ 5 % !"
      -- local code = "x y + abs x y - abs 1 + ^ 2 << 5 % !"
      -- local code = "x 2 * y % !"
      -- local code = "x 128 - 64 * y 128 - % !"
      local code = "x y ^ 7 % !"
      local opt = {}
      opt["x"] = x
      opt["y"] = y

      local val = interpreter.EXEC(code, opt)
      file:write(val .. (x == sz and "" or " "))
      file:write(x == sz and "\n" or "")
    end
  end

  file:close()
end

return M
