local function msub(line, s, f)
  return line:sub(s, f) .. vim.fn.strcharpart(line:sub(f + 1), 0, 1)
end

local function link_scaner(line)
  local pos = 1
  return function()
    while true do
      local start, finish = line:find('%[[^%[%]]-%]%([^%(%)]-%)', pos)
      if not start then break end
      pos = finish + 1

      str = line:sub(start, finish)

      return {
        str = str,
        name = str:match('%[(.-)%]'),
        link = str:match('%((.-)%)'),
        start = start,
        finish = finish
      }
    end
  end
end

-- based on https://github.com/notomo/curstr.nvim/blob/fa35837da5412d1a216bd832f827464d7ac7f0aa/lua/curstr/core/cursor.lua#L20
local function cword()
  local pos = vim.api.nvim_win_get_cursor(0)
  local line = vim.api.nvim_get_current_line()
  local pattern = ("\\v\\k*%%%sc\\k+"):format(pos[2] + 1)
  local str, start_byte = unpack(vim.fn.matchstrpos(line, pattern))
  if start_byte == -1 then return end
  local after_part = vim.fn.strpart(line, start_byte)
  local start = #line - #after_part
  local finish = start + #str
  return {
    str = str,
    start = start,
    finish = finish
  }
end

local function get_visual()
  local s = vim.fn.getpos("'<")
  local f = vim.fn.getpos("'>")
  assert(s[2] == f[2], "Can't make multiline links")
  local str = msub(vim.api.nvim_get_current_line(), s[3], f[3] - 1)
  local start = s[3] - 1
  local finish = start + str:len()

  return {
    str = str,
    start = start,
    finish = finish
  }
end

return {
  msub = msub,
  link_scaner = link_scaner,
  cword = cword,
  get_visual = get_visual
}
