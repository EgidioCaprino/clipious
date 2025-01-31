import 'package:bloc/bloc.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:invidious/extensions.dart';
import 'package:invidious/videos/models/video_in_list.dart';
import 'package:logging/logging.dart';

import '../../globals.dart';
import '../../playlists/models/playlist.dart';

part 'add_to_playlist.g.dart';

const String likePlaylistName = '❤️';

class AddToPlaylistCubit extends Cubit<AddToPlaylistController> {
  final log = Logger('AddToPlaylistcubit');

  AddToPlaylistCubit(super.initialState) {
    onReady();
  }

  bool videoInPlaylist(String playlistId) {
    Playlist? pl = state.playlists.firstWhere((pl) => pl.playlistId == playlistId);

    return (pl?.videos.indexWhere((element) => element.videoId == state.videoId) ?? -1) >= 0;
  }

  addToPlaylist(String playlistId) async {
    await service.addVideoToPlaylist(playlistId, state.videoId);
    onReady();
  }

  Future<void> onReady() async {
    await getAllPlaylists();
    await countPlaylistsForVideo();
    await checkVideoLikeStatus();
  }

  getAllPlaylists() async {
    emit(state.copyWith(loading: true));
    late List<Playlist> playlists;
    if (state.isLoggedIn) {
      playlists = await service.getUserPlaylists();
    }
    emit(state.copyWith(playlists: playlists, loading: false));
  }

  Future<Playlist?> likePlaylist() async {
    Playlist? pl = state.playlists.firstWhereOrNull((pl) => pl.title == likePlaylistName);

    return pl;
  }

  checkVideoLikeStatus() async {
    Playlist? p = await likePlaylist();
    VideoInList? video = p?.videos.firstWhereOrNull((element) => element.videoId == state.videoId);

    bool isVideoLiked = video != null;

    if (!isClosed) {
      emit(state.copyWith(isVideoLiked: isVideoLiked));
      log.fine('video is currently liked ? $state.isVideoLiked');
    }
  }

  Future<Playlist?> createPlayList() async {
    await service.createPlayList(likePlaylistName, "private");
    await onReady();
    return likePlaylist();
  }

  countPlaylistsForVideo() async {
    int playListCount =
        state.playlists.where((list) => list.videos.indexWhere((video) => video.videoId == state.videoId) >= 0).length;
    log.fine('playlist count ${state.playListCount}');
    if (!isClosed) {
      emit(state.copyWith(playListCount: playListCount));
    }
  }

  Future<void> toggleLike() async {
    emit(state.copyWith(loading: true));

    await onReady();
    Playlist? p = await likePlaylist();
    p ??= await createPlayList();

    bool isVideoLiked = state.isVideoLiked;
    if (p != null && state.videoId != null) {
      if (isVideoLiked) {
        log.fine('Video is liked, unliking it');
        VideoInList? v = p.videos.firstWhereOrNull((element) => element.videoId == state.videoId!);
        if (v?.indexId != null) {
          await service.deleteUserPlaylistVideo(p.playlistId, v!.indexId!);
          isVideoLiked = isVideoLiked;
        }
      } else {
        log.fine('Video is not liked yet, we add it to the like playlist');
        await service.addVideoToPlaylist(p.playlistId, state.videoId!);
        isVideoLiked = isVideoLiked;
      }
    }
    emit(state.copyWith(isVideoLiked: isVideoLiked, loading: false));
    onReady();
  }

  saveVideoToPlaylist(String selectedPlaylistId) async {
    await service.addVideoToPlaylist(selectedPlaylistId, state.videoId);
    await onReady();
  }
}

@CopyWith(constructor: "_")
class AddToPlaylistController {
  List<Playlist> playlists = [];
  int playListCount = 0;
  String videoId;
  bool isVideoLiked = false;

  bool loading = true;
  bool isLoggedIn = service.isLoggedIn();

  AddToPlaylistController(this.videoId);

  AddToPlaylistController._(
      this.playlists, this.playListCount, this.videoId, this.loading, this.isLoggedIn, this.isVideoLiked);
}
