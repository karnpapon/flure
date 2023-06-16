local matrix = require "libs.matrix"

local M = {}
M.grid = {}

-- initialize grid pixels (matrix)
function M.init_grid(sz)
  local mat_x = matrix.new(0, sz, sz, 0)
  local mat_y = matrix.new(0, sz, sz, 0)

  for y = 1, sz, 1 do
    for x = 1, sz, 1 do
      mat_y[x][y] = y
      mat_x[x][y] = x
    end
  end

  M.grid["x"] = mat_x
  M.grid["y"] = mat_y
end

return M
