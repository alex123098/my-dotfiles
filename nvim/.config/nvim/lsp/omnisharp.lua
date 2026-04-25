return {
  handlers = {
    ["textDocument/definition"] = function(...)
      return require("omnisharp_extended").handler(...)
    end,
  },
  enable_roslyn_analyzers = true,
  organize_imports_on_format = true,
  enable_import_completion = true,
  enable_decompilation_support = true,
}
