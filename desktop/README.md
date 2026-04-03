# AuthVault Desktop

Aplikasi desktop untuk otentikasi dua faktor (2FA) menggunakan TOTP/HOTP.

## Build

```bash
mkdir build && cd build
cmake ..
make
```

## Tests

```bash
cd tests
mkdir build && cd build
cmake ..
make
./authvault_tests
```
