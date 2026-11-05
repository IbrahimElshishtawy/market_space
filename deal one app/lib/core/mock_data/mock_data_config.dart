class MockDataConfig {
  final bool isMockEnabled;
  final Duration simulatedDelay;
  final bool simulateRandomErrors;
  final double errorRate;

  const MockDataConfig({
    this.isMockEnabled = true,
    this.simulatedDelay = const Duration(milliseconds: 150),
    this.simulateRandomErrors = false,
    this.errorRate = 0.0,
  });

  static const MockDataConfig defaultMock = MockDataConfig();
}
