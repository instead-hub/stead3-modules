## translate module

This module lets you use `gettext` to translate your works - in contrast to copy-and-rewrite approach. It has only one option:

    require 'translate'
    translate.source = 'en'

The default value is `'ru'`, so you should definitely set it to your native language 2-letter code. The module declares a function `__()` that translates all text from the source language to the one currently selected in INSTEAD preferences.

That is all there is to that. You require the module, wrap all strings like this: `__([[text]])` and start Poedit or whatever you prefer on the source code. To get help on gettext one should turn to a search engine.
