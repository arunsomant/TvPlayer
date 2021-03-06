import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_native_player/custom_controller/material/dialog/player_material_bottom_sheet.dart';
import 'package:flutter_native_player/custom_controller/player_overlay/player_widget.dart';
import 'package:flutter_native_player/model/duration_state.dart';
import 'package:flutter_native_player/model/player_resource.dart';
import 'package:get/get.dart';

import 'hls/fetch_hls_master_playlist.dart';
import 'method_manager/download_state.dart';
import 'method_manager/playback_state.dart';
import 'method_manager/player_method_manager.dart';

class FlutterNativeGetxController extends SuperController with GetSingleTickerProviderStateMixin {
  final BuildContext context;
  final PlayerResource playerResource;
  final bool playWhenReady;
  final String title;
  late FetchHlsMasterPlaylist fetchHlsMasterPlaylist;
  late PlayerMethodManager playerMethodManager;
  late PlayerMaterialBottomSheet playerMaterialBottomSheet;

  FlutterNativeGetxController(
      {required this.context,
        required this.playerResource,
        required this.playWhenReady,
        required this.title});

  ///Current Position for subtitle
  Duration? currentPosition;

  ///Duration state for count down time
  DurationState? durationState;

  ///Download state for validate widget
  DownloadState? downloadState;

  ///Timer count for showing controller timeout
  Timer? controllerTimeout;

  ///State for player overlay controller
  bool isShowController = true;

  ///State for loading widget that on over player and overlay controller
  bool isShowLoading = false;

  bool isReady = false;

  ///Component widget like button, progress bar, etc as singleton
  final playerWidget = PlayerWidget();

  ///Icon for button play that will modify base on playback state.
  Icon iconControlPlayer = const Icon(
    Icons.play_arrow,
    color: Colors.white,
  );

  ///Icon for button download that will modify base on download state.
  Icon iconDownloader = const Icon(
    Icons.arrow_downward,
    color: Colors.white,
  );

  ///State for visible or hide button play that will modify base on playback state.
  bool isVisibleButtonPlay = true;

  ///State for visible or hide button download that will modify base on download state
  bool isShowProgressDownload = true;

  ///Progress value to update view of circular progress bar that will modify base on progress download state.
  double percentageDownloaded = 0;

  ///Indicatermate to show or hide loading over download button before show circular progress bar that will modify base on download state.
  bool isIndicatermateCircularProgress = false;

  Timer? _visibile_controllers_future;

  late AnimationController animatedController;

  final test = false.obs;

  @override
  void onInit() {
    ///It's use to fetch hls segment and subtitle.
    fetchHlsMasterPlaylist =
        FetchHlsMasterPlaylist(playerResource: playerResource);

    animatedController =  AnimationController(vsync: this, duration: Duration(milliseconds: 450));
    ///Method that use to interact with player on native code.
    playerMethodManager = PlayerMethodManager(
        fetchHlsMasterPlaylist: fetchHlsMasterPlaylist,
        playWhenReady: playWhenReady,
        vsync:animatedController);

    ///Method that use to open bottom sheet, i.e open bottom sheet to show quality, playback speed, download by quality.
    playerMaterialBottomSheet = PlayerMaterialBottomSheet(
        context: context,
        fetchHlsMasterPlaylist: playerMethodManager.fetchHlsMasterPlaylist,
        playerMethodManager: playerMethodManager);

    ///Called when player subtitle has changed, i.e user change from english to khmer.
    _handleSubtitleEvent();

    ///Called when player state has changed, i.e. new player position, etc.
    _handleDurationStateEvent();

    ///Called when download state has changed, i.e user start, pause, resume, failed download.
    _handleDownloadEvent();

    ///Called when play back state has changed i.e player going to ready to play, pause, play, loading, and finish.
    _handlePlaybackStateEvent();

    ///Called every 8 seconds to hide overlay controller.
    handleControllerTimeout();

    super.onInit();
  }

  void _updateEventTypePlay() {
    animatedController.forward();
    iconControlPlayer = const Icon(
      Icons.pause_outlined,
      color: Colors.white,
    );
  }

  void _updateEventTypePause() {
    animatedController.reverse();
    iconControlPlayer = const Icon(
      Icons.play_arrow,
      color: Colors.white,
    );
  }

  void _updateEventTypeFinished() {
    animatedController.reverse();
    controllerTimeout?.cancel();
    isShowLoading = false;
    isVisibleButtonPlay = true;
    isShowController = true;
    iconControlPlayer = const Icon(
      Icons.replay,
      color: Colors.white,
    );
  }

  void _handleSubtitleEvent() {
    playerMethodManager.setSubtitleSelectedListener((source) {
      fetchHlsMasterPlaylist.setupSubtitleSource(source);
      update();
    });
  }

  void _handleDurationStateEvent() {
    playerMethodManager.streamDurationState.listen((event) {
      currentPosition = Duration(milliseconds: event.progress.inMilliseconds);
      durationState = event;
      update();
    });
  }

  double durationToInt()  {
    Duration duration = Duration(milliseconds: playerMethodManager.currentPosition());
    if(duration != null && playerMethodManager.totalDuration()!=null){
      int milli_second_duration =  playerMethodManager.totalDuration();
      int milli_second_position = duration.inMilliseconds;
      double position_int = (milli_second_position/milli_second_duration)*100;
      print("position: ${(position_int>100)? 100:((position_int<0)? 0:position_int)}");
      return (position_int>100)? 100:((position_int<0)? 0:position_int);
    }
    return 0;
  }

  String printDuration(Duration duration) {

    if(duration == null){
      return "00:00:00";
    }
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));

    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  void _handlePlaybackStateEvent() {
    playerMethodManager.streamPlaybackState.listen((event) {
      switch (event) {
        case PlaybackState.readyToPlay:
          {
            isShowLoading = false;
            isVisibleButtonPlay = true;
            isReady = true;
          }
          break;
        case PlaybackState.play:
          {
            handleControllerTimeout();
            _updateEventTypePlay();
          }
          break;
        case PlaybackState.pause:
          {
            controllerTimeout?.cancel();
            _updateEventTypePause();
          }
          break;
        case PlaybackState.loading:
          {
            isShowLoading = true;
            isVisibleButtonPlay = false;
          }
          break;
        case PlaybackState.finish:
          {
            _updateEventTypeFinished();
          }
          break;
      }
      update();
    });
  }

  void _handleDownloadEvent() {
    playerMethodManager.streamProgressDownloadState.listen((event) {
      percentageDownloaded = event;
      update();
    });
    playerMethodManager.streamDownloadState.listen((event) {
      downloadState = event;
      if (event == DownloadState.downloadCompleted) {
        playerMethodManager.fetchHlsMasterPlaylist.listQuality?.clear();
      }
      update();
    });
  }

  void handleControllerTimeout() {
    controllerTimeout?.cancel();
    controllerTimeout = Timer.periodic(const Duration(seconds: 5), (timer) {
      isShowController = false;
      update();
    });
  }

  hideControllers(){
    print('HideController called: $isShowController');
    isShowController = true;

    if(controllerTimeout != null){
      controllerTimeout?.cancel();
    }
    controllerTimeout = Timer(Duration(milliseconds: 5000), () {
      isShowController = false;
      update();
    });
    // and later, before the timer goes off...
    update();
  }

  forceHideControllers(){
    isShowController = false;
    update();
    if(controllerTimeout != null){
      controllerTimeout?.cancel();
    }
  }

  @override
  void onDetached() {}

  @override
  void onInactive() {}

  @override
  void onPaused() {
    playerMethodManager.pause();
  }

  @override
  void onResumed() {}
}
