#!/usr/bin/env bash

#
# RFC 3339 date time with seconds
dateRfc () { date --rfc-3339=seconds; }

#
# Silent popd wrapper
#
popd () { command popd "$@" > /dev/null; }

#
# Silent pushd wrapper
#
pushd () { command pushd "$@" > /dev/null; }