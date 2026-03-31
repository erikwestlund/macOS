setopt AUTO_CD

autoload -Uz compinit
compinit

if [ -d /opt/homebrew/share/zsh-completions ]; then
  fpath=(/opt/homebrew/share/zsh-completions $fpath)
fi

if [ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
  source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

if [ -f /opt/homebrew/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh ]; then
  source /opt/homebrew/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
fi

bindkey '^[[A' up-line-or-search
bindkey '^[[B' down-line-or-search
bindkey '^[OA' up-line-or-search
bindkey '^[OB' down-line-or-search
