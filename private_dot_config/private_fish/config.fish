set -gx EDITOR nvim
set -gx VISUAL nvim

if not status is-interactive
    return # do nothing
end

function fish_greeting
    fastfetch -c paleofetch
end

if test -f ~/dotfiles/.aliases
    source ~/dotfiles/.aliases
end

if test -f ~/.aliases
    source ~/.aliases
end

if test -f ~/.secret-aliases
    source ~/.secret-aliases
end

fish_add_path -m /home/nbkt/.local/bin

starship init fish | source
zoxide init fish | source
