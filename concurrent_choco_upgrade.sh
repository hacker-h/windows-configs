#!/bin/bash
#Upgrades all installed chocolatey packages to the latest version
packages=$(choco list -la | cut -d' ' -f1)
packages=$(echo ${packages} | cut -d' ' -f2-)
((numberOfPackages = $(echo ${packages} | wc -w) - 1))
packages=$(echo ${packages} | cut -d' ' -f1-${numberOfPackages})
echo ${packages}
for word in ${packages}; do
	start choco upgrade -y ${word} &
done
