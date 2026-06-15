# Automated Project Bootstrapping & Process Management

A self-contained shell script that bootstraps a **Student Attendance Tracker** workspace. It creates the directory structure, generates all source files, lets you configure attendance thresholds, validates the environment, and cleans up gracefully if interrupted.

## What the script does

When you run it, `setup_project.sh` performs the following steps automatically:

1. Asks for a project name and builds a parent directory called `attendance_tracker_<name>`.
2. Creates the required folder structure (`Helpers/` and `reports/`) inside it.
3. Generates the four source files (`attendance_checker.py`, `assets.csv`, `config.json`, `reports.log`).
4. Optionally updates the warning and failure thresholds, validating that your input is numeric before editing `config.json` with `sed`.
5. Runs a health check to confirm `python3` is installed.
6. Verifies that every expected file landed in the correct place.

The final structure looks like this:

```
attendance_tracker_<name>/
├── attendance_checker.py
├── Helpers/
│   ├── assets.csv
│   └── config.json
└── reports/
    └── reports.log
```

## How to run it

1. Make the script executable (only needed once):

   ```bash
   chmod +x setup_project.sh
   ```

2. Run it:

   ```bash
   ./setup_project.sh
   ```

3. Answer the prompts:
   - Enter a project name.
   - Choose whether to update the thresholds (`y`/`n`). If yes, enter a numeric warning value and a numeric failure value. Non-numeric input is rejected and the defaults are used instead.

## How to trigger the archive (cleanup) feature

The script installs a signal trap for **SIGINT** (Ctrl+C). If you cancel the script while it is running, the trap activates and:

1. Bundles the partially built project directory into an archive named `attendance_tracker_<name>_archive.tar.gz`.
2. Deletes the incomplete directory so the workspace stays clean.

To see this in action, press **Ctrl+C while the script is actively running** (not while it is waiting at a prompt). For demonstration purposes you can temporarily add a `sleep 10` line after the directory-creation step to give yourself a window to interrupt, then press Ctrl+C during that pause. You should see:

```
Interrupt received. Archiving current state...
Archived to attendance_tracker_<name>_archive.tar.gz
Removed incomplete directory to keep workspace clean.
```

Remember to remove the `sleep` line before submitting.

## Requirements

- A Unix-like environment (Linux or macOS) with `bash`.
- `python3` (the health check reports whether it is installed; the generated attendance checker requires it to run).

## Notes

- The script is fully self-contained. It generates all source files itself, so only `setup_project.sh` needs to be present to build a complete project.
- The default thresholds are a warning at 80% and a failure at 45%. These can be changed at runtime when prompted.
