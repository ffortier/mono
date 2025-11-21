#!/usr/bin/env bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

die() {
    echo -e "${RED}FATAL:${NC} $*" >&2
    exit 1
}

info() {
    echo -e "${GREEN}INFO:${NC} $*" >&2
}