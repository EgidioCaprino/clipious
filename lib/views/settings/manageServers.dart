import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:invidious/controllers/serverListSettingsController.dart';
import 'package:invidious/views/settings/manageServerInner.dart';

class ManageServers extends StatefulWidget {
  const ManageServers({super.key});

  @override
  ManageServerState createState() => ManageServerState();
}

class ManageServerState extends State<ManageServers> {
  @override
  Widget build(BuildContext context) {
    var locals = AppLocalizations.of(context)!;
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: colorScheme.background,
          scrolledUnderElevation: 0,
          title: Text(locals.manageServers),
        ),
        backgroundColor: colorScheme.background,
        body: SafeArea(
            bottom: false,
            child: BlocProvider(create: (BuildContext context) => ServerListSettingsCubit(ServerListSettingsController(dbServers: [], publicServers: [])), child: const ManagerServersView())));
  }
}
