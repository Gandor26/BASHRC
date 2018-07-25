export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

# header layout
parse_git_branch(){
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/' -e $'s/^/ \xee\x82\xa0/'
}
export PS1="\[\e[1;34m\][\[\e[1;32m\]\u\[\e[1;34m\]@\[\e[1;32m\]\h: \[\e[1;34m\]\W\[\e[1;33m\]\$(parse_git_branch)\[\e[1;34m\]]\[\e[1;34m\]$ \[\e[0m\]"

# alias functions
alias l='ls'
alias ls='ls -GFh'
alias ll='ls -al'
alias du='du -d 1 -h'
alias ct='ls -l | wc -l'
alias ~!='cd ~'
alias ..='cd ..'
alias .2='cd ../..'
alias jn='jupyter notebook'
alias jl='jupyter lab'
function sfs() { sshfs -o idmap=user "$1:/home/xiaoyong" "/Users/x_jin/remote/$1"; }
function umt() { umount -f "/Users/x_jin/remote/$1"; }

# autocomplete ssh hostnames
_complete_ssh_hosts()
{
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    comp_ssh_hosts=`
        cat ~/.ssh/known_hosts | \
        cut -f 1 -d ' ' | \
        sed -e s/,.*//g | \
        grep -v ^# | \
        uniq | \
        grep -v "\[" ;
        cat ~/.ssh/config | \
        grep "^Host " | \
        awk '{print $2}'
        `
    COMPREPLY=( $(compgen -W "${comp_ssh_hosts}" -- $cur))
    return 0
}
complete -F _complete_ssh_hosts ssh
complete -F _complete_ssh_hosts sfs
complete -F _complete_ssh_hosts umt
