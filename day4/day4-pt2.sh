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

	processLine()
	{
		row=$1
		local col value adjacent checkrow checkcol checkvalue
		local output=""
		local sum=0

		for (( col=0; col <= maxcols; col++ )); do

			# check value.
			value="$(getArrayValue $row $col)"
			# echo -ne $value

			# if 0, skip.
			if (( value == 0 )); then
				# echo -ne .
				output+="."
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

					checkvalue="$(getArrayValue $((row + checkrow)) $((col + checkcol)))"
					((adjacent+=checkvalue))
				done
			done

			# echo -ne $adjacent
			output+="$adjacent"

			if (( adjacent < 4 )); then
				(( sum++ ))
			fi
		done

		echo "$row|$output|$sum" >> "${output_file}"
	}
# functions


rm -f ${output_file}

# read the input file
sum=0
row=0
declare -A matrix

echo "Load data into array"

# put chars into 2d array
while read -u 11 -r line; do
	# echo $line
	lineLen=${#line}
	
	col=0
	while read -u 12 digit; do
		putArray $row $col $digit
		((col++))
	done 12< <(echo $line | grep -o .)

	((row++))
done 11< <(tr '.@' '01' < $input_file)

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
echo "Sum             = $sum" | tee -a sums.txt

# expected=1451
# if [[ $input_file == "example.txt" ]]; then
# 	expected=13
# fi

# echo "expected result = $expected"
# if (( sum != expected )); then
# 	echo "Error!"
# 	exit 1;
# else
# 	echo "It worked!"
# fi

sort -n ${output_file} > ${output_file}2
mv ${output_file}2 ${output_file}

# post-processing....

# create next input file (input2.txt ?)
if (( sum > 0 )); then

	echo "needs another round..."

	((nextRun=run+1))
	awk -F'|' '{print $2}' ${output_file} | tr '0123' '...' | tr '456789' '@@@@@@' > input$nextRun.txt

	./day4-pt2.sh input$nextRun.txt $nextRun 
else

	echo "cannot optimise any further..."

	cat sums.txt

	echo -ne "After this many iterations: "
	wc -l sums.txt | grep -Eo '\d+'

	echo -ne "Grand total is: "
	awk '{ sum += $3 } END { print sum }' sums.txt

fi


# rm -f ${output_file}
exit;


# --- Part Two ---

# Now, the Elves just need help accessing as much of the paper as they can.

# Once a roll of paper can be accessed by a forklift, it can be removed. 
# Once a roll of paper is removed, the forklifts might be able to access more rolls of paper, 
# which they might also be able to remove. 
# How many total rolls of paper could the Elves remove if they keep repeating this process?

# Starting with the same example as above, 
# here is one way you could remove as many rolls of paper as possible, 
# using highlighted @ to indicate that a roll of paper is about to be removed, 
# and using x to indicate that a roll of paper was just removed:

# Initial state:
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

# Remove 13 rolls of paper:
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

# Remove 12 rolls of paper:
# .......x..
# .@@.x.x.@x
# x@@@@...@@
# x.@@@@..x.
# .@.@@@@.x.
# .x@@@@@@.x
# .x.@.@.@@@
# ..@@@.@@@@
# .x@@@@@@@.
# ....@@@...

# Remove 7 rolls of paper:
# ..........
# .x@.....x.
# .@@@@...xx
# ..@@@@....
# .x.@@@@...
# ..@@@@@@..
# ...@.@.@@x
# ..@@@.@@@@
# ..x@@@@@@.
# ....@@@...

# Remove 5 rolls of paper:
# ..........
# ..x.......
# .x@@@.....
# ..@@@@....
# ...@@@@...
# ..x@@@@@..
# ...@.@.@@.
# ..x@@.@@@x
# ...@@@@@@.
# ....@@@...

# Remove 2 rolls of paper:
# ..........
# ..........
# ..x@@.....
# ..@@@@....
# ...@@@@...
# ...@@@@@..
# ...@.@.@@.
# ...@@.@@@.
# ...@@@@@x.
# ....@@@...

# Remove 1 roll of paper:
# ..........
# ..........
# ...@@.....
# ..x@@@....
# ...@@@@...
# ...@@@@@..
# ...@.@.@@.
# ...@@.@@@.
# ...@@@@@..
# ....@@@...

# Remove 1 roll of paper:
# ..........
# ..........
# ...x@.....
# ...@@@....
# ...@@@@...
# ...@@@@@..
# ...@.@.@@.
# ...@@.@@@.
# ...@@@@@..
# ....@@@...

# Remove 1 roll of paper:
# ..........
# ..........
# ....x.....
# ...@@@....
# ...@@@@...
# ...@@@@@..
# ...@.@.@@.
# ...@@.@@@.
# ...@@@@@..
# ....@@@...

# Remove 1 roll of paper:
# ..........
# ..........
# ..........
# ...x@@....
# ...@@@@...
# ...@@@@@..
# ...@.@.@@.
# ...@@.@@@.
# ...@@@@@..
# ....@@@...

# Stop once no more rolls of paper are accessible by a forklift. In this example, a total of 43 rolls of paper can be removed.

# Start with your original diagram. How many rolls of paper in total can be removed by the Elves and their forklifts?



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

