HISTFILESIZE=100000
export HISTTIMEFORMAT='%F %T '
export PATH=$PATH:/root/bin:/usr/local/go/bin:/root/lib/go/bin

source /root/.completion/git-completion.zsh
complete -C /root/lib/go/bin/gocomplete go

export GIT_SSL_NO_VERIFY=1
# export GIT_CURL_VERBOSE=1

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
alias cdoppo='cd /home/slasher/Documents/oppo'
alias cdcubefs='cd /home/slasher/Documents/oppo/cubefs'
alias cdblobstore='cd /home/slasher/Documents/oppo/cubefs/blobstore'
alias cdrpc2='cd /home/slasher/Documents/oppo/cubefs/blobstore/common/rpc2'
alias cdsrc='cd /root/lib/go/src'

# proxy list
alias proxy='export https_proxy=http://127.0.0.1:7890 http_proxy=http://127.0.0.1:7890 all_proxy=socks5://127.0.0.1:7890'
alias unproxy='unset https_proxy http_proxy all_proxy'

# golang
alias gotf='go test -v -run'
alias gota='go test -v --memprofile profile_mem.out --cpuprofile profile_cpu.out --blockprofile profile_block.out --mutexprofile profile_mutex.out -covermode=count --coverprofile profile_cover.out'
alias gotc='go test -v -covermode=count --coverprofile /tmp/profile_cover.out'
alias gotp='go tool pprof -http=:8080 '
alias gott='go tool trace profile_trace.out'
alias gotb='go test -v -bench=. -run=^$'
alias gotbm='go test -v -bench=. -run=^$ --benchmem'
alias gotbmc='go test -v -bench=. -run=^$ --benchmem --cpuprofile profile_cpu.out'
alias gotbmm='go test -v -bench=. -run=^$ --benchmem --memprofile profile_mem.out'
alias gotbmmc='go test -v -bench=. -run=^$ --benchmem --memprofile profile_mem.out --cpuprofile profile_cpu.out'
alias gotbmmct='go test -v -bench=. -run=^$ --benchmem --memprofile profile_mem.out --cpuprofile profile_cpu.out -trace=profile_trace.out'
alias gotbmmb='go test -v -run=^$ --benchmem --memprofile profile_mem.out --cpuprofile profile_cpu.out'
alias gocover='go tool cover -html=/tmp/profile_cover.out -o /media/sf_Document/coverage.html'
alias goclean='rm -f profile_* \*.test'
alias goescape="go build -gcflags='-m -m' > xxx 2>&1"

# golang
source /root/lib/go/env.sh
export GOROOT=/usr/local/go
export GOPATH=/root/lib/go
export GOFLAGS=-mod=mod
export GO111MODULE=on
# export GOPROXY=https://goproxy.io
export GOPROXY=https://goproxy.cn,direct
# export GORACE="log_path=/home/slasher/Documents/oppo/blobstore/race strip_path_prefix=/home/slasher/Documents/oppo/blobstore halt_on_error=1"
export JENKINS_TEST=TRUE

# rust
source $HOME/.cargo/env
export CARGO_NET_GIT_FETCH_WITH_CLI=true
export RUST_SRC_PATH=$(rustc --print sysroot)/lib/rustlib/src/rust/library

fg() {
    if [[ $# -eq 1 && $1 = - ]]; then
        builtin fg %-
    else
        builtin fg %"$@"
    fi
}

# fnm
FNM_PATH="/root/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$FNM_PATH:$PATH"
  eval "`fnm env`"
fi
