local files = require("microscope-files")
local lists = require("microscope.lists")
local code_lists = require("microscope-code.lists")

return {
  code_implementations = {
    open = files.open,
    preview = files.preview.cat,
    chain = function(text, win, buf)
      return { code_lists.implementation(win, buf), lists.fzf(text) }
    end,
  },
  code_references = {
    open = files.open,
    preview = files.preview.cat,
    chain = function(text, win, buf)
      return { code_lists.references(win, buf), lists.fzf(text) }
    end,
  },
  code_definitions = {
    open = files.open,
    preview = files.preview.cat,
    chain = function(text, win, buf)
      return { code_lists.definition(win, buf), lists.fzf(text) }
    end,
  },
  code_type_definition = {
    open = files.open,
    preview = files.preview.cat,
    chain = function(text, win, buf)
      return { code_lists.type_definition(win, buf), lists.fzf(text) }
    end,
  },
}
