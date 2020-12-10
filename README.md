# multi_hl

 A vim script (vim plugin) to enable multiple words highlight

## Installation (using vim-plug)

 - Install vim-plug ( https://github.com/junegunn/vim-plug )

 #### Linux
 ```
 curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
 ```
 #### Windows (Powershell)
 ```
 iwr -useb https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim |`
    ni $HOME/vimfiles/autoload/plug.vim -Force
 ```

 - Add following lines in your .vimrc

  ```
  call plug#begin('~/.vim/plugged')
  Plug 'juehyun/multi_hl'
  call plug#end()
  ```

 - Open gvim and type following command
  ```
  :PlugInstall
  ```

## Usage

 - This vim script file come from "https://vim.fandom.com/wiki/Highlight_multiple_words" and only chagne the 'hot-key'

 - Refer the URL for the usage

## Changes

 - Hot-keys

  | ---------------- | --------------- |
  | original hot-key | changed hot-key |
  | ---------------- | --------------- |
  | Keypad 0         | \0              |
  | Keypad 1         | \1              |
  | Keypad 2         | \2              |
  | Keypad 3         | \3              |
  | Keypad 4         | \4              |
  | Keypad 5         | \5              |
  | Keypad 6         | \6              |
  | Keypad 7         | \7              |
  | Keypad 8         | \8              |
  | Keypad 9         | \9              |
  | Keypad +         | \=              |
  | Keypad -         | \-              |
  | Keypad *         | \\              |
  | \m               | \m              |
  | ---------------- | --------------- |

 - Color

  The colors for highlight pattern are changed
