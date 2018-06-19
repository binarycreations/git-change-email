!/bin/env bash
# vim: tw=80 tabstop=4 softtabstop=4 shiftwidth=4 ai et colorcolumn=80
#
# A shell script to change the name of a single author's email address
# throughout the history of a Git repo.
#

set -x

function print_help() {
    HELP="#git-change-email
    
A shell script to change the name of a single author's email
address throughout the history of a Git repo. Creates a new copy of the repo
with these changes.

##Usage:

git-change-email EMAIL_OLD EMAIL_NEW SOURCE DEST\n

EMAIL_OLD - The old email address, each commit with this email will be replaced
by EMAIL_NEW
EMAIL_NEW - The new email address to use in place of EMAIL_OLD
SOURCE - Source directory containing Git repo where changes are applied
BACKUP - Optional argument - Desintation directory where backup copy of repo is placed.

##Example:

git-change-email foo@example.com bar@example.com ./repo-dir ./backup-dir


"

    printf "$HELP"
}

function args() {
    if [ "$1" == "--help" ]
    then
        print_help
    elif [ "$2" -lt 3 ] || [ "$2" -gt 4 ]
    then
        echo "Wrong number of arguments. See --help"
        exit
    fi
}

function copy_repo {
    if [ -n "$DEST" ]
    then
        if [ -d "$DEST" ]
        then
            mkdir -p "$DEST"
        fi
        
        cp -r "$SOURCE" "$DEST"
    fi
}

function change_email {
export EMAIL_OLD
export EMAIL_NEW

git filter-branch -f --commit-filter 'if [ "$GIT_AUTHOR_EMAIL" = "$EMAIL_OLD" ];
then export GIT_AUTHOR_EMAIL="$EMAIL_NEW"; fi; git commit-tree "$@"'
}


function main() {
    EMAIL_OLD=$1
    EMAIL_NEW=$2
    SOURCE=$3
    DEST=$4
    
    args "$1" "$#"
    copy_repo 
    change_email
}

main $@
