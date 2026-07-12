source /usr/share/cachyos-fish-config/cachyos-config.fish
alias dlp "~/.dlp.sh"
# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end

# Added by LM Studio CLI (lms)
set -gx PATH $PATH /home/jon/.lmstudio/bin
# End of LM Studio CLI section

# Add npm global binaries to PATH
set -gx PATH /home/jon/.npm-global/bin $PATH

set -gx PATH $PATH /usr/lib/tumbler-1

# OpenClaw Completion
source "/home/jon/.openclaw/completions/openclaw.fish"

alias keybinds="vscodium ~/.config/hypr/config/keybinds.conf"
alias kb="keybinds"

# >>> grok installer >>>
fish_add_path $HOME/.grok/bin
# <<< grok installer <<<
