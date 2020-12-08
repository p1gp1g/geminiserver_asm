#!/bin/sh

[ "$DOMAIN" == "" ] && export DOMAIN=localhost
[ "$FILES_PATH" == "" ] && export FILES_PATH=/files/
[ "$REDIR_PATH" == "" ] && export REDIR_PATH=/files/index
[ "$PAGE_LENGTH" == "" ] && export PAGE_LENGTH=0x400

nasm -f elf64 server.asm -D "domain='$DOMAIN'" -D "filespath='$FILES_PATH'" -D "redirpath='$REDIR_PATH'" -D "pagelength=$PAGE_LENGTH"
ld -o server server.o
