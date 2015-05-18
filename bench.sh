#!/bin/sh

# How many runs?
TIMES=100

# Common Haste args
ARGS="--opt-whole-program --onexec perf.hs"

# Haste.Foreign args
HFARGS="-D__USE_HASTE_FOREIGN__"

# FFI args
FFIARGS="--with-js=perf-aux.js"

# Haste compile command lines, sans differing arguments
COMPILE_TIGHT="hastec $ARGS -D__USE_TIGHT_LOOP__"
COMPILE_LOOSE="hastec $ARGS"

perf() {
    totaltime=0
    for i in $(seq 1 $TIMES) ; do
        sudo nice -n -20 time -o time.tmp -f %U js perf.js > /dev/null
        totaltime=$(echo "$totaltime+$(cat time.tmp)" | bc)
    done
    avgtime=$(echo "scale=2; $totaltime/$TIMES" | bc)
    echo "$1: $avgtime"
}

compare_ffis() {
    compile="$1"
    name="$2"
    echo "=== $name ==="
    $($compile $HFARGS)
    perf "Haste.Foreign"
    haste="$avgtime"

    $($compile $FFIARGS)
    perf "FFI"
    ratio=$(echo "scale=2; $haste/$avgtime" | bc)
    echo "Haste.Foreign/FFI avg. time ratio: $ratio\n"
}

compare_ffis "$COMPILE_TIGHT" "tight loop (no inbound)"
compare_ffis "$COMPILE_LOOSE" "loose loop (no inbound)"
compare_ffis "$COMPILE_TIGHT -D__MARSHAL_INBOUND__" "tight loop (w/ inbound)"
compare_ffis "$COMPILE_LOOSE -D__MARSHAL_INBOUND__" "loose loop (w/ inbound)"
