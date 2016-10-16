# colors and formatting: http://misc.flogisoft.com/bash/tip_colors_and_formatting
# http://unix.stackexchange.com/questions/124407/what-color-codes-can-i-use-in-my-ps1-prompt
# black red green yellow blue magenta cyan white
# https://gabri.me/blog/custom-colors-in-your-zsh-prompt
# http://unix.stackexchange.com/questions/32273/16-colors-in-zshell
# https://wiki.archlinux.org/index.php/zsh#Colors
# zsh variables - http://zsh.sourceforge.net/Doc/Release/Prompt-Expansion.html
# color table - https://en.wikipedia.org/wiki/ANSI_escape_code#Colors
# https://www-s.acm.illinois.edu/workshops/zsh/prompt/escapes.html
# https://gabri.me/blog/custom-colors-in-your-zsh-prompt
# Good colors:
#   http://dobsondev.com/2014/02/21/customizing-your-terminal/
#   http://code.tutsplus.com/tutorials/how-to-customize-the-command-prompt--net-20586

# spectrum_ls => shows you full color spectrum

##### Current directory > pwd
local current_dir='%{$FG[154]% %~%{$reset_color%}'

##### Current GIT repository info, if available
local git_info='$(git_prompt_info)'

####################
# Get ruby env and version
# To build ruby prompt
####################
# the rbenv_prompt_info line should be used if you are using the rbenv oh-my-zsh plugin
#if [[ $(rbenv_prompt_info) ]]; then
if [[ $(which rbenv) ]]; then
  # if rbenv-ruby is being used out rbenv:(ruby_version)
  rubyversion_=`ruby -e 'print "#{ RUBY_VERSION }p#{ RUBY_PATCHLEVEL }"'`
  RUBY_PROMPT_="%{$FG[141]rbenv:%}\$( _redder \($rubyversion_\))"
elif [ -e ~/.rvm/bin/rvm-prompt ] && [ rvm_prompt_info ]; then
  # -> if rvm is installed, output rvm:(ruby_version)
  RUBY_PROMPT_="%{$FG[141]rvm:%}\$( _redder \$(ruby_prompt_info))"
else
  # if system installed ruby is being used, output system:(ruby_version)
  rubyversion_=`ruby -e 'print "#{ RUBY_VERSION }p#{ RUBY_PATCHLEVEL }"'`
  RUBY_PROMPT_="%{$FG[141]system:%}\$( _redder \($rubyversion_\))"
fi


####################
# bold and colorize the specified text
# @param $1 = text
# @param $2 = color
####################
function colorize_ {
  if [[ -n $1 && -n $2 ]]; then
    echo "$terminfo[bold]$fg[$2]$1$reset_color"
  fi
}

####################
# whatever txt is specified to function, it will be HIGHLIGHTED :color and bold
# this ensures a DRY layout rather, rather than reusing the same formatting
####################
function _whiteType { if [ -n "$1" ]; then colorize_ $1 white; fi }
function _magentaType { if [ -n "$1" ]; then colorize_ $1 magenta; fi }
function _redder { if [ -n "$1" ]; then echo "$FG[166]$1$reset_color"; fi }

# when current dir is a git repo, output its status as colored icons
function gitStatus {
  if git rev-parse --git-dir > /dev/null 2>&1; then
    if [[ -z $(git_prompt_info) ]]; then
        echo "%{$fg[blue]%}detached-head%{$reset_color%}) $(git_prompt_status) %{$fg[yellow]%}→ "
    else
      echo "git:$(git_prompt_info) $(git_prompt_status)"
    fi
  else
    echo "%{$fg[cyan]%}→ "
  fi
}


