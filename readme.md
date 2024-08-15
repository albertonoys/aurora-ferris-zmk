# ZMK config for Aurora Sweep

## Scripts and Workflows

### draw.sh

This script generates SVG visualizations of the keyboard layout:

- Finds all `.keymap` files in the `config` directory
- Uses the `keymap` tool to parse each keymap file and generate YAML and SVG files
- Outputs the SVG files in the `keymap-drawer` directory

### docker-build.sh

This script automates the process of building ZMK firmware using Docker:

- Creates a Docker volume and container for ZMK builds
- Builds firmware for both left and right halves.
- Copies the built firmware files to the host machine
- Manages the Docker container lifecycle (creation, starting, stopping)

### flash_firmware.sh

This script automates the process of flashing firmware to both halves of a split keyboard. It performs the following tasks:

- Detects the operating system and sets the appropriate mount point
- Extracts and flashes firmware for both the left and right halves
- Provides user-friendly prompts and progress indicators using `gum`
- Optionally removes the firmware zip file after flashing

### .github/workflows/draw-keymaps.yml

This GA workflow automatically generates keymap diagrams using the keymap-drawer tool:

- Triggers on pushes that modify keymap files or related configurations
- Uses the `caksoylar/keymap-drawer` action to draw ZMK keymaps
- Processes all `.keymap` files in the `config` directory
- Outputs SVG files to the `keymap-drawer` directory
- Amends the commit with the generated diagrams


![Aurora Sweep Keymap](https://raw.githubusercontent.com/albertonoys/zmk-config/main/keymap-drawer/splitkb_aurora_sweep.svg)
