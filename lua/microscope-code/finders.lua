local files = require("microscope-files")
local steps = require("microscope.steps")
local code_steps = require("microscope-code.steps")

return {
  code_implementations = {
    open = files.open,
    preview = files.preview.cat,
    chain = function(text, win, buf)
      return { code_steps.implementation(win, buf), steps.fzf(text) }
    end,
  },
  code_references = {
    open = files.open,
    preview = files.preview.cat,
    chain = function(text, win, buf)
      return { code_steps.references(win, buf), steps.fzf(text) }
    end,
  },
  code_definitions = {
    open = files.open,
    preview = files.preview.cat,
    chain = function(text, win, buf)
      return { code_steps.definition(win, buf), steps.fzf(text) }
    end,
  },
  code_type_definition = {
    open = files.open,
    preview = files.preview.cat,
    chain = function(text, win, buf)
      return { code_steps.type_definition(win, buf), steps.fzf(text) }
    end,
  },
}
