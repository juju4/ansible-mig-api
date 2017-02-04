[![Build Status - Master](https://travis-ci.org/juju4/ansible-mig-api.svg?branch=master)](https://travis-ci.org/juju4/ansible-mig-api)
[![Build Status - Devel](https://travis-ci.org/juju4/ansible-mig-api.svg?branch=devel)](https://travis-ci.org/juju4/ansible-mig-api/branches)
# MIG ansible role: mig-api service

Ansible role to setup MIG aka Mozilla InvestiGator: mig-api component
Refer to [mig master role](https://github.com/juju4/ansible-mig) for complete integration.
http://mig.mozilla.org/

## Requirements & Dependencies

### Ansible
It was tested on the following versions:
 * 2.0
 * 2.2

### Operating systems

Ubuntu 14.04, 16.04 and Centos7

## Example Playbook

Just include this role in your list.

Currently, I used a slightly modified version of Mayeu.RabbitMQ as normally, this role is expecting to have rabbitmq certificates available on orchestrator and I'm generating them on mig role if not existing.

You should have your investigator gpg keys (fingerprint, pubkey) ready before executing this role or use gpgkey_generate role to do so..

It is advised to use separate role migclient for client install as mig role as a role dependency to RabbitMQ and it does not seem possible to have it conditional currently. (https://groups.google.com/forum/#!msg/ansible-devel/NsgcczA8czs/fwjrNJB5a4QJ)

Finish install by
0) check API is accessible
```
    $ curl http://localhost/api/v1/
    $ curl http://localhost/api/v1/dashboard | python -mjson.tool
```
(or https if enabled)
1) validate w mig-console (need to set ~/.migrc, template provided)
```
$ sudo cp -R .gnupg /home/mig/; sudo chown -R mig /home/mig/.gnupg
$ sudo -u mig -H -s
$ $HOME/go/src/mig.ninja/mig/bin/linux/amd64/mig-console
```
2) run locally mig-agent or deploy it somewhere
```
$GOPATH/src/mig.ninja/mig/bin/linux/amd64/mig-agent-latest
```
if server is withagent enabled, mig-agent should already be running
```
$ pgrep mig-agent
```
As for any services, you are recommended to do hardening.
Especially on RabbitMQ part (include erlang epmd)

Some nrpe commands are included to help for monitoring.

Post-install, check your migrc and run mig-console (as mig user)
```
$ cat ~/.migrc
$ $HOME/go/src/mig.ninja/mig/bin/linux/amd64/mig-console
```

## Variables

There is a good number of variables to set the different settings of MIG. Both API and RabbitMQ hosts should be accessible to clients.
Some like password should be stored in ansible vault for production systems at least.

```
mig_user: "{{ ansible_ssh_user }}"
mig_gover: 1.5.2
mig_gopath: "/home/{{ mig_user }}/go"
mig_src: "{{ mig_gopath }}/src/mig.ninja/mig"
mig_api_port: 51664

mig_db_migadmin_pass: xxx
mig_db_migapi_pass: xxx
mig_db_migscheduler_pass: xxx

mig_rabbitmq_adminpass: xxx
mig_rabbitmq_schedpass: xxx
mig_rabbitmq_agentpass: xxx
mig_rabbitmq_workrpass: xxx

mig_rabbitmq_certinfo: '/C=US/ST=CA/L=San Francisco/O=MIG Ansible'
mig_rabbitmq_certduration: 1095
mig_rabbitmq_rsakeysize: 2048
mig_rabbitmq_cadir: "/home/{{ mig_user }}/ca"
mig_rabbitmq_cakey: "{{ mig_rabbitmq_cadir }}/ca.key"
mig_rabbitmq_cacertcrt: "{{ mig_rabbitmq_cadir }}/ca.crt"
#mig_rabbitmq_cacert: "{{ mig_rabbitmq_cadir }}/cacert.cert"
mig_rabbitmq_serverdir: "/home/{{ mig_user }}/server"
mig_rabbitmq_serverkey: "{{ mig_rabbitmq_serverdir }}/server-{{ ansible_hostname }}.key"
mig_rabbitmq_servercsr: "{{ mig_rabbitmq_serverdir }}/server-{{ ansible_hostname }}.csr"
mig_rabbitmq_servercrt: "{{ mig_rabbitmq_serverdir }}/server-{{ ansible_hostname }}.crt"
mig_rabbitmq_clientdir: "/home/{{ mig_user }}/client"

## To switch true, you need valid public signed certificate, not self-certificate
mig_nginx_use_ssl: false
mig_nginx_cert: /path/to/cert
mig_nginx_key: /path/to/key


### client
#mig_src: "{{ mig_gopath }}/src/mig.ninja/mig"
#mig_agent_bin: "{{ mig_src }}/{{ ansible_os_family }}/{{ ansible_architecture }}/mig-agent-latest"
#mig_api_host: localhost
#mig_api_port: 51664
#mig_path: 
## agent will use those proxy as rescue network access if direct access not working
mig_proxy_list: '{`proxy.example.net:3128`, `proxy2.example.net:8080`}'
mig_client_investigators:
    - { realname: "{{ gpg_realname }}", fingerprint: '', pubkeyfile: "{{ gpg_pubkeyfileexport }}", pubkey: "{{ lookup('file', '/path/to/pubkey') }}", weight: 2 }

```

## Continuous integration

This role has a travis basic test (for github), more advanced with kitchen and also a Vagrantfile (test/vagrant).
Default kitchen config (.kitchen.yml) is lxd-based, while (.kitchen.vagrant.yml) is vagrant/virtualbox based.

Once you ensured all necessary roles are present, You can test with:
```
$ gem install kitchen-ansible kitchen-lxd_cli kitchen-sync kitchen-vagrant
$ cd /path/to/roles/juju4.mig-api
$ kitchen verify
$ kitchen login
$ KITCHEN_YAML=".kitchen.vagrant.yml" kitchen verify
```
or
```
$ cd /path/to/roles/juju4.mig-api/test/vagrant
$ vagrant up
$ vagrant ssh
```

## Troubleshooting & Known issues

* Troubleshoot API request.
Check nginx log (/var/log/nginx/*.log), mig-api (/var/log/supervisor/mig-api.log)

* mig-agent-search failing to generate security token
```
$ mig-agent-search -c ~/.migrc "name like '%%'"
panic: failed to generate a security token using key xxx from /home/_mig/.gnupg/secring.gpg
```
Ensure fingerprint inside .migrc is consistent with your secret keys
```
$ gpg --fingerprint EMAIL | awk -F= '/Key fingerprint/ { gsub(/ /,"", $2); print $2 }'
```

* fail to create investigator
```
curl -q -F 'name=MIG dupond Investigator' -F publickey=@/tmp/dupont.asc -F 'isadmin=false' http://10.252.116.58:1664/api/v1/investigator/create/
{"collection":{"version":"1.0","href":"http://10.252.116.58:1664/api/v1/investigator/create/","template":{},"error":{"code":"7078220333064","message":"unexpected end of JSON input"}}}
```
in /var/log/supervisor/mig-api.log
```
2016/01/30 11:22:23 7078220333064 - - [info] src=10.252.116.58 category=investigator auth=[authdisabled 0] POST HTTP/1.1 /api/v1/investigator/create/ resp_code=500 resp_size=183 user-agent=curl/7.47.0
```

## License

BSD 2-clause

