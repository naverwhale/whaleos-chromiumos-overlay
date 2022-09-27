This package is modified from upstream Gentoo to patch against CVE-2020-27840 and CVE-2021-20277. It is impractical
to update to the latest upstream package as this version (2.0.12) is required by Samba, and uprevving Samba is a
major task that would block patching ldb against these security vulnerabilities.

An upgrade of Samba from 4.11.13 to 4.14.4 is in progress, this will allow us to remove these ldb patches and move
ldb back to portage-stable. It is expected that this will be completed by Jun 30 2021.
