# main prog: load data
{
for (i=1; i<=NF; i++)
{
a[NR,i] = $i
}
# find max num of cols
if (NF > max)
{
max = NF
}
}

# finally,
# iterate array sideways (col by col)
END {
for (i=1; i<=max; i++) {
for (j=1; j<=NR; j++) {
printf "%s%s", a[j,i], (j==NR ? "\n" : " ")
}
}
}
