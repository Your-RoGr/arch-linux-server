#!/bin/bash

# Restore database
./gogs restore --from="gogs-backup.zip" --database-only
mkdir tmp
unzip gogs-backup.zip -d tmp

# Restore pics
mv tmp/gogs-backup/data/avatars data
mv tmp/gogs-backup/data/repo-avatars data

# Restore git
unzip tmp/gogs-backup/repositories.zip -d /data/git
git config --global --add safe.directory /data/git/gogs-repositories/rogr/multios-api.git

# Set the base directory
base_dir="/data/git/gogs-repositories"

# Check if the base directory exists
if [ ! -d "$base_dir" ]; then
    echo "Error: The base directory '$base_dir' does not exist."
    exit 1
fi

# Iterate through all the directories in the base directory
for dir in "$base_dir"/*/; do
    if [ -z "$(find "$dir" -maxdepth 0 -type d -empty)" ]; then
        for git_dir in "$dir"*.git; do
            git config --global --add safe.directory "$git_dir"
            echo "Added '$git_dir' to the list of safe directories."
        done
    fi
done

# Clear
rm -rf tmp
rm -rf gogs-backup.zip
exit
