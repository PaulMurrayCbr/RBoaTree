#!/bin/bash

while true
do 
	rdoc -a -o app-doc app
	rails s 
	echo 'ctrl-C now!'; sleep 1; echo 'too late!'
done

