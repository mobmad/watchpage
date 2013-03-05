#!/bin/bash
function twilio_notify() {
	curl -X POST "https://api.twilio.com/2010-04-01/Accounts/$TWILIO_ACCOUNT_SID/SMS/Messages.xml" \
		--data-urlencode "From=$TWILIO_FROM" \
		--data-urlencode "To=$TWILIO_TO" \
		--data-urlencode "Body=$LABEL changed. $URL" \
		-u "$TWILIO_ACCOUNT_SID:$TWILIO_TOKEN"
}

# -----------------------------------------------------------------------------
# Argument checking
# -----------------------------------------------------------------------------
LABEL=$1
URL=$2
TWILIO=false

if [ $# -ne 2 ]; then
	echo "Usage: ./script.sh <label> <url>"
	echo "Example: ./script.sh mywebsitechecker http://www.my-web-site.com"
	exit 0
fi

if [ -f "twilio.config" ]; then
	TWILIO=true
	source "twilio.config"
else
	echo "No twilio.config file found. Twilio notifications will not be triggered"
fi

# -----------------------------------------------------------------------------
# Creating git rep for label if not created already
# -----------------------------------------------------------------------------
if [ ! -d "$LABEL" ]; then
	echo "Directory $LABEL does not exist, creating directory and initializing as git repo."
	mkdir $LABEL && \
	cd $LABEL && \
	git init && \
	touch data.txt && \
	git add data.txt && \
	git commit -m "Initial commit" && \
	echo "Done! Optional: Add a git remote to $LABEL and configure post-commit hooks on remote (github/bitbucket)"
	exit 0
fi


# -----------------------------------------------------------------------------
# Run loop
# -----------------------------------------------------------------------------
cd $LABEL
echo "Monitoring $LABEL ($URL)"

while true; do
	echo "Checking at $(date)"
	
	curl -L "$URL" > data.txt || echo "Curl failed with code $?" > data.txt
	git commit -am "Content changed" 

	# Checks the exit code of the last command. Will be 0 if a commit was made, 1 on no changes
	if [[ $? -eq 0 ]] ; then
		echo "CONTENT CHANGED"
		if [[ $(git remote|wc -l|tr -d ' ') -eq "1" ]] ; then
			git push origin master
		fi

		if $TWILIO ; then
			twilio_notify
		fi
	fi

	# Sleep 10-15 mins
	SLEEP_MINS=$(($RANDOM % 6 + 10))
	echo "Sleeping $SLEEP_MINS mins..."
	sleep $((60 * $SLEEP_MINS))
done