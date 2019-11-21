#!/bin/sh
# This file is part of LTSP, https://ltsp.org
# Copyright 2019 the LTSP team, see AUTHORS
# SPDX-License-Identifier: GPL-3.0-or-later

# Prefix frontpage matter in the man pages

set -e
cd "${0%/*}"
test -f ../../ltsp/docs/ltsp.8.md || exit 1

i=0
for mp in $(ls ../../ltsp/docs/*.[0-9].md | sort -d); do
    i=$((i+1))
    mp=${mp#../../ltsp/docs/}
    echo "$mp"
    applet_section=${mp%.md}
    applet=${applet_section%.[0-9]}
    section=${applet_section#$applet.}
    description=$(sed -n '2s/.*- \(.*\)/\1/p' "../../ltsp/docs/$mp")
    {
        cat <<EOF
---
title: $applet
parent: Man pages
nav_order: $i
---

EOF
        cat "../../ltsp/docs/$mp" | sed 's/*\*--/**-\\-/g'
    } >"$applet.md"
done
