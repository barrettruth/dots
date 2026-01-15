#!/usr/bin/env zsh

autoload -U compinit && compinit -d "$XDG_STATE_HOME"/zcompdump -u
autoload -U colors && colors
autoload -U add-zsh-hook
zmodload zsh/complist

zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-za-z}'

set completion-ignore-case on
unset completealiases
setopt auto_cd incappendhistory extendedhistory histignorealldups hist_ignore_space

export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=59'
export HYPHEN_INSENSITIVE='true'

if [[ ! -d "$ZDOTDIR/pure" ]]; then
  git clone --depth=1 https://github.com/sindresorhus/pure.git "$ZDOTDIR/pure"
fi

export PURE_PROMPT_SYMBOL=">"
export PURE_PROMPT_VICMD_SYMBOL="<"
export PURE_GIT_UP_ARROW="^"
export PURE_GIT_DOWN_ARROW="v"
export PURE_GIT_STASH_SYMBOL="="
export PURE_CMD_MAX_EXEC_TIME=5
export PURE_GIT_PULL=0
export PURE_GIT_UNTRACKED_DIRTY=1

zstyle ':prompt:pure:git:stash' show yes

fpath+=("$ZDOTDIR"/pure)
autoload -Uz promptinit && promptinit
prompt pure

autoload -Uz add-zle-hook-widget

function _pure_cursor_shape() {
  case $KEYMAP in
    vicmd) echo -ne '\e[2 q' ;;
    viins|main) echo -ne '\e[6 q' ;;
  esac
}

function _pure_cursor_init() {
  echo -ne '\e[6 q'
}

add-zle-hook-widget zle-keymap-select _pure_cursor_shape
add-zle-hook-widget zle-line-init _pure_cursor_init

export FZF_COMPLETION_TRIGGER=\;
export FZF_CTRL_R_OPTS='--reverse'
export FZF_TMUX=1
export FZF_CTRL_T_COMMAND='rg --files --hidden --color=auto'
local FZF_OPTS='--bind=ctrl-a:select-all --bind=ctrl-f:half-page-down --bind=ctrl-b:half-page-up --no-scrollbar --no-info'
export FZF_DEFAULT_OPTS="$FZF_OPTS"

. <(fzf --zsh)

fzf-config-widget() {
    file="$(FZF_CTRL_T_COMMAND="fd --type file --hidden . ~/.config | sed 's|$HOME|~|g'" __fzf_select | cut -c2-)"
    LBUFFER+="$file"
    zle reset-prompt
}

zle -N fzf-config-widget

bindkey '^E' fzf-config-widget

_fzf_theme_precmd() {
    local theme_file="$XDG_CONFIG_HOME/fzf/themes/theme"
    local theme_target=$(readlink "$theme_file" 2>/dev/null) || return
    typeset -g _FZF_THEME_TARGET
    test "$theme_target" = "$_FZF_THEME_TARGET" && return
    _FZF_THEME_TARGET="$theme_target"
    test -r "$theme_file" && export FZF_DEFAULT_OPTS="$(<"$theme_file") $FZF_OPTS"
}
add-zsh-hook precmd _fzf_theme_precmd

test -r "$XDG_CONFIG_HOME/rg/base" && export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/rg/base"

_rg_theme_precmd() {
    local base="$XDG_CONFIG_HOME/rg/base"
    local colors="$XDG_CONFIG_HOME/rg/themes/theme"
    local config="$XDG_CONFIG_HOME/rg/config"

    local flag="$(uname -s | grep -q Darwin && echo '-f %m' || echo '-c %Y')"
    local base_mtime="$(stat "$flag" "$base" 2>/dev/null)"
    local colors_target="$(readlink "$colors" 2>/dev/null)"
    local check="$base_mtime:$colors_target"

    if [[ "$check" != "$_RG_CHECK" ]]; then
        _RG_CHECK="$check"
        test -f "$base" && test -f "$colors" && { cat "$base"; echo; cat "$colors"; } > "$config"
    fi

    test -f "$config" && export RIPGREP_CONFIG_PATH="$config"
}
add-zsh-hook precmd _rg_theme_precmd

bindkey -v
bindkey '^[[3~' delete-char
bindkey '^P' up-line-or-history
bindkey '^N' down-line-or-history
bindkey '^J' backward-char
bindkey '^K' forward-char

eval "$(direnv hook zsh)"

. "$ZDOTDIR"/.zaliases
