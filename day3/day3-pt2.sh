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

		progressBar()
		{
			local input_file=$1
			local total=$(wc -l $input_file | grep -Eo '\d+')
			local j

			echo -ne "Progress:\n["
			eval "printf -- ' %0.s' {1..$total}"
			echo -ne "]"

			if (( COLUMNS <= total )); then
				# echo "Big."
				# echo "Cols  $COLUMNS"
				# echo "Total $total"

				tput cuu 1 # move up 1 col
			fi
			echo -ne "\r["
		}
	# end functions

	if [[ $1 == 'example' || $1 == 'example.txt' ]]; then
		input_file="example.txt"
	fi
# setup


# functions
	process-line()
	{
		# local line=$1
		# local outputfile=$2
		# # echo -ne "$line : "

		# answer=$(test-number "$line")
		# echo "$line=$answer" >> ${outputfile}

		local line=$1
		local outputfile=$2
		local ogline=$line

		outputLen=12
		answer=""

		# split the string by char.
		declare -A digits=()
		strToArray "$line"
		# echo ${digits[@]}

		# loop

		while [[ ${#answer} -lt 12 ]]; do

			# find the highest digit between index 0-> (15-12) (lineLen - outputLen)
			# echo -ne "$line : "
			highestDigit
			answer+="$highestValue"
			# echo "[$highestValueIdx] $highestValue. $answer"
			((outputLen--))

			# remove the chars on and before the selected char
			line="${line:$highestValueIdx +1}"
			# split the string by char.
			strToArray "$line"

		done

		echo "$ogline=$answer" >> ${outputfile}
	}

	strToArray()
	{
		digits=()
		local line=$1
		local digit
		local i=0

		while read -u 12 digit; do
			digits[$i]=$digit
			((i++))
		done 12< <(echo $line | grep -o .)
	}

	highestDigit()
	{
		highestValue=-1
		highestValueIdx=-1
		local i
		for (( i=0; i <= ${#line} - outputLen; i++ )); do
			if [[ ${digits[$i]} -gt $highestValue ]]; then
				highestValue=${digits[$i]};
				highestValueIdx=$i;
			fi
		done
	}
# functions

output_file=output.txt
rm -f ${output_file}

progressBar "${input_file}"

# read the input file
sum=0

while IFS='|' read -u 11 -r line expected; do
	process-line "$line" "${output_file}" && echo -ne "." &
	# ((sum += answer))
done 11< $input_file

wait

# # Read/sum output file
sum=$(awk -F'=' '{ sum += $2; } END { print sum }' ${output_file})
echo -e "\n"
echo "Sum             = $sum"

expected=169347417057382
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
# The escalator doesn't move.
# The Elf explains that it probably needs more joltage to overcome the static friction of the system and hits the big red "joltage limit safety override" button.
# You lose count of the number of times she needs to confirm "yes, I'm sure" and decorate the lobby a bit while you wait.

# Now, you need to make the largest joltage by turning on exactly twelve batteries within each bank.

# The joltage output for the bank is still the number formed by the digits of the batteries you've turned on;
# the only difference is that now there will be 12 digits in each bank's joltage output instead of two.

# Consider again the example from before:

# 987654321111111
# 811111111111119
# 234234234234278
# 818181911112111

# Now, the joltages are much larger:

# In 987654321111111, the largest joltage can be found by turning on everything except some 1s at the end to produce 987654321111.
# In the digit sequence 811111111111119, the largest joltage can be found by turning on everything except some 1s, producing 811111111119.
# In 234234234234278, the largest joltage can be found by turning on everything except a 2 battery, a 3 battery, and another 2 battery near the start to produce 434234234278.
# In 818181911112111, the joltage 888911112111 is produced by turning on everything except some 1s near the front.
# The total output joltage is now much larger: 987654321111 + 811111111119 + 434234234278 + 888911112111 = 3121910778619.


# 234234234234278 : 434234234278
# 987654321111111 : 987654321111
# 811111111111119 : 811111111119
# 818181911112111 : 888911112111

# What is the new total output joltage?


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

