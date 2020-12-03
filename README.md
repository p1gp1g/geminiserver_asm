# Geminiserver_server

It is a verify simple gemini server written in x64 asm.

It doesn't handle TLS, therefor we'll delegate this to openssl and socat. Therefore, you'll need to install socat. Pages are limited to 1024 bytes but it can be increased easily. The code is not optimized at all.

Requirements:
* socat
* nasm

## Installation

First of all, you'll need to edit the following var in the code:
* str_url
* str_failure
* len_failure

len_failure is the length of str_failure. You can know it running (then add +1):
```
echo "30 gemini://{YourDomain}/files/index" | wc -c
```

```
./compile.sh		# compile
mkdir -p server_root/files		# create a directory to uploads your files
echo "# Index" > server_root/files/index # Redirections go to this file
cp server server_root/		# upload the compiled binary
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365 -nodes -subj "/CN={YourDomain}"		# Generate self-signed certificate
cp cert.perm cert		# Concatenate cert and key
cat key.pem >> cert		# For socat
```

To run, the server :

```
# chroot --userspec=nobody:nobody server_root /server &
$ socat ssl-l:1965,cert=cert,fork,reuseaddr,verify=0 tcp:localhost:8888 &
```

Or simply run `start`, as root.
