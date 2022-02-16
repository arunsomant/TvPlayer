import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_player/custom_controller/configuration/player_progress_colors.dart';
import 'package:flutter_native_player/custom_controller/player_overlay/player_loading.dart';
import 'package:flutter_native_player/custom_controller/player_overlay/player_overlay_controller.dart';
import 'package:flutter_native_player/flutter_native_getx_controller.dart';
import 'package:flutter_native_player/model/player_resource.dart';
import 'package:flutter_native_player/subtitles/player_kid_subtitles_drawer.dart';
import 'package:get/get.dart';

import 'constant.dart';

class FlutterNativePlayer extends StatelessWidget {
  final PlayerResource playerResource;
  final PlayerProgressColors? progressColors;
  final bool playWhenReady;
  final double width;
  final double height;
  final String title;

  const FlutterNativePlayer(
      {Key? key,
        required this.playerResource,
        this.progressColors,
        this.playWhenReady = true,
        required this.width,
        required this.height,
        required this.title})
      : super(key: key);

  Widget androidPlatform(Map<String, dynamic> creationParams) {
    return PlatformViewLink(
      viewType: Constant.MP_VIEW_TYPE,
      surfaceFactory:
          (BuildContext context, PlatformViewController controller) {
        return AndroidViewSurface(
          controller: controller as AndroidViewController,
          gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
          hitTestBehavior: PlatformViewHitTestBehavior.opaque,
        );
      },
      onCreatePlatformView: (PlatformViewCreationParams params) {
        return PlatformViewsService.initSurfaceAndroidView(
          id: params.id,
          viewType: Constant.MP_VIEW_TYPE,
          layoutDirection: TextDirection.ltr,
          creationParams: creationParams,
          creationParamsCodec: const StandardMessageCodec(),
        )
          ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
          ..create();
      },
    );
  }

  Widget iOSPlatform(Map<String, dynamic> creationParams) {
    return UiKitView(
        viewType: Constant.MP_VIEW_TYPE,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec());
  }

