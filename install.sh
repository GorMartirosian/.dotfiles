#!/usr/bin/env bash

backup_directory="$HOME/.dotfiles.backup"
dotfiles_directory="$HOME/.dotfiles"
files_and_dirs_to_skip=("install.sh" ".git")

create_backup_dir() {
    mkdir -p "$backup_directory"
}

should_skip_this_file() {
    local name="$1"

    for skip in "${files_and_dirs_to_skip[@]}"; do
        if [[ "$name" == "$skip" ]]; then
            return 0    # yes
        fi
    done

    return 1    # no
}

move_identical_files_and_dirs_to_backup_dir() {
    shopt -s nullglob dotglob
    for item in "$dotfiles_directory/"*; do
	local file_or_dir_name=$(basename "$item")

	if [[ -e "$HOME/$file_or_dir_name" ]]; then
    	    if ! should_skip_this_file "$file_or_dir_name"; then
        	mv "$HOME/$file_or_dir_name" "$backup_directory"
    	    fi
	fi

    done
    shopt -u nullglob dotglob
}

create_symlinks_to_dotfiles() {
    shopt -s nullglob dotglob
    for item in "$dotfiles_directory/"*; do
        local name
        name=$(basename "$item")

	if should_skip_this_file "$name"; then
		continue
	fi	

        if [[ $1 == "overwrite" ]]; then
            ln -sfn "$dotfiles_directory/$name" "$HOME/$name"
        else
            ln -sn "$dotfiles_directory/$name" "$HOME/$name"
        fi
    done
    shopt -u nullglob dotglob
}

read -r -p "Do you want to make a backup directory for \
existing config files (~/.dotfiles.backup)? (yes/no/exit):" answer

if [[ "$answer" == "y" || "$answer" == "yes" ]]; then
    create_backup_dir
    echo "Created backup directory $backup_directory"
    move_identical_files_and_dirs_to_backup_dir
    echo "Moved identical files/directories of $HOME/.dotfiles \
    	 from $HOME to $backup_directory"
    create_symlinks_to_dotfiles
    echo "Created symlinks to $HOME/.dotfiles"
elif [[ "$answer" == "n" || "$answer" == "no" ]]; then
    create_symlinks_to_dotfiles "overwrite"
    echo "Created symlinks to $HOME/.dotfiles (previous content overwritten!)"
else
    echo "Aborted"
    exit 0
fi
