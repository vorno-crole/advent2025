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

	if [[ $input_file == 'example' ]]; then
		input_file="example.txt"
	fi

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
# setup


# functions
# functions

# prep
output_file='output.txt'
# rm -f $output_file
exit;



# --- Part Two ---



# --- Part One ---

# You slide down the firepole in the corner of the playground and land in the North Pole base movie theater!

# The movie theater has a big tile floor with an interesting pattern. 
# Elves here are redecorating the theater by switching out some of the square tiles in the big grid they form. 
# Some of the tiles are red; the Elves would like to find the largest rectangle that uses red tiles for two of its opposite corners. 
# They even have a list of where the red tiles are located in the grid (your puzzle input).

# For example:

# 7,1
# 11,1
# 11,7
# 9,7
# 9,5
# 2,5
# 2,3
# 7,3

# Showing red tiles as # and other tiles as ., the above arrangement of red tiles would look like this:

# ..............
# .......#...#..
# ..............
# ..#....#......
# ..............
# ..#......#....
# ..............
# .........#.#..
# ..............
# You can choose any two red tiles as the opposite corners of your rectangle; your goal is to find the largest rectangle possible.

# For example, you could make a rectangle (shown as O) with an area of 24 between 2,5 and 9,7:

# ..............
# .......#...#..
# ..............
# ..#....#......
# ..............
# ..OOOOOOOO....
# ..OOOOOOOO....
# ..OOOOOOOO.#..
# ..............
# Or, you could make a rectangle with area 35 between 7,1 and 11,7:

# ..............
# .......OOOOO..
# .......OOOOO..
# ..#....OOOOO..
# .......OOOOO..
# ..#....OOOOO..
# .......OOOOO..
# .......OOOOO..
# ..............
# You could even make a thin rectangle with an area of only 6 between 7,3 and 2,3:

# ..............
# .......#...#..
# ..............
# ..OOOOOO......
# ..............
# ..#......#....
# ..............
# .........#.#..
# ..............
# Ultimately, the largest rectangle you can make in this example has area 50. One way to do this is between 2,5 and 11,1:

# ..............
# ..OOOOOOOOOO..
# ..OOOOOOOOOO..
# ..OOOOOOOOOO..
# ..OOOOOOOOOO..
# ..OOOOOOOOOO..
# ..............
# .........#.#..
# ..............
# Using two red tiles as opposite corners, what is the largest area of any rectangle you can make?

