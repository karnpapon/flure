local lu = require('luaunit')
local vm = require("core.vm")

function test_arithmatic_add()
  local return_code = vm.REPL("10 10 +")
  local res = vm.top_interp_stack()
  lu.assertEquals(return_code, 1)
  lu.assertEquals(res, 20)
end

function test_arithmatic_sub()
  local return_code = vm.REPL("20 10 -")
  local res = vm.top_interp_stack()
  lu.assertEquals(return_code, 1)
  lu.assertEquals(res, 10)
end

function test_arithmatic_mult()
  local return_code = vm.REPL("40 20 *")
  local res = vm.top_interp_stack()
  lu.assertEquals(return_code, 1)
  lu.assertEquals(res, 800)
end

function test_arithmatic_div()
  local return_code = vm.REPL("20 5 /")
  local res = vm.top_interp_stack()
  lu.assertEquals(return_code, 1)
  lu.assertEquals(res, 4)
end

os.exit(lu.LuaUnit.run())
