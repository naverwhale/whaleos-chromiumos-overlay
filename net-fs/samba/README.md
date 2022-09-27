This package (samba) has been modified from upstream Gentoo due to multiple
changes necessary for use in Chrome OS. These changes include:
- Bug fixes (i.e. for https://bugzilla.samba.org/show_bug.cgi?id=12696) not yet
  added to a release
- Non-upstreamed patches needed for Active Directory support
- Various cross-compilation fixes needed for aarch64 and lld linking
- Features disabled (i.e. perl and python) to minimise files installed in the
  rootfs.

Although some of these changes could be upstreamed, such as cross-compilation
fixes, it is unlikely that all changes necessary for Chrome OS could be
submitted to upstream Gentoo. Therefore it is unliklely this package could be
moved back to portage-stable.
