#!/bin/bash
# ExE Boss’s Shell Prompt <https://github.com/ExE-Boss/shell-prompt>
# Copyright (C) 2017 ExE Boss
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# If id command returns zero, we’ve got root access.
if [ $(id -u) -eq 0 ]; then
	PS1="\[\e[1;31m\]"
else
	PS1="\[\e[m\]"
fi
if (echo "$0" | grep -q '^-'); then
	PS1+=$(echo "$0" | tail -c +2)
else
	PS1+=$0
fi
PS1+=" \[\e[1;32m\]\u@\h \[\e[1;34m\]\w\[\e[39;49m\]> "
