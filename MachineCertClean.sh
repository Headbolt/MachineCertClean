#!/bin/bash
#
###############################################################################################################################################
#
# ABOUT THIS PROGRAM
#
#	MachineCertClean.sh
#	https://github.com/Headbolt/MachineCertClean
#
#   This Script is designed for use in JAMF
#
#   This script was designed to check the System Keychain for Expired Certificates in the name of the Machine
#	
#
###############################################################################################################################################
#
# HISTORY
#
#   Version: 1.0 - 01/02/2021
#
#   - 01/02/2021 - V1.0 - Created by Headbolt
#
###############################################################################################################################################
#
# DEFINE VARIABLES & READ IN PARAMETERS
#
###############################################################################################################################################
#
MachineName=$2 # Grab Machine Name from JAMF Variable #2
#
# Set the name of the script for later logging
ScriptName="append prefix here as needed - Delete Expired Machine Certificates"
#
###############################################################################################################################################
#
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
###############################################################################################################################################
#
# Defining Functions
#
###############################################################################################################################################
#
# Certificate Deletion Function
#
DeleteCert(){
#
CertAlreadyDeleted=$(security find-identity | grep $Thumb)
#
if [[ $CertAlreadyDeleted != "" ]] # Check Incase Cert Already Deleted (Certs Often Listed Twice)
	then
		SectionEnd
		/bin/echo 'Deleting expired Certificate ''"'$Name'"'' with Thumbprint'
		/bin/echo $Thumb
		/bin/echo 'Because it has a status of ''"'$Status'"'
		/bin/echo # Outputting a Blank Line for Reporting Purposes
		/bin/echo 'Running Command'
		/bin/echo '"'security delete-certificate -Z $Thumb /Library/Keychains/System.keychain'"'
		#
		security delete-certificate -Z $Thumb /Library/Keychains/System.keychain
		CertsDeleted=YES
fi
#
}
#
###############################################################################################################################################
#
# Section End Function
#
SectionEnd(){
#
/bin/echo # Outputting a Blank Line for Reporting Purposes
/bin/echo  ----------------------------------------------- # Outputting a Dotted Line for Reporting Purposes
/bin/echo # Outputting a Blank Line for Reporting Purposes
#
}
#
###############################################################################################################################################
#
# Script End Function
#
ScriptEnd(){
#
/bin/echo Ending Script '"'$ScriptName'"'
#
/bin/echo # Outputting a Blank Line for Reporting Purposes
/bin/echo  ----------------------------------------------- # Outputting a Dotted Line for Reporting Purposes
/bin/echo # Outputting a Blank Line for Reporting Purposes
#
}
#
###############################################################################################################################################
#
# End Of Function Definition
#
###############################################################################################################################################
#
# Beginning Processing
#
###############################################################################################################################################
#
# Outputting a Blank Line for Reporting Purposes
/bin/echo
SectionEnd
#
IFS=$'\n' # Set the Internal Field Separator to Newline
#
if [ $ZSH_VERSION ] # If Using ZSH instead of Bash then wordsplit needs enabling for the IFS to work
	then
		setopt sh_word_split
fi
#
/bin/echo 'Checking for EXPIRED Certificates matching MachineName ''"'$MachineName'"'
#
ExpiredCerts=$(security find-identity | grep EXPIRED ) # Grabs the expired certificate hashes
#
for Cert in $ExpiredCerts
do
	Thumb=$(/bin/echo $Cert | awk '{print $2}')
	Name=$(/bin/echo $Cert | awk '{print $3}' | cut -c 2- | rev | cut -c 2- | rev)
	Status=$(/bin/echo $Cert | awk '{print $4}')
	#
	if /bin/echo $Name | grep -iqF $MachineName 
		then
			DeleteCert
	fi
done
#
unset IFS # Unset the Internal Field Separator
#
if [[ $CertsDeleted != "YES" ]] # Check Incase no Matching Certs found
	then
		SectionEnd
		/bin/echo "No matching Certificates found"
fi
#
SectionEnd
ScriptEnd
