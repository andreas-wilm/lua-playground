# Personal Lua playground

## Tools

### REPL

#### [Croissant](https://github.com/giann/croissant)


#### [luaprompt](https://github.com/dpapavas/luaprompt)

Installed via `luarocks install --local luaprompt HISTORY_DIR=/usr/local/Cellar/readline/8.3.1/`. `luap` fails with undefined symbol in `prompt.so`

#### Jupyter

Using xeus-lua in a separate conda env

## Gotchas

`Lua considers both zero and the empty string as true in conditional tests` ([src](https://www.lua.org/pil/contents.html)

`The .. is the string concatenation operator in Lua. When you write it right after a numeral, you must separate them with a space; otherwise, Lua thinks that the first dot is a decimal point.` ([src](https://www.lua.org/pil/contents.html)

`The basic Lua library provides ipairs, a handy function that allows you to iterate over the elements of an array, following the convention that the array ends at its first nil element.` ([src](https://www.lua.org/pil/contents.html)

