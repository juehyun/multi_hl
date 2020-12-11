# multi_hl

 A vim script (vim plugin) to enable multiple words highlight

 - Screenshot

	![multi_hl](screenshot.png)

## Installation (using plugin manager, vim-plug)

 - Install vim-plug

	Linux
	```
	curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
	https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	```

	Windows ( Powershell )
	```csh
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

 - From time to time ... catch the changes :)
	```
	:PlugUpdate
	```

refer https://github.com/junegunn/vim-plug for more details about vim-plug

## Installation (manunally download and copy)

 - Download and copy files to .vim/plugin folder

	```
	git clone https://github.com/juehyun/multi_hl  multi_hl.git
	cd multi_hl.git/plugin
	cp -p * ~/.vim/plugin/
	```

## Usage

 - Refer the original URL(https://vim.fandom.com/wiki/Highlight_multiple_words) for the details. but I believe the descriptions about hot-keys (see below) will be enough.

 - The changes from original are

   - Change hot-keys : use '\\\<key\>' instead of numeric keypad, because that most laptops are not easy to use numeric keypad :<

   - Add circular highlight key for using 27 colors circularly ( '\\\\' )

## Hot-Keys

 - Change hotkeys to avoid using keypad (instead use '\' key) because my laptop doesn't have keypad  :<

   | original hot-key | changed hot-key    | description                                                                                                          |
   | ---------------- | ------------------ | ----------------------------------                                                                                   |
   | Keypad 0         | \0                 | search pattern (word under cursor or visual selected region) and CLEAR the highlight. (i.e. clear current highlight) |
   | Keypad 1         | \1                 | search pattern (word under cursor or visual selected region) and SET highlight using 'hl1' color (see highlight.csv) |
   | Keypad 2         | \2                 | same as above, use 'hl2' color                                                                                       |
   | Keypad 3         | \3                 | ...                                                                                                                  |
   | Keypad 4         | \4                 | ...                                                                                                                  |
   | Keypad 5         | \5                 | ...                                                                                                                  |
   | Keypad 6         | \6                 | ...                                                                                                                  |
   | Keypad 7         | \7                 | ...                                                                                                                  |
   | Keypad 8         | \8                 | ...                                                                                                                  |
   | Keypad 9         | \9                 | ...                                                                                                                  |
   | Keypad +         | \\=                | restore previous cleared(saved) highlights                                                                           |
   | Keypad -         | \\-                | clear all highlights (also save current highlights)                                                                  |
   | Keypad *         | \\\                | highlight pattern using 27 colors circularly                                                                         |
   | \m               | \m                 | toggle enable/disable script (initially enabled)                                                                     |


## Colors

 - Check screenshot for color example

 - See 'plugin\highlights.csv' file to change color configuration
