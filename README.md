# SV Matchit

`%` matching for SystemVerilog block keywords in Neovim.

For example with the cursor on module:

```systemverilog
module foo;
    logic a;
endmodule
```

Clicking % will jump to the matching `endmodule` keyword.

## Install

Build the native library in the repository before starting Neovim:

```sh
cargo build --release
```

The plugin loads the resulting library directly from `target/release`; it does
not download, build, or search Neovim's runtime path for it.

```lua
{
  dir = 'evanwporter/sv-matchit',
  config = function() require('sv-matchit').setup() end,
}
```

## Credits

This plugin is a fork of [blink.pairs](https://github.com/saghen/blink.pairs).
