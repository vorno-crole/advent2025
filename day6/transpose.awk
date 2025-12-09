# main prog: load data
{
split($0, chars, "")
for (i=1; i<=length($0); i++)
{
a[NR,i] = $i
if (i > max)
{
max = NF
}
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
