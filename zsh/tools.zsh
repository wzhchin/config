########################################
### Languages Settings
########################################
## Go Settings
export GOPROXY=https://proxy.golang.com.cn,direct

## Python Settings
export PIP_CACHE_DIR=$CHIN_CACHE_DIR/.pip-cache

## Node Settings
# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
# pnpm end


## Rust Settings
export RUSTUP_DIST_SERVER="https://rsproxy.cn"
export RUSTUP_UPDATE_ROOT="https://rsproxy.cn/rustup"
[ -d ~/.cargo/bin ] && export PATH="$HOME/.cargo/bin:$PATH"

## Android
export ANDROID_HOME="$HOME/Android/Sdk"
### unset this
unset ANDROID_SDK_ROOT
[ -d "$ANDROID_HOME" ] && [ -d "$ANDORID_HOME/ndk" ] && export NDK_HOME="$ANDROID_HOME/ndk/$(ls -1 $ANDROID_HOME/ndk)"


[ -d "/opt/android-studio/jbr" ] && export IDEA_HOME=/opt/android-studio/jbr

########################################
### Tool Settings
########################################
export PATH="$HOME/.local/bin:$PATH"

## Fzf Utils
export FZF_DEFAULT_OPTS='--walker-skip .git,node_modules,target'
j() {
    local folder option
    option="$(tac "${DIR_HISTORY_FILE}" | awk 'arr[$0]++ == 0' | grep -vxF "$PWD" | fzf -q "$1" --reverse --height 40% | sed -r 's/\r?\n?$//g')"

    if [[ -z "$option" ]]; then
        return 0
    fi

    if [ -d "${option}" ]; then
        folder="$option"
    elif [ -e "${option}" ]; then
        printf "Open its parent dir: \n\t%s\033[31m/%s\033[0m\n" "${option%/*}" "${option##*/}"
        folder="${option%/*}"
    else
        printf '%s does not exist.\n' "$option"
        return
    fi

    builtin cd -- "$folder"
    unset folder option
}

jl() {
    local folder option
    local -a entries
    entries=(./*(DNom))

    (( $#entries )) || return 0

    IFS= read -r -d $'\0' option < <(
        printf '%s\0' "${entries[@]}" |
            fzf --read0 --print0 -q "${1:-}" --reverse --height 40%
    ) || return 0

    if [[ -z "$option" ]]; then
        return 0
    fi

    if [ -d "${option}" ]; then
        folder="$option"
    elif [ -e "${option}" ]; then
        printf "Open its parent dir: \n\t%s\033[31m/%s\033[0m\n" "${option%/*}" "${option##*/}"
        folder="${option%/*}"
    else
        printf '%s does not exist.\n' "$option"
        return
    fi

    builtin cd -- "$folder"
    unset folder option
}

tddr() {
    if [ -z "$CHIN_DAILY_DIR" ]; then
        echo "Set CHIN_DAILY_DIR"
        return 1
    fi
    local _d="$(ls $CHIN_DAILY_DIR | fzf -q "$1" --header='Ctrl-j: use input' --bind 'ctrl-j:become(printf "%s\n" {q})' --bind 'enter:accept-or-print-query' | sed "s/__date__/$(date +%y%m-%d)/g")"
    local _dd="$CHIN_DAILY_DIR/$_d"
    if ! [ -d "$_dd" ]; then
        if ! echo "$_d" | grep -i -E '[0-9]{2}[01][0-9]-[0-3][0-9]'; then
	    _dd="$CHIN_DAILY_DIR/$(date +%y%m-%d)-$_d"
        fi
        mkdir -p "$_dd"
    fi
    cd "$_dd"
}

[ -f /usr/share/fzf/key-bindings.zsh ] && . /usr/share/fzf/key-bindings.zsh

########################################
### Alias Settings
########################################
## Aliases
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias rga="rg --no-ignore-files --no-ignore --hidden -i"
alias fda='NO_COLOR=1 fd -I --hidden'
alias mpa='mpv --no-video'
alias aria2n='aria2c --no-conf=true -j4 -x4 -s4'
alias fgt="unset HISTFILE"
alias mkp='mkdir -p'
alias less="less -R"
alias ap="realpath -s"
alias rmi="trash"

mkpar() {
    local -a args
    while [ "$#" -gt 0 ]; do
        case "$1" in
            -*) args=("${args[@]}" "$1") ;;
            *) args=("${args[@]}" "${1%/*}") ;;
        esac
        shift
    done
    mkdir -p "${args[@]}"

}

cdpar() {
    local -a args
    while [ "$#" -gt 0 ]; do
        case "$1" in
            -*) args=("${args[@]}" "$1") ;;
            *) args=("${args[@]}" "${1%/*}") ;;
        esac
        shift
    done
    cd "${args[@]}"
}

hpx() {
    if [[ -z "${HTTP_PROXY:-}${HTTPS_PROXY:-}${http_proxy:-}${https_proxy:-}" ]]; then
        if [[ -z "${CHIN_HTTP_PROXY:-}" ]]; then
            printf 'CHIN_HTTP_PROXY is not set.\n' >&2
            return 1
        fi

        export HTTP_PROXY="$CHIN_HTTP_PROXY"
        export HTTPS_PROXY="$CHIN_HTTP_PROXY"
        export http_proxy="$CHIN_HTTP_PROXY"
        export https_proxy="$CHIN_HTTP_PROXY"
        printf 'set proxy to %s\n' "$CHIN_HTTP_PROXY"
    else
        unset HTTP_PROXY HTTPS_PROXY http_proxy https_proxy
        printf 'unset proxy\n'
    fi
}


check-path() {
    echo "$PATH" | sed -z 's/:/\n/g' | awk '{arr[$0]++; print arr[$0], $0}'
}
