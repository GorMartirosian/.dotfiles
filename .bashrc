# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
fi
unset rc

export EDITOR="emacsclient -c -a emacs"
export VISUAL=emacs
# export PATH="$HOME/sbcl/bin:$PATH"
# export SBCL_HOME="$HOME/sbcl/lib/sbcl"
export JAVA_HOME="/usr/lib/jvm/jdk-24.0.1-oracle-x64"
export PATH="$HOME/.qlot/bin:$PATH"

