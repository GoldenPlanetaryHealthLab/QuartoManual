echo "Extracting abstract from README.md to usrse2026/abstract.md"

infile=$1
awk '/^## Abstract[[:space:]]*$/ { in_section=1; next } /^## / && in_section { exit } in_section { print }' $infile > usrse2026/abstract.md