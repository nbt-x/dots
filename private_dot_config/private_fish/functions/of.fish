function of --description 'Fuzzy-find a file and open it'
    set file (begin; fd --type f --type d . ~; fd --type f --type d --hidden . ~/dotfiles; end | fzf --no-preview)
    and begin
        systemd-run --user --no-block xdg-open $file
    end
end
