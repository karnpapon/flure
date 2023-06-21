# `flure`

a small stack-based language for creating procedural binary graphic (1-bit). run in [FORTH](https://www.forth.com/forth/)-like interpreter, written in [lua](https://www.lua.org/), hence the name `flure` (FORTH-like lua).

## prerequisites
- install lua packages by `sh ./requirements_install.sh`, makesure [`luarocks`](https://luarocks.org/) is already installed. 

## run
- `lua main.lua` for REPL mode.
- `lua main.lua --build <OPTIONAL_FILE_NAME>`, to output 1-bit graphic image.

## example codes
- `x y ^ 5 % !` will compute an image as [`.pbm`](https://oceancolor.gsfc.nasa.gov/staff/norman/seawifs_image_cookbook/faux_shuttle/pbm.html) file. the procedurals are
  - start from `x` xor `y` 
  - then modulo by `5` 
  - and convert to `1` or `0` by `!` 
  - the process will be computed in matrix's manner(current size is `128px`*`128px`, these number can be substituted by `w`, `h`).
  - you can try copy `x y ^ 5 % !` to [the playground](https://flure-lang.netlify.app) to see the result.
  - <details><summary>or click here to show the result image ( based-on <a href="https://twitter.com/aemkei/status/1378106731386040322">Martin Kleppe's post</a>)</summary><img alt="00" src="example_img.png"></details>

## usages
- `flure` use reverse polish notation ([RPN](https://mathworld.wolfram.com/ReversePolishNotation.html)) eg `10 10 +` = `20`
- `x` and `y` correspond to x,y coordinates
- `w` and `h` = `128`(px), `128`(px), eg. `x w 2 / - w 4 / * y w 2 / - % !` [try on flure's playground](https://flure-lang.netlify.app/)
- [operators] arithmatics = `+`, `-`, `*`, `/`, `%`, `abs`(make absolute number)
- [operators] bitwise = `&`, `|`, `^`, `<<`, `>>`
- [operators] stack = `pop`, `push`, `show`
- [operators] core = (`-1` = `true`, `0` = `false`) [see example](./docs/example.md)
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
- function declaration (or `word` in `FORTH`'s term) `: <function_name> <...args> ;` eg. `: loop 1 - dup 0 = if else loop then ;`
- compile mode = `:`, delimited compile mode = `;`
- basic control flow `<condition> if <if_case> else <else_case> then ;`
- comments = `( <...any_comments_here> )`
- `immediate`ly call a function = eg. `: bob 20 20 + ; immediate`, will return `40` without calling `bob` function.
- to exit = `bye`

## resources
- https://beza1e1.tuxen.de/articles/forth.html
- https://www.youtube.com/watch?v=gPk-e9vGSWU&list=PLGY0au-SczlkeccjBFsLIE_BKp_sRfEdb&ab_channel=CodeandCrux
- https://github.com/nornagon/jonesforth/blob/master/jonesforth.S