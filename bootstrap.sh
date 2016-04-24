#!/bin/bash

\curl -sSL https://github.com/ermaker/bootstrap/raw/master/vagrant.sh | bash

vagrant plugin install vagrant-aws
vagrant plugin install vagrant-env
