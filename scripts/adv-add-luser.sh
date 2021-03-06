#!/bin/bash

# This script creates a new user on the system. The script must be run with superuser privileges.
# You must supply a username as the first argument of the script
# Optionally, you can also provide the ticket request number for the request in the comments field. [TRN-0000]
# Passwords will be automatically generated for the account.
# This script implements message suppression.
# Finally, user account information will be printed to the console.
CONTACT_SYS_ADMIN=0

# Check for superuser status
if [[ "${UID}" -ne 0 ]]
then
  echo 'You must run this script with superuser privileges' >&2
  exit 1
fi

# Check for parameter
if [[ "${#}" -lt 1 ]]
then
  echo 'The first parameter provided must be the username of the account.' >&2
  echo "Usage: ${0} USER_NAME [COMMENT]" >&2
  exit 1
fi

# Extract USER_NAME from Parameter Set
USER_NAME="${1}"

# Bundle all other parameters into a comment
COMMENT="${@}"

# Create the user account, or Log Error
useradd -c "${COMMENT}" -m ${USER_NAME} &> /dev/null
if [[ "${?}" -ne 0 ]]
then
  echo "Unable to create the user account." >&2
  echo 'Manually create the user account, or, submit a ticket to the Sys-Admin Team' >&2
  echo 'If you submit a ticket to the Sys-Admin Team, please allow 48 hours for ticket resolution.' >&2
  echo 'If the Sys-Admin Team cannot meet the 48 hour deadline, you will receive a notification with a set deadline' >&2
  exit 1
fi

# Generate a random password
KEY_FRAGMENT_1=$(date +%s%N) >&2
RANDOM_NUM=$(((RANDOM * 25) + 1 )) >&2
KEY_FRAGMENT_2=$(head -c ${RANDOM_NUM} </dev/urandom) >&2
KEY_FRAGMENT_3="${RANDOM}${RANDOM}${RANDOM}${RANDOM}" >&2
FORGED_KEY="${KEY_FRAGMENT_3}${KEY_FRAGMENT_1}${KEY_FRAGMENT_2}" >&2
PASSWORD=$(echo "${FORGED_KEY}" | sha256sum | head -c 48) >&2

# Set password for the user account, or, Log Error
echo "${PASSWORD}" | passwd --stdin ${USER_NAME} &> /dev/null
if [[ "${?}" -ne 0 ]]
then
  echo "Unable to set the password for the user account." >&2
  echo 'Manually set the password, or, submit a ticket to the Sys-Admin Team' >&2
  echo 'If you submit a ticket to the Sys-Admin Team, please allow 48 hours for ticket resolution.' >&2
  echo 'If the Sys-Admin Team cannot meet the 48 hour deadline, you will receive a notification with a set deadline' >&2
  exit 1
fi

# Force Password Change On First Login
passwd -e ${USER_NAME} &> /dev/null

# Print Info To Console
echo
echo 'Username:'
echo "${USER_NAME}"
echo
echo 'Password:'
echo "${PASSWORD}"
echo
echo 'Hostname:'
echo "${HOSTNAME}"
exit 0