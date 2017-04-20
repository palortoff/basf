#!/bin/bash

platform(){
    echo $(uname | cut -d _ -f 1 | tr '[:upper:]' '[:lower:]')
}
