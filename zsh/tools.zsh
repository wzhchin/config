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
        printf "$option is not existed.\n"
        return
    fi

    cd "$folder"
    unset folder option
}

jl() {
    local folder option
    option="$(ls -at | fzf -q "$1" --reverse --height 40% | sed -r 's/\r?\n?$//g')"

    if [[ -z "$option" ]]; then
        return 0
    fi

    if [ -d "${option}" ]; then
        folder="$option"
    elif [ -e "${option}" ]; then
        printf "Open its parent dir: \n\t%s\033[31m/%s\033[0m\n" "${option%/*}" "${option##*/}"
        folder="${option%/*}"
    else
        printf "$option is not existed.\n"
        return
    fi

    cd "$folder"
    unset folder option
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

mkpp() {
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

hpx() {
    if [ -z "$HTTP_PROXY" ]; then
        export HTTP_PROXY="$CHIN_HTTP_PROXY"
        echo "set proxy to $HTTP_PROXY"
    else
        export HTTP_PROXY=
        echo "unset proxy"
    fi
    export HTTPS_PROXY="$HTTP_PROXY"
}

tddr() {
    if [ -z "$CHIN_DAILY_DIR" ]; then
        echo "Set CHIN_DAILY_DIR"
        return 1
    fi
    if [ "$1" = fzf ]; then
        local _d="$CHIN_DAILY_DIR/$(ls $CHIN_DAILY_DIR | fzf)"
    else
        local _d="$CHIN_DAILY_DIR/$(date +%y%m-%d)"
    fi
    if [ -n "$1" ]; then
        _d="$_d-$1"
    fi
    mkdir -p "$_d"
    cd "$_d"
}

check-path() {
    echo "$PATH" | sed -z 's/:/\n/g' | awk '{arr[$0]++; print arr[$0], $0}'
}
