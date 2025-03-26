# Regname


## Regname

Rename files & directories in local or secondary directory using regexp.


## Build

```sh
go build .

# windows
GOOS=windows GOARCH=amd64 go build .
```

## Usage

```help
  -copy
        Copy file instead rename
  -dir string
        Directory to walk (default ".")
  -expr string
        Regular expression to extract name (default "^(.*)$")
  -extension
        Match with file extension
  -mode int
        (0) File & Directory in local directory
        (1) Directory in local directory
        (2) File in local directory
        (3) Rename File in secondary directory to local directory
  -order int
        Order, ${o} is place in template
        Default order is like ${template}${order}${extension}
  -skip int
        Skip too many files directory if mode=3 (default 10)
  -template string
        Rename to template (default "${1}")
```


## Example

### Match All

```txt
./regname -dir . -expr "^reg(.*)$" -template "new_reg\${1}_\${1}"

[Test] README.md  -> Skip same name
[Test] go.mod     -> Skip same name
[Test] go.sum     -> Skip same name
[Test] regname    -> new_regname_name
[Test] regname.go -> new_regname_name.go
```

### Rename File with Order

```txt
./regname -dir . -mode 2 -expr "^(.*)\.(.*)$" -template "order\${o}_\${1}.\${2}" -order 2 -extension

[Test] README.md  -> order01_README.md
[Test] go.mod     -> order02_go.mod
[Test] go.sum     -> order03_go.sum
[Test] regname    -> Skip same name
[Test] regname.go -> order04_regname.go
```

### Copy File in Secondary Directories

```txt
./regname -dir .. -mode 3 -expr "^(.*)$" -template "_\${1}_" -order 3 -copy

[Test] regname/README.md  -> regname_README_001.md
[Test] regname/go.mod     -> regname_go_002.mod
[Test] regname/go.sum     -> regname_go_003.sum
[Test] regname/regname    -> regname_regname_004
[Test] regname/regname.go -> regname_regname_005.go
```
