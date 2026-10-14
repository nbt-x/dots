function sf --description 'Fuzzy-find a file and send it via wormhole'
    set file (begin; fd --type f --type d . ~; fd --type f --type d --hidden . ~/dotfiles; end | fzf --no-preview)
    and wormhole send $file
end
