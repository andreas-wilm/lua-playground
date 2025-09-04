# A naive implementation of Conway's Game of Life

Just for learning Lua. For the real stuff, check out hashlife implementations and Golly

## Goals

- Interactive: clicking toggles state 
- With camera but no periodic boundary (confusing to look at)
- Color support
  - At startup the cells are assigned colors randomly
  - Newly-created cells take the most common color of neighbouring cells
  - When cells die, they leave a shaded version of their original color
- REL import
- Support for start and stop
- Support for setting time
- Cell aging: Use a color gradient to represent the age of cells, with older cells having a different color or texture.

```lua
cells[][] = color -- >0 alive
age[][] = int -- generation; -1 for time since death
```




