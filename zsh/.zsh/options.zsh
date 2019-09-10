setopt EXTENDED_HISTORY # Write the history file in the ':start:elapsed;command' format.
setopt APPEND_HISTORY # append new sessions to the current hist file
setopt INC_APPEND_HISTORY # Write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY # Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST # Expire a duplicate event first when trimming history.
setopt HIST_IGNORE_DUPS # Do not record an event that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS # delete old duplicated entries
setopt HIST_FIND_NO_DUPS # dont display lines already found in history
setopt HIST_IGNORE_SPACE # dont remember commands starting with space, this allows us to keep some commands private
setopt HIST_VERIFY # verify before executing selected history entry

setopt AUTO_CD # if you just type the name of a directory, cd into it
setopt AUTO_PUSHD # make cd push the old dir onto the dir stack
setopt CDABLE_VARS # try to expand arguments to cd if nothing matches
setopt PUSHD_IGNORE_DUPS # don't push duplicates onto the dir stack
setopt AUTO_NAME_DIRS # allows naming dirs as variables
setopt MULTIOS # perform implicit tees or cats when multiple redirections are attempted
setopt PROMPT_SUBST # pretty prompts
