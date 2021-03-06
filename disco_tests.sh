#!/bin/bash

OUT=/tmp/out

cd disco
find . -name '*.beam' | sudo xargs rm -f
find . -name '*.pyc' | sudo xargs rm -f

cd lib || exit 2
sudo python setup.py install || exit 3
cd .. || exit 2

sudo make install || exit 1
disco start || exit 1

cd tests
python testcases.py | cut -d'.' -f1 | sort | uniq | while read test; do
  grep -q $test ../../shayan/blacklist
  if [ $? -eq 0 ]
  then
      echo "Skipping test $test"
      continue
  fi
  echo "disco test $test"
  disco test $test 2>$OUT
  tail -n 1 $OUT | grep OK
  if [ $? -ne 0 ]
  then
    exit 1
  fi
done

pgrep beam | xargs kill
