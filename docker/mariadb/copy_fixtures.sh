#!/bin/sh

filenum=0
filestr=
numcounts=0
gennum () {
	filestr=$filenum
	numcounts=1
	while [ $numcounts -lt 4 ];
	do
		filestr="0$filestr"
		numcounts=$((numcounts+1))
	done
	filenum=$((filenum+1))
}

for file in $(ls /app/fixtures/migrations);
do
	gennum
	cp "/app/fixtures/migrations/$file" "/docker-entrypoint-initdb.d/$filestr-$file"
done

for file in $(ls /app/fixtures/data);
do
	gennum
	cp "/app/fixtures/data/$file" "/docker-entrypoint-initdb.d/$filestr-$file"
done