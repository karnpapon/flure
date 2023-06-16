#!/usr/bin/env bash

while read -r line; do
 luarocks install $(echo $line | awk -F '==' '{print $1, $2}')  
    # if [ "$line" = "readline==3.3-0" ]; then
    #   echo "installing readline..."
    #   luarocks install readline HISTORY_INCDIR=/opt/homebrew/opt/readline/include/ HISTORY_LIBDIR=/opt/homebrew/opt/readline/lib/ READLINE_DIR=/opt/homebrew/opt/readline/
    # else
    #   echo "installing others packages..."
    #   luarocks install $(echo $line | awk -F '==' '{print $1, $2}')  
    # fi
done < requirements_lua.txt


