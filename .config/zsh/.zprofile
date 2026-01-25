#!/usr/bin/env zsh

export THEME="${THEME:-midnight}"

export XDG_CONFIG_HOME="$HOME"/.config
export XDG_CACHE_HOME="$HOME"/.cache
export XDG_DATA_HOME="$HOME"/.local/share
export XDG_STATE_HOME="$HOME"/.local/state
export XINITRC="$XDG_CONFIG_HOME"/X11/xinitrc

export GHOSTTY_SHELL_INTEGRATION_NO_CURSOR=1

export EDITOR='nvim'
export HIST_STAMPS='dd/mm/yyyy'
export HISTFILE="$XDG_STATE_HOME/zsh_history"
export HISTSIZE=2000
export HISTFILESIZE=2000
export MANPAGER='nvim +Man!'
export SAVEHIST=2000
export TERMINAL=ghostty
export TERMINFO="$XDG_DATA_HOME"/terminfo
export TERM=xterm-ghostty
export QT_AUTO_SCREEN_SCALE_FACTOR=1

function prepend_path() {
    [[ "$PATH" == *"$1"* ]] && return
    export PATH="$1:$PATH";
}
function append_path() {
    [[ "$PATH" == *"$1"* ]] && return
    export PATH="$PATH:$1";
}

export BROWSER='google-chrome-stable'
export NVM_DIR="$XDG_DATA_HOME"/nvm
[[ -o interactive ]] && . /usr/share/nvm/init-nvm.sh

append_path "$HOME"/.local/bin
test -d "$XDG_CONFIG_HOME"/luarocks && prepend_path "$XDG_CONFIG_HOME"/luarocks/bin

export GOMODCACHE="$XDG_CACHE_HOME"/go/mod
export GOPATH="$XDG_DATA_HOME"/go
append_path "$GOPATH"/bin

export PNPM_HOME="$XDG_DATA_HOME"/pnpm
append_path "$PNPM_HOME"

export OPAMROOT="$XDG_DATA_HOME"/opam
[[ -o interactive ]] && eval "$(opam env)"

export SCRIPTS="$HOME"/.local/bin/scripts
append_path "$SCRIPTS"

append_path "$XDG_DATA_HOME"/cargo/bin

export AWS_SHARED_CREDENTIALS_FILE="$XDG_CONFIG_HOME"/aws/credentials
export AWS_CONFIG_FILE="$XDG_CONFIG_HOME"/aws/config
export BOTO_CONFIG="$XDG_CONFIG_HOME"/boto/config
export CARGO_HOME="$XDG_DATA_HOME"/cargo
export CLAUDE_CONFIG_DIR="$XDG_CONFIG_HOME"/claude
export RUSTUP_HOME="$XDG_DATA_HOME"/rustup
export DOCKER_CONFIG="$XDG_CONFIG_HOME"/docker
export GRADLE_USER_HOME="$XDG_CONFIG_HOME"/gradle
export LESSHISTFILE=-
export LIBVIRT_DEFAULT_URI=qemu:///system
export MBSYNCRC="$XDG_CONFIG_HOME"/mbsync/config
export MYPY_CACHE_DIR="$XDG_CACHE_HOME"/mypy
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME"/npm/npmrc
export NODE_REPL_HISTORY="$XDG_STATE_HOME"/node_repl_history
export PARALLEL_HOME="$XDG_CONFIG_HOME"/parallel
export PRETTIERD_CONFIG_HOME="$XDG_STATE_HOME"/prettierd
export PASSWORD_STORE_DIR="$XDG_DATA_HOME"/pass
export PSQL_HISTORY="$XDG_STATE_HOME"/psql_history
export PYTHONSTARTUP="$XDG_CONFIG_HOME"/python/pythonrc
export PYTHON_HISTORY=$XDG_STATE_HOME/python_history
export PYTHONPYCACHEPREFIX=$XDG_CACHE_HOME/python
export PYTHONUSERBASE=$XDG_DATA_HOME/python
test -f "$XDG_CONFIG_HOME"/rg/base && export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/rg/base"
export SQLITE_HISTORY="$XDG_STATE_HOME"/sqlite_history
export TEXMFHOME=$XDG_DATA_HOME/texmf
export TEXMFVAR=$XDG_CACHE_HOME/texlive/texmf-var
export TEXMFCONFIG=$XDG_CONFIG_HOME/texlive/texmf-config
export JUPYTER_CONFIG_DIR="$XDG_CONFIG_HOME/jupyter"
export JUPYTER_PLATFORM_DIRS=1
export PNPM_NO_UPDATE_NOTIFIER=true

if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
    if [[ "$USE_WAYLAND" ]]; then
        export XDG_SESSION_TYPE=wayland
        export ELECTRON_OZONE_PLATFORM_HINT=wayland
        export GTK_USE_PORTAL=1
        export OZONE_PLATFORM=wayland
        export QT_QPA_PLATFORM=wayland
        export GDK_BACKEND=wayland,x11
        export SDL_VIDEODRIVER=wayland
    else
        export XDG_SESSION_TYPE=x11
    fi
fi
