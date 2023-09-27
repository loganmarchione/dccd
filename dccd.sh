#!/bin/bash

########################################
# Default configuration values
########################################
BASE_DIR=""                     # Initialize empty variable
REMOTE_BRANCH="main"            # Default remote branch name
LOG_FILE="/tmp/dccd.log"        # Default log file name

########################################
# Functions
########################################
log_message() {
    local message="$1"
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $message" | tee -a "$LOG_FILE"
}

update_compose_files() {
    local dir="$1"

    cd "$dir" || { log_message "ERROR: Directory doesn't exist, exiting..."; exit 127; }

    # Make sure we're in a git repo
    if [ ! -d .git ]; then
        log_message "ERROR: Directory is not a git repository, exiting..."
        exit 1
    else
        log_message "INFO:  Git repository found!"
    fi

    # Check if there are any changes in the Git repository
    if ! git fetch origin;
        log_message "ERROR: Unable to fetch changes from the remote repository (the server may be offline or unreachable)"
        exit 1
    fi

    local_hash=$(git rev-parse HEAD)
    remote_hash=$(git rev-parse "origin/$REMOTE_BRANCH")
    log_message "INFO:  Local hash is  $local_hash"
    log_message "INFO:  Remote hash is $remote_hash"

    # Check for uncommitted local changes
    uncommitted_changes=$(git status --porcelain)
    if [ -n "$uncommitted_changes" ]; then
        log_message "ERROR: Uncommitted changes detected in $dir, exiting..."
        exit 1
    fi

    # Check if the local hash matches the remote hash
    if [ "$local_hash" != "$remote_hash" ]; then
	log_message "STATE: Hashes don't match, updating..."

        # Pull any changes in the Git repository
        if ! git pull --quiet origin "$REMOTE_BRANCH";
            log_message "ERROR: Unable to pull changes from the remote repository (the server may be offline or unreachable)"
            exit 1
        fi

	find . -type f \( -name 'docker-compose.yml' -o -name 'docker-compose.yaml' \) | sort | while IFS= read -r file; do
  	    # Extract the directory containing the file
  	    dir=$(dirname "$file")

    	# Check if the directory matches the exclusion pattern
    	    if [[ "$dir" != *"$EXCLUDE"* ]]; then
                log_message "STATE: Redeploying compose file for $file"
                docker compose -f "$file" up -d --quiet-pull
    	    fi
        done

    else
        log_message "STATE: Hashes match, so nothing to do"
    fi

    log_message "STATE: Done!"
}

usage() {
    printf "
    Usage: $0 [OPTIONS]

    Options:
      -b <name>       Specify the remote branch to track (default: main)
      -d <path>       Specify the base directory of the git repository  (required)
      -h              Show this help message
      -l <path>       Specify the path to the log file (default: /tmp/dccd.log)
      -x <path>       Exclude directories matching the specified pattern (relative to the base directory)

"
    exit 1
}

########################################
# Options
########################################

while getopts ":b:d:hl:x:" opt; do
    case "$opt" in
        b)
            REMOTE_BRANCH="$OPTARG"
            ;;
        d)
            BASE_DIR="$OPTARG"
            ;;
        h)
            usage
            ;;

        l)
            LOG_FILE="$OPTARG"
            ;;
        x)
            EXCLUDE="$OPTARG"
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            usage
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            usage
            ;;
    esac
done

########################################
# Script starts here
########################################

touch $LOG_FILE
echo "########################################" >> $LOG_FILE
echo "# Starting!" >> $LOG_FILE
echo "########################################" >> $LOG_FILE
log_message "STATE: Starting!" 

# Check if BASE_DIR is provided
if [ -z "$BASE_DIR" ]; then
    log_message "ERROR: The base directory (-d) is required, exiting..."
    usage
else 
    log_message "INFO:  Base directory is set to $BASE_DIR"
fi

# Check if REMOTE_BRANCH is provided
if [ -z "$BASE_DIR" ]; then
    log_message "STATE: The remote branch isn't specified, so using $REMOTE_BRANCH"
else
    log_message "INFO:  The remote branch is set to $REMOTE_BRANCH"
fi

# Check if directory is excluded
if [ -n "$EXCLUDE" ]; then
    log_message "INFO:  Will be excluding pattern $EXCLUDE"
fi

update_compose_files $BASE_DIR

# Get list of directories to process
#directories_to_process=$(find "$BASE_DIR" -type d ! -path "$BASE_DIR/.git" ! -path "$BASE_DIR/.git/*" ! -path "$BASE_DIR/$EXCLUDE" ! -path "$BASE_DIR/$EXCLUDE/*")

#IFS=$'\n'  # Set the field separator to newline to handle directory names with spaces
#for dir in $directories_to_process; do
#   log_message "INFO:  Processing $dir"
#done
