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
    CURRENT=`find recipes-wolfssl/$1/*.bb | grep -Eo '[0-9]+.[0-9]+.[0-9]+'`
}

get_new() {
    NEW=$(curl -s "https://api.github.com/repos/wolfssl/$1/releases/latest" | jq -r '.tag_name' | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+')
}


update() {
    if [ -z "$CURRENT" ] || [ -z "$NEW" ]; then
        printf "Error: Current or new version is empty for %s. Skipping update.\n" "$1"
        return
    fi

    if [ "$CURRENT" != "$NEW" ]; then
        printf "Updating from %s to %s for %s...\n" "$CURRENT" "$NEW" "$1"
        TAG="v$NEW-stable"
        if [ "$1" = "wolfmqtt" ] || [ "$1" == "wolftpm" ] || [ "$1" == "wolfprovider" ]; then
            TAG="v$NEW"
        fi

        # Clone the new version repository
        if ! git clone -b "$TAG" "git@github.com:wolfssl/$1" &> /dev/null; then
            printf "Error cloning %s. Skipping.\n" "$1"
            return
        fi

        # Get the new revision
        cd "$1" &> /dev/null
        REV=$(git rev-list -n 1 "$TAG")
        cd .. && rm -rf "$1"

        # Check if the old .bb file exists before attempting to move
        if [ ! -f "./recipes-wolfssl/$1/$1_$CURRENT.bb" ]; then
            printf "Error: .bb file for %s with version %s not found. Skipping.\n" "$1" "$CURRENT"
            return
        fi

        # Check if the new .bb file already exists
        if [ -f "./recipes-wolfssl/$1/$1_$NEW.bb" ]; then
            echo "New .bb file for version $NEW already exists. Deleting it to proceed with update."
            # Delete the existing new .bb file
            rm -f "./recipes-wolfssl/$1/$1_$NEW.bb"
        fi

        # Move the .bb file to the new version
        git mv "./recipes-wolfssl/$1/$1_$CURRENT.bb" "./recipes-wolfssl/$1/$1_$NEW.bb" &> /dev/null

        # Update the revision in the new .bb file
        if [ -f "./recipes-wolfssl/$1/$1_$NEW.bb" ]; then
            sed -i "s/rev=.*/rev=$REV\"/" "./recipes-wolfssl/$1/$1_$NEW.bb"
            git add "./recipes-wolfssl/$1/$1_$NEW.bb" &> /dev/null
        else
            printf "Error updating .bb file for %s to version %s. File not found after move.\n" "$1" "$NEW"
            return
        fi

        # Additional steps for wolfSSL
        if [ "$1" = "wolfssl" ]; then
            printf "\tUpdating wolfcrypt test and benchmark...\n"
            # Update wolfcrypt test
            if [ -f "./recipes-examples/wolfcrypt/wolfcrypttest/wolfcrypttest.bb" ]; then
                sed -i "s/rev=.*/rev=$REV\"/" "./recipes-examples/wolfcrypt/wolfcrypttest/wolfcrypttest.bb"
                git add "./recipes-examples/wolfcrypt/wolfcrypttest/wolfcrypttest.bb" &> /dev/null
            else
                printf "Error: wolfcrypttest.bb file not found.\n"
            fi
            # Update wolfcrypt benchmark
            if [ -f "./recipes-examples/wolfcrypt/wolfcryptbenchmark/wolfcryptbenchmark.bb" ]; then
                sed -i "s/rev=.*/rev=$REV\"/" "./recipes-examples/wolfcrypt/wolfcryptbenchmark/wolfcryptbenchmark.bb"
                git add "./recipes-examples/wolfcrypt/wolfcryptbenchmark/wolfcryptbenchmark.bb" &> /dev/null
            else
                printf "Error: wolfcryptbenchmark.bb file not found.\n"
            fi
        fi
    else
        printf "Version %s is the latest for %s. No update needed.\n" "$CURRENT" "$1"
    fi
}


check_and_update() {

printf "Checking version of ${1} to use..."
get_current "${1}"
get_new "${1}"
update "${1}"

}

check_and_update "wolfssl"

check_and_update "wolfmqtt"

check_and_update "wolfssh"

check_and_update "wolftpm"

check_and_update "wolfclu"

check_and_update "wolfssl-py"

check_and_update "wolfcrypt-py"

check_and_update "wolfengine"

check_and_update "wolfprovider"




exit 0
