import 'package:bloc/bloc.dart';
import 'package:fbroadcast/fbroadcast.dart';

import '../database.dart';
import '../globals.dart';
import '../models/db/server.dart';

class ServerSettingsCubit extends Cubit<Server> {
  ServerSettingsCubit(super.initialState);

  useServer(bool value) {
    db.useServer(state);
    state.inUse = true;
    emit(state);
  }

  @override
  emit(Server state) {
    super.emit(state.copyWith());
  }

  void logOut() {
    Server s = state;
    s.sidCookie = null;
    s.authToken = null;
    db.upsertServer(s);
    emit(state);
  }

  Future<void> logInWithToken() async {
    await service.logIn(state.url);
    Server server = db.getServer(state.url)!;
    emit(server);
  }

  Future<void> logInWithCookie(String username, String password) async {
    print('login with $username, $password');
    String cookie = await service.loginWithCookies(state.url, username, password);

    state.sidCookie = cookie;
    db.upsertServer(state);
    FBroadcast.instance().broadcast(BROADCAST_SERVER_CHANGED);
    emit(state);
  }

  deleteServer() {
    db.deleteServer(state);
    // widget.refreshServers();

    Server currentServer = db.getCurrentlySelectedServer();
    if (currentServer.url == state.url) {
      db.deleteSetting(SELECTED_SERVER);
    }
    emit(state);
  }

  bool get canDelete => db.getServers().length > 1;
}

/*
class ServerSettingsController {
  late Server server;


  ServerSettingsController(this.server);

}
*/
