enum TimelineKind {
  home('ホーム', 'notes/timeline', 'homeTimeline'),
  local('ローカル', 'notes/local-timeline', 'localTimeline'),
  social('ソーシャル', 'notes/hybrid-timeline', 'hybridTimeline'),
  global('グローバル', 'notes/global-timeline', 'globalTimeline');

  const TimelineKind(this.label, this.endpoint, this.streamingChannel);

  final String label;
  final String endpoint;
  final String streamingChannel;
}
