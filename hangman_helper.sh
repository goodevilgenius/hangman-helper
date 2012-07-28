#!/bin/bash

words=/usr/share/dict/words
tmp=`mktemp`

always=false
if [ "$1" = "-a" ]
then
    always=true
    shift
    echo "Hit Ctrl-C to exit the program"
fi

[ -n "$1" -a -f "$1" ] && words="$1"

function doit() {
    echo "When entering the word as it is so far known, use a . (period) or - (hyphen) in place of unknown letters, or \"q\" to quit"
    read -p "Word known? " l
    [ "$l" = q ] && return 1
    echo "Simply list all the charcters (no spaces), you have already guessed (you may omit the correct ones, if you choose)"
    read -p "Guessed so far? " g

    f=$(( echo -n $l | sed -r 's/[\.-]//g' ; echo $g ) | fold -w1 | sort | uniq | sed '{:q;N;s/\n//g;t q}')

    if [ -n "$f" ]
    then
	reg="^$(echo $l | sed "s/[\.-]/[^${f}]/g")$"
    else
	reg="^$(echo $l | sed "s/-/./g")$"
    fi

    egrep "$reg" "$words" | tr A-Z a-z | sort | uniq > "$tmp"

    (
	echo 
	echo "Total possible words" $(wc -l <"$tmp")
	echo "Here are five random possibilities"
	shuf "$tmp" | head -5
	echo

	echo "Here are the most common remaining letters"
	sed '{:q;N;s/\n//g;t q}' "$tmp" | sed "s/[$f]//g" | fold -w1 | sort | uniq -c | sort -nr 
    ) | less
}

if $always
then
    while doit
    do let a=0
    done
else
    doit
fi
rm "$tmp"
