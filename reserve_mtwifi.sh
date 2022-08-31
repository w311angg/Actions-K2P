changed_files=$(git diff-tree --no-commit-id --name-only -r 9483e6d)

while IFS= read -r line; do
    echo reserving $line
    git checkout 9483e6d~1 -- $line
done <<< "$changed_files"
