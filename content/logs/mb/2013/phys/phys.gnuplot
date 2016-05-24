set key off
set xlabel "weight (kg)"
set ylabel "height (cm)"

set term svg dashed font "helvetica,10"
set output "phys.svg"

plot [43:77] [140:190] \
    100*sqrt(x/18.5) lt 2 lc rgb "gray", \
    100*sqrt(x/20.34) lt 1 lc rgb "pink", \
    100*sqrt(x/21.93) lt 1 lc rgb "gray", \
    100*sqrt(x/23.52) lt 1 lc rgb "light-blue", \
    100*sqrt(x/25) lt 2 lc rgb "gray", \
    "fem.txt" lc rgb "magenta", \
    "fem.txt" using ($1+0.5):($2):3 with labels left, \
    "mal.txt" lc rgb "blue", \
    "mal.txt" using ($1+0.5):($2):3 with labels left
