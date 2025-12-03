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


# functions
	test-number()
	{
		local num=$1
		local numLen=${#num}
		local mid=$(( numLen / 2 ))
		local j

		for (( j = 1; j <= mid; j++ )); do
			local substr=${num:0:j}

			# Check the string
			if [[ $num =~ ^(${substr}){2,}$ ]]; then
				return 0
				break;
			fi
		done;

		return 1;
	}

	test-range()
	{
		local low=$1
		local high=$2
		local outputfile=$3

		local num
		local sum=0

		for (( num = $low; num <= $high; num++ )); do
			if test-number "$num"; then
				(( sum += $num ))
			fi
		done

		echo "$low-$high=$sum" >> ${outputfile}
	}
# functions

output_file=output.txt
rm -f ${output_file}

# read the input file
while IFS='-' read -u 11 -r low high; do
	test-range "$low" "$high" "$output_file" && echo -ne "." &
done 11< <(cat $input_file | tr ',' '\n')

wait

# Read/sum output file
sum=$(awk -F'=' '{ sum += $2; } END { print sum }' ${output_file})
echo
echo "sum             = $sum"

expected=37432260594
echo "expected result = $expected"
if (( sum != expected )); then
	echo "Error!"
	exit 1;
else
	echo "It worked!"
fi

rm -f ${output_file}
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

