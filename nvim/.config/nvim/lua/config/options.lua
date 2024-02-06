-- treat zsh files as shell scripts
vim.filetype.add({
  extension = {
    zsh = "sh",
    sh = "sh",
  },
  filename = {
    [".zshenv"] = "sh",
    [".zshrc"] = "sh",
  },
})
