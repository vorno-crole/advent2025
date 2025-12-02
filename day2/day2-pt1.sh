#!/usr/bin/env bash

# setup
	YLW="\033[33;1m"
	GRN="\033[32;1m"
	WHT="\033[97;1m"
	BLU="\033[94;1m"
	RED="\033[91;1m"
	RES="\033[0m"

	input_file="input.txt"

	# functions
		pause()
		{
			read -p "Press Enter to continue."
		}
	# end functions

	if [[ $1 == 'example' ]]; then 
		input_file="example.txt"
	fi
# setup


sum=0


# read the input file, line by line
i=0
while IFS='-' read -u 11 -r low high; do
	((i++))
	# echo -e "$i : $low - $high";

	for (( num=$low; num <= $high; num++ )); do
		# echo -ne "$num, "

		# TODO 
			# split the number into two even-sized strings
			# if both splits are ==, then +1
			len=${#num}
			# echo -ne "$len "
			len=$(( len / 2 ))
			# echo "$len"
			
			split1=${num:0:len}
			len=$(( len++ ))
			split2=${num:len}

			# echo -ne "$split1 $split2, "

			if [[ $split1 == $split2 ]]; then
				# echo -ne "found one!"
				(( sum += $num ))
			fi

	done

	echo -ne "."

	# break;
done 11< <(cat $input_file | tr ',' '\n')

echo "sum = $sum"


# Since the young Elf was just doing silly patterns, you can find the invalid IDs by looking for any ID which is made only of some sequence of digits repeated twice. 
# So, 55 (5 twice), 6464 (64 twice), and 123123 (123 twice) would all be invalid IDs.

# None of the numbers have leading zeroes; 0101 isn't an ID at all. (101 is a valid ID that you would ignore.)

# Your job is to find all of the invalid IDs that appear in the given ranges. In the above example:

# 11-22 has two invalid IDs, 11 and 22.
# 95-115 has one invalid ID, 99.
# 998-1012 has one invalid ID, 1010.
# 1188511880-1188511890 has one invalid ID, 1188511885.
# 222220-222224 has one invalid ID, 222222.
# 1698522-1698528 contains no invalid IDs.
# 446443-446449 has one invalid ID, 446446.
# 38593856-38593862 has one invalid ID, 38593859.
# The rest of the ranges contain no invalid IDs.
# Adding up all the invalid IDs in this example produces 1227775554.

# What do you get if you add up all of the invalid IDs?

