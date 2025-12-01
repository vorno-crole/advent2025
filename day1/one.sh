#!/usr/bin/env bash

# setup
	YLW="\033[33;1m"
	GRN="\033[32;1m"
	WHT="\033[97;1m"
	BLU="\033[94;1m"
	RED="\033[91;1m"
	RES="\033[0m"


	input_file="input"
	dial_current="50"
	dial_size="99" # 0 to 99 
	landed_zeros="0"
	passed_zeros="0"

	# functions
		pause()
		{
			read -p "Press Enter to continue."
		}
	# end functions

	if [[ $1 == 'example' ]]; then 
		input_file="example"
	fi
# setup


echo "dial = $dial_current"
echo "landed zeros = $landed_zeros"
echo "passed zeros = $passed_zeros"

i=0

# read the input file, line by line
while read -u 11 -r line; do
	((i++))
	echo -ne "$i :  ";

	direction="$(grep -Eo '^\w{1}' <<< $line)"
	distance="$(ggrep -Po '\d*$' <<< $line)"

	echo -ne "$direction : $distance  "

	# TODO adjust dial based on input
	dial_prev=$dial_current

	if [[ $direction == 'L' ]]; then
		echo -ne "subtract   "
	elif [[ $direction == 'R' ]]; then
		echo -ne "add   "
	fi

	# round and rounds...
	while [[ $distance -gt 100 ]]; do 
		((distance-=100))
		((passed_zeros+=1))
		echo -ne "passed zeros = $passed_zeros  "
		# check=t
	done

	# apply value
	if [[ $direction == 'L' ]]; then
		((dial_current-=$distance))

		if [[ $dial_current -lt 0 ]]; then
			((dial_current=$dial_current+100))

			if [[ $dial_current -ne 0 && $dial_prev -ne 0 ]]; then
				((passed_zeros+=1))
				echo -ne "passed zero!  "
				echo -ne "passed zeros = $passed_zeros  "
			fi
		fi


	elif [[ $direction == 'R' ]]; then
		((dial_current+=$distance))


		if [[ $dial_current -gt $dial_size ]]; then
			((dial_current=$dial_current-100))

			if [[ $dial_current -ne 0 && $dial_prev -ne 0 ]]; then
				((passed_zeros+=1))
				echo -ne "passed zero!  "
				echo -ne "passed zeros = $passed_zeros  "
			fi
		fi

	fi


	echo -ne "new dial = $dial_current"
	if [[ $dial_current -eq 0 ]]; then
		((landed_zeros+=1))
		# ((passed_zeros-=1))
		echo -ne "   landed zero!"
		echo -ne "landed zeros = $landed_zeros  "
	fi

	if [[ $dial_current -lt 0 ]]; then
		echo "Error"
		exit 1;
	elif [[ $dial_current -gt $dial_size ]]; then
		echo "Error"
		exit 1;
	fi

	echo

	echo "landed zeros = $landed_zeros"
	echo "passed zeros = $passed_zeros"
	# pause

	# if [[ $i -gt 100 ]]; then
	# 	break;
	# fi

done 11< $input_file

echo "landed zeros = $landed_zeros"
echo "passed zeros = $passed_zeros"
echo "sum = $(($landed_zeros+$passed_zeros))"


exit;

# For example, suppose the attached document contained the following rotations:

# L68
# L30
# R48
# L5
# R60
# L55
# L1
# L99
# R14
# L82
# Following these rotations would cause the dial to move as follows:

# The dial starts by pointing at 50.
# The dial is rotated L68 to point at 82.
# The dial is rotated L30 to point at 52.
# The dial is rotated R48 to point at 0.
# The dial is rotated L5 to point at 95.
# The dial is rotated R60 to point at 55.
# The dial is rotated L55 to point at 0.
# The dial is rotated L1 to point at 99.
# The dial is rotated L99 to point at 0.
# The dial is rotated R14 to point at 14.
# The dial is rotated L82 to point at 32.
# Because the dial points at 0 a total of three times during this process, the password in this example is 3.



