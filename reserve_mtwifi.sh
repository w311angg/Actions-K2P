changed_files=$(git diff-tree --no-commit-id --name-only -r a28334d)

while IFS= read -r line; do
    git checkout a28334d~1 -- $line
done <<< "$changed_files"
