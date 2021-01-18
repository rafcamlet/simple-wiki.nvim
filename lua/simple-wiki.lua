local _, Path = pcall(require, 'plenary.path')
if not Path then return print('This plugin requires nvim-lua/plenary.nvim to work!') end

local link_scaner = require 'simple-wiki.helpers'.link_scaner
local cword = require 'simple-wiki.helpers'.cword
local get_visual = require 'simple-wiki.helpers'.get_visual

local config = {}

local function setup(opts)
  if not opts.path then return print('You must set path') end
  config.path = Path:new(opts.path)
  config.link_key_mapping = opts.link_key_mapping or '<cr>'
  vim.cmd('augroup SimpleWikiAutogroup')
  vim.cmd('autocmd!')
  vim.cmd(('au BufEnter %s/*.md nnoremap <buffer> %s :lua require"simple-wiki".open_or_create()<cr>'):format(config.path:expand(), config.link_key_mapping))
  vim.cmd(('au BufEnter %s/*.md vnoremap <buffer> %s :<c-u>lua require"simple-wiki".create_link(true)<cr>'):format(config.path:expand(), config.link_key_mapping))
  vim.cmd('augroup END')
end

local function link_to_name(name)
  if name == 'index.md' then return 'index' end
  return name:gsub('_' .. string.rep('%d', 12) .. '.md$', '')
end

local function get_link()
  line = vim.api.nvim_get_current_line()
  local x = vim.api.nvim_win_get_cursor(0)[2] + 1

  for v in link_scaner(line) do
    if x >= v.start and x <= v.finish then return v end
  end
end

local function open()
  local link = get_link()
  if not link then return end

  local current_file = vim.fn.expand('%:t')

  local path = config.path:joinpath(link['link']):expand()
  local is_new = not Path:new(path):exists()

  if is_new then vim.cmd('write') end
  vim.cmd('e ' .. path)
  vim.api.nvim_set_current_dir(config.path:expand())

  if is_new and vim.api.nvim_buf_line_count(0) == 1 then
    vim.api.nvim_buf_set_lines(0, 1, 1, false, {
      '', ("[%s](%s)"):format(link_to_name(current_file), current_file)
    })
  end
end

local function create_link(visual)
  local word

  if visual then
    word = get_visual()
  else
    word = cword()
  end

  if not word then return end

  local line = vim.api.nvim_get_current_line()
  local file_name = word.str:gsub(' ', '_'):lower() .. '_' .. vim.fn.strftime('%d%m%y%H%M%S') .. '.md'

  local str = ("%s[%s](%s)%s"):format(
    line:sub(0, word.start),
    word.str,
    file_name,
    line:sub(word.finish + 1)
  )

  vim.api.nvim_set_current_line(str)
end

local function open_or_create()
  if get_link() then open() else create_link() end
end

local function index()
  vim.cmd('e ' .. config.path:joinpath('index.md'):expand())
  vim.api.nvim_set_current_dir(config.path:expand())
end

local function search()
  local _, Telescope = pcall(require, 'telescope.builtin')
  if not Telescope then return print('This function requires nvim-telescope/telescope.nvim to work!') end
  Telescope.find_files{cwd = config.path:expand()}
end

return {
  index = index,
  setup = setup,
  create_link = create_link,
  open_or_create = open_or_create,
  search = search
}
