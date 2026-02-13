# The following variables will be overwritten by /etc/zshrc,
# so they need to be reset in .zshrc

# HISTFILE: This variable sets the location of the history file.
# The history file is where the shell stores command history.
# The value is set to "${XDG_STATE_HOME}/zsh/history", which means the history file is stored in the zsh directory under the XDG_STATE_HOME directory.
export HISTFILE="${XDG_STATE_HOME}/zsh/history"

# HISTSIZE: This variable sets the number of commands to remember in the command history.
# The value is set to "999999999", which means the shell will remember up to 999999999 commands.
export HISTSIZE="999999999"

# SAVEHIST: This variable sets the number of commands to store in the history file when an interactive shell exits.
# The value is set to "999999999", which means up to 999999999 commands will be saved in the history file when the shell exits.
export SAVEHIST="999999999"
