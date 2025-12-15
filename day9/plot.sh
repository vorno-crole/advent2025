#!/bin/bash

# Check if input file is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <coordinate_file>"
    echo "File format: one x,y coordinate per line (e.g., '10,20')"
    exit 1
fi

INPUT_FILE="$1"

# Check if file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: File '$INPUT_FILE' not found"
    exit 1
fi

# Create temporary gnuplot script
GNUPLOT_SCRIPT=$(mktemp)
OUTPUT_IMAGE="output.png"

# Generate gnuplot commands
cat > "$GNUPLOT_SCRIPT" << 'EOF'
set terminal png size 800,800
set output 'output.png'
set title "Connected Line Segments"
set xlabel "X"
set ylabel "Y"
set xrange [0:100000]
set yrange [0:100000]
set grid
plot '-' with lines linewidth 1 linecolor rgb "red" notitle
EOF

# Append coordinate data to gnuplot script
cat "$INPUT_FILE" | tr ',' ' ' >> "$GNUPLOT_SCRIPT"
head -n1 "$INPUT_FILE" | tr ',' ' ' >> "$GNUPLOT_SCRIPT"

# Add end marker for inline data
echo "e" >> "$GNUPLOT_SCRIPT"

# Execute gnuplot
gnuplot "$GNUPLOT_SCRIPT"

# Clean up
rm "$GNUPLOT_SCRIPT"

echo "Plot generated: $OUTPUT_IMAGE"
