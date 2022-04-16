
return function(client, bufnr)

  if client.name == "sumneko_lua" then
    client.resolved_capabilities.document_formatting = true
  end

end
