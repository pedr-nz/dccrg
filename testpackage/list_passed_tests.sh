#!/bin/bash

grep -ro "PASS.*$" $1 | sort | tee "$1.passed_list"
wc -l "$1.passed_list"
