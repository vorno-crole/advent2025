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
	remove-last-chars()
	{
		local string=$1
		local num=$2

		# Calculate the new length
		new_length=$(( ${#string} - num ))

		# Extract the substring
		result="${string:0:$new_length}"

		echo "$result"
	}

	index-of()
	{
		local text=$1
		local search=$2
		# text="MULTI: primary virtual IP for xyz/x.x.x.x:44595: 10.0.0.12"
		# search="IP for"

		prefix=${text%%$search*}
		echo ${#prefix}
	}

	test-number()
	{
		local num=$1
		local numLen=${#num}
		local tens
		local units

		# TODO
		# find the largest 12 digit number, without rearranging the digits in $num
		echo -ne "$line "
		
		local answer=""
		local i
		local j
		local startChar=0

		for (( i = 11; i >= 0; i-- )); do
			echo -ne "$i "
			for (( j = 9; j >= 1; j-- )); do
				echo -ne "$j - "
				substr1=$(remove-last-chars $num $i)
				substr2=${substr1:$startChar}
				echo -ne "$substr1 $substr2 "

				if [[ $substr2 =~ $j ]]; then
					answer+="$j"
					startChar=$(index-of $substr1 $j)
					echo -ne "startChar $startChar "
					break;
				fi
			done;
			echo
		done;

		echo $answer
		exit;

		return 1;
	}

	test-line()
	{
		local line=$1
		local outputfile=$2
		# echo -ne "$line : "

		answer=$(test-number "$line")
		echo "$line=$answer" >> ${outputfile}
	}

	check-answer()
	{
		local answer=$1
		local expected=$2

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

# progress bar
# total=$(wc -l $input_file | grep -Eo '\d+')
# echo -ne "Progress:\n "

# for (( j = 1; j <= total; j++ )); do
# 	echo -ne " "
# done
# echo -ne "]\r["

# read the input file
sum=0

while IFS='|' read -u 11 -r line expected; do
	# echo -ne "$line : "
	# lineLen=${#line}
	outputLen=12
	answer=""

	# rm -f ${output_file};

	# split the string by char.
	declare -A digits=()
	strToArray "$line"
	# echo ${digits[@]}

	# echo; cat ${output_file};

	# loop
	echo -ne "$line : "
	i=0
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

		((i++))
		# if (( i == 3 )); then 
		# 	break
		# fi
	done

	echo "$answer"
	((sum += answer))

done 11< $input_file

# # Read/sum output file
# sum=$(awk -F'=' '{ sum += $2; } END { print sum }' ${output_file})
# echo -e "\n"
echo "Sum             = $sum"

# rm -f ${output_file}
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

