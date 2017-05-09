#!/bin/bash

environment_platform(){
    echo $(uname | cut -d _ -f 1 | tr '[:upper:]' '[:lower:]')
}

environment_is_root_linux(){
    [ `whoami` == "root" ] || return 1
}

environment_is_root_mingw64(){
    net session > /dev/null 2>&1 || return 1
}

environment_is_root(){
    environment_is_root_`environment_platform`
}
