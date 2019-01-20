#!/bin/sh
## one script to be used by travis, jenkins, packer...

umask 022

rolesdir=$(dirname $0)/..

[ ! -d $rolesdir/juju4.adduser ] && git clone https://github.com/juju4/ansible-adduser $rolesdir/juju4.adduser
[ ! -d $rolesdir/juju4.gpgkey_generate ] && git clone https://github.com/juju4/ansible-gpgkey_generate $rolesdir/juju4.gpgkey_generate
[ ! -d $rolesdir/juju4.redhat_epel ] && git clone https://github.com/juju4/ansible-redhat-epel $rolesdir/juju4.redhat_epel
[ ! -d $rolesdir/juju4.golang ] && git clone https://github.com/juju4/ansible-golang $rolesdir/juju4.golang
[ ! -d $rolesdir/juju4.mig-postgres ] && git clone https://github.com/juju4/ansible-mig-postgres $rolesdir/juju4.mig-postgres
## galaxy naming: kitchen fails to transfer symlink folder
#[ ! -e $rolesdir/juju4.mig-api ] && ln -s ansible-mig-api $rolesdir/juju4.mig-api
[ ! -e $rolesdir/juju4.mig-api ] && cp -R $rolesdir/ansible-mig-api $rolesdir/juju4.mig-api

## don't stop build on this script return code
true

