#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "$0")"; pwd)"

# for debugging only:
#set | sort

. "$SCRIPT_DIR/ooom-config.sh"

# for debugging only:
#set | sort | grep _ | egrep -v '^(BASH|UPSTART)_'

if [ ! -d "$LOG_DIR" ]
then
	mkdir -p "$LOG_DIR"
fi

for i in `seq 1 1 10`
do
	file="$SCRIPT_DIR/ooom-boot-$i.sh"

	if [ ! -f "$file" ]
	then
		continue
	fi

	LOG=$LOG_DIR/ooom.log

	echo === Executing: bash -x "$file" | tee -a $LOG

	LOGN=$LOG_DIR/ooom-boot-$i.log

	bash -x "$file" 2>&1 | tee -a $LOGN

	echo === $file returned $? at `date` | tee -a $LOG

	mv "$file" "$file.done"

	j=$(($i + 1))

	nextfile="$SCRIPT_DIR/ooom-boot-$j.sh"

	if [ -f "$nextfile" ]
	then
		echo === Executing: shutdown -r now | tee -a $LOG

		shutdown -r now
		exit
	fi

	if [ "$FINAL_COMMAND" ]
	then
		echo === Executing: $FINAL_COMMAND | tee -a $LOG

		$FINAL_COMMAND
	fi

done
