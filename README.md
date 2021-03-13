The `Makefile` in this repo is configured to use separate preprocess, compile, assemble, and link steps, keeping all intermediate assets to allow for inspection using various tools.

Run make with `-r` to ignore the built-in rules and force use of the additional intermediate rules defined here

`make -r`
