#!/bin/bash

# Copyright (C) 2006-2022 wolfSSL Inc.
#
# This file is part of wolfSSL.
#
# wolfSSL is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# wolfSSL is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1335, USA


get_current() {
    CURRENT=`find recipes-wolfssl/$1/* | grep -Eo '[0-9]+.[0-9]+.[0-9]+'`
}

get_new() {
    NEW=`curl -s https://api.github.com/repos/wolfssl/$1/releases/latest | grep -i $1- | grep name | grep -Eo -m 1 '[0-9]+.[0-9]+.[0-9]+'`
}

update() {
    if [ "$CURRENT" != "$NEW" ]; then
        printf "updating from $CURRENT to $NEW\n"
        git mv ./recipes-wolfssl/$1/$1_$CURRENT.bb ./recipes-wolfssl/$1/$1_$NEW.bb &> /dev/null
        if [ "$1" = "wolfssl" ]; then
            printf "\tUpdating wolfcrypt test and benchmark...\n"
            sed -i "s/WOLFCRYPT_V=.*/WOLFCRYPT_V=\"$NEW\"/" ./recipes-examples/wolfcrypt/wolfcrypttest/wolfcrypttest.bb
            git add ./recipes-examples/wolfcrypt/wolfcrypttest/wolfcrypttest.bb &> /dev/null
            sed -i  "s/WOLFCRYPT_V=.*/WOLFCRYPT_V=\"$NEW\"/" ./recipes-examples/wolfcrypt/wolfcryptbenchmark/wolfcryptbenchmark.bb
            git add ./recipes-examples/wolfcrypt/wolfcryptbenchmark/wolfcryptbenchmark.bb &> /dev/null
        fi 
    else
        printf "version $CURRENT is the latest\n"
    fi
}


printf "Checking version of wolfSSL to use..."
get_current "wolfssl"
get_new "wolfssl"
update "wolfssl"

printf "Checking version of wolfMQTT to use..."
get_current "wolfmqtt"
get_new "wolfmqtt"
update "wolfmqtt"

printf "Checking version of wolfSSH to use..."
get_current "wolfssh"
get_new "wolfssh"
update "wolfssh"

printf "Checking version of wolfTPM to use..."
get_current "wolftpm"
get_new "wolftpm"
update "wolftpm"

exit 0
