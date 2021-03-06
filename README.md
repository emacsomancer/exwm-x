- [EXWM-X](#orga1030b5)
  - [What is EXWM-X](#org6d27276)
  - [Showcase](#orgb44a96f)
  - [Feature](#org0b06346)
    - [Appconfig](#org2e0300d)
    - [Buttons](#orgceb084e)
    - [Easy move/resize](#org43ad560)
    - [Quick Run](#org8669a11)
    - [Dmenu](#org5094762)
    - [Sendstring](#org1c3c006)
    - [Others](#org3007436)
  - [Install](#org68c5982)
  - [Configure](#org1d88bcf)
    - [Add exwm-x directory to emacs's load-path](#orgf644424)
    - [Edit "~/.initrc" file or "~/.xsession" file](#org347ee36)
    - [Make "~/.initrc" or "~/.xsession" excutable](#org412e4a2)
    - [Edit "~/.exwm-x"](#org0876ba5)
  - [Usage](#org4b29c02)
    - [Build appconfig database](#org2f7f9a0)
    - [The usage of "exwmx-example"](#org48a3974)
  - [Issues](#orgc0a79a5)


<a id="orga1030b5"></a>

# EXWM-X


<a id="org6d27276"></a>

## What is EXWM-X

EXWM-X is a derivative window manager based on EXWM (emacs x window manager), which focus on Mouse-Control-People.


<a id="orgb44a96f"></a>

## Showcase

1.  Tilling windows

    ![img](./snapshots/tilling-window.png)

2.  Floating windows

    ![img](./snapshots/floating-window.png)


<a id="org0b06346"></a>

## Feature


<a id="org2e0300d"></a>

### Appconfig

\`exwmx-appconfig' is a database manager, which is used to record and manage appconfigs (an appconfig is a plist of application's information), when run command \`exwmx-appconfig', a buffer with appconfig-template will be poped up, user can edit the template and run \`exwmx-appconfig-finish' to save the change or run \`exwmx-appconfig-ignore' to ignore the change.

All appconfigs will be saved into file: \`exwmx-appconfig-file'.

By default, every appconfig have the following keys:

1.  :command

    Record the shell command of application.

2.  :alias

    Define alias of an application, this key is used by \`exwmx-quickrun'.

3.  :pretty-name

    In EXWM and EXWM-X, an application is assocated with an emacs buffer, user can set the buffer's name with :pretty-name.

4.  :paste-key

    Record the paste keybinding of an application, this key is used by \`exwmx-sendstring'.

5.  :class

    Record the application's class, this key is used by \`exwmx-quickrun'.

6.  :instance

    Record the application's instance, this key is used by \`exwmx-quickrun'.

7.  :title

    Record the application's title, this key is used by \`exwmx-quickrun'.

8.  :floating

    If set it to \`t', application will floating when launched.

9.  :size-and-position

    If set :floating to \`t', user can use this key to set the floating window's size and position.

    Its value is a list of four elements:

        (width height x-pos y-pos)

    1.  if element >= 1, it regard as: number of pixel, if 0 < element < 1, it regard as: screen \* element.
    2.  user can set x-pos and y-pos to 'center, which mean that put the window to the center of screen.
    3.  User can set fallback value with the variable: \`exwmx-floating-default-size-and-position'.

10. :add-prefix-keys

    Add a key to \`exwm-input-prefix-keys' of application.

11. :remove-prefix-keys

    Remove a key from \`exwm-input-prefix-keys' of application,

    Note: if set it to \`t', all keys in \`exwm-input-prefix-keys' will be removed, this is very useful when you want to launch a new emacs session, this make new emacs session use **nearly** all the keybindings except the keybindings defined by \`exwmx-input-set-key'.

12. :ignore-simulation-keys

    Ingore simulation keys of application, if you set :remove-prefix-keys to 't, maybe you should set this option to 't too.

13. :eval

    Evaluation a expression when launch an application.


<a id="orgceb084e"></a>

### Buttons

EXWM-X add the following **buttons** to mode-line, user can click them to operate application's window:

1.  [X]: Delete the current application.
2.  [D]: Delete the current emacs window.
3.  [F]: Toggle floating/tilling window.
4.  [<]: Move window border to left.
5.  [+]: Maximize the current window.
6.  [>]: Move window border to right.
7.  [-]: Split window horizontal.
8.  [|]: Split window vertical.
9.  [\_]: minumize floating application
10. [Line 'XXXX'] or [L]: line-mode
11. [Char 'XXXX'] or [C]: Char-mode
12. [9][8][7][6][5]: Set the size of the floating window to 90%~50% of screen.

Note: user can use mode-line as the button-line of floating window:

    (setq exwmx-button-floating-button-line 'mode-line)


<a id="org43ad560"></a>

### Easy move/resize

By default, EXWM use "s-'down-mouse-1'" to move a floating-window and "s-'down-mouse-3'" to resize a floating-window.

When EXWM-X is enabled, user can drag **title showed in button-line** to move a floating-window. and click [9][8][7][6][5] in button-line to set a floating-window's size, **without press WIN key**.

Note: button-line is mode-line or header-line of emacs.


<a id="org8669a11"></a>

### Quick Run

If the application's window is found, jump to this window, otherwise, launch the application with command.

1.  Common usage

        (exwmx-quickrun "firefox")

    Note: \`exwmx-quickrun' **need** appconfigs stored in \`exwmx-appconfig-file', user should store appconfigs of frequently used applications by yourself with the help of \`exwmx-appconfig'.

2.  Define an alias

    Search an appconfig which :alias is "web-browser", and run this appconfig's :command.

        (exwmx-quickrun "web-browser" t)

3.  Adjust window ruler

        (exwmx-quickrun "firefox" nil '(:class :instance :title))

    or

        (exwmx-quickrun "firefox" nil '(:class "XXX" :instance "XXX" :title "XXX"))


<a id="org5094762"></a>

### Dmenu

\`exwmx-dmenu' let user input or select (with the help of ivy) a command in minibuffer, and execute it.

\`exwmx-dmenu' support some command prefixes:

1.  ",command": run "command" in terminal emulator, for example, ",top" will execute a terminal emulator, then run shell command: "top" .

    Note: user can change terminal emulator by variable \`exwmx-terminal-emulator'.

2.  ";command": run an emacs command which name is exwmx:"command".
3.  "-Num1Num2": split window top-to-bottom, for example, the result of command "-32" is: 3 windows on top and 2 windows in buttom.
4.  "|Num1Num2": split window left-to-right, for example, the result of command "|32" is: 3 windows at left and 2 window at right.

User can customize the prefixes of \`exwmx-dmenu' with the help of \`exwmx-dmenu-prefix-setting'.


<a id="org1c3c006"></a>

### Sendstring

\`exwmx-sendstring' let user send a string to application, it is a simple tool but very useful, for example:

1.  Find a Unicode character then search it to with google.
2.  Input Chinese without install ibus, fcitx or other external input method, just use emacs's buildin input method, for example: chinese-pyim, chinese-py, a good emergency tools :-)
3.  Write three line emacs-lisp example and send it to github.
4.  Draw an ascii table with table.el and send it to BBC.
5.  &#x2026;&#x2026;

when run \`exwmx-sendstring', a buffer will be poped up to let user edit. after run command \`exwmx-sendstring-finish', the content of the buffer will be sent to the input field of current application.

\`exwmx-sendstring-from-minibuffer' is a simple version of \`exwmx-sendstring', it use minibuffer to get input.

\`exwmx-sendstring-from-kill-ring' can select a string in kill-ring then send this string to application.

\`exwmx-sendstring&#x2013;send' can send a string to application, it is used by elisp.

NOTE: if \`exwmx-sendstring' can not work well with an application, user should set :paste-key of this application with the help of \`exwmx-appconfig'.


<a id="org3007436"></a>

### Others

1.  \`exwmx-shell-command': run a shell command.
2.  \`exwmx-terminal-emulator': run a shell command in a terminal emulator.


<a id="org68c5982"></a>

## Install

1.  Config melpa repository, please see：<http://melpa.org/#/getting-started>
2.  M-x package-install RET exwm-x RET


<a id="org1d88bcf"></a>

## Configure


<a id="orgf644424"></a>

### Add exwm-x directory to emacs's load-path

Pasting the below line to "~/.emacs" is a simple way.

    (add-to-list 'load-path "/path/to/exwm-x")


<a id="org347ee36"></a>

### Edit "~/.initrc" file or "~/.xsession" file

You should edit "~/.initrc" file or "~/.xsession" file like below example:


    # Fallback cursor
    # xsetroot -cursor_name left_ptr

    # Keyboard repeat rate
    # xset r rate 200 60

    xhost +SI:localuser:$USER

    exec dbus-launch --exit-with-session emacs --eval '(require (quote exwmx-loader))'


<a id="org412e4a2"></a>

### Make "~/.initrc" or "~/.xsession" excutable

    chmod a+x ~/.xsession

or

    chmod a+x ~/.initrc


<a id="org0876ba5"></a>

### Edit "~/.exwm-x"

Add your exwm config to this file, for example:

    (require 'exwm)
    (require 'exwm-x)
    (require 'exwmx-xfce)
    (require 'exwmx-example)
    (exwmx-input-set-key (kbd "C-t v") 'exwmx:file-browser)
    (exwmx-input-set-key (kbd "C-t f") 'exwmx:web-browser)
    (exwmx-input-set-key (kbd "C-t e") 'exwmx:emacs)
    (exwmx-input-set-key (kbd "C-t c") 'exwmx-xfce-terminal)
    (exwmx-input-set-key (kbd "C-t z") 'exwmx-floating-hide-all)
    (exwmx-input-set-key (kbd "C-t C-c") 'exwmx-xfce-new-terminal)
    (exwmx-input-set-key (kbd "C-t b") 'exwmx-switch-application)

    (exwmx-input-set-key (kbd "C-t C-f") 'exwmx-floating-toggle-floating)


<a id="org4b29c02"></a>

## Usage


<a id="org2f7f9a0"></a>

### Build appconfig database

When user **first** login in EXWM-X desktop environment, appconfigs of frequently used applications should be added to appconfig database file: \`exwmx-appconfig-file', it is simple but **very very** important, for many useful commands of EXWM-X need this database file, for example: \`exwmx-quickrun', \`exwmx-sendstring' and so on.

user should do like the below:

1.  Launch an application with \`exwmx-dmenu'.
2.  Run command \`exwmx-appconfig'.
3.  Edit appconfig template
4.  Save
5.  Launch another application with \`exwmx-dmenu'.
6.  &#x2026;&#x2026;.


<a id="org48a3974"></a>

### The usage of "exwmx-example"

"exwmx-example" is EXWM-X buildin example, user can use it to test EXWM-X's features, the following is its keybindings. by the way, EXWM-X is a EXWM derivative, most EXWM commands can be used too :-)

| Key       | command                         |
|--------- |------------------------------- |
| "C-t ;"   | exwmx-dmenu                     |
| "C-t C-e" | exwmx-sendstring                |
| "C-t C-r" | exwmx-appconfig                 |
| "C-t 1"   | exwmx-switch-to-1-workspace     |
| "C-t 2"   | exwmx-switch-to-2-workspace     |
| "C-t 3"   | exwmx-switch-to-3-workspace     |
| "C-t 4"   | exwmx-switch-to-4-workspace     |
| "C-x o"   | switch-window                   |
| "C-c y"   | exwmx-sendstring-from-kill-ring |

If exwmx-example doesn't suit for your need, just copy and paste its useful pieces to your "~/.exwm-x" file.

If user want to full override exwmx-example, a simple way is setting like the below line **before load exwmx-loader**.

    (defvar exwmx-default-example)
    (setq exwmx-default-example 'your-own-example)


<a id="orgc0a79a5"></a>

## Issues

1.  When exwmx-xfce is enabled, header-line of floating window will dispear when move it to another workspace.


Converted from exwm-x.el by [el2org](https://github.com/tumashu/el2org) .