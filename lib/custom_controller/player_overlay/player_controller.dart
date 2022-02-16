import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_player/flutter_native_getx_controller.dart';

class PlayerController extends StatelessWidget {
  final FlutterNativeGetxController controller;
  final GestureTapCallback onTap;
  const PlayerController(
      {Key? key, required this.controller, required this.onTap})
      : super(key: key);

  Widget controllerTop() {
    return Container(
      alignment: Alignment.topCenter,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      height: 50,
      child: Row(
        children: [
          ///Will enable if configuration have be done
          // controller.playerWidget.buttonClick(
          //     const Icon(
          //       Icons.arrow_back,
          //       color: Colors.white,
          //     ),
          //     null,
          //     () {}),
          Expanded(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ///This feature will release as soon as possible
              // controller.playerWidget.downloadWidget(
              //     downloadState: controller.downloadState,
              //     percentageDownloaded: controller.percentageDownloaded,
              //     openOptionQuality: () {
              //       controller.playerMaterialBottomSheet
              //           .showQualityDownloadSelectionWidget(
              //               controller.playerMethodManager.getListQuality(),
              //               controller.playerMethodManager
              //                   .fetchHlsMasterPlaylist.playerResource);
              //     },
              //     retryDownload: () {
              //       controller.playerMethodManager.setRetryDownload();
              //     },
              //     cancelDownload: () {
              //       controller.playerMethodManager.setCancelDownload();
              //     }),
              controller.playerResource.playerSubtitleResources != null
                  ? controller.playerWidget.buttonClick(
                      const Icon(
                        Icons.subtitles_outlined,
                        color: Colors.white,
                      ),
                      null, () {
                      controller.playerMaterialBottomSheet
                          .showSubtitlesSelectionWidget(controller
                              .playerMethodManager.fetchHlsMasterPlaylist
                              .getListSubtitle());
                    })
                  : const SizedBox(),
              controller.playerWidget.buttonClick(
                  const Icon(
                    Icons.more_horiz_sharp,
                    color: Colors.white,
                  ),
                  null, () {
                controller.playerMaterialBottomSheet
                    .showMoreTypeSelectionWidget(
                        controller.playerMethodManager.getListQuality(),
                        controller.playerMethodManager.getCurrentUrlQuality());
              }),
            ],
          ))
        ],
      ),
    );
  }

  Widget controllerCenter() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        controller.playerWidget.buttonClick(
            const Icon(
              Icons.replay_10,
              color: Colors.white,
            ),
            50, () {
          controller.playerMethodManager.replay();
        }),
        Container(
          alignment: Alignment.center,
          width: 60,
          height: 60,
          child: controller.isVisibleButtonPlay
              ? controller.playerWidget
                  .buttonClick(controller.iconControlPlayer, 50, () {
                  controller.playerMethodManager.playByState();
                })
              : const SizedBox(),
        ),
        controller.playerWidget.buttonClick(
            const Icon(Icons.forward_10, color: Colors.white), 50, () {
          controller.playerMethodManager.forward();
        })
      ],
    );
  }

  Widget controllerBottom() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      alignment: Alignment.bottomCenter,
      height: 50,
      child: Row(
        children: [
          GestureDetector(
            child: controller.playerWidget
                .currentTimeWidget(controller.durationState),
            onTap: onTap,
          ),
          Expanded(
              child: controller.playerWidget.progressBar(
                  controller: controller,
                  onSeekListener: (duration) {
                    controller.playerMethodManager
                        .seekTo(duration.inMilliseconds);
                  })),
          GestureDetector(
            child: controller.playerWidget
                .totalTimeWidget(controller.durationState),
            onTap: onTap,
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: Colors.black38,
        ),
        /*Column(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              child: controllerTop(),
              onTap: onTap,
            ),
            Expanded(
                flex: 1,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: onTap,
                  child: controllerCenter(),
                )),
            controllerBottom()
          ],
        )*/
        TvControl()
      ],
    );
  }

  Widget TvControl(){
    return  RawKeyboardListener(
      focusNode: FocusNode(skipTraversal: true,canRequestFocus: false),
      onKey: (RawKeyEvent event) {
        print("KeyEvent");
        if (event is RawKeyDownEvent && event.data is RawKeyEventDataAndroid) {
          RawKeyDownEvent rawKeyDownEvent = event;
          RawKeyEventDataAndroid rawKeyEventDataAndroid = rawKeyDownEvent.data as RawKeyEventDataAndroid;
          print("Focus Node 0 ${rawKeyEventDataAndroid.keyCode}");
          if(!controller.isShowController && rawKeyEventDataAndroid.keyCode != 4) {
            controller.hideControllers();
            // return;
          }else{
            (rawKeyEventDataAndroid.keyCode != 4)? controller.hideControllers() : 0 ;
            if(rawKeyEventDataAndroid.keyCode==22){
              // _fastForwardRewindVideo(Duration(minutes: 5).inSeconds);
            }
          }
        }
      },
      child: Positioned(
        left: 0,
        right: 0,
        top: 0,
        bottom: 0,
        child: Visibility(
          visible: (controller.isShowController),
          child: Container(
            color: Colors.black87,
            child: Stack(
              children: [
                Positioned(
                  left: 40,
                  right: 40,
                  bottom: 40,
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'title',
                          style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              color: Colors.white
                          ),
                        ),
                        SizedBox(height: 20),
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                child: Row(
                                  children: [
                                    MaterialButton(
                                      focusColor: Colors.white38,
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      onPressed: (){
                                        controller.playerMethodManager.superFastRewind();
                                        controller.hideControllers();
                                      },
                                      child: Container(
                                        height: 40,
                                        //width: 40,
                                        child: Center(child: Text("-10 min")),
                                        decoration: BoxDecoration(
                                          //color: (post_x == 2 && post_y == video_controller_play_position )? Colors.white24:Colors.transparent,
                                            borderRadius: BorderRadius.circular(5)
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    MaterialButton(
                                      focusColor: Colors.white38,
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      onPressed: (){
                                        controller.playerMethodManager.replay();
                                        controller.hideControllers();
                                      },
                                      child: Container(
                                        height: 40,
                                        width: 40,
                                        child: const Icon(Icons.fast_rewind,color: Colors.white,size: 35),
                                        decoration: BoxDecoration(
                                          //color: (post_x == 2 && post_y == video_controller_play_position )? Colors.white24:Colors.transparent,
                                            borderRadius: BorderRadius.circular(5)
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    MaterialButton(
                                      focusColor: Colors.white38,
                                      minWidth: 40,
                                      autofocus: true,
                                      padding: EdgeInsets.zero,
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      onPressed: (){
                                        controller.playerMethodManager.playByState();
                                        controller.hideControllers();
                                      },
                                      child: Container(
                                        height: 40,
                                        width: 40,
                                        child:
                                        Center(
                                          child: AnimatedIcon(
                                            icon: AnimatedIcons.play_pause,
                                            progress: controller.playerMethodManager.animatedController,
                                            size: 35,
                                            color: Colors.white,
                                          ),
                                        ),
                                        decoration: BoxDecoration(
                                            color: Colors.white24,
                                            borderRadius: BorderRadius.circular(5)
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    MaterialButton(
                                      focusColor: Colors.white38,
                                      onPressed: (){
                                        controller.playerMethodManager.forward();
                                        controller.hideControllers();
                                      },
                                      child: Container(
                                        height: 40,
                                        width: 40,
                                        child: const Icon(Icons.fast_forward,color: Colors.white,size: 35),
                                        decoration: BoxDecoration(
                                          //color: (post_x == 3 && post_y == video_controller_play_position )? Colors.white24:Colors.transparent,
                                            borderRadius: BorderRadius.circular(5)
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    MaterialButton(
                                      focusColor: Colors.white38,
                                      onPressed: (){
                                        controller.playerMethodManager.superFastForward();
                                        controller.hideControllers();
                                      },
                                      child: Container(
                                        height: 40,
                                        //width: 40,
                                        child: const Center(child: Text("+10 min")),
                                        decoration: BoxDecoration(
                                          //color: (post_x == 2 && post_y == video_controller_play_position )? Colors.white24:Colors.transparent,
                                            borderRadius: BorderRadius.circular(5)
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),

                        Focus(
                          focusNode: FocusNode(skipTraversal: true,descendantsAreFocusable: false,canRequestFocus: false),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Container(
                              child: SliderTheme(
                                data: SliderThemeData(
                                  trackShape: CustomTrackShape(),
                                  activeTrackColor:  const Color(0xFFFECB35).withOpacity(0.5),
                                  thumbColor: const Color(0xFFDBA622),
                                  showValueIndicator: ShowValueIndicator.always,
                                ),
                                child: Slider(
                                  inactiveColor: Colors.white38,

                                  min: 0,
                                  max: 100,
                                  value: controller.durationToInt(),
                                  onChanged: (value) {

                                  },
                                  onChangeStart: (va){
                                    print("onChangeStart");
                                  },

                                  onChangeEnd: (va){
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
                                    controller.printDuration(Duration(milliseconds: controller.playerMethodManager.currentPosition())),
                                    style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 18
                                    ),
                                  ),
                                  const Text(
                                    " / ",
                                    style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 18
                                    ),
                                  ),
                                  Text(
                                    controller.printDuration(Duration(milliseconds: controller.playerMethodManager.totalDuration())),
                                    style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 18
                                    ),
                                  )
                                ],
                              )
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}



class CustomTrackShape extends RoundedRectSliderTrackShape {Rect getPreferredRect({
  required RenderBox parentBox,
  Offset offset = Offset.zero,
  required SliderThemeData sliderTheme,
  bool isEnabled = false,
  bool isDiscrete = false,}) {final double trackHeight = sliderTheme.trackHeight??0;
final double trackLeft = offset.dx;
final double trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
final double trackWidth = parentBox.size.width;
return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);}}
