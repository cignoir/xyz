xyz
===
## Sample
```bash
$ bundle exec ruby xyz.rb --src lena.png --dst lena_convert.png --flip v --sub 0.5 --split --resize 0.2
```

## Usage
```bash
Usage: xyz [options]
    -s, --src=VALUE                  Source file path
    -d, --dst=VALUE                  Destination file path
    -f, --flip=VALUE                 Flip u | v | uv | vu
        --sub=VALUE                  Subtract RGB by 0.0 - 1.0
        --split                      Split RGB channels
        --resize=VALUE               Resize by 0.0 - 1.0
```
