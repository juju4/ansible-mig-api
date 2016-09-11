#!/bin/sh
## one script to be used by travis, jenkins, packer...

umask 022

rolesdir=$(dirname $0)/..

[ ! -d $rolesdir/adduser ] && git clone https://github.com/juju4/ansible-adduser $rolesdir/adduser
[ ! -d $rolesdir/gpgkey_generate ] && git clone https://github.com/juju4/ansible-gpgkey_generate $rolesdir/gpgkey_generate
[ ! -d $rolesdir/redhat-epel ] && git clone https://github.com/juju4/ansible-redhat-epel $rolesdir/redhat-epel
[ ! -d $rolesdir/golang ] && git clone https://github.com/juju4/ansible-golang $rolesdir/golang

