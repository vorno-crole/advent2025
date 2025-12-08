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
			# local input_file=$1
			# local total=$(wc -l $input_file | grep -Eo '\d+' | head -1)
			local total=$1
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

	checkNumInRange()
	{
		local low=$1
		local high=$2
		local num=$3

		# echo "$low $high"
		if (( num >= low && num <= high)); then
			echo 1;
			return;
		fi

		echo 0;
	}

	countRange()
	{
		local low=$1
		local high=$2

		echo $((high - low + 1))
	}


	# 3-5
	# 10-14
	# 16-20
	# 12-18



# input	3-10
# 					update	new range	remove existing range
# ranges	1-2		no
# 			11-20	no
# 			1-5		yes		1-10		y
# 			5-10	yes		1-10		y
# 			6-20	yes		6-20		y




	insertRange()
	{
		local inLow=$1
		local inHigh=$2
		local update=1

		declare -A dropRanges=()

		echo -e "\ninserting range ${inLow}-${inHigh}"

		if [[ ! -s ${ranges_file} ]]; then
			echo "${inLow}-${inHigh}" >> ${ranges_file}
			echo "adding without changes"
			return
		fi

		# input 3, 5
		while (( update == 1 )); do
			update=0
			add=1

			tracking=0
			checknumber=-1
			# checknumber=43423330466629

			if (( inLow == checknumber || inHigh == checknumber )); then
				tracking=1;
			fi
			

			key=0
			while IFS=- read -u 12 -r rLow rHigh; do
				((key++))
				echo "$key: checking ${rLow}-${rHigh}"

				# # iterate ranges
				# rLow = 1
				# rHigh = 10

				if (( inLow <= rLow && inHigh >= rLow )); then
					echo "A: dropping $rLow-$rHigh"

					if (( rLow < inLow )); then
						inLow=$rLow
					fi

					if (( rHigh > inHigh )); then
						inHigh=$rHigh
					fi

					update=1
					echo "new insert is ${inLow}-${inHigh}"
				fi

				if (( tracking == 1 )); then
					echo "input: ${inLow}-${inHigh}"
					echo "range: ${rLow}-${rHigh}"
					pause
				fi

				if (( inLow <= rHigh && inHigh >= rHigh )); then
					echo "B: dropping $rLow-$rHigh"

					if (( rLow < inLow )); then
						inLow=$rLow
					fi

					if (( rHigh > inHigh )); then
						inHigh=$rHigh
					fi
					update=1
					echo "new insert is ${inLow}-${inHigh}"
				fi

				if (( inHigh < inLow )); then
					echo "Error!"
					exit 1;
				fi

				if (( tracking == 1 )); then
					echo "input: ${inLow}-${inHigh}"
					echo "range: ${rLow}-${rHigh}"
					pause
				fi


				# TODO check for the inverse?
				#		inputlow AND inputhigh are both wholly contained within a range
				if (( update == 0 )); then
					checkInverse=0
					((checkInverse+=$(checkNumInRange $rLow $rHigh $inLow)))
					((checkInverse+=$(checkNumInRange $rLow $rHigh $inHigh)))
					# echo "$checkInverse : $add"
					# echo 

					if (( checkInverse == 2 )); then
						echo "do not add"
						add=0
						pause
						break
					fi
					# pause
				fi


				if (( update == 1 )); then
					# echo "input: ${inLow}-${inHigh}"
					# echo "range: ${rLow}-${rHigh}"
					# pause
					sed -i '' "${key}d" ${ranges_file}
					# pause
					# dropRanges+=($rLow);
					echo "rerun!"
					echo "input: ${inLow}-${inHigh}"
					break;
				# else
				# 	echo "adding without changes"
				fi

			done 12< ${ranges_file}

			if (( add == 0 )); then
				break;
			fi

		done

		if (( add == 1 )); then
			# ranges[$inLow]="${inLow}-${inHigh}"
			echo -e "adding range ${inLow}-${inHigh}\n"
			echo "${inLow}-${inHigh}" >> ${ranges_file}
			# pause
			# echo
		fi
	}


# functions

ranges_file=ranges.txt

rm -f ${output_file}
rm -f ${ranges_file}
touch ${ranges_file}


# read the input file
sum=0


# put ranges into array
# declare -A ranges
mode=load
echo "Load ranges"

progressBar $(grep -n '^$' example.txt | cut -d: -f1)

i=0
while IFS=- read -u 11 -r low high; do
	((i++))
	if [[ $mode == "load" ]]; then
		if [[ $low == "" ]]; then
			break
		fi

		insertRange $low $high # && echo -ne "."
		# if (( i == 2 )); then 
		# 	break;
		# fi
	fi
done 11< $input_file

# echo -ne "$ranges" > ranges.txt
sort -n -u -o ranges.txt ranges.txt
# sum=$(wc -l ranges.txt | grep -Eo '\d+' | head -1)

sum=0
rm -f ${ranges_file}2
while IFS=- read -u 11 -r low high; do
	count=$(countRange $low $high)
	echo "$low-$high=$count" >> ${ranges_file}2
	((sum+=count))
done 11< ${ranges_file}




# ranges.txt should be:
# 3-5
# 10-20

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
