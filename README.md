# Entra Client Certificates

Build the image.

```bash
docker build -t entra-client-certificates . --no-cache
```

Then `cd` into any directory and create the `inputs` folder.

```bash
cd ~/Downloads
mkdir inputs
cd inputs
```

Create any number of `json`files, their file names will be the output file names.

inputs/certificate-foo.json
```json
{
  "commonName": "foo-entra-app",
  "days": 365,
  "password": "MyS3cureP@ss",
  "keyLength": 2048
}
```

inputs/certificate-bar.json
```json
{
  "commonName": "bar-entra-app",
  "days": 365,
  "password": "MyS3cureP@ss",
  "keyLength": 2048
}
```

Run the command, it will create the `outputs` directory.

```bash
docker run --rm \
  -v "$(pwd)/inputs:/inputs" \
  -v "$(pwd)/outputs:/outputs" \
  entra-client-certificates
```

Your directory will look something like this.

```bash
~/Downloads ᐅ tree
 .
├──  inputs
│   ├──  bar-file-name.json
│   └──  foo-file-name.json
└──  outputs
    ├──  bar-file-name.cer
    ├──  bar-file-name.password.txt
    ├──  bar-file-name.pfx
    ├──  bar-file-name.pfx.base64.txt
    ├──  foo-file-name.cer
    ├──  foo-file-name.password.txt
    ├──  foo-file-name.pfx
    └──  foo-file-name.pfx.base64.txt
```

