#!/bin/bash
echo "Remove kernel logs"
sudo rm /var/log/kern.log
sudo rm /var/log/syslog
echo "Remoce cache"
sudo rm .cache.mk
echo "Start"
make bzImage -j23 && sudo make install
