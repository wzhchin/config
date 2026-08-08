# PKGBUILD Rules

Add `!debug` to the `options` array by default.

Preserve existing option values and avoid duplicate `!debug` entries.

Keep debug packages only when the user requests them or package requirements need them.

If a Makefile exists, reuse suitable targets in `build()`, `check()`, and `package()`.

Pass the packaging variables that each target supports.

Set the installation prefix to `/usr`.

In `package()`, use `make DESTDIR="$pkgdir" install` only when the target supports staged installation.

Do not run an unstaged `make install` from `package()`.

If the install target cannot stage files, install package files explicitly.

For non-obvious setup commands, consider a package `.install` file.

Set the PKGBUILD `install` variable to that file.

When the file provides setup guidance, print a short usage guide from `post_install()`.

Print upgrade guidance from `post_upgrade()` only when the required steps change.

If guidance applies to one transition, guard it with `$2` and `vercmp`.

Do not execute user-specific setup commands from package hooks.

Do not print generic commands or long documentation during installation.

Generate `.SRCINFO` from `PKGBUILD` after package metadata changes.

Do not edit `.SRCINFO` by hand.
