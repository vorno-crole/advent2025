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

	for (( num = $low; num <= $high; num++ )); do
		# echo -ne "$num, "
		numLen=${#num}
		substr=''

		# TODO 
			# iterate the num string, char by char
			# and , each loop, build up the length

			for (( j = 1; j <= numLen; j++ )); do
				# echo -ne "j:$j "
				substr=${num:0:j}
				# echo -ne "sub: $substr "

				if [[ ${#substr} == numLen ]]; then
					continue;
				fi

				# Check the string

				if [[ $num =~ ^(${substr}){2,}$ ]]; then
					echo -e "$num found one! "
					(( sum += $num ))
					break;
				fi

				# the slow way....
				# result=$(ggrep -Po "^(${substr}){2,}$" <<< $num)
				# echo "r: $result"
				# if [[ $result != "" ]]; then
				# 	echo -ne "$num "
				# 	echo -e "found one! "
				# 	(( sum += $num ))
				# 	break;
				# fi
				# echo
			done; 
	done

	echo -ne "."

	# break;
done 11< <(cat $input_file | tr ',' '\n')

echo "sum = $sum"
exit;


# --- Part Two ---
# The clerk quickly discovers that there are still invalid IDs in the ranges in your list. 
# Maybe the young Elf was doing other silly patterns as well?

# Now, an ID is invalid if it is made only of some sequence of digits repeated at least twice. 
# So, 12341234 (1234 two times), 
#     123123123 (123 three times), 
#     1212121212 (12 five times), 
# and 1111111 (1 seven times) are all invalid IDs.

# From the same example as before:

# 11-22 still has two invalid IDs, 11 and 22.
# 95-115 now has two invalid IDs, 99 and 111.
# 998-1012 now has two invalid IDs, 999 and 1010.
# 1188511880-1188511890 still has one invalid ID, 1188511885.
# 222220-222224 still has one invalid ID, 222222.
# 1698522-1698528 still contains no invalid IDs.
# 446443-446449 still has one invalid ID, 446446.
# 38593856-38593862 still has one invalid ID, 38593859.
# 565653-565659 now has one invalid ID, 565656.
# 824824821-824824827 now has one invalid ID, 824824824.
# 2121212118-2121212124 now has one invalid ID, 2121212121.
# Adding up all the invalid IDs in this example produces 4174379265.


222222 found one!
.11 found one!
22 found one!
.99 found one!
111 found one!
.999 found one!
1010 found one!
.1188511885 found one!
..446446 found one!
.38593859 found one!
.565656 found one!
.824824824 found one!
.2121212121 found one!
.sum = 4174379265


# What do you get if you add up all of the invalid IDs using these new rules?



# --- Part One ---

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

