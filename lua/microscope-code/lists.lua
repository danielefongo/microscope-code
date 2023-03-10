local lists = {}

local function relative_path(filename)
  return string.gsub(filename, vim.fn.getcwd() .. "/", "")
end

local function parser(data)
  local elements = vim.split(data.text, ":", {})

  return {
    text = data.text,
    file = elements[1],
    row = tonumber(elements[2]),
    col = tonumber(elements[3]),
  }
end

local function lsp_request_list(win, buf, action)
  return {
    fun = function(on_data)
      local params = vim.lsp.util.make_position_params(win, "utf-8")
      params.context = { includeDeclaration = true }

      vim.lsp.buf_request(buf, action, params, function(err, result, ctx, _)
        if err then
          vim.api.nvim_err_writeln(string.format("microscope-code: %s failed: %s", action, err.message))
          return
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
          vim.pretty_print(value)
          table.insert(
            results,
            string.format("%s:%s:%s: %s", relative_path(value.filename), value.lnum, value.col, value.text)
          )
        end

        on_data(results)
      end)
    end,
    parser = parser,
  }
end

function lists.implementation(win, buf)
  return lsp_request_list(win, buf, "textDocument/implementation")
end

function lists.references(win, buf)
  return lsp_request_list(win, buf, "textDocument/references")
end

function lists.definition(win, buf)
  return lsp_request_list(win, buf, "textDocument/definition")
end

function lists.type_definition(win, buf)
  return lsp_request_list(win, buf, "textDocument/typeDefinition")
end

return lists
