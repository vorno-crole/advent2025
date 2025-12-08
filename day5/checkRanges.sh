#!/usr/bin/env bash

input_file=ranges.txt

i=0
while IFS=- read -u 11 -r low high; do
	((i++))

	lowcount=$(grep -o $low ranges.txt | wc -l | grep -Eo '\d+')

	highcount=$(grep -o $high ranges.txt | wc -l | grep -Eo '\d+')

	if (( lowcount + highcount > 2 )); then
		echo "low: $low  occurs: $lowcount"
		echo "high: $high  occurs: $highcount"

	fi

done 11< $input_file
