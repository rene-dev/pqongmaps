#!/bin/sh

# 2012-02-21 Simon mail@simonszu.de

# Include config for ruby 1.9.2. Specify homedir first
export HOME= 
. $HOME/.bash_profile

# read rvmrc. Specify path to rvmrc first
. $HOME/path/to/.rvmrc

# let rackup start in fcgi mode
export PHP_FCGI_CHILDREN=1

# exec rackup with config from config.ru
exec rackup