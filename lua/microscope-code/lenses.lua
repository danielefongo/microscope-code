local error = require("microscope.api.error")
local lenses = {}

local function relative_path(filename)
  local path = vim.fn.getcwd():gsub("[%-%.%+%[%]%(%)%$%^%%%?%*]", "%%%1") .. "/"
  return string.gsub(filename, path, "")
end

local function lsp_request(opts)
  local action = opts.action
  local param_builder = opts.params
  local format_elements = opts.format

  return {
    fun = function(flow, request)
      local results = flow.await(function(callback)
        local params = param_builder(request)

        local ok = false
        for _, client in pairs(vim.lsp.get_active_clients()) do
          if client.supports_method(action) then
            ok = true
          end
        end

        if not ok then
          error.critical(string.format("microscope-code: %s not supported", action))
          return callback()
        end

        vim.lsp.buf_request(request.buf, action, params, function(err, result, ctx, _)
          if err then
            error.critical(string.format("microscope-code: %s failed: %s", action, err.message))
            return callback()
          end

          local elements = {}
          if result then
            if not vim.tbl_islist(result) then
              elements = { result }
            else
              elements = result
            end
          end

          local results = format_elements(request, elements, ctx)

          callback(results)
        end)
      end)

      flow.write(results)
    end,
  }
end

local function locations_lens(action)
  return lsp_request({
    action = action,
    params = function(request)
      local params = vim.lsp.util.make_position_params(request.win, "utf-8")
      params.context = { includeDeclaration = true }
      return params
    end,
    format = function(_, elements, ctx)
      local offset_encoding = vim.lsp.get_client_by_id(ctx.client_id).offset_encoding
      local items = vim.lsp.util.locations_to_items(elements, offset_encoding)

      return vim.tbl_map(function(item)
        return string.format("%s:%s:%s: %s", relative_path(item.filename), item.lnum, item.col, item.text)
      end, items)
    end,
  })
end

function lenses.buffer_symbols()
  return lsp_request({
    action = "textDocument/documentSymbol",
    params = function(request)
      return vim.lsp.util.make_position_params(request.win, "utf-8")
    end,
    format = function(request, elements)
      local items = vim.lsp.util.symbols_to_items(elements, request.buf)

      return vim.tbl_map(function(item)
        return string.format("%s:%s: %s", item.lnum, item.col, item.text)
      end, items)
    end,
  })
end

function lenses.workspace_symbols()
  return lsp_request({
    action = "workspace/symbol",
    params = function()
      return { query = "" }
    end,
    format = function(request, elements)
      local items = vim.lsp.util.symbols_to_items(elements, request.buf)

      return vim.tbl_map(function(item)
        return string.format(
          "%s:%s:%s: %s",
          relative_path(item.filename),
          item.lnum,
          item.col,
          item.text:gsub("\n", " ")
        )
      end, items)
    end,
  })
end

function lenses.implementation()
  return locations_lens("textDocument/implementation")
end

function lenses.references()
  return locations_lens("textDocument/references")
end

function lenses.definition()
  return locations_lens("textDocument/definition")
end

function lenses.type_definition()
  return locations_lens("textDocument/typeDefinition")
end

return lenses
