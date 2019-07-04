---
parent: Advanced topics
---

# Versioning

Taking into account the [Debian policy](https://www.debian.org/doc/debian-policy/ch-binary.html#version-numbers-based-on-dates), LTSP uses the following [calver](https://calver.org/) versioning scheme:
* 19.04: a typical upstream release in April 2019
* 19.04.2: additional releases within the same month add a counter
* 19.04.10: rarely, maintenance _upstream_ releases for older LTSP versions may be needed when grave bugs are backported or security issues are discovered; since these will be kept in separate repositories, they can just bump that month's counter, or use "+"

Distribution package versioning should be separated with a hyphen "-" or tilde "~":
* 19.04-3: the third Debian packaging of the 19.04 release
* 19.04-3ubuntu1: an Ubuntu-patched version of the aforementioned Debian package
* 19.04.2+201904120827\~ubuntu18.04.1: an Ubuntu PPA daily proposed build ("+" should be "~" if debian/changelog contains the unreleased version)

Note: the YYYY.MM scheme was also considered, but it's longer, and YY.MM can easily be upgraded to YYYY.MM or to YYMM, but not the opposite.
