# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi


#CUDA INFORMATION
show_cuda () {
  # cuda
  CUDA_VERSION=$(command nvcc --version | sed -n 4p | sed 's/.*, release .*, V\(.*\)/\1/')
  echo "CUDA_VERSION: $CUDA_VERSION"
  # cudnn
  if [ -e $CUDA_HOME/include/cudnn.h ]; then
    CUDNN_MAJOR=$(cat $CUDA_HOME/include/cudnn.h | grep '#define CUDNN_MAJOR' | awk '{print $3}')

    CUDNN_MINOR=$(cat $CUDA_HOME/include/cudnn.h | grep '#define CUDNN_MINOR' | awk '{print $3}')
    CUDNN_PATCHLEVEL=$(cat $CUDA_HOME/include/cudnn.h | grep '#define CUDNN_PATCHLEVEL' | awk '{print $3}')
    CUDNN_VERSION="$CUDNN_MAJOR.$CUDNN_MINOR.$CUDNN_PATCHLEVEL"
    echo "CUDNN_VERSION: $CUDNN_VERSION"
  fi
}

#nvidia-smi
alias nv='nvidia-smi'
nvp(){ nvidia-smi|awk '$2=="Processes:"{aa=1;}{if(aa==1)print $0}'; free -h; }
nvpi(){ nvidia-smi|awk '{if(aa==1){print $0;aa=2;}}$2=="'$1'"{print $0;if(aa==0)aa=1}';}
nvrp(){ nvidia-smi |awk 'v==2&&$0~/^\|/{print $0}$0=="|=============================================================================|"{v=2}';}
nvrid(){ nvidia-smi |awk 'v==2&&$0~/^\|/{print $0}$0=="|=============================================================================|"{v=2}'|awk '{print $2}';}
nvfreeid(){ nvidia-smi |awk 'v==2&&$0~/^\|/{print $0}$0=="|=============================================================================|"{v=2}'|awk '{r[$2]=1}END{for(i=0;i<=15;i+=1    )if(r[i]!=1)print i}';}
cudapy(){ DEVICE_ID=$1; FILENAME=$2; shift; shift; CUDA_VISIBLE_DEVICES=$DEVICE_ID python $FILENAME $@; }

#DEEPLEARNING LIBRARY INFORMATION
show_dnn () {
  show_cuda
  # pytorch
  TORCH_VERSION=$(python -c "import pkg_resources; print(pkg_resources.get_distribution('torch').version)" 2>/dev/null)
  if [ ! -z $TORCH_VERSION ]; then
    echo "PYTORCH_VERSION: $TORCH_VERSION"
  fi
  # tensorflow
  TENSORFLOW_VERSION=$(python -c "import pkg_resources; print(pkg_resources.get_distribution('tensorflow').version)" 2>/dev/null)
  if [ ! -z $TENSORFLOW_VERSION ]; then
    echo "TENSORFLOW_VERSION: $TENSORFLOW_VERSION"
  fi
}


# added by Anaconda3 4.4.0 installer
export PATH="/home/xiaoyong/tmux/bin:/home/xiaoyong/anaconda3/bin:$PATH"
alias act="source activate"
alias da="source deactivate"
alias jn="jupyter notebook"
alias jl='jupyter lab'
