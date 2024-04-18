local files = require("microscope-files")
local lenses = require("microscope.builtin.lenses")
local code_lenses = require("microscope-code.lenses")
local parsers = require("microscope.builtin.parsers")
local files_parsers = require("microscope-files.parsers")

return {
  code_implementations = {
    lens = lenses.fzf(lenses.cache(code_lenses.implementation())),
    parsers = { files_parsers.file_row_col, parsers.fuzzy },
    open = files.open,
    preview = files.preview.cat,
  },
  code_references = {
    lens = lenses.fzf(lenses.cache(code_lenses.references())),
    parsers = { files_parsers.file_row_col, parsers.fuzzy },
    open = files.open,
    preview = files.preview.cat,
  },
  code_definitions = {
    lens = lenses.fzf(lenses.cache(code_lenses.definition())),
    parsers = { files_parsers.file_row_col, parsers.fuzzy },
    open = files.open,
    preview = files.preview.cat,
  },
  code_type_definition = {
    lens = lenses.fzf(lenses.cache(code_lenses.type_definition())),
    parsers = { files_parsers.file_row_col, parsers.fuzzy },
    open = files.open,
    preview = files.preview.cat,
  },
  code_workspace_symbols = {
    lens = lenses.head(lenses.fzf(lenses.cache(code_lenses.workspace_symbols()))),
    parsers = { files_parsers.file_row_col, parsers.fuzzy },
    open = files.open,
    preview = files.preview.cat,
    args = { limit = 100 },
  },
  code_buffer_symbols = {
    lens = lenses.head(lenses.fzf(lenses.cache(code_lenses.buffer_symbols()))),
    parsers = { files_parsers.row_col, parsers.fuzzy },
    open = files.open,
    preview = files.preview.cat,
    args = { limit = 100 },
  },
}