####################
# Declare PROMPT Variables
####################
local USER_PROMPT_="%{$fg[magenta]%}%n%{$reset_color%}" # %{$fg[cyan]%}%n "%{$fg[cyan]%}$USER$reset_color"
local DIR_PROMPT_="in %{$fg[blue][%}${current_dir}%}%{$fg[blue]]>%}%{$reset_color%}"
local GIT_PROMPT="${git_info}"
local TRAILING_CARET_="$(_whiteType '»')"
# based on strftime formatting to display time
local TIMESTAMP_="%{$fg[magenta]%}%D{[%I:%M%p]}%{$reset_color%}"


PROMPT="%(?.%{%F{green}%}✔.%{%F{red}%}✘)%{%F{yellow}%} %{%F{black}%}""

$USER_PROMPT_ $DIR_PROMPT_ $RUBY_PROMPT_ $TRAILING_CARET_ \$(gitStatus)
%{$FG[075]⇒%}%{$reset_color%} "
PS2=$'%{$fg[cyan]%}»%{$reset_color%} '  # Prompt when continued etc ie: \
PS3=$' [>'     # Prompt for input/choice

# Distingush between a failed and accepted previous command
# from https://gist.github.com/smileart/3750104
# %(?.%{%F{green}%}✔.%{%F{red}%}✘)%{%F{yellow}%}

#PROMPT="
#$USER_PROMPT_ $DIR_PROMPT_ $RUBY_PROMPT_ $(git_prompt_ahead) $TRAILING_CARET_ \$(gitStatus)
#%{$FG[075]⇒%}%{$reset_color%} "
#PROMPT='
#%{$fg[magenta]%}%n%{$reset_color%} at %{$fg[yellow]%}%{$reset_color%} in %{$\
#fg_bold[green]%}${PWD/#$HOME/~}%{$reset_color%}$(git_prompt_info)\
#%(?,,%{${fg_bold[blue]}%}[%?]%{$reset_color%} )$ '


# right prompt
if type "virtualenv_prompt_info" > /dev/null
then
  RPROMPT='$(virtualenv_prompt_info)$TIMESTAMP_'
  #RPROMPT='%{$GREEN_BOLD%}%{$RESET_COLOR%}'
else
  RPROMT='$TIMESTAMP_'
  #RPROMPT='${return_status}$(git_time_since_commit)$(git_prompt_status)%{$reset_color%}'
fi


# to display around git_prompt
ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[blue]%}(%{$fg[green]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}" # after git_info
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[yellow]%}✗%{$reset_color%} " # if a commit is required
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%}) ✔" # if all changes have been commited ✔

# Format for git_prompt_status
# https://github.com/halfo/lambda-mod-zsh-theme/blob/master/lambda-mod.zsh-theme
ZSH_THEME_GIT_PROMPT_ADDED="%{$fg[green]%}✚ "
ZSH_THEME_GIT_PROMPT_MODIFIED="%{$fg[yellow]%}● " # ✹
ZSH_THEME_GIT_PROMPT_DELETED="%{$fg[red]%}✖  "
ZSH_THEME_GIT_PROMPT_RENAMED="%{$fg[magenta]%}▴ "
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg[yellow]}# "
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$FG[043]%}?"



# LS colors, used from avit.zsh-theme
# LS colors, made with http://geoff.greer.fm/lscolors/
export LSCOLORS="exfxcxdxbxegedabagacad"
export LS_COLORS='di=34;40:ln=35;40:so=32;40:pi=33;40:ex=31;40:bd=34;46:cd=34;43:su=0;41:sg=0;46:tw=0;42:ow=0;43:'
export GREP_COLOR='1;33'


### Good
# unicode - http://unicode-table.com/en/
# https://github.com/halfo/lambda-mod-zsh-theme
#   https://github.com/halfo/lambda-mod-zsh-theme/blob/master/lambda-mod.zsh-theme
#
# RPROMPT -
#   https://github.com/robbyrussell/oh-my-zsh/blob/master/themes/smt.zsh-theme
#   https://github.com/halfo/lambda-mod-zsh-theme/blob/master/lambda-mod.zsh-theme
