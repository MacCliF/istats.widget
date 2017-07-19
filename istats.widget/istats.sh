#!/usr/bin/env bash

#
# Execute bash profile
#
if [ -f ~/.bash_profile ]; then
    source ~/.bash_profile
elif [ -f ~/.bash_login ]; then
    source ~/.bash_login
elif [ -f ~/.profile ]; then
    source ~/.profile
fi

#
# Execute iStats command
# istats enable TG0P
if [ -n "$(which /usr/local/bin/istats)" ]; then
    # define command
    command=( "$(which /usr/local/bin/istats)" )

    # execute
    "${command[@]}"
fi
