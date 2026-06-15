#!/bin/bash

#First ask for project name, and create paths from it
read -rp "Enter project name: " username
Parent_directory="attendance_tracker_${username}"
Archive_name="attendance_tracker_${username}_archive"

#Signal Trap to archive and delete incomplete directory on Ctrl+C
cleanup() {
	echo ""
	echo "Interrupt received. Archiving current state..."
	if [ -d "$Parent_directory" ]; then
		tar -czf "${Archive_name}.tar.gz" "$Parent_directory"
		echo "Archived to ${Archive_name}.tar.gz"
		rm -rf "$Parent_directory"
		echo "Removed incomplete directory to keep workspace clean."
	fi
	exit 1
}
trap cleanup SIGINT

#Directory creation with error handling
if [ -d "$Parent_directory" ]; then
	echo "Error: $Parent_directory already exists. Aborting."
	exit 1
fi 

if ! mkdir -p "$Parent_directory/Helpers" "$Parent_directory/reports"; then
	echo "Error: could not create directories (check permissions)."
	exit 1
fi

#Generating Source files
cat << 'EOF' > "$Parent_directory/attendance_checker.py"
import csv
import json
import os
from datetime import datetime

def run_attendance_check():
    # 1. Load Config
    with open('Helpers/config.json', 'r') as f:
        config = json.load(f)
    
    # 2. Archive old reports.log if it exists
    if os.path.exists('reports/reports.log'):
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        os.rename('reports/reports.log', f'reports/reports_{timestamp}.log.archive')

    # 3. Process Data
    with open('Helpers/assets.csv', mode='r') as f, open('reports/reports.log', 'w') as log:
        reader = csv.DictReader(f)
        total_sessions = config['total_sessions']
        
        log.write(f"--- Attendance Report Run: {datetime.now()} ---\n")
        
        for row in reader:
            name = row['Names']
            email = row['Email']
            attended = int(row['Attendance Count'])
            
            # Simple Math: (Attended / Total) * 100
            attendance_pct = (attended / total_sessions) * 100
            
            message = ""
            if attendance_pct < config['thresholds']['failure']:
                message = f"URGENT: {name}, your attendance is {attendance_pct:.1f}%. You will fail this class."
            elif attendance_pct < config['thresholds']['warning']:
                message = f"WARNING: {name}, your attendance is {attendance_pct:.1f}%. Please be careful."
            
            if message:
                if config['run_mode'] == "live":
                    log.write(f"[{datetime.now()}] ALERT SENT TO {email}: {message}\n")
                    print(f"Logged alert for {name}")
                else:
                    print(f"[DRY RUN] Email to {email}: {message}")

if __name__ == "__main__":
    run_attendance_check()
EOF

cat << 'EOF' > "$Parent_directory/Helpers/assets.csv"
Email,Names,Attendance Count,Absence Count
alice@example.com,Alice Johnson,14,1
bob@example.com,Bob Smith,7,8
charlie@example.com,Charlie Davis,4,11
diana@example.com,Diana Prince,15,0
EOF


cat << 'EOF' > "$Parent_directory/Helpers/config.json"
{
    "thresholds": {
        "warning": 80,
        "failure": 45
    },
    "run_mode": "live",
    "total_sessions": 15
}
EOF

cat << 'EOF' > "$Parent_directory/reports/reports.log"
--- Attendance Report Run: 2026-02-06 18:10:01.468726 ---
[2026-02-06 18:10:01.469363] ALERT SENT TO bob@example.com: URGENT: Bob Smith, your attendance is 46.7%. You will fail this class.
[2026-02-06 18:10:01.469424] ALERT SENT TO charlie@example.com: URGENT: Charlie Davis, your attendance is 26.7%. You will fail this class.
EOF


#Dynamic Config - prompt, validate numeric, sed in-place
read -rp "Update thresholds? (y/n): " answer
if [ "$answer" = "y" ]; then
	read -rp "Enter warning threshold (80): " warning
	read -rp "Enter failure threshold (45): " failure
	
	warning=${warning:-80}
	failure=${failure:-45}

	if ! [[ "$warning" =~ ^[0-9]+$ ]] || ! [[ "$failure" =~ ^[0-9]+$ ]]; then
		echo "Invalid (non-numeric) input. Using defaults: 80 / 45."
		warning=80
		failure=45
	fi
	#Portable in-place edit
	sed -i.bak "s/\"warning\": *[0-9]*/\"warning\": $warning/" "$Parent_directory/Helpers/config.json"
	sed -i.bak "s/\"failure\": *[0-9]*/\"failure\": $failure/" "$Parent_directory/Helpers/config.json"
	rm -f "$Parent_directory/Helpers/config.json.bak"
	echo "Threshold updated to warning=$warning, failure=$failure."
else
	echo "Keeping default thresholds."
fi

#Environment Health Check
if python3 --version >/dev/null 2>&1; then
	echo "Health check passed: $(python3 --version)"
else
	echo "WARNING: python3 is NOT installed on this system."
fi

#Verify Structure
if [ -f "$Parent_directory/attendance_checker.py" ] && \
   [ -f "$Parent_directory/Helpers/config.json" ] && \
   [ -f "$Parent_directory/reports/reports.log" ]; then
	echo "Setup complete. Structure verified: $Parent_directory"
else
	echo "Warning: structure verification failed."
fi
