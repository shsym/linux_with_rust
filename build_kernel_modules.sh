#!/bin/bash
export INSTALL_MOD_STRIP=1
make modules -j11 && sudo make modules_install
