set_term () {
  if [[ "$TERM" =~ screen ]]; then
    _terms=(screen.xterm-256color screen-256color xterm-256color screen-16color screen xterm-16color xterm)
  else
    _terms=(xterm-256color xterm-16color xterm)
  fi
  for t in "${_terms[@]}";do
    if infocmp >&/dev/null;then
      break
    else
      export TERM=$t
    fi
  done
}
set_term
alias ssh="sshrc"
