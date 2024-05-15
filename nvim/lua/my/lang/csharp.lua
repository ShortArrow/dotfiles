local M = {}

M.neotest = {
  dap = {
    -- Extra arguments for nvim-dap configuration
    -- See https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for values
    args = { justMyCode = false },
    -- Enter the name of your dap adapter, the default value is netcoredbg
    adapter_name = "netcoredbg"
  },
  -- Let the test-discovery know about your custom attributes (otherwise tests will not be picked up)
  -- Note: Only custom attributes for non-parameterized tests should be added here. See the support note about parameterized tests
  custom_attributes = {
    xunit = { "MyCustomFactAttribute" },
    nunit = { "MyCustomTestAttribute" },
    mstest = { "MyCustomTestMethodAttribute" }
  },
  -- Provide any additional "dotnet test" CLI commands here. These will be applied to ALL test runs performed via neotest. These need to be a table of strings, ideally with one key-value pair per item.
  dotnet_additional_args = {
    "--verbosity detailed"
  },
  -- Tell neotest-dotnet to use either solution (requires .sln file) or project (requires .csproj or .fsproj file) as project root
  -- Note: If neovim is opened from the solution root, using the 'project' setting may sometimes find all nested projects, however,
  --       to locate all test projects in the solution more reliably (if a .sln file is present) then 'solution' is better.
  discovery_root = "solution"     -- Default is project
}

return M
