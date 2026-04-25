class InterventionState {
  final bool isLoading;
  final Map<String, int>? stats;
  final String? error;

  InterventionState({this.isLoading = false, this.stats, this.error});

  InterventionState copyWith({
    bool? isLoading,
    Map<String, int>? stats,
    String? error,
  }) {
    return InterventionState(
      isLoading: isLoading ?? this.isLoading,
      stats: stats ?? this.stats,
      error: error ?? this.error,
    );
  }
}
