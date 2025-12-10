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
	followLine()
	{
		local x="$1"
		local y="$2"
		local prev="$3"

		prevLen=${#prev}

		# echo "followLine $x $y $prev"

		char=$(getChar $x $y)
		# echo "$char"

		case $char in
			'|')
				# follow the line
				followLine $x $((y+1)) $prev
				return;;
			
			'^')
				# follow two lines!
				if (( prevLen <= maxPids )); then
					followLine $((x-1)) $((y+1)) "${prev}L" &
					followLine $((x+1)) $((y+1)) "${prev}R" &
				else
					followLine $((x-1)) $((y+1)) "${prev}L"
					followLine $((x+1)) $((y+1)) "${prev}R"
				fi
				return;;

			'.')
				# error
				echo "Error: $x $y $prev"
				exit 1;;

			'')
				# no more lines!
				echo "$prev" | tee -a $output_file;;
		esac
	}

	followLine2()
	{
		local x="$1"
		local y="$2"
		# local value="$3"

		# echo "followLine2 $x $y $counter"

		char=$(getChar $x $y)
		# echo "$char"

		# local showme=0
		# if (( maxX < x )); then
		# 	maxX=$x
		# 	showme=1
		# fi
		# if (( maxY < y )); then
		# 	maxY=$y
		# 	showme=1
		# fi
		# if (( showme == 1 )); then
		echo -ne "\rProcessing $x,$y..."
		# fi

		case $char in
			'S')
				# follow the line
				putCharCounter $x $y $char
				followLine2 $x $((y+1))
				return;;

			'|')
				# capture a +1 on this x,y
				# then follow the line
				addCounter $x $y 1
				followLine2 $x $((y+1))
				return;;
			
			'^')
				# follow two lines
				putCharCounter $x $y $char
				followLine2 $((x-1)) $((y+1)) # L
				followLine2 $((x+1)) $((y+1)) # R
				return;;

			'.')
				# error
				echo "Error: $x $y"
				exit 1;;

			'')
				# no more lines!
				# echo "$prev" | tee -a $output_file
				return;;
		esac
	}


	getChar()
	{
		local x="$1"
		local y="$2"
		local line char

		line="${lines[$y]}"
		char="${line:$x:1}"
		echo $char
	}

	addValue()
	{
		addCounter $1 $2 $3
	}

	getValue()
	{
		local x="$1"
		local y="$2"
		local key="$x,$y"
		local value=0

		if [[ ${counter[$key]} != "" ]]; then
			value="${counter[$key]}"
		fi

		echo "$value"
	}

	addCounter()
	{
		local x="$1"
		local y="$2"
		local num="$3"
		local key="$x,$y"

		if [[ ${counter[$key]} == "" ]]; then
			counter[$key]=0
		fi

		local value=${counter[$key]}
		((value+=num))

		counter[$key]=$value
	}

	putCharCounter()
	{
		local x="$1"
		local y="$2"
		local value="$3"
		local key="$x,$y"

		counter[$key]=$value
	}

# functions

# prep
output_file='output-calcs.txt'
rm -f $output_file

# create the solution
./day7-pt1.sh ${input_file} > /dev/null
input_file="output.txt"


# load lines into array
declare -A lines
declare -A counter
lineNum=0
while IFS= read -u 11 -r line; do
	lines[$lineNum]="$line"
	((lineNum++))
done 11< ${input_file}

# echo "${lines[@]}"

# iterate lines and chars
# add everything up?
for (( y=0; y < lineNum; y++ )); do
	line="${lines[$y]}"

	for (( x=0; x < ${#line}; x++ )); do
		char=$(getChar $x $y)

		case $char in
			'.') ;;

			'S') value=1
				 addValue $((x)) $((y+1)) $value;;

			'|') value=$(getValue $((x)) $((y-1)))
				 addValue $((x)) $((y+1)) $value;;

			'^') value=$(getValue $((x)) $((y-1)))
				 addValue $((x-1)) $((y+1)) $value
				 addValue $((x+1)) $((y+1)) $value;;
		esac
	done
done


# outputs
shopt -s extglob;
for (( y=0; y < lineNum; y++ )); do
	line="${lines[$y]}"
	lineSum=0
	outline=""
	for (( x=0; x < ${#line}; x++ )); do

		char="${counter["$x,$y"]}"

		case $char in
			'.' | '^' | 'S')
				outline+="$char";;

			'') outline+=".";;

			*([0-9]))
				((lineSum+=char))
				outline+="$(printf '%x' $char)";;
		esac
	done

	echo "$outline = $lineSum" | tee -a ${output_file}
done

echo
echo -ne "Result is: "
tail -n1 output-calcs.txt | awk -F'=' '{print $2}'

exit;






# --- Part Two ---

# With your analysis of the manifold complete, you begin fixing the teleporter. 
# However, as you open the side of the teleporter to replace the broken manifold, 
# you are surprised to discover that it isn't a classical tachyon manifold - it's a quantum tachyon manifold.

# With a quantum tachyon manifold, only a single tachyon particle is sent through the manifold. 
# A tachyon particle takes both the left and right path of each splitter encountered.

# Since this is impossible, the manual recommends the many-worlds interpretation of quantum tachyon splitting: 
# each time a particle reaches a splitter, it's actually time itself which splits. 
# In one timeline, the particle went left, and in the other timeline, the particle went right.

