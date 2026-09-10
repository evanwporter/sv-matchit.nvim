-- TODO: injected languages for markdown
-- TODO: many many more language definitions

local success, err = pcall(require, 'blink.lib')
if not success then
  error('blink.pairs v0.6+ requires blink.lib ("saghen/blink.lib") installed via your package manager: ' .. err)
end
if vim.fn.has('nvim-0.12') == 0 then error('blink.lib v0.6+ requires nvim 0.12+, consider pinning to v0.5') end

local logger = require('blink.pairs.logger')
local native = require('blink.lib.native.managed').new({
  module_name = 'blink.pairs',
  library_name = 'blink_pairs_parser',
  current_file_path = debug.getinfo(1, 'S').source:sub(2),
  logger = logger,
})

local pairs = {}

--- @param user_config blink.pairs.Config
function pairs.setup(user_config)
  local config = require('blink.pairs.config')
  config(user_config)

  if not pairs.library_available() then
    return logger:notify(vim.log.levels.ERROR, {
      { 'v0.6+ uses a new build/download system for the native library. Please add ' },
      { " build = function() require('blink.pairs').build():pwait(60000) end ", 'DiagnosticVirtualTextInfo' },
      { ' OR ' },
      { " build = function() require('blink.pairs').download():pwait(60000) end ", 'DiagnosticVirtualTextInfo' },
      { ' to your lazy.nvim config. For vim.pack, simply call either function before calling setup().' },
    })
  end

  if config.mappings.enabled then require('blink.pairs.mappings').enable() end
  if config.highlights.enabled then require('blink.pairs.highlight').register(config.highlights) end

  -- Set up % mapping for jumping to matching delimiters
  vim.keymap.set({ 'n', 'x', 'o' }, '%', function()
    pairs.jump_to_match()
  end, { noremap = true, silent = true, desc = 'Jump to matching delimiter' })
end

function pairs.library_available() return native:library_available() end

--- Builds the precompiled library if it's not already available
--- @param opts? { force?: boolean, dev?: boolean }
--- @return blink.lib.Task
function pairs.build(opts)
  return native:build(
    { 'cargo', 'build', '--release' },
    function(repo_root, platform)
      return {
        repo_root .. '/target/release/libblink_pairs_parser' .. platform.lib_extension,
        repo_root .. '/target/release/blink_pairs_parser' .. platform.lib_extension,
      }
    end,
    opts
  )
end

--- Downloads the precompiled library if it's not already available
--- @param opts? { force?: boolean, dev?: boolean }
--- @return blink.lib.Task
function pairs.download(opts)
  return native:download(
    function(git_tag, platform)
      return 'https://github.com/saghen/blink.pairs/releases/download/'
        .. git_tag
        .. '/'
        .. platform.triple
        .. platform.lib_extension
    end,
    opts
  )
end

-- Get match at a given position in a buffer
function pairs.get_match_at(bufnr, row, col)
  local ok, blink_pairs = pcall(require, 'blink_pairs')
  if not ok or not blink_pairs.get_match_at then return nil end

  return blink_pairs.get_match_at(bufnr, row, col)
end

-- Jump to matching delimiter with %
function pairs.jump_to_match()
  local rust = require('sv-matchit.rust')
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row, col = cursor[1] - 1, cursor[2]

  local match_pair = rust.get_match_pair(bufnr, row, col)
  if not match_pair or #match_pair < 2 then return end

  -- Determine which match we're on and jump to the other
  local current_match = match_pair[1]
  local target_match = match_pair[2]

  -- If cursor is closer to second match, swap them
  if current_match.line > row or (current_match.line == row and current_match.col > col) then
    current_match, target_match = target_match, current_match
  end

  -- Jump to target (convert from 0-indexed to 1-indexed)
  vim.api.nvim_win_set_cursor(0, { target_match.line + 1, target_match.col })
end

return pairs
