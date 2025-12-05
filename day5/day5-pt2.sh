#!/usr/bin/env bash

# setup
	YLW="\033[33;1m"
	GRN="\033[32;1m"
	WHT="\033[97;1m"
	BLU="\033[94;1m"
	RED="\033[91;1m"
	RES="\033[0m"

	input_file="$1"
	run=1
	if [[ $2 != "" ]]; then
		run=$2
	fi
	output_file="output$run.txt"

	# functions
		pause()
		{
			read -p "Press Enter to continue."
		}

		progressBar()
		{
			local input_file=$1
			local total=$(wc -l $input_file | grep -Eo '\d+' | head -1)
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

	if [[ $input_file == 'example' ]]; then
		input_file="example.txt"
	fi
# setup


# functions
	checkNumber()
	{
		local num=$1
		local low high

		for range in "${ranges[@]}"; do

			# echo -ne "$range "
			low=${range%-*};
			high=${range##*-}

			# echo "$low $high"

			if (( num >= low && num <= high)); then
				echo 1;
				return;
			fi
		done
		echo 0;
	}

# functions

rm -f ${output_file}

# read the input file
sum=0

# put ranges into array
ranges=()
mode=load
echo "Load ranges"
while IFS=- read -u 11 -r low high; do

	if [[ $mode == "load" ]]; then
		if [[ $low == "" ]]; then
			echo -e "\nCheck values"
			mode=check
			continue
		fi

		echo "$low-$high"
		ranges+=("$low-$high")

	elif [[ $mode == "check" ]]; then
		num=$low

		fresh=$(checkNumber $num)
		((sum+=fresh))
		echo "$num: $fresh"
	fi

done 11< $input_file

# echo ${ranges[@]}
echo
echo "Sum             = $sum"

exit;




((maxrows=row -1))
((maxcols=col -1))


echo "Processing data"
progressBar "${input_file}"

# iterate array
for (( row=0; row <= maxrows; row++ )); do
	processLine $row && echo -ne "." &
done

wait

# # # Read/sum output file
sum=$(awk -F'|' '{ sum += $3; } END { print sum }' ${output_file})
echo -e "\n"


# rm -f ${output_file}
exit;


# --- Part Two ---

# The Elves start bringing their spoiled inventory to the trash chute at the back of the kitchen.

# So that they can stop bugging you when they get new inventory, 
# the Elves would like to know all of the IDs that the fresh ingredient ID ranges consider to be fresh. 
# An ingredient ID is still considered fresh if it is in any range.

# Now, the second section of the database (the available ingredient IDs) is irrelevant. 
# Here are the fresh ingredient ID ranges from the above example:

# 3-5
# 10-14
# 16-20
# 12-18

# The ingredient IDs that these ranges consider to be fresh are 3, 4, 5, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, and 20. 
# So, in this example, the fresh ingredient ID ranges consider a total of 14 ingredient IDs to be fresh.

# Process the database file again. How many ingredient IDs are considered to be fresh according to the fresh ingredient ID ranges?




# --- Part One ---

# As the forklifts break through the wall, the Elves are delighted to discover that there was a cafeteria on the other side after all.

# You can hear a commotion coming from the kitchen. 
# "At this rate, we won't have any time left to put the wreaths up in the dining hall!" Resolute in your quest, you investigate.

# "If only we hadn't switched to the new inventory management system right before Christmas!" another Elf exclaims. You ask what's going on.

# The Elves in the kitchen explain the situation: because of their complicated new inventory management system, 
# they can't figure out which of their ingredients are fresh and which are spoiled. When you ask how it works, 
# they give you a copy of their database (your puzzle input).

# The database operates on ingredient IDs. 
# It consists of a list of fresh ingredient ID ranges, a blank line, and a list of available ingredient IDs. For example:

# 3-5
# 10-14
# 16-20
# 12-18
# 
# 1
# 5
# 8
# 11
# 17
# 32

# The fresh ID ranges are inclusive: the range 3-5 means that ingredient IDs 3, 4, and 5 are all fresh. The ranges can also overlap; an ingredient ID is fresh if it is in any range.

# The Elves are trying to determine which of the available ingredient IDs are fresh. In this example, this is done as follows:

# Ingredient ID 1 is spoiled because it does not fall into any range.
# Ingredient ID 5 is fresh because it falls into range 3-5.
# Ingredient ID 8 is spoiled.
# Ingredient ID 11 is fresh because it falls into range 10-14.
# Ingredient ID 17 is fresh because it falls into range 16-20 as well as range 12-18.
# Ingredient ID 32 is spoiled.
# So, in this example, 3 of the available ingredient IDs are fresh.

# Process the database file from the new inventory management system. How many of the available ingredient IDs are fresh?

# To begin, get your puzzle input.

# Answer: 
 

# You can also [Share] this puzzle.
