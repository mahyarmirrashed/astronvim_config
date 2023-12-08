return {
  settings = {
    python = {
      pythonPath = vim.env.CONDA_PREFIX and vim.env.CONDA_PREFIX .. "/bin/python",
    },
  },
}