  Widget crossPlatform() {
    final creationParams = {
      Constant.KEY_PLAYER_RESOURCE: playerResourceToJson(playerResource),
      Constant.KEY_PLAY_WHEN_READY: playWhenReady
    };
    Widget platform;
    if (defaultTargetPlatform == TargetPlatform.android) {
      platform = androidPlatform(creationParams);
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      platform = iOSPlatform(creationParams);
    } else {
      platform = const Text("Error no view type");
    }
    return Container(
        alignment: Alignment.topCenter,
        width: double.infinity,
        height: double.infinity,
        child: platform,
        color: Colors.black);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: FlutterNativeGetxController(
          context: context,
          playerResource: playerResource,
          playWhenReady: playWhenReady,title: title),
      builder: (FlutterNativeGetxController controller) {
        return WillPopScope(
          onWillPop: () async{
            if(controller.isShowController){
              controller.forceHideControllers();
              return false;
            }
            return true;
          },
          child: RawKeyboardListener(
            focusNode: FocusNode(skipTraversal: true, canRequestFocus: false),
            onKey: (RawKeyEvent event) {
              print("KeyEvent from ouside");
              if (event is RawKeyDownEvent &&
                  event.data is RawKeyEventDataAndroid) {
                RawKeyDownEvent rawKeyDownEvent = event;
                RawKeyEventDataAndroid rawKeyEventDataAndroid =
                rawKeyDownEvent.data as RawKeyEventDataAndroid;
                print("Focus Node 0 ${rawKeyEventDataAndroid.keyCode}");
                if (!controller.isShowController &&
                    rawKeyEventDataAndroid.keyCode != 4) {
                  controller.hideControllers();
                  // return;
                } else {
                  (rawKeyEventDataAndroid.keyCode != 4)
                      ? controller.hideControllers()
                      : 0;
                  if (rawKeyEventDataAndroid.keyCode == 22) {
                    // _fastForwardRewindVideo(Duration(minutes: 5).inSeconds);
                  }
                }
              }
            },
            child: Stack(
              children: [
                Focus(
                    focusNode: FocusNode(
                        canRequestFocus: false,
                        skipTraversal: true,
                        descendantsAreFocusable: false),child: crossPlatform()),
                Focus(
                  focusNode: FocusNode(
                      canRequestFocus: false,
                      skipTraversal: true,
                      descendantsAreFocusable: false),
                  child: PlayerLoading(
                    controller: controller,
                  ),
                ),
                controller.isShowController && controller.isReady
                    ? TvControl(controller)
                    : MaterialButton(
                  focusColor: Colors.transparent,
                  color: Colors.transparent,
                  materialTapTargetSize:
                  MaterialTapTargetSize.shrinkWrap,
                  onPressed: () {
                  },
                  child: Container(
                    height: 40,
                    //width: 40,
                    child: const Center(child: Text("")),
                    decoration: BoxDecoration(
                      //color: (post_x == 2 && post_y == video_controller_play_position )? Colors.white24:Colors.transparent,
                        borderRadius: BorderRadius.circular(5)),
                  ),
                ),

              ],
            ),
          ),
        );
      },
    );
  }

  Widget TvControl(FlutterNativeGetxController controller) {
    return Visibility(
      visible: (controller.isShowController),
      child: Container(
        color: Colors.black87,
        child: Stack(
          children: [
            Positioned(
              left: 20,
              right: 20,
              bottom: 40,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${controller.title}',
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        child: Row(
                          children: [
                            MaterialButton(
                              focusColor: Colors.white38,
                              materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                              onPressed: () {
                                controller.playerMethodManager
                                    .superFastRewind();
                                controller.hideControllers();
                              },
                              child: Container(
                                height: 40,
                                //width: 40,
                                child: const Center(child: Text("-10 min")),
                                decoration: BoxDecoration(
                                  //color: (post_x == 2 && post_y == video_controller_play_position )? Colors.white24:Colors.transparent,
                                    borderRadius: BorderRadius.circular(5)),
                              ),
                            ),
                            const SizedBox(width: 20),
                            MaterialButton(
                              focusColor: Colors.white38,
                              materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                              onPressed: () {
                                controller.playerMethodManager.replay();
                                controller.hideControllers();
                              },
                              child: Container(
                                height: 40,
                                width: 40,
                                child: const Icon(Icons.fast_rewind,
                                    color: Colors.white, size: 35),
                                decoration: BoxDecoration(
                                  //color: (post_x == 2 && post_y == video_controller_play_position )? Colors.white24:Colors.transparent,
                                    borderRadius: BorderRadius.circular(5)),
                              ),
                            ),
                            const SizedBox(width: 20),
                            MaterialButton(
                              focusColor: Colors.white38,
                              minWidth: 40,
                              autofocus: true,
                              padding: EdgeInsets.zero,
                              materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                              onPressed: () {
                                controller.playerMethodManager.playByState();
                                controller.hideControllers();
                              },
                              child: Container(
                                height: 40,
                                width: 40,
                                child: Center(
                                    child:Obx(() {
                                      final test =  controller.test.isTrue;
                                      return  AnimatedIcon(
                                        icon: AnimatedIcons.play_pause,
                                        progress: controller
                                            .animatedController,
                                        size: 35,
                                        color: Colors.white,
                                      );})
                                ),
                                decoration: BoxDecoration(
                                    color: Colors.white24,
                                    borderRadius: BorderRadius.circular(5)),
                              ),
                            ),
                            const SizedBox(width: 20),
                            MaterialButton(
                              focusColor: Colors.white38,
                              onPressed: () {
                                controller.playerMethodManager.forward();
                                controller.hideControllers();
                              },
                              child: Container(
                                height: 40,
                                width: 40,
                                child: const Icon(Icons.fast_forward,
                                    color: Colors.white, size: 35),
                                decoration: BoxDecoration(
                                  //color: (post_x == 3 && post_y == video_controller_play_position )? Colors.white24:Colors.transparent,
                                    borderRadius: BorderRadius.circular(5)),
                              ),
                            ),
                            const SizedBox(width: 20),
                            MaterialButton(
                              focusColor: Colors.white38,
                              onPressed: () {
                                controller.playerMethodManager
                                    .superFastForward();
                                controller.hideControllers();
                              },
                              child: Container(
                                height: 40,
                                //width: 40,
                                child: const Center(child: Text("+10 min")),
                                decoration: BoxDecoration(
                                  //color: (post_x == 2 && post_y == video_controller_play_position )? Colors.white24:Colors.transparent,
                                    borderRadius: BorderRadius.circular(5)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Focus(
                    focusNode: FocusNode(
                        skipTraversal: true,
                        descendantsAreFocusable: false,
                        canRequestFocus: false),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Container(
                        child: SliderTheme(
                          data: SliderThemeData(
                            trackShape: CustomTrackShape(),
                            activeTrackColor:
                            const Color(0xFFFECB35).withOpacity(0.5),
                            thumbColor: const Color(0xFFDBA622),
                            showValueIndicator: ShowValueIndicator.always,
                          ),
                          child: Slider(
                            inactiveColor: Colors.white38,
                            min: 0,
                            max: 100,
                            value: controller.durationToInt(),
                            onChanged: (value) {},
                            onChangeStart: (va) {
                              print("onChangeStart");
                            },
                            onChangeEnd: (va) {
                              print("onChangeEnd");
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            controller.printDuration(Duration(
                                milliseconds: controller.playerMethodManager
                                    .currentPosition())),
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 18),
                          ),
                          const Text(
                            " / ",
                            style:
                            TextStyle(color: Colors.white70, fontSize: 18),
                          ),
                          Text(
                            controller.printDuration(Duration(
                                milliseconds: controller.playerMethodManager
                                    .totalDuration())),
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 18),
                          )
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomTrackShape extends RoundedRectSliderTrackShape {
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight ?? 0;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}
