- [Around 95% of steam users are running windows 64-bit](https://store.steampowered.com/hwsurvey/Steam-Hardware-Software-Survey-Welcome-to-Steam). And so are a lot of other people who can't use your lisp software easily.
- With regular lisp-executable dumping, every change requires booting up windows and rebuilding the entire binary. What if you didn't have to touch windows at all? What if all you had to do was `copy`, `paste`, and `rename`?

### End to End Example For Distribution and Installation:
1. I have an app that I want to name `game.exe`
2. I rename `puprun.exe` to `game.exe`
3. I create `game.lisp` file to load lisp code. This is the same as opening a lisp repl with quicklisp installed.
4. I put `game.exe` and `game.lisp` in a folder, lets call it `gamev1.0`
5. [optional] run `game.exe` to preload the quicklisp libraries
6. I zip up `gamev1.0` to `gamev1.0.zip`
7. I upload `gamev1.0.zip` to the internet
8. A user downloads `gamev1.0.zip`
9. The user unzips `gamev1.0.zip` to `gamev1.0` 
10. The user clicks the `gamev1.0` folder to enter it
11. The user clicks on `game.exe`
12. The libraries are downloaded if not already bundled with the download
13. The user uses the program

### More details
Inside the `build` folder is a windows `x86_64` executable that, will, in the same directory as the executable, execute a lisp file of the same name and create a dedicated quicklisp installation.

lets go inside the `"build"` folder

`puprun.exe` is a standalone windows executable that can be placed anywhere

running `puprun.exe` will:
1. make sure a dedicated quicklisp exists called `puprun_sys` in same folder as `puprun.exe`  
2. load `puprun.lisp` in same folder as `puprun.exe`

if `puprun.exe` is renamed to `foobar.exe` then `foobar.exe` will:  
1. make sure a dedicated quicklisp exists called `foobar_sys` in same folder as `foobar.exe`  
2. load `foobar.lisp` in same folder as `foobar.exe` 

etc...

### How to build

1. `(ql:quickload :trivial-ship)` [need this repo]
2. `(trivial-ship::build-buildapp)`
3. `(trivial-ship::build-puprun)`
