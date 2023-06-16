local inspect = require("inspect")
local interpreter = require "core.vm"
local matrix = require "libs.matrix"

local M = {}
local drawer_vm = {}
local drawer_state = {}

function M.init_vm() drawer_vm = {stk = {}, reg = {}, stkpos = -1, err = 0} end

function M.init_state(size)
  drawer_state = {bytes = {}, sz = size, len = 0}
  for i = 1, drawer_state.sz, 1 do drawer_state.bytes[i] = 0 end
end

function regset(i, val) drawer_vm.reg[i] = val end

function M.render(file_name)
  local sz = 128 * 2

  M.init_vm()
  M.init_state(sz)

  local file = io.open(tostring(file_name) .. ".pbm", "w")

  file:write(
      "P1\n# test image\n" .. drawer_state.sz .. " " .. drawer_state.sz .. "\n")

  local mat_x = matrix.new(0, sz, sz, 0)
  local mat_y = matrix.new(0, sz, sz, 0)

  for y = 1, drawer_state.sz, 1 do
    for x = 1, drawer_state.sz, 1 do
      mat_y[x][y] = y
      mat_x[x][y] = x

      -- "x y + abs x y - abs 1 + ^ 2 << 7 % !"
      -- local code =
      --     tostring(mat_x[x][y]) .. " " .. tostring(mat_y[x][y]) .. " " ..
      --         "+ abs " .. tostring(mat_x[x][y]) .. " " .. tostring(mat_y[x][y]) ..
      --         " " .. "- abs 2 + ^ 2 << 5 % !"

      local code =
          tostring(mat_x[x][y]) .. " " .. tostring(mat_y[x][y]) .. " " .. "^" ..
              " " .. "5 % !"

      local val = interpreter.exec(code)
      file:write(val)
      file:write(x == drawer_state.sz and "\n" or "")
    end
  end

  -- matrix.print(matrix.add(mat_x, mat_y))
  -- matrix.print(mat_x)
  -- print("\n")
  -- matrix.print(mat_y)

  file:close()
end

return M
