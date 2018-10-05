plan basic::undef(TargetSpec $nodes, Optional[String] $message = undef) {
  return apply($nodes) {
    if $message {
      notify { 'message': message => $message }
    }
  }
}
