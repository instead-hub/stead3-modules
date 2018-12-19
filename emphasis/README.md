## emphasis module

This module lets you ditch `txtb` and `txtem` functions in the game main code. Compare: `pn "Hi"..txtem("Player")` and `pn "Hi *Player*"`.

**Usage:**

    **bold** or __bold__
    *italic*
    _underline_
     -strikeout-

Just write `require "emphasis"` and use these shortcuts. Module requires `format` module automatically.
