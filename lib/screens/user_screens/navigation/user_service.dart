import 'package:first_flutter/screens/user_screens/navigation/user_service_tab_body/user_Pending_service.dart';
import 'package:first_flutter/screens/user_screens/navigation/user_service_tab_body/user_completed_service.dart';
import 'package:first_flutter/screens/user_screens/navigation/user_service_tab_body/user_ongoing_service.dart';
import 'package:flutter/material.dart';

import '../../../widgets/user_tab_bar.dart';

class UserService extends StatefulWidget {
  const UserService({super.key});

  @override
  State<UserService> createState() => _UserServiceState();
}

class _UserServiceState extends State<UserService>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  int _currentTabIndex = 0;

  // Keys for each tab to force refresh
  List<GlobalKey> _tabKeys = [
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh when app comes to foreground
    if (state == AppLifecycleState.resumed) {
      _refreshCurrentTab();
    }
  }

  void _handleTabChange() {
    // Check if tab index has changed (not just animation)
    if (!_tabController.indexIsChanging && _tabController.index != _currentTabIndex) {
      setState(() {
        _currentTabIndex = _tabController.index;
        // Generate new key to force rebuild
        _tabKeys[_currentTabIndex] = GlobalKey();
      });
    }
  }

  void _refreshCurrentTab() {
    setState(() {
      _tabKeys[_currentTabIndex] = GlobalKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        UserTabBar(controller: _tabController),
        Expanded(child: _tabBarView()),
      ],
    );
  }

  Widget _tabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        UserPendingService(key: _tabKeys[0]),
        UserOngoingService(key: _tabKeys[1]),
        UserCompletedService(key: _tabKeys[2]),
      ],
    );
  }
}