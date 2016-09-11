# Superglue [![version](https://img.shields.io/badge/version-0.1.0--beta-yellow.svg?style=flat)](http://superglue.tech)

_Superglue_ is a collection of [Debian compliant](https://www.debian.org/doc/manuals/debian-reference/ch12.en.html#_posix_shell_compatibility) (mostly [POSIX](https://en.wikipedia.org/wiki/POSIX) compliant) shell scripts that are designed to make scripting more efficient. Each script has a function loaded via ```/etc/profile.d/superglue.sh``` and an executable installed in ```/usr/bin``` to provide maximum usefulness.

**From the author,**<br>
As of September 2016, I am starting _Superglue_ with two commonly needed and helpful scripts, [alert](#alert) and [error](#error). I am considering adding many other currently private scripts to this collection and would like to know your opinions about the quality and usefulness of these initial two scripts before adding more. Please share your thoughts with <adam@imaginate.life>.<br>
\-- Adam


## Install
```bash
cd ~
git clone https://github.com/imaginate/superglue.git
cd superglue
make [--force]
```
**Note:** ```apt-get``` packaging is on the to-do list. If you want to help please message Adam.


## Scripts

### alert()

### error()


## Bugs & Features
**For Existing Scripts:** [open an issue](https://github.com/imaginate/superglue/issues)<br>
**For Future Scripts:** <adam@imaginate.life>


## Everything Else
<adam@imaginate.life>
