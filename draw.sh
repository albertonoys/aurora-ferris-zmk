#!/usr/bin/env bash

# Function to generate SVG for a keymap file
generate_svg_for_keymap() {
    local keymap_file="$1"
    local keymap_name=$(basename "$keymap_file" .keymap)
    local output_yaml="keymap-drawer/${keymap_name}.yaml"
    local output_svg="keymap-drawer/${keymap_name}.svg"

    # Parse the keymap file and create SVG
    keymap --config "keymap-drawer/config.yaml" parse -z $keymap_file -o $output_yaml &&
    keymap --config "keymap-drawer/config.yaml" draw $output_yaml -o $output_svg

    echo "SVG generated: $output_svg"
}

# Find all .keymap files in the config directory and generate SVGs
find config -name "*.keymap" | while read -r keymap_file; do
    generate_svg_for_keymap "$keymap_file"
done
