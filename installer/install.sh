#!/bin/sh -e
# command and configuration setup under XDG Base Directory Specification
# https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
# @ NAME_ORIG       command name (original)
# @ NAME_ALT        command name (alternative under XDG)
# @ REPO_NAME       config var for git repo name (w/ or w/o "https://github.com/")
# @ CLONE_NAME      config var for git repo checkout dir name
cd >/dev/null || true
HOME=$(pwd)
help () {
  echo "syntax: ${0##*/} NAME_ALT"
  echo "syntax: ${0##*/} NAME_ALT REPO_NAME"
  echo "syntax: ${0##*/} NAME_ORIG NAME_ALT REPO_NAME"
  echo "syntax: ${0##*/} NAME_ORIG NAME_ALT REPO_NAME CLONE_NAME"
  echo
  echo "Set up a NAME_ALT command executed under the XDG based alternative"
  echo "environment with its configuration from REPONAME for a NAME_ORIG"
  echo "command."
  echo
  echo " * If NAME_ORIG is missing, 'nvim' is used."
  echo " * If CLONE_NAME is missing, NAME_ORIG is used."
  echo " * reqirement: NAME_ORIG !=  NAME_ALT"
  echo
  echo "'\$PATH' needs to include '~/bin'."
  echo "REPO_NAME can use short form for GitHub."
  echo "Default REPO_NAME is 'AstroNvim/AstroNvim'"
}

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  help
  exit 0
elif [ $# = 1 ]; then
  NAME_ORIG="nvim"
  NAME_ALT="$1"
  REPO_NAME="AstroNvim/AstroNvim"
  CLONE_NAME="$NAME_ORIG"
elif [ $# = 2 ]; then
  NAME_ORIG="nvim"
  NAME_ALT="$1"
  shift
  REPO_NAME="$1"
  shift
  CLONE_NAME="$NAME_ORIG"
elif [ $# = 3 ]; then
  NAME_ORIG="$1"
  shift
  NAME_ALT="$1"
  shift
  REPO_NAME="$1"
  shift
  CLONE_NAME="$NAME_ORIG"
elif [ $# = 4 ]; then
  NAME_ORIG="$1"
  shift
  NAME_ALT="$1"
  shift
  REPO_NAME="$1"
  shift
  CLONE_NAME="$1"
else
  help
  exit 0
fi
if [ "$NAME_ORIG" = "$NAME_ALT" ]; then
  help
  exit 1
fi

if [ -z "$REPO_NAME" ]; then
  # undocumented: just create an alternative command without configuration
  REPO_NAME=""
else
  if [ "$REPO_NAME" = "${REPO_NAME##http}" ]; then
    REPO_NAME="https://github.com/$REPO_NAME"
  fi
  if [ "$REPO_NAME" = "${REPO_NAME%.git}" ]; then
    REPO_NAME="$REPO_NAME.git"
  fi
fi

# initialize
BIN_DIR="$HOME/bin"  # may be ~/.local/bin
XDG_CONFIG_HOME="$HOME/.config/$NAME_ALT"
XDG_DATA_HOME="$HOME/.local/share/$NAME_ALT"
XDG_CACHE_HOME="$HOME/.cache/$NAME_ALT"
# sanity check
if  ! type "$NAME_ORIG" >/dev/null ; then
  echo "'$NAME_ORIG' is not available on this system"
  exit 1
fi

if [ -e "$BIN_DIR/$NAME_ALT" ]; then
  printf "%s" "$BIN_DIR/$NAME_ALT file aleady exists.  Remove it? [y/N]: "
  read -r YN
  if [ "$YN" = "y" ] || [ "$YN" = "Y" ]; then
    rm -f "$BIN_DIR/$NAME_ALT"
  else
    exit 1
  fi
fi

if [ -e "$XDG_CONFIG_HOME" ]; then
  printf "%s" "'$XDG_CONFIG_HOME' directory(?) aleady exists.  Remove it? [y/N]: "
  read -r YN
  if [ "$YN" = "y" ] || [ "$YN" = "Y" ]; then
    printf "%s" "Are you sure? [y/N]: "
    read -r YN
    if [ "$YN" = "y" ] || [ "$YN" = "Y" ]; then
      rm -rf "$XDG_CONFIG_HOME"
    else
      exit 1
    fi
  else
    exit 1
  fi
fi

if [ -e "$XDG_DATA_HOME" ]; then
  printf "%s" "'$XDG_DATA_HOME' directory(?) aleady exists.  Remove it? [y/N]: "
  read -r YN
  if [ "$YN" = "y" ] || [ "$YN" = "Y" ]; then
    rm -rf "$XDG_DATA_HOME"
  else
    exit 1
  fi
fi

if [ -e "$XDG_CACHE_HOME" ]; then
  printf "%s" "'$XDG_CACHE_HOME' directory(?) aleady exists.  Remove it? [y/N]: "
  read -r YN
  if [ "$YN" = "y" ] || [ "$YN" = "Y" ]; then
    rm -rf "$XDG_CACHE_HOME"
  else
    exit 1
  fi
fi

mkdir -p "$BIN_DIR"
# all new directories
mkdir -p "${XDG_CONFIG_HOME}"
mkdir -p "${XDG_DATA_HOME}"
mkdir -p "${XDG_CACHE_HOME}"

# install
echo "Install an alternative command with offset XDG_* settings."
echo "  Original command = '${NAME_ORIG}'"
echo "  New command      = '${NAME_ALT}' in '$BIN_DIR'"
echo "  XDG_CONFIG_HOME  = '${XDG_CONFIG_HOME}'"
echo "  XDG_DATA_HOME    = '${XDG_DATA_HOME}'"
echo "  XDG_CACHE_HOME   = '${XDG_CACHE_HOME}'"
cd "${XDG_CONFIG_HOME}"
if [ -n "$REPO_NAME" ];then
  git clone "$REPO_NAME" "$CLONE_NAME"
fi
cat > "$BIN_DIR/$NAME_ALT" << EOF
#!/bin/sh -e
# set up an alternative work environment for $NAME_ORIG
XDG_CONFIG_HOME="$XDG_CONFIG_HOME"
XDG_DATA_HOME="$XDG_DATA_HOME"
XDG_CACHE_HOME="$XDG_CACHE_HOME"
export XDG_CONFIG_HOME XDG_DATA_HOME XDG_CACHE_HOME
# shellcheck disable=SC2093
exec $NAME_ORIG "\$@"
EOF
# ensure to be executable
chmod 755 "$HOME/bin/$NAME_ALT"

# vim:set ai et sw=2 ts=2 sts=2 tw=80:
