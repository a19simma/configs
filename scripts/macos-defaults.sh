#!/usr/bin/env bash
#
# DEPRECATED — do not use. Kept only as a pointer.
#
# macOS defaults are now declared in mise.macos.toml under
# [bootstrap.macos.*] and applied with:
#
#     mise bootstrap macos defaults apply
#
# That is better than this script was in three ways:
#   - idempotent and inspectable: `mise bootstrap macos defaults status`
#     reports each key as set / differs / unset
#   - typed: an int 1 does not silently satisfy a configured `true`
#   - inert on Linux, so one config serves both platforms
#
# Delete this file once you're satisfied the mise path works.
#
echo "This script is deprecated. Run instead:"
echo "    mise bootstrap macos defaults status   # see drift"
echo "    mise bootstrap macos defaults apply    # write them"
exit 1
