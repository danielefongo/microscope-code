local error = require("microscope.api.error")
local lenses = {}

local function relative_path(filename)
  return string.gsub(filename, vim.fn.getcwd() .. "/", "")
end

local function lsp_request_list(action)
  return {
    fun = function(flow, request)
      local results = flow.await(function(callback)
        local params = vim.lsp.util.make_position_params(request.win, "utf-8")
        params.context = { includeDeclaration = true }

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

          local locations = {}
          if result then
            if not vim.tbl_islist(result) then
              locations = { result }
            else
              locations = result
            end
          end

          local offset_encoding = vim.lsp.get_client_by_id(ctx.client_id).offset_encoding
          local items = vim.lsp.util.locations_to_items(locations, offset_encoding)

          local results = {}
          for _, value in pairs(items) do
            table.insert(
              results,
              string.format("%s:%s:%s: %s", relative_path(value.filename), value.lnum, value.col, value.text)
            )
          end

          callback(results)
        end)
      end)

      flow.write(results)
    end,
  }
end

function lenses.implementation()
  return lsp_request_list("textDocument/implementation")
end

function lenses.references()
  return lsp_request_list("textDocument/references")
end

function lenses.definition()
  return lsp_request_list("textDocument/definition")
end

function lenses.type_definition()
  return lsp_request_list("textDocument/typeDefinition")
end

return lenses
