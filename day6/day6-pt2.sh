#!/usr/bin/env bash

# setup
	YLW="\033[33;1m"
	GRN="\033[32;1m"
	WHT="\033[97;1m"
	BLU="\033[94;1m"
	RED="\033[91;1m"
	RES="\033[0m"

	if [[ $1 == "" ]]; then
		echo "No input given"
		echo "Usage: $0 input.txt"
		exit 1;
	fi

	input_file="$1"

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
	# checkNumber()
	# {
	# 	local num=$1
	# 	local low high

	# 	for range in "${ranges[@]}"; do

	# 		# echo -ne "$range "
	# 		low=${range%-*};
	# 		high=${range##*-}

	# 		# echo "$low $high"

	# 		if (( num >= low && num <= high)); then
	# 			echo 1;
	# 			return;
	# 		fi
	# 	done
	# 	echo 0;
	# }

# functions

output_file='output1.txt'

# order the input file
numLines=$(wc -l < ${input_file} | grep -Eo '\d+')
tail -1 ${input_file} > ${input_file}2
head -$((numLines -1)) ${input_file} >> ${input_file}2


# work out the width of each column
delimiters=()
lineNum=0
while read -u 11 -r line; do

	# iterate through line characters
	thisSum=""

	for (( i=0; i<${#line}; i++ )); do
		char="${line:$i:1}"  # Extract one character at index 'i'
		# echo -ne "Character: '$char'"

		if [[ $lineNum -eq 0 && $char != ' ' ]]; then
			# echo -ne " new sum"
			delimiters+=($((i)))
		fi

		# echo
	done

	((lineNum++))
	break;
done 11< ${input_file}2

echo ${delimiters[@]}

# next step, re-read file, go through each column and pop them somewhere.

lineNum=0
while IFS= read -u 11 -r line; do
	# echo "$lineNum - $line"

	# iterate through line characters
	# lineLen=${#line}
	sumNum=0
	lastSum=0 # is this the last sum on the line?

	while ((lastSum == 0)); do
		sumCharStart=$((delimiters[sumNum]))
		sumCharEnd=$((delimiters[sumNum+1] -1))

		if (( sumCharEnd > 1 )); then
			echo -ne "This sum's chars: $sumCharStart -> $sumCharEnd"
			sumWidth=$((sumCharEnd-sumCharStart))
			sum="${line:$sumCharStart:$sumWidth}"
		else
			sumCharEnd="(end)"
			((lastSum++))
			echo -ne "This sum's chars: $sumCharStart -> $sumCharEnd"
			sumWidth=0
			sum="${line:$sumCharStart}"
		fi

		echo "  [$sum]"

		((sumNum++))
	done;

	echo


	# exit;

	# for (( i=0; i<${#line}; i++ )); do
	# 	char="${line:$i:1}"  # Extract one character at index 'i'
	# 	# echo -ne "Character: '$char'"

	# 	if [[ $lineNum -eq 0 && $char != ' ' ]]; then
	# 		# echo -ne " new sum"
	# 		delimiters+=($i)
	# 	fi

	# 	echo
	# done

	((lineNum++))
	# break;
done 11< ${input_file}2


exit;


# then
sum=0
	# echo "$line";

	i=0
	sign=""
	output=""

	while read -u 12 -r num; do
		# echo "$num"
		if (( i == 0 )); then
			# echo "found the sign: $num"
			sign="$num"
			((i++))
			continue
		fi

		output+="$num$sign"
		((i++))
	done 12< <(awk -f split.awk <<< "$line")

	# remove last char
	output="${output%?}"

	echo -ne "$output=";
	answer="$(( $output ))"
	echo "$answer"
	((sum+=answer))



echo
echo "Sum             = $sum"

exit;



# rm -f ${output_file}
exit;


# --- Part Two ---

# The big cephalopods come back to check on how things are going. 
# When they see that your grand total doesn't match the one expected by the worksheet, 
# they realize they forgot to explain how to read cephalopod math.

# Cephalopod math is written right-to-left in columns. 
# Each number is given in its own column, 
# with the most significant digit at the top and the least significant digit at the bottom. 
# (Problems are still separated with a column consisting only of spaces, and the symbol at the bottom of the problem is still the operator to use.)

# Here's the example worksheet again:

# 123 328  51 64 
#  45 64  387 23 
#   6 98  215 314
# *   +   *   +  

# Reading the problems right-to-left one column at a time, the problems are now quite different:

# The rightmost problem is 4 + 431 + 623 = 1058
# The second problem from the right is 175 * 581 * 32 = 3253600
# The third problem from the right is 8 + 248 + 369 = 625
# Finally, the leftmost problem is 356 * 24 * 1 = 8544
# Now, the grand total is 1058 + 3253600 + 625 + 8544 = 3263827.

# Solve the problems on the math worksheet again. 
# What is the grand total found by adding together all of the answers to the individual problems?


# --- Part One ---

# After helping the Elves in the kitchen, 
# you were taking a break and helping them re-enact a movie scene when you over-enthusiastically jumped into the garbage chute!

# A brief fall later, you find yourself in a garbage smasher. 
# Unfortunately, the door's been magnetically sealed.

# As you try to find a way out, you are approached by a family of cephalopods! 
# They're pretty sure they can get the door open, but it will take some time. While you wait, they're curious if you can help the youngest cephalopod with her math homework.

# Cephalopod math doesn't look that different from normal math. 
# The math worksheet (your puzzle input) consists of a list of problems; 
# each problem has a group of numbers that need to be either added (+) or multiplied (*) together.

# However, the problems are arranged a little strangely; 
# they seem to be presented next to each other in a very long horizontal list. 

# For example:

# 123 328  51 64 
#  45 64  387 23 
#   6 98  215 314
# *   +   *   +  

# Each problem's numbers are arranged vertically; 
# at the bottom of the problem is the symbol for the operation that needs to be performed. 
# Problems are separated by a full column of only spaces. 
# The left/right alignment of numbers within each problem can be ignored.

# So, this worksheet contains four problems:

# 123 * 45 * 6 = 33210
# 328 + 64 + 98 = 490
# 51 * 387 * 215 = 4243455
# 64 + 23 + 314 = 401

# To check their work, cephalopod students are given the grand total of adding together all of the answers to the individual problems. 
# In this worksheet, the grand total is 33210 + 490 + 4243455 + 401 = 4277556.

# Of course, the actual worksheet is much wider. You'll need to make sure to unroll it completely so that you can read the problems clearly.

# Solve the problems on the math worksheet. What is the grand total found by adding together all of the answers to the individual problems?

