# `flure`

[Forth](https://www.forth.com/forth/)-like interpreter, written in [lua](https://www.lua.org/).

## run
- `lua main.lua`

## usages
- `flure` is stack-based interpreter thus it use reverse polish notation ([RPN](https://mathworld.wolfram.com/ReversePolishNotation.html)) eg `10 10 +` = `20`
- support basic arithmatics `+`, `-`, `*`, `/`
- support function declaration `: <function_name> <...args> ;` eg. `: loop 1 - dup 0 = if else loop then ;`
- compile mode = `:`, terminate compile mode = `;`
- support basic control flow `<condition> if <if_case> else <else_case> then ;`
- to exit = `bye`
- show stack = `show`
- remove top stack (last item pushed to stack) = `pop`
- comments = `( <...any_comments_here> )`
- `immediately` call a function = eg. `: bob 20 20 + ; immediate`, will return `40` without calling `bob` function.
- basic ops (`-1` = `true`, `0` = `false`) [see example](./example)
  - `= (equal)`
  - `<> (not_equal)`
  - `and`
  - `or`
  - `> (greater_than)`
  - `< (less_than)`
  - `dup (duplicate)`
  - `swap`
  - `2dup (double duplicates)`
  - `rot (rotate)`



## resources
- https://beza1e1.tuxen.de/articles/forth.html
- https://www.youtube.com/watch?v=gPk-e9vGSWU&list=PLGY0au-SczlkeccjBFsLIE_BKp_sRfEdb&ab_channel=CodeandCrux
- https://github.com/nornagon/jonesforth/blob/master/jonesforth.S