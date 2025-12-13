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
rm -f $output_file

distances_file="distances.txt"

if [ ! -f $distances_file ]; then
    echo "Distances file not found!"
	exit 1;
fi

declare -A jboxes
declare -A distances

lineNum=0
while IFS=, read -u 11 -r x y z; do
	# echo "$lineNum: $x, $y, $z"
	jboxes[$lineNum]="$x,$y,$z,0" # 0 = no circuit
	((lineNum++))
done 11< ${input_file}

# cat distances.txt; exit

echo "load distances into array"
i=0
while IFS="|" read -u 11 -r dist j1 jbox1 j2 jbox2; do
	# 316.90219311326957113731|0|162,817,812|19|425,690,689
	# echo "$i: $dist $j1 $jbox1 $j2 $jbox2"

	distances[$i]="$dist|$j1|$j2"
	((i++))
done 11< $distances_file


echo "iterate thru closest 1000 distances"
declare -A circuits
maxDepth=1000
maxCirc=0
# for (( i=0; i< $maxDepth; i++ )); do
i=0
while true; do
	echo -ne "$i  "
	IFS="|" read -r dist j1 j2 <<< "${distances[$i]}"
	# echo "$dist $j1 $j2"
	# echo "${jboxes[$j1]}"
	# echo "${jboxes[$j2]}"

	# get info on j1 and j2
	IFS="," read -r x1 y1 z1 c1 <<< "${jboxes[$j1]}"
	IFS="," read -r x2 y2 z2 c2 <<< "${jboxes[$j2]}"

	# pair="$c1$c2"

	# if neither are in a circuit, link them up, new circ number
	if (( c1 == 0 && c2 == 0 )); then
		((maxCirc++))
		c1=$maxCirc
		c2=$maxCirc
		jboxes[$j1]="$x1,$y1,$z1,$c1"
		jboxes[$j2]="$x2,$y2,$z2,$c2"

		circuits[$maxCirc]="$j1,$j2"
		echo -ne "new circ: C$maxCirc  "
		echo ${circuits[$maxCirc]}

	# if one is in a circuit, one is not, link them up, same circ number
	elif (( (c1 == 0 && c2 > 0) || (c2 == 0 && c1 > 0) )); then
		circ=$(( c1 + c2 ))
		jboxes[$j1]="$x1,$y1,$z1,$circ"
		jboxes[$j2]="$x2,$y2,$z2,$circ"

		value=${circuits[$circ]}
		if (( c1 == 0 )); then
			circuits[$circ]="$value,$j1"
		else
			circuits[$circ]="$value,$j2"
		fi

		echo -ne "link up, same circ: C$circ  "
		echo ${circuits[$circ]}

	# if both are in same circuit, nothing to do
	# if (( c1 == 0 && c2 == 0 ))
	elif (( c1 > 0 && c2 > 0 && c1 == c2 )); then
		echo -ne "nothing to do: already in same circ: C$c1 [$j1] [$j2]  "
		echo ${circuits[$c1]}

	## if both in a circuit, diff circuits - gotta combine them!
	elif (( c1 > 0 && c2 > 0 && c1 != c2 )); then
		# how?
		echo "!! combine C$c1 and C$c2  "

		circ=$c1
		# jboxes[$j1]="$x1,$y1,$z1,$circ"
		# jboxes[$j2]="$x2,$y2,$z2,$circ"

		value=${circuits[$c1]}
		circuits[$c1]="$value,${circuits[$c2]}"


		# iterate all the c2's, open jbox and set to c1
		# echo "${circuits[$c2]}"
		circJboxes=()
		IFS=, read -ra circJboxes <<< "${circuits[$c2]}"

		for j3 in "${circJboxes[@]}"; do
			# echo "$j3"
			IFS="," read -r x3 y3 z3 c3 <<< "${jboxes[$j3]}"
			jboxes[$j3]="$x3,$y3,$z3,$circ"
		done

		# echo "count of circs: ${#circuits[@]}"
		unset circuits[$c2]
		# echo "count of circs: ${#circuits[@]}"

		echo -ne "${circuits[$c1]}  "
		# echo -ne "${circuits[$c2]}  "
		echo

		# exit;
	fi

	# if (( i >= 100 )); then
	# 	exit
	# fi

	if (( i > 0 && ${#circuits[@]} == 1 )); then
		echo -ne "Are we done?     "

		IFS="," read -r x1 y1 z1 c1 <<< "${jboxes[$j1]}"
		circJboxes=()
		IFS="," read -ra circJboxes <<< "${circuits[$c1]}"
		echo -ne "Circ $circNum size: ${#circJboxes[@]}  "

		if [[ ${#circJboxes[@]} -eq 1000 ]]; then
			echo "yes"

			echo "${jboxes[$j1]}"
			echo "${jboxes[$j2]}"

			echo "x coords multiplied: "
			echo $(( x1 * x2 ))

			break;
		else
			echo "no"
		fi

	fi

	((i++))
done


echo "printing all circuits and size"
for circNum in "${!circuits[@]}"; do
	# echo "Key: $line"
	# echo "Value: ${circuits[$line]}"
	circJboxes=()
	IFS="," read -ra circJboxes <<< "${circuits[$circNum]}"

	echo -ne "Circ $circNum size: ${#circJboxes[@]}  "
	echo ${circJboxes[@]}
	echo "${#circJboxes[@]}=C$circNum" >> $output_file
done

# echo "${circuits[@]}"
echo
echo -ne "Result is: "
sort -nr output.txt | head -n3 | awk -F'=' 'BEGIN {sum=1;} {sum*=$1;} END {print sum}'
exit;


# --- Part Two ---

# The Elves were right; they definitely don't have enough extension cables. 
# You'll need to keep connecting junction boxes together until they're all in one large circuit.

# Continuing the above example, 
# the first connection which causes all of the junction boxes to form a single circuit is between the junction boxes at 216,146,977 and 117,168,530. 
# The Elves need to know how far those junction boxes are from the wall so they can pick the right extension cable; 
# multiplying the X coordinates of those two junction boxes (216 and 117) produces 25272.

# Continue connecting the closest unconnected pairs of junction boxes together until they're all in the same circuit. 
# What do you get if you multiply together the X coordinates of the last two junction boxes you need to connect?


# --- Part One ---

# Equipped with a new understanding of teleporter maintenance, you confidently step onto the repaired teleporter pad.

# You rematerialize on an unfamiliar teleporter pad and find yourself in a vast underground space which contains a giant playground!

# Across the playground, a group of Elves are working on setting up an ambitious Christmas decoration project. 
# Through careful rigging, they have suspended a large number of small electrical junction boxes.

# Their plan is to connect the junction boxes with long strings of lights. 
# Most of the junction boxes don't provide electricity; however, when two junction boxes are connected by a string of lights, 
# electricity can pass between those two junction boxes.

# The Elves are trying to figure out which junction boxes to connect so that electricity can reach every junction box. 
# They even have a list of all of the junction boxes' positions in 3D space (your puzzle input).

# For example:

# 162,817,812
# 57,618,57
# 906,360,560
# 592,479,940
# 352,342,300
# 466,668,158
# 542,29,236
# 431,825,988
# 739,650,466
# 52,470,668
# 216,146,977
# 819,987,18
# 117,168,530
# 805,96,715
# 346,949,466
# 970,615,88
# 941,993,340
# 862,61,35
# 984,92,344
# 425,690,689

# This list describes the position of 20 junction boxes, one per line. 
# Each position is given as X,Y,Z coordinates. 
# So, the first junction box in the list is at X=162, Y=817, Z=812.

# To save on string lights, 
# the Elves would like to focus on connecting pairs of junction boxes that are as close together as possible according to straight-line distance. 
# In this example, the two junction boxes which are closest together are 162,817,812 and 425,690,689.

# By connecting these two junction boxes together, because electricity can flow between them, 
# they become part of the same circuit. 
# After connecting them, there is a single circuit which contains two junction boxes, 
# and the remaining 18 junction boxes remain in their own individual circuits.

# Now, the two junction boxes which are closest together but aren't already directly connected are 162,817,812 and 431,825,988. 
# After connecting them, since 162,817,812 is already connected to another junction box, 
# there is now a single circuit which contains three junction boxes and an additional 17 circuits which contain one junction box each.

# The next two junction boxes to connect are 906,360,560 and 805,96,715. 
# After connecting them, there is a circuit containing 3 junction boxes, a circuit containing 2 junction boxes, 
# and 15 circuits which contain one junction box each.

# The next two junction boxes are 431,825,988 and 425,690,689. 
# Because these two junction boxes were already in the same circuit, nothing happens!

# This process continues for a while, and the Elves are concerned that they don't have enough extension cables for all these circuits. 
# They would like to know how big the circuits will be.

# After making the ten shortest connections, there are 11 circuits: 
# one circuit which contains 5 junction boxes, 
# one circuit which contains 4 junction boxes, 
# two circuits which contain 2 junction boxes each, 
# and seven circuits which each contain a single junction box. 
# Multiplying together the sizes of the three largest circuits (5, 4, and one of the circuits of size 2) produces 40.

# Your list contains many junction boxes; connect together the 1000 pairs of junction boxes which are closest together. 
# Afterward, what do you get if you multiply together the sizes of the three largest circuits?

