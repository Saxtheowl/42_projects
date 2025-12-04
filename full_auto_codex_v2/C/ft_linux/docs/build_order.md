# Ordonnancement LFS (système de base)

Inspiré de LFS 12.x, à adapter selon versions retenues. Chaque build se fait en chroot avec toolchain prête.

1. man-pages
2. iana-etc
3. glibc (final)
4. zlib
5. bzip2
6. xz
7. zstd
8. file
9. readline
10. m4
11. bc
12. flex
13. tcl, expect, dejagnu (pour tests gcc)
14. binutils (final)
15. gmp, mpfr, mpc
16. attr, acl, libcap
17. shadow
18. gcc (final)
19. pkg-config-lite
20. ncurses
21. coreutils
22. diffutils
23. gawk
24. findutils
25. grep
26. gzip
27. make
28. patch
29. tar
30. texinfo
31. vim
32. procps-ng
33. util-linux
34. eudev
35. kmod
36. sysvinit
37. e2fsprogs
38. less, iproute2, dhcpcd (réseau)
39. bash (si rebuild), cleanup /tmp, strip, logs.

Ensuite : kernel 6.6.54 + GRUB.
