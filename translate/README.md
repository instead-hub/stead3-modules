## translate module

This module lets you use `gettext` to translate your works - in contrast to copy-and-rewrite approach. You can turn it on in three lines:

    loadmod 'translate'
    translate:set_source( 'en' )
    translate:init()

The default source language value is `'ru'`, so you should definitely set it to your native language 2-letter code.
The module declares a function `__()` that translates all text from the source language to the one currently selected in INSTEAD preferences.

That is all there is.
You require the module, wrap all strings like this: `__([[text]])` and start Poedit or whatever you prefer on the source code. To get help on gettext one should turn to a search engine.

The `test` directory presents an example. Try to open `ru.po` in Poedit.

The translations should be in `.mo` gettext format and the module expects them in the `translations` directory.
