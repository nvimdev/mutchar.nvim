local api = vim.api
local util = require('dyninput.util')
local rs = {}

function rs.single_colon(opt)
  local line = api.nvim_get_current_line()
  if line:find('%s*use$%s*') then
    return false
  end
  local curnode = util.ts_cursor_node(opt)
  local parent = util.ts_parent_node_type(opt)
  if
    (parent == 'let_declaration' and curnode and curnode:type() == 'identifier')
    or parent == 'parameters'
  then
    return true
  end
  local scope = util.ts_blank_node_parent(opt.buf)
  if scope == 'struct_item' or scope == 'struct_expression' then
    return true
  end
end

function rs.double_colon(opt)
  local line = api.nvim_buf_get_text(opt.buf, opt.lnum - 1, 0, opt.lnum - 1, opt.col, {})[1]
  local part = vim.split(line, '%s')
  local word = part[#part]

  local list = { 'Option', 'String', 'std', 'super', 'Vec' }
  for _, item in ipairs(list) do
    if word == item or word:sub(#word - #item + 1, #word) == item then
      return true
    end
  end

  if util.ts_parent_node_type(opt) == 'generic_function' then
    return true
  end

  local type = { 'enum', 'namespace', 'type' }
  --match module/enum
  if util.ts_hl_match(type, word, opt) then
    return true
  end
end

function rs.thin_arrow()
  local line = api.nvim_get_current_line()
  if line:find('^%s*[pub%s*]*fn') then
    return true
  end
end

function rs.closure_fn(opt)
  local curnode = util.ts_cursor_node(opt)
  if curnode and curnode:type() == 'arguments' then
    return true
  end
end

function rs.fat_arrow(opt)
  local type = util.ts_blank_node_parent(opt.buf)
  if type ~= 'match_block' and type ~= 'match_expression' and type ~= 'ERROR' then
    return
  end
  return true
end

return rs