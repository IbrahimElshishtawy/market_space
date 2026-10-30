class HomeHeaderData {
  final String appName;
  final String userName;
  final String location;
  final String? avatarUrl;
  final int unreadNotificationsCount;
  final int cartItemsCount;

  const HomeHeaderData({
    this.appName = 'Deal One',
    required this.userName,
    required this.location,
    this.avatarUrl,
    this.unreadNotificationsCount = 1,
    this.cartItemsCount = 0,
  });
}
