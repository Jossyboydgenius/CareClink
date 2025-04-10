abstract class DashboardEvent {
  const DashboardEvent();
}

class LoadDashboardSummaries extends DashboardEvent {
  final bool forceRefresh;

  const LoadDashboardSummaries({this.forceRefresh = false});
}
