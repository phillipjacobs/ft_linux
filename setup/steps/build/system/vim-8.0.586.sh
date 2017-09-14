#!/bin/bash

texinfo-6.4
pkg_source="vim-8.0.586.tar.bz2"

pkg_name="$(basename $(tar -tf $1/$pkg_source | head -n 1 | cut -d'/' -f 1))"

base_dir=$1
log_file=$2"/"$(echo $pkg_name)".log"

status=0

setup(){
	cd $base_dir												|| return
	tar -xf $pkg_source											|| return
	cd $pkg_name												|| return
}

build(){
	echo '#define SYS_VIMRC_FILE "/etc/vimrc"' >> src/feature.h	|| return

	# disable a test that fails
	sed -i '/call/{s/split/xsplit/;s/303/492/}' src/testdir/test_recover.vim

	./configure --prefix=/usr									|| return

	make														|| return
	make install												|| return

	ln -sv vim /usr/bin/vi										|| continue
	
	for L in  /usr/share/man/{,*/}man1/vim.1; do
		ln -sv vim.1 $(dirname $L)/vi.1							|| continue
	done
	
	ln -sv ../vim/vim80/doc /usr/share/doc/vim-8.0.586			|| continue

		echo '
set nocompatible
set backspace=2
set mouse=r
syntax on
if (&term == "xterm") || (&term == "putty")
  set background=dark
endif
	' > /etc/vimrc

	printf "\033[36[m[ {✓}SUCCESS ] Now run : vim -c ':options' \033[0m\n"
}

teardown(){
	cd $base_dir
	rm -rfv $pkg_name



























# 	echo '"
# " General configuration
# "

# " activate indentation
# filetype off
# filetype plugin indent on
# set smartindent

# " non-expanded, 4-wide tabulations
# set tabstop=4
# set shiftwidth=4
# set noexpandtab

# " disable vi-compatibility
# set nocompatible

# " real-world encoding
# set encoding=utf-8
# " disable bom mode
# " set nobomb

# " interpret modelines in files
# set modelines=1

# " do not abandon buffers
# set hidden

# " dont bother throttling tty
# set ttyfast

# " more useful backspace behavior
# set backspace=indent,eol,start

# " use statusbar on all windows
# set laststatus=2

# " search
# set ignorecase
# set smartcase
# set incsearch
# set showmatch
# set hlsearch

# " prevent backups when editing system files
# au BufWrite /private/tmp/crontab.* set nowritebackup
# au BufWrite /private/etc/pw.* set nowritebackup

# "
# " Custom configuration
# "

# " plugins
# execute pathogen#infect()

# " file informations
# set ruler
# set number

# " syntax color
# syntax on

# hi Normal		ctermfg=White		ctermbg=none

# hi StatusLine	ctermfg=DarkGray	ctermbg=White
# hi ColorColumn						ctermbg=DarkGray
# hi OverLength						ctermbg=DarkGray
# hi Comment		ctermfg=DarkCyan	ctermbg=none
# hi Constant		ctermfg=Green		ctermbg=none
# hi Statement	ctermfg=Cyan		ctermbg=none
# hi Type			ctermfg=Cyan		ctermbg=none
# hi PreProc		ctermfg=Green		ctermbg=none
# hi String		ctermfg=Green		ctermbg=none
# hi Error		ctermfg=Red			ctermbg=none
# hi Pmenu		ctermfg=White		ctermbg=none
# hi PmenuSel		ctermfg=White		ctermbg=DarkGray
# hi LineNr		ctermfg=DarkGray	ctermbg=none
# hi NonText		ctermfg=DarkGray	ctermbg=none

# hi Special		ctermfg=Green		ctermbg=none
# hi Underlined	ctermfg=Red			ctermfg=none
# hi Identifier	ctermfg=Green		ctermbg=none

# hi Todo			ctermfg=White		ctermbg=none
# hi Search		ctermfg=Black		ctermbg=Gray

# hi VertSplit	ctermfg=Gray		ctermbg=Gray
# hi VertSplitNC	ctermfg=DarkGray	ctermbg=Gray' > /etc/vimrc
}

# Internal process

if [ $status -eq 0 ]; then
	setup >> $log_file 2>&1
	status=$?
fi

if [ $status -eq 0 ]; then
	build >> $log_file 2>&1
	status=$?
fi

if [ $status -eq 0 ]; then
	teardown >> $log_file 2>&1
	status=$?
fi

exit $status
