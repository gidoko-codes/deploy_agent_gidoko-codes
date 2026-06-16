# Automated Project Bootstrapping & Process Management

This script is a self-contained shell script that bootstraps a Student Attendance Tracker workspace. It creates the directory structure, generates all source files, lets the user configure attendance thresholds, validates the environment, and cleans up gracefully if interrupted.

# What the script does

When you run it, `setup_project.sh` performs the following steps automatically:

1. Asks for a project name and builds a parent directory called `attendance_tracker_<name>`.
2. Creates the required folder structure (`Helpers/` and `reports/`) inside it.
3. Generates the four source files (`attendance_checker.py`, `assets.csv`, `config.json`, `reports.log`).
4. Optionally updates the warning and failure thresholds, validating that your input is numeric before editing `config.json` with `sed`.
5. Runs a health check to confirm `python3` is installed.
6. Verifies that every expected file landed in the correct place. b
The final structure looks like this:


## How to run it

1. Make the script executable (only needed once) by running the:

   chmod +x setup_project.sh command

2. Run it:

   ./setup_project.sh


3. Answer the prompts:
   - Enter a project name.
   - Choose whether to update the thresholds (`y`/`n`). If yes, enter a numeric warning value and a numeric failure value. Non-numeric input is rejected and the defaults are used instead.

## How to trigger the archive (cleanup) feature

The script installs a signal trap for **SIGINT** (Ctrl+C). If you cancel the script while it is running, the trap activates and:

1. Bundles the partially built project directory into an archive named `attendance_tracker_<name>_archive.tar.gz`.
2. Deletes the incomplete directory so the workspace stays clean.

The link to my descriptive video: https://drive.google.com/file/d/1cNKNN5C8InmXegFAGxW_0_vOkb708GAo/view?usp=sharing
