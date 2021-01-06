# multi_hl

 A vim script (vim plugin) to enable multiple words highlight

 - Screenshot

	![multi_hl](screenshot.png)

## Installation (using 'vim-plug' plugin manager, recommended)

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

 - From time to time ... update changes :)
	```
	:PlugUpdate
	```

refer https://github.com/junegunn/vim-plug for more details about vim-plug

## Installation (manunally download and copy, not recommended)

 - Download and copy files to .vim/plugin folder

	```
	git clone https://github.com/juehyun/multi_hl  multi_hl.git
	cd multi_hl.git/plugin
	cp -p * ~/.vim/plugin/
	```

## Usage

 - Try following hot-keys in gvim

## Hot-Keys

   | hot-key    | description                                                                                                              |
   | ---------- | ----------------------------------                                                                                       |
   | \0         | search pattern (the word under cursor or visual selected region) and SET highlight using 'hl0' color (see highlighs.csv) |
   | \1         | search pattern (the word under cursor or visual selected region) and SET highlight using 'hl1' color (see highlight.csv) |
   | \2         | same as above, use 'hl2' color                                                                                           |
   | \3         | ...                                                                                                                      |
   | \4         | ...                                                                                                                      |
   | \5         | ...                                                                                                                      |
   | \6         | ...                                                                                                                      |
   | \7         | ...                                                                                                                      |
   | \8         | ...                                                                                                                      |
   | \9         | ...                                                                                                                      |
   | \\-         | search pattern (the word under cursor or visual selected region) and CLEAR the highlight.                                |
   | \\=         | search pattern (the word under cursor or visual selected region) and SET highlight using 'hl1 ~ hl26' color circularly   |
   | \s         | save current highlights                                                                                                  |
   | \r         | restore previous saved highlights                                                                                        |
   | \\\        | clear all highlights (also save current highlights)                                                                      |
   | \m         | toggle enable/disable script (initially enabled)                                                                         |


## Colors

 - Check screenshot for color example

 - or type the gvim command ':Hsample<CR>'

 - See 'plugin/highlights.csv' file to customize colors
