
HISTFILESIZE=100000
export HISTTIMEFORMAT='%F %T '
export PATH=$PATH:/root/bin:/usr/local/go/bin:/root/lib/go/bin

source /root/.completion/git-completion.bash
complete -C /root/lib/go/bin/gocomplete go

export GIT_SSL_NO_VERIFY=1
export GIT_CURL_VERBOSE=1

alias ll='ls -lF'
alias la='ls -lFa'
alias grep='grep --color'
alias j='jobs'
alias his='history'

# go to upper dir!
alias u='cd .. '
alias uu='cd ../.. '
alias uuu='cd ../../.. '

# rename
alias python='/usr/bin/python2.7'

# cd
alias cddownload='cd /home/slasher/Downloads'
alias cdgithub='cd /home/slasher/Documents/github'

# proxy list
alias proxy='export https_proxy=http://127.0.0.1:7890 http_proxy=http://127.0.0.1:7890 all_proxy=socks5://127.0.0.1:7890'
alias unproxy='unset https_proxy http_proxy all_proxy'

# golang
alias gotf='go test -v -run'
alias gota='go test -v --memprofile profile_mem.out --cpuprofile profile_cpu.out --blockprofile profile_block.out --mutexprofile profile_mutex.out -covermode=count --coverprofile profile_cover.out'
alias gotc='go test -v -covermode=count --coverprofile profile_cover.out'
alias gotp='go tool pprof -http=:8080 '
alias gotb='go test -v -bench=. -run=^$'
alias gotbm='go test -v -bench=. -run=^$ --benchmem'
alias gotbmc='go test -v -bench=. -run=^$ --benchmem --cpuprofile profile_cpu.out'
alias gotbmm='go test -v -bench=. -run=^$ --benchmem --memprofile profile_mem.out'
alias gotbmmc='go test -v -bench=. -run=^$ --benchmem --memprofile profile_mem.out --cpuprofile profile_cpu.out'
alias gocover='go tool cover -html=profile_cover.out -o /tmp/coverage.html'
alias goclean='rm -f profile_* *.test'

# golang
export GOROOT=/usr/local/go
export GOPATH=/root/lib/go
export GOFLAGS=-mod=mod
export GO111MODULE=on
export GOPROXY=https://goproxy.io

# rust
source $HOME/.cargo/env
export CARGO_NET_GIT_FETCH_WITH_CLI=true
export RUST_SRC_PATH=$(rustc --print sysroot)/lib/rustlib/src/rust/library

# fg() {
#     if [[ $# -eq 1 && $1 = - ]]; then
#         builtin fg %-
#     else
#         builtin fg %"$@"
#     fi
# }
