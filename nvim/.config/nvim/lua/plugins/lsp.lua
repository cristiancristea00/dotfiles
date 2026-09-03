--[[===========================================================================
  plugins/lsp.lua — language server activation and LSP keymaps
  ============================================================================

  The config uses Neovim's native LSP client (:h lsp):

    * nvim-lspconfig contributes default configs (cmd, filetypes, root
      markers) for each server as lsp/*.lua files on the runtimepath.
    * This config's after/lsp/*.lua files are merged on top of those defaults
      (:h lsp-config-merge). The after/ prefix is required: plain lsp/ files
      from every runtimepath entry merge at the same tier, where the plugin's
      copy wins by load order, while after/lsp/ is the tier for user
      overrides. clangd, sourcekit, ty, ruff, and yamlls have overrides;
      other servers run on nvim-lspconfig's defaults.
    * vim.lsp.enable() below activates the servers named in lua/languages.lua;
      each attaches to buffers of its filetypes when a matching root is found.

  Troubleshooting: :checkhealth vim.lsp (attached clients, log path) and
  :lua =vim.lsp.get_clients().

  ── BUILT-IN LSP KEYMAPS (Neovim 0.11 or later, no config needed) ─────────
    K     hover documentation            grn   rename symbol
    grr   references (quickfix)          gra   code action
    gri   go to implementation           grt   go to type definition
    gO    document symbols outline       <C-s> signature help (insert mode)
    ]d/[d next/prev diagnostic           <C-w>d diagnostic float
    ]D/[D last/first diagnostic          grx   run code lens
  Fuzzy variants of several of these are on <leader>f* (plugins/fzf.lua).
===========================================================================]]--

-- WHAT: Enable every server named in the language table, once each.
-- WHY : Servers are declared only in the table, so this is the single call
--       site; the `seen` set skips a server that two entries share.
local servers, seen = {}, {}
for _, lang in ipairs(require("languages")) do
    for _, server in ipairs(lang.servers or {}) do
        if not seen[server] then
            seen[server] = true
            table.insert(servers, server)
        end
    end
end
vim.lsp.enable(servers)

-- WHAT: Buffer-local keymaps, created whenever a server attaches.
-- WHY : The maps exist only in buffers with a server, so `gd` keeps its
--       default meaning elsewhere.
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("cfg_lsp_attach", { clear = true }),
    desc = "Buffer-local LSP keymaps",
    callback = function(ev)
        local function bufmap(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, desc = desc })
        end

        -- WHAT: Jump to definition (gd) and declaration (gD).
        -- WHY : Neovim 0.11 maps neither; only <C-]> through tagfunc reaches
        --       the definition. The gD map is for C and Objective-C, where the
        --       declaration is the header prototype.
        bufmap("n", "gd", vim.lsp.buf.definition, "Go to definition")
        bufmap("n", "gD", vim.lsp.buf.declaration, "Go to declaration")

        -- WHAT: Toggle inlay hints (inline parameter names, inferred types) for
        --       servers that provide them (rust-analyzer, clangd, ty).
        -- WHY : A toggle rather than always on: hints help when reading
        --       unfamiliar code and take space when writing.
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if client and client:supports_method("textDocument/inlayHint") then
            bufmap("n", "<leader>ti", function()
                local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf })
                vim.lsp.inlay_hint.enable(not enabled, { bufnr = ev.buf })
            end, "Toggle inlay hints")
        end

        -- WHAT: The clangd header/source switch, its one custom LSP command.
        -- WHY : The command is registered by nvim-lspconfig, which maps no key
        --       to it.
        if client and client.name == "clangd" then
            bufmap("n", "<leader>ch", "<cmd>LspClangdSwitchSourceHeader<CR>", "Switch source/header")
        end
    end,
})
