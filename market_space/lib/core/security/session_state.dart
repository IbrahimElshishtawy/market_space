enum SessionStatus {
  unauthenticated,
  authenticated,
}

class SessionState {
  final SessionStatus status;
  final String? userId;

  const SessionState({
    required this.status,
    this.userId,
  });

  const SessionState.unauthenticated()
      : status = SessionStatus.unauthenticated,
        userId = null;

  const SessionState.authenticated({
    required this.userId,
  }) : status = SessionStatus.authenticated;

  bool get isAuthenticated => status == SessionStatus.authenticated;
}
