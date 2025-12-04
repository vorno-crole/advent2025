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
	# process-line()
	# {
	# 	# local line=$1
	# 	# local outputfile=$2
	# 	# # echo -ne "$line : "

	# 	# answer=$(test-number "$line")
	# 	# echo "$line=$answer" >> ${outputfile}

	# 	local line=$1
	# 	local outputfile=$2
	# 	local ogline=$line

	# 	outputLen=12
	# 	answer=""

	# 	# split the string by char.
	# 	declare -A digits=()
	# 	strToArray "$line"
	# 	# echo ${digits[@]}

	# 	# loop

	# 	while [[ ${#answer} -lt 12 ]]; do

	# 		# find the highest digit between index 0-> (15-12) (lineLen - outputLen)
	# 		# echo -ne "$line : "
	# 		highestDigit
	# 		answer+="$highestValue"
	# 		# echo "[$highestValueIdx] $highestValue. $answer"
	# 		((outputLen--))

	# 		# remove the chars on and before the selected char
	# 		line="${line:$highestValueIdx +1}"
	# 		# split the string by char.
	# 		strToArray "$line"

	# 	done

	# 	echo "$ogline=$answer" >> ${outputfile}
	# }

	# strToArray()
	# {
	# 	digits=()
	# 	local line=$1
	# 	local digit
	# 	local i=0

	# 	while read -u 12 digit; do
	# 		digits[$i]=$digit
	# 		((i++))
	# 	done 12< <(echo $line | grep -o .)
	# }

	# highestDigit()
	# {
	# 	highestValue=-1
	# 	highestValueIdx=-1
	# 	local i
	# 	for (( i=0; i <= ${#line} - outputLen; i++ )); do
	# 		if [[ ${digits[$i]} -gt $highestValue ]]; then
	# 			highestValue=${digits[$i]};
	# 			highestValueIdx=$i;
	# 		fi
	# 	done
	# }
# functions

# output_file=output.txt
# rm -f ${output_file}




putArray()
{
	local x=$1
	local y=$2
	local value=$3

	matrix["$x,$y"]="$value"
}

getArrayValue()
{
	local x=$1
	local y=$2
	# local value=$3

	if (( x < 0 || x > maxrows )); then 
		echo 0
		return
	fi

	if (( y < 0 || y > maxcols )); then 
		echo 0
		return
	fi

	# echo "[$x,$y] = ${matrix[$x,$y]}" >&2

	echo "${matrix["$x,$y"]}"
}







# progressBar "${input_file}"

# read the input file
sum=0
declare -A matrix
row=0

# put chars into 2d array
while read -u 11 -r line; do
	echo $line
	lineLen=${#line}
	
	col=0
	while read -u 12 digit; do
		putArray $row $col $digit
		((col++))
	done 12< <(echo $line | grep -o .)

	# process-line "$line" "${output_file}" && echo -ne "." &
	# ((sum += answer))
	((row++))

done 11< <(tr '.@' '01' < $input_file)

echo
# echo ${matrix[@]}
# exit;


((maxrows=row -1))
((maxcols=col -1))
# TODO
	# now process... somehow?

# iterate array
for (( row=0; row <= maxrows; row++ )); do

	for (( col=0; col <= maxcols; col++ )); do

		# check value.
		value="$(getArrayValue $row $col)"
		# echo -ne $value

		# if 0, skip.
		if (( value == 0 )); then
			echo -ne .
			continue;
		fi

		# assume value is 1.
		# check adjacent values
		adjacent=0
		# echo checking

		for (( checkrow=-1; checkrow <= 1; checkrow++ )); do
			for (( checkcol=-1; checkcol <= 1; checkcol++ )); do

				if (( checkrow == 0 && checkcol == 0 )); then
					continue;
				fi

				# echo $checkrow $checkcol

				checkvalue="$(getArrayValue $((row + checkrow)) $((col + checkcol)))"
				((adjacent+=checkvalue))
			done
		done

		echo -ne $adjacent

		if (( adjacent < 4 )); then
			# echo -ne x
			(( sum++ ))
		else
			# echo -ne @
			true
		fi
	done

	echo
	# break;
done

# wait

# # # Read/sum output file
# sum=$(awk -F'=' '{ sum += $2; } END { print sum }' ${output_file})
# echo -e "\n"
echo "Sum             = $sum"

expected=13
echo "expected result = $expected"
if (( sum != expected )); then
	echo "Error!"
	exit 1;
else
	echo "It worked!"
fi

rm -f ${output_file}
exit;


# --- Part One ---

# The rolls of paper (@) are arranged on a large grid; 
# the Elves even have a helpful diagram (your puzzle input) indicating where everything is located.

# For example:

# ..@@.@@@@.
# @@@.@.@.@@
# @@@@@.@.@@
# @.@@@@..@.
# @@.@@@@.@@
# .@@@@@@@.@
# .@.@.@.@@@
# @.@@@.@@@@
# .@@@@@@@@.
# @.@.@@@.@.

# The forklifts can only access a roll of paper if there are fewer than four rolls of paper 
# in the eight adjacent positions. If you can figure out which rolls of paper the forklifts can access, 
# they'll spend less time looking and more time breaking down the wall to the cafeteria.

# In this example, there are 13 rolls of paper that can be accessed by a forklift (marked with x):

# ..xx.xx@x.
# x@@.@.@.@@
# @@@@@.x.@@
# @.@@@@..@.
# x@.@@@@.@x
# .@@@@@@@.@
# .@.@.@.@@@
# x.@@@.@@@@
# .@@@@@@@@.
# x.x.@@@.x.

# Consider your complete diagram of the paper roll locations. 
# How many rolls of paper can be accessed by a forklift?


# --- Part Two ---
