#!/usr/bin/env bash

# fail on any command exiting non-zero
set -eo pipefail

# download openssl
wget http://security.debian.org/debian-security/pool/updates/main/o/openssl/openssl_1.0.1t.orig.tar.gz
wget http://security.debian.org/debian-security/pool/updates/main/o/openssl/openssl_1.0.1t-1+deb8u6.debian.tar.xz

# extract
tar xf openssl_1.0.1t.orig.tar.gz
cd openssl-1.0.1t/
tar xf ../openssl_1.0.1t-1+deb8u6.debian.tar.xz

# disable features
sed -i 's/no-rc5 zlib/no-rc5 no-zlib/' debian/rules
sed -i 's/no-shared/no-shared no-ssl2 no-ssl3 no-zlib-dynamic/' debian/rules

# build, this will take a while
DEB_BUILD_OPTI ONS=nocheck dpkg-buildpackage -us -uc

# extract the deb packages to a directory
cd ..

mkdir patched-openssl

cd patched-openssl

for datfile in ../*.deb; do
  7z -y x "$datfile"
  tar xf data.tar
done

SOURCE_KEEPALIVED=http://www.keepalived.org/software/keepalived-1.3.5.tar.gz

# grab the source files
wget -P . $SOURCE_KEEPALIVED --no-check-certificate

tar xzf keepalived-1.3.5.tar.gz

cd keepalived-1.3.5

CFLAGS="-I/tmp/patched-openssl/usr/include" LDFLAGS="-L/tmp/patched-openssl/usr/lib -lssl -lz -ldl" ./configure

make SHARED=0 CC='gcc -static'

cp bin/* /tmp
