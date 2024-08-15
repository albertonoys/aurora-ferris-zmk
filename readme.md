# ZMK config for Aurora Sweep

## Scripts and Workflows

### draw.sh

This script generates SVG visualizations of the keyboard layout:

- Finds all `.keymap` files in the `config` directory
- Uses the `keymap` tool to parse each keymap file and generate YAML and SVG files
- Outputs the SVG files in the `keymap-drawer` directory

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

### .github/workflows/build-local.yml

This GA workflow builds the ZMK firmware locally for the split keyboard. It:

- Sets up the necessary build environment (Python, CMake, Ninja, ARM GCC)
- Initializes and updates the West build system
- Builds firmware for both the left and right halves of the Aurora Sweep
- Saves the built firmware files with timestamps in /build


![Aurora Sweep Keymap](https://raw.githubusercontent.com/albertonoys/zmk-config/main/keymap-drawer/splitkb_aurora_sweep.svg)
