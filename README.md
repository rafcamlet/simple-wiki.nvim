![simple wiki example](/gifs/example.gif)

## Requirements

- neovim v0.5-dev - nightly build
- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) (optional)


## Instalation

With vim-plug:

```
Plug "nvim-lua/plenary.nvim"
Plug "rafcamlet/simple-wiki.nvim"
```

## Configuration

```lua
require 'simple-wiki'.setup {
  path = '~/my_wiki', -- your wiki directory - must be set
  link_key_mapping = '<cr>' -- open or create note form link - default: <cr>
}
```

## Usage

```lua
require "simple-wiki".index() -- open wiki index file
require "simple-wiki".search() -- open Telescope in wiki directory - requires telescope.nvim
require "simple-wiki".open_or_create() -- Open or create link from current word
require "simple-wiki".create_link() -- create link from current word
require "simple-wiki".create_link(true) -- create link from visual selection
```

`open_or_create` and `create_link(true)` are automatically mapped to `link_key_mapping` for files under wiki directory.

-----

#### Warning: Under development - configuration and api may change in the future