# To fix the manifold, what you really need to know is the number of timelines active after 
# a single particle completes all of its possible journeys through the manifold.

# In the above example, there are many timelines. For instance, there's the timeline where the particle always went left:

# .......S.......
# .......|.......
# ......|^.......
# ......|........
# .....|^.^......
# .....|.........
# ....|^.^.^.....
# ....|..........
# ...|^.^...^....
# ...|...........
# ..|^.^...^.^...
# ..|............
# .|^...^.....^..
# .|.............
# |^.^.^.^.^...^.
# |..............

# Or, there's the timeline where the particle alternated going left and right at each splitter:

# .......S.......
# .......|.......
# ......|^.......
# ......|........
# ......^|^......
# .......|.......
# .....^|^.^.....
# ......|........
# ....^.^|..^....
# .......|.......
# ...^.^.|.^.^...
# .......|.......
# ..^...^|....^..
# .......|.......
# .^.^.^|^.^...^.
# ......|........

# Or, there's the timeline where the particle ends up at the same point as the alternating timeline, but takes a totally different path to get there:

# .......S.......
# .......|.......
# ......|^.......
# ......|........
# .....|^.^......
# .....|.........
# ....|^.^.^.....
# ....|..........
# ....^|^...^....
# .....|.........
# ...^.^|..^.^...
# ......|........
# ..^..|^.....^..
# .....|.........
# .^.^.^|^.^...^.
# ......|........

# In this example, in total, the particle ends up on 40 different timelines.

# Apply the many-worlds interpretation of quantum tachyon splitting to your manifold diagram. 
In total, how many different timelines would a single tachyon particle end up on?


# --- Part One ---

# You thank the cephalopods for the help and exit the trash compactor, 
# finding yourself in the familiar halls of a North Pole research wing.

# Based on the large sign that says "teleporter hub", they seem to be researching teleportation; 
# you can't help but try it for yourself and step onto the large yellow teleporter pad.

# Suddenly, you find yourself in an unfamiliar room! The room has no doors; the only way out is the teleporter. 
# Unfortunately, the teleporter seems to be leaking magic smoke.

# Since this is a teleporter lab, there are lots of spare parts, manuals, and diagnostic equipment lying around. 
# After connecting one of the diagnostic tools, it helpfully displays error code 0H-N0, which apparently means that there's an issue with one of the tachyon manifolds.

# You quickly locate a diagram of the tachyon manifold (your puzzle input). 
# A tachyon beam enters the manifold at the location marked S; tachyon beams always move downward. 
# Tachyon beams pass freely through empty space (.). However, if a tachyon beam encounters a splitter (^), 
# the beam is stopped; instead, a new tachyon beam continues from the immediate left and from the immediate right of the splitter.

# For example:

# .......S.......
# ...............
# .......^.......
# ...............
# ......^.^......
# ...............
# .....^.^.^.....
# ...............
# ....^.^...^....
# ...............
# ...^.^...^.^...
# ...............
# ..^...^.....^..
# ...............
# .^.^.^.^.^...^.
# ...............
# In this example, the incoming tachyon beam (|) extends downward from S until it reaches the first splitter:

# .......S.......
# .......|.......
# .......^.......
# ...............
# ......^.^......
# ...............
# .....^.^.^.....
# ...............
# ....^.^...^....
# ...............
# ...^.^...^.^...
# ...............
# ..^...^.....^..
# ...............
# .^.^.^.^.^...^.
# ...............
# At that point, the original beam stops, and two new beams are emitted from the splitter:

# .......S.......
# .......|.......
# ......|^|......
# ...............
# ......^.^......
# ...............
# .....^.^.^.....
# ...............
# ....^.^...^....
# ...............
# ...^.^...^.^...
# ...............
# ..^...^.....^..
# ...............
# .^.^.^.^.^...^.
# ...............
# Those beams continue downward until they reach more splitters:

# .......S.......
# .......|.......
# ......|^|......
# ......|.|......
# ......^.^......
# ...............
# .....^.^.^.....
# ...............
# ....^.^...^....
# ...............
# ...^.^...^.^...
# ...............
# ..^...^.....^..
# ...............
# .^.^.^.^.^...^.
# ...............

# At this point, the two splitters create a total of only three tachyon beams, 
# since they are both dumping tachyons into the same place between them:

# .......S.......
# .......|.......
# ......|^|......
# ......|.|......
# .....|^|^|.....
# ...............
# .....^.^.^.....
# ...............
# ....^.^...^....
# ...............
# ...^.^...^.^...
# ...............
# ..^...^.....^..
# ...............
# .^.^.^.^.^...^.
# ...............
# This process continues until all of the tachyon beams reach a splitter or exit the manifold:

# .......S.......
# .......|.......
# ......|^|......
# ......|.|......
# .....|^|^|.....
# .....|.|.|.....
# ....|^|^|^|....
# ....|.|.|.|....
# ...|^|^|||^|...
# ...|.|.|||.|...
# ..|^|^|||^|^|..
# ..|.|.|||.|.|..
# .|^|||^||.||^|.
# .|.|||.||.||.|.
# |^|^|^|^|^|||^|
# |.|.|.|.|.|||.|
# To repair the teleporter, you first need to understand the beam-splitting properties of the tachyon manifold. 
# In this example, a tachyon beam is split a total of 21 times.

# Analyze your manifold diagram. How many times will the beam be split?
