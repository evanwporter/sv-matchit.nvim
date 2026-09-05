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

```lua
{
  'evanwporter/sv-matchit',
  ft = "systemverilog",
  build = "nix develop --command cargo build --release",
  opts = {},
}
```

## Credits

This plugin is a fork of [blink.pairs](https://github.com/saghen/blink.pairs).
