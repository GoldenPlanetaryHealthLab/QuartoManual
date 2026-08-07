

infile=$1
awk '/^## Abstract[[:space:]]*$/ { in_section=1; next } /^## / && in_section { exit } in_section { print }' $infile > abstract.md