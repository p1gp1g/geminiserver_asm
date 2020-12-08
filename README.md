# Geminiserver_server

It is a verify simple gemini server written in assembler (linux-amd64-nolibc-nasm).

It doesn't handle TLS: it is delegate to openssl and socat.

Requirements:
* socat
* nasm

## Installation

Export the following variable:

* DOMAIN: your domain (eg. localhost)
* FILES_PATH: the directory where the files will be, in the chroot (eg. /files/ )
* REDIR_PATH: redirection path when a file is not found or an error occured (eg. /files/index )
* PAGE_LENGTH: the maximum page length

### Build

Run `./make`

or execute:
```
nasm -f elf64 server.asm -D "domain='$DOMAIN'" -D "filespath='$FILES_PATH'" -D "redirpath='$REDIR_PATH'"
ld -o server server.o
```
### Configuration

As said above, socat handles TLS with openssl. Therefore, the certificate needs to be generated for it:
```
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365 -nodes -subj "/CN=${DOMAIN}"		# Generate self-signed certificate
cp cert.perm cert   # Concatenate cert and key
cat key.pem >> cert   # For socat
```

Ensure to have a valid file to redirect to:
```
mkdir -p server_root/${FILES_PATH}
echo "# Index" >> server_root/${REDIR_PATH}
```

## Run

```
# chroot --userspec=nobody:nobody server_root /server &
$ socat ssl-l:1965,cert=cert,fork,reuseaddr,verify=0 tcp:localhost:8888 &
```

Or simply run `start`, as root.
