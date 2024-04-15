#!/usr/bin/env bash

#
# CIS-CAT Script Check Engine
#
# Name         Date       Description
# -------------------------------------------------------------------
# E. Pinnell   09/05/23   Verify user default group ID (user and GID need to be separated by a ':' e.g. root:0) 

# XCCDF_VALUE_REGEX="root:0" # Example XCCDF_VALUE_REGEX

l_output="" l_output2=""

while IFS=: read -r l_user l_gid; do
   l_passwd_file_gid="$(awk -F: '$1=="'"$l_user"'"{print $4}' /etc/passwd | xargs)"
   if [ "$l_passwd_file_gid" != "$l_gid" ]; then
      l_output2="$l_output2\n  - User \"$l_user\" primary group ID is: \"$l_passwd_file_gid\" and should be: \"$l_gid\""
   else
      l_output="$l_output\n  - User \"$l_user\" primary group ID is correctly set to: \"$l_passwd_file_gid\""
   fi
done <<< "$XCCDF_VALUE_REGEX"

# If the tests produce no failing output, we pass
if [ -z "$l_output2" ]; then
	echo -e "\n- Audit Result:\n  ** PASS **$l_output"
	exit "${XCCDF_RESULT_PASS:-101}"
else
	echo -e "\n- Audit Result:\n  ** FAIL **\n - * Reasons for audit failure * :$l_output2\n"
	exit "${XCCDF_RESULT_FAIL:-102}"
fi