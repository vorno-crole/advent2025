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
	calcArea()
	{
		local c1=$1
		local c2=$2

		local x1 y1
		local x2 y2
		local area
		local Xrange Yrange

		IFS="," read -r x1 y1 <<< "$c1"
		IFS="," read -r x2 y2 <<< "$c2"

		Xrange=$(( x1 - x2 ))
		Yrange=$(( y1 - y2 ))

		if (( Xrange < 0 )); then
			(( Xrange *= -1 ))
		fi
		if (( Yrange < 0 )); then
			(( Yrange *= -1 ))
		fi
		((Xrange++))
		((Yrange++))
		area=$(( Xrange * Yrange ))

		# echo "$c1 $c2 : $Xrange $Yrange : $area"
		echo "$area"
	}
# functions

# prep
# output_file='output.txt'
# rm -f $output_file


# load data into array
coords=()
echo "load data into array"
mapfile -t coords < $input_file

# echo "${coords[@]}"

echo "figure out matrix"
declare -A multiples
i=0
while (( i < ${#coords[@]} )); do
	echo -ne "$i "
	j=0
	while (( j < ${#coords[@]} )); do
		if (( i == j )); then
			((j++))
			continue
		fi

		key="$i,$j"
		if (( j < i )); then
			key="$j,$i"
		fi

		if [[ ${multiples[$key]} != "" ]]; then
			((j++))
			continue
		fi

		area=$(calcArea ${coords[$i]} ${coords[$j]})
		multiples[$key]=$area

		echo -ne .
		((j++))
	done

	echo
	((i++))
done
echo

# echo "${multiples[@]}"
sortedMultiples=()

mapfile -t sortedMultiples < <(printf '%s\n' "${multiples[@]}" | sort -rn)
# echo "${sortedMultiples[@]}"

echo -e "\n"
echo "Largest multiple is ${sortedMultiples[0]}"


# --- Part Two ---

# The Elves just remembered: they can only switch out tiles that are red or green. 
# So, your rectangle can only include red or green tiles.

# In your list, every red tile is connected to the red tile before and after it by a straight line of green tiles. 
# The list wraps, so the first red tile is also connected to the last red tile. 
# Tiles that are adjacent in your list will always be on either the same row or the same column.

# Using the same example as before, the tiles marked X would be green:

# ..............
# .......#XXX#..
# .......X...X..
# ..#XXXX#...X..
# ..X........X..
# ..#XXXXXX#.X..
# .........X.X..
# .........#X#..
# ..............
# In addition, all of the tiles inside this loop of red and green tiles are also green. 
# So, in this example, these are the green tiles:

# ..............
# .......#XXX#..
# .......XXXXX..
# ..#XXXX#XXXX..
# ..XXXXXXXXXX..
# ..#XXXXXX#XX..
# .........XXX..
# .........#X#..
# ..............
# The remaining tiles are never red nor green.

# The rectangle you choose still must have red tiles in opposite corners, 
# but any other tiles it includes must now be red or green. 
# This significantly limits your options.

# For example, you could make a rectangle out of red and green tiles with an area of 15 between 7,3 and 11,1:

# ..............
# .......OOOOO..
# .......OOOOO..
# ..#XXXXOOOOO..
# ..XXXXXXXXXX..
# ..#XXXXXX#XX..
# .........XXX..
# .........#X#..
# ..............
# Or, you could make a thin rectangle with an area of 3 between 9,7 and 9,5:

# ..............
# .......#XXX#..
# .......XXXXX..
# ..#XXXX#XXXX..
# ..XXXXXXXXXX..
# ..#XXXXXXOXX..
# .........OXX..
# .........OX#..
# ..............
# The largest rectangle you can make in this example using only red and green tiles has area 24. 
# One way to do this is between 9,5 and 2,3:

# ..............
# .......#XXX#..
# .......XXXXX..
# ..OOOOOOOOXX..
# ..OOOOOOOOXX..
# ..OOOOOOOOXX..
# .........XXX..
# .........#X#..
# ..............
# Using two red tiles as opposite corners, 
# what is the largest area of any rectangle you can make using only red and green tiles?


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

