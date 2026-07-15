#!/bin/bash

grep -ro "PASS.*$" $1 | sort
