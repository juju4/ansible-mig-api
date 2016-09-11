#!/usr/bin/env bats

setup() {
    apt-get install -y curl >/dev/null || yum -y install curl >/dev/null
}

@test "process mig-api should be running" {
    run pgrep mig-api
    [ "$status" -eq 0 ]
    [[ "$output" != "" ]]
}

@test "API url should be accessible internally" {
    run curl -sSq http://localhost:1664/api/v1/dashboard
    [ "$status" -eq 0 ]
    [[ "$output" =~ "\"version\":\"1.0\"" ]]
}

## 404 page not found
#@test "API url should be accessible through nginx" {
#    run curl -sSq http://localhost/api/v1/
#    [ "$status" -eq 0 ]
#    [[ "$output" =~ "\"version\":\"1.0\"" ]]
#}

@test "API dashboard should be accessible through nginx" {
    run curl -sSq http://localhost/api/v1/dashboard
    [ "$status" -eq 0 ]
    [[ "$output" =~ "\"version\":\"1.0\"" ]]
}

