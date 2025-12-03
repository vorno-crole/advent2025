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
		local tens
		local units

		for (( tens = 9; tens >= 1; tens-- )); do
			# echo -ne $tens
			for (( units = 9; units >= 1; units-- )); do
				# echo $units

				if [[ $num =~ ${tens}{1}[1-9]*${units}{1} ]]; then
					echo "$tens$units";
					return 0;
				fi
			done
		done

		return 1;
	}
# functions





# read the input file
sum=0
while IFS='|' read -u 11 -r line expected; do
	echo -ne "$line : "
	
	answer=$(test-number "$line")
	echo -ne "[$answer] "

	(( sum += answer ))

	if [[ $expected != "" ]]; then 
		if [[ $answer -eq $expected ]]; then
			echo "OK"
		else
			echo "Error"
			exit 1
		fi
	else
		echo
	fi

	# break;
done 11< $input_file

echo "Sum = $sum"
exit;


# --- Part Two ---



# --- Part One ---

# There are batteries nearby that can supply emergency power to the escalator for just such an occasion. 
# The batteries are each labeled with their joltage rating, a value from 1 to 9.
# You make a note of their joltage ratings (your puzzle input). For example:

# 987654321111111
# 811111111111119
# 234234234234278
# 818181911112111
# The batteries are arranged into banks; each line of digits in your input corresponds to a single bank of batteries. 
# Within each bank, you need to turn on exactly two batteries; 
# the joltage that the bank produces is equal to the number formed by the digits on the batteries you've turned on. 
# For example, if you have a bank like 12345 and you turn on batteries 2 and 4, the bank would produce 24 jolts. (You cannot rearrange batteries.)

# You'll need to find the largest possible joltage each bank can produce. In the above example:

# In 987654321111111, you can make the largest joltage possible, 98, by turning on the first two batteries.
# In 811111111111119, you can make the largest joltage possible by turning on the batteries labeled 8 and 9, producing 89 jolts.
# In 234234234234278, you can make 78 by turning on the last two batteries (marked 7 and 8).
# In 818181911112111, the largest joltage you can produce is 92.
# The total output joltage is the sum of the maximum joltage from each bank, so in this example, the total output joltage is 98 + 89 + 78 + 92 = 357.

# There are many batteries in front of you. Find the maximum joltage possible from each bank; what is the total output joltage?

