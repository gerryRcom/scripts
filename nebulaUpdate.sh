#!/bin/bash
# Runs on a weekly cron job, checks for existance of a new nebula binary in a defined folder
# if a binary exists and it's newer than the current running version it is replaced.
#
# Set nebula binary paths
nebulaInstalled='/usr/local/bin/nebula/nebula'
nebulaNew='/tmp/nebula'

# Create log entry
echo "#" >> /var/log/nebulaUpdate.log
echo "#### nebulaUpdate run `date`" >> /var/log/nebulaUpdate.log

# Clean exit if either binary is not present; nothing to do.
if [[ ! -f $nebulaNew ]] || [[ ! -f $nebulaInstalled ]]; then
    echo "Exiting as valid binary not found" >> /var/log/nebulaUpdate.log
    exit 0
fi

# Get nebula binary versions and save to log
nebulaInstalledVersion=`$nebulaInstalled -version | cut -f 2 -d' '`
nebulaNewVersion=`$nebulaNew -version | cut -f 2 -d' '`
echo "Current binary version: $nebulaInstalledVersion" >> /var/log/nebulaUpdate.log
echo "New binary version: $nebulaNewVersion" >> /var/log/nebulaUpdate.log

# Clean exit if binary versions are the same; nothing to do.
if [[ $nebulaInstalledVersion == $nebulaNewVersion ]]; then
    echo "Exiting as new binary not found" >> /var/log/nebulaUpdate.log
    exit 0
fi

# If a new version is detected, stop the service, replce the binary then start the service again, log activity.
echo "#" >> /var/log/nebulaUpdate.log
echo "Stopping service before replacing binary" >> /var/log/nebulaUpdate.log
systemctl stop nebula.service 2>>/var/log/nebulaUpdate.log
echo "Replacing binary" >> /var/log/nebulaUpdate.log
cp -f $nebulaNew $nebulaInstalled 2>>/var/log/nebulaUpdate.log
echo "Starting service after replacing binary" >> /var/log/nebulaUpdate.log
echo "Installed version is now: `$nebulaInstalled -version | cut -f 2 -d' '`" >> /var/log/nebulaUpdate.log
systemctl start nebula.service 2>>/var/log/nebulaUpdate.log
exit 0