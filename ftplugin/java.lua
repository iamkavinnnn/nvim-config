-- ~/.config/nvim/ftplugin/java.lua
local home = os.getenv 'HOME'
local jdtls = require 'jdtls'

-- Find the root of the project
local root_markers = { '.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle' }
local root_dir = require('jdtls.setup').find_root(root_markers)
if root_dir == '' then
  return
end

-- Project specific settings
local project_name = vim.fn.fnamemodify(root_dir, ':p:h:t')
local workspace_dir = home .. '/.cache/jdtls/workspace/' .. project_name

-- Locate the jdtls installation
local mason_registry = require 'mason-registry'
local jdtls_path
if mason_registry.is_installed 'jdtls' then
  jdtls_path = mason_registry.get_package('jdtls'):get_install_path()
else
  vim.notify('jdtls is not installed', vim.log.levels.ERROR)
  return
end

-- Find the launcher jar (the file pattern might differ based on your installation)
local launcher_jar = vim.fn.glob(jdtls_path .. '/plugins/org.eclipse.equinox.launcher_*.jar')
if launcher_jar == '' then
  vim.notify('Could not find launcher jar', vim.log.levels.ERROR)
  return
end

-- Setup configuration
local config_dir
if vim.fn.has 'mac' == 1 then
  config_dir = jdtls_path .. '/config_mac'
elseif vim.fn.has 'unix' == 1 then
  config_dir = jdtls_path .. '/config_linux'
elseif vim.fn.has 'win32' == 1 then
  config_dir = jdtls_path .. '/config_win'
end

-- Setup the jdtls command properly
local config = {
  cmd = {
    'java',
    '-Declipse.application=org.eclipse.jdt.ls.core.id1',
    '-Dosgi.bundles.defaultStartLevel=4',
    '-Declipse.product=org.eclipse.jdt.ls.core.product',
    '-Dlog.protocol=true',
    '-Dlog.level=ALL',
    '-Xmx1g',
    '--add-modules=ALL-SYSTEM',
    '--add-opens',
    'java.base/java.util=ALL-UNNAMED',
    '--add-opens',
    'java.base/java.lang=ALL-UNNAMED',
    '-jar',
    launcher_jar,
    '-configuration',
    config_dir,
    '-data',
    workspace_dir,
  },

  root_dir = root_dir,

  -- Here you can configure eclipse.jdt.ls specific settings
  settings = {
    java = {
      home = os.getenv 'JAVA_HOME',
      eclipse = {
        downloadSources = true,
      },
      configuration = {
        updateBuildConfiguration = 'interactive',
      },
      maven = {
        downloadSources = true,
      },
      implementationsCodeLens = {
        enabled = true,
      },
      referencesCodeLens = {
        enabled = true,
      },
      format = {
        enabled = true,
      },
    },
    signatureHelp = { enabled = true },
    completion = {
      favoriteStaticMembers = {
        'org.hamcrest.MatcherAssert.assertThat',
        'org.hamcrest.Matchers.*',
        'org.junit.Assert.*',
        'org.junit.Assume.*',
        'org.junit.jupiter.api.Assertions.*',
        'org.junit.jupiter.api.Assumptions.*',
        'org.junit.jupiter.api.DynamicContainer.*',
        'org.junit.jupiter.api.DynamicTest.*',
        'java.util.Objects.requireNonNull',
        'java.util.Objects.requireNonNullElse',
        'org.mockito.Mockito.*',
      },
    },
    contentProvider = { preferred = 'fernflower' },
    extendedClientCapabilities = jdtls.extendedClientCapabilities,
  },

  -- Language server capabilities
  capabilities = require('cmp_nvim_lsp').default_capabilities(),

  -- Attach any additional commands or keybindings
  on_attach = function(client, bufnr)
    -- Your on_attach function here
    -- Example keybinding
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { buffer = bufnr })
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = bufnr })
    -- Add more keybindings as needed
  end,
}

-- Start the language server
jdtls.start_or_attach(config)

-- Ignore and comment out code below if needed

-- -- ~/.config/nvim/ftplugin/java.lua
-- local jdtls_ok, jdtls = pcall(require, 'jdtls')
-- if not jdtls_ok then
--   vim.notify 'JDTLS not found, install with `:LspInstall jdtls`'
--   return
-- end
--
-- -- Find root directory
-- local root_markers = { 'gradlew', '.git', 'mvnw', 'pom.xml', 'build.gradle' }
-- local root_dir = require('jdtls.setup').find_root(root_markers)
--
-- -- Installation path
-- local home = os.getenv 'HOME'
-- local install_path = home .. '/.local/share/nvim/mason/packages/jdtls'
-- local launcher_jar = vim.fn.glob(install_path .. '/plugins/org.eclipse.equinox.launcher_*.jar')
--
-- -- Project name for workspace
-- local project_name = vim.fn.fnamemodify(root_dir, ':p:h:t')
-- local workspace_dir = home .. '/.cache/jdtls/workspace/' .. project_name
--
-- -- Basic config
-- local config = {
--   cmd = {
--     'java',
--     '-Declipse.application=org.eclipse.jdt.ls.core.id1',
--     '-Dosgi.bundles.defaultStartLevel=4',
--     '-Declipse.product=org.eclipse.jdt.ls.core.product',
--     '-Dlog.protocol=true',
--     '-Dlog.level=ALL',
--     '-Xms1g',
--     '--add-modules=ALL-SYSTEM',
--     '--add-opens',
--     'java.base/java.util=ALL-UNNAMED',
--     '--add-opens',
--     'java.base/java.lang=ALL-UNNAMED',
--     '-jar',
--     launcher_jar,
--     '-configuration',
--     install_path .. '/config_' .. (os.getenv 'OS' and 'win' or 'linux'),
--     '-data',
--     workspace_dir,
--   },
--   root_dir = root_dir,
-- }
--
-- -- Start the language server
-- jdtls.start_or_attach(config)
