#!/bin/bash

# Script to dynamically find rootvg disks, perform bosboot, update the boot list, and save the system configuration.

# Dynamically find the hdisk names for the rootvg
ROOTVG_HD_DISK=$(lsvg -p rootvg | awk '{print $1}' | grep -E '^hdisk[0-9]+$')

# Check if hdisk names were found
if [ -z "${ROOTVG_HD_DISK}" ]; then
    echo "Error: No hdisk devices found for rootvg."
    exit 1
fi

# Perform bosboot for the rootvg disks
for hdisk in ${ROOTVG_HD_DISK}; do
    echo "Running bosboot for /dev/${hdisk}..."
    if ! bosboot -ad /dev/${hdisk}; then
        echo "Error: bosboot failed for /dev/${hdisk}"
        exit 1
    fi
done

# Perform bosboot for /dev/ipldevice
echo "Running bosboot for /dev/ipldevice..."
if ! bosboot -ad /dev/ipldevice; then
    echo "Error: bosboot failed for /dev/ipldevice"
    exit 1
fi

# Update the boot list
echo "Updating boot list for rootvg disks..."
if ! bootlist -m normal ${ROOTVG_HD_DISK}; then
    echo "Error: Failed to update the normal boot list."
    exit 1
fi

if ! bootlist -m service cd0 rmt0 ${ROOTVG_HD_DISK}; then
    echo "Error: Failed to update the service boot list."
    exit 1
fi

# Save the base system configuration
echo "Saving base system configuration..."
if ! savebase -v; then
    echo "Error: Failed to save the base system configuration."
    exit 1
fi

echo "Script completed successfully."
