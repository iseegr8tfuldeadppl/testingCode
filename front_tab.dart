
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lefkiriboubakerhalaltinder/utils/dimensions.dart';
import '../../utils/colors.dart';
import '../../widgets/text.dart';

class FrontTab extends StatefulWidget {
  const FrontTab({Key? key}) : super(key: key);

  @override
  State<FrontTab> createState() => _FrontTabState();
}

class _FrontTabState extends State<FrontTab>  with TickerProviderStateMixin  {


  // CARD PHOTOS PAGER:
  PageController cardImageController = PageController(viewportFraction: 1.0);
  var _currImageIndexValue = 0.0;

  // SWIPE: left right, maybe up down
  bool swipedOff = false; // to prevent the code swiping off both the horizontal and vertical if card were to be pulled to a corner instead of a side
  bool pulledHorizontally = false, pulledVertically = false;
  List<String> cards = [];
  double verticalDragPosition = 0.0;
  double dragPosition = 0.0;
  double rotationAngle = 0.0;
  late AnimationController _flingController;
  late AnimationController _verticalFlingController;
  late AnimationController _returnController;
  late Animation<double> _flingAnimation;
  late Animation<double> _verticalFlingAnimation;
  late Animation<double> _returnAnimation;

  late Animation<double> _comingToFrontAnimation;
  late AnimationController _comingToFrontController;

  // LOADING:
  late AnimationController _loadingController;

  // EXPAND CARD:
  // Add this to your _FrontTabState class
  bool isDetailedView = false;
  // Add this to your initState() method
  late AnimationController _detailController;
  late Animation<double> _detailAnimation;

  // CARD DATA
  int totalImages = 3;

  // PHOTOS TUTORIAL:
  late AnimationController _descTutorialController;
  late Animation<double> _descTutorialAnimation;
  late AnimationController _photosTutorialController;
  late Animation<double> _photosTutorialAnimation;
  bool showingTutorial = false;

  // SWIPING TUTORIAL:
  late AnimationController _swipingTutorialController;
  late Animation<double> _swipingTutorialAnimation;
  late AnimationController _verticalSwipingTutorialController;
  late Animation<double> _verticalSwipingTutorialAnimation;
  int tutorialDirection = 1;


  @override
  void initState() {
    super.initState();

    // Initialize your list of cards here
    cards = [
      "",
      "",
      "",
      "",
    ];


    // CARD PHOTOS PAGER:
    cardImageController.addListener(() {
      setState(() {
        _currImageIndexValue = cardImageController.page!;
      });
    });


    // EXPAND CARD:
    _detailController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _detailAnimation = CurvedAnimation(
      parent: _detailController,
      curve: Curves.easeInOut,
    )..addStatusListener((status) {
      if(status == AnimationStatus.dismissed){

      } else if (status == AnimationStatus.completed) {

        // SWIPE HINT: show user they can swipe, a slight fling and then it lets go, but for some reason, the swing has to be as screens wide as how far the images are from us
        double swipe = Dimensions.screenWidth*cardImageController.page! + ((cardImageController.page==totalImages-1?-1:1)*Dimensions.screenWidth/4);
        cardImageController.animateTo(swipe, duration: const Duration(milliseconds: 600), curve: Curves.easeOut,);

      }
    });

    // LOADING:
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _loadingController.stop(); // Initially stop the animation


    // COMING TO FRONT: next page
    _comingToFrontController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _comingToFrontAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(_comingToFrontController);



    // FLING FRONT CARD: shoot it sideways
    _flingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _flingAnimation = Tween<double>(begin: 0, end: 1).animate(_flingController)
      ..addListener(() {
        setState(() {
          dragPosition += _flingAnimation.value;
        });
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.forward) {
          _comingToFrontController.forward();
        }
        if (status == AnimationStatus.completed) {
          // Remove the card from the layout
          // For demonstration, we just reset the position
          swipedOff = false;
          setState(() {
            cardImageController.jumpTo(0);
            cards.removeLast();
            dragPosition = 0;
            rotationAngle = 0;
            verticalDragPosition = 0;
          });
          _comingToFrontController.reverse();
          if(cards.isEmpty) _startAnimation();
          // TODO: sent http request to firebase
        }
      });

    // RETURN FRONT CARD: to original position
    _returnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _returnAnimation = Tween<double>(begin: 0, end: 1).animate(_returnController)
      ..addListener(() {
        setState(() {
          dragPosition = dragPosition * (1 - _returnAnimation.value);
          verticalDragPosition = verticalDragPosition * (1 - _returnAnimation.value);
          rotationAngle = rotationAngle * (1 - _returnAnimation.value);
        });
      });

    // FLING FRONT CARD: up and down fling
    _verticalFlingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _verticalFlingAnimation = Tween<double>(begin: 0, end: 500).animate(_verticalFlingController)
      ..addListener(() {
        setState(() {
          verticalDragPosition += _verticalFlingAnimation.value;
        });
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.forward) {
          if(cards.isNotEmpty) _comingToFrontController.forward();
        }
        if (status == AnimationStatus.completed) {
          verticalDragPosition += _verticalFlingAnimation.value; // only apply the result at the end
          // Remove the card from the layout
          // For demonstration, we just reset the position
          swipedOff = false;
          setState(() {
            cards.removeLast();
            dragPosition = 0;
            rotationAngle = 0;
            verticalDragPosition = 0;
          });
          if(cards.isEmpty) _startAnimation();
          else _comingToFrontController.reverse();
          // TODO: sent http request to firebase
        }
      });





    // PHOTOS TUTORIAL:
    _photosTutorialController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _photosTutorialAnimation = CurvedAnimation(
      parent: _photosTutorialController,
      curve: Curves.easeInOut,
    )..addStatusListener((status) {
      if(status == AnimationStatus.dismissed){
        _descTutorialController.forward();

      } else if (status == AnimationStatus.completed) {
        // Do something when animation is complete

        Future.delayed(const Duration(seconds: 2), () {
          _photosTutorialController.reverse();
        });
      }
    });


    // DESCRIPTION TUTORIAL:
    _descTutorialController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _descTutorialAnimation = CurvedAnimation(
      parent: _descTutorialController,
      curve: Curves.easeInOut,
    )..addStatusListener((status) {
      if(status == AnimationStatus.dismissed){
        setState(() {
          showingTutorial = false;
        });

      } else if (status == AnimationStatus.completed) {
        // Do something when animation is complete

        Future.delayed(const Duration(seconds: 2), () {
          _descTutorialController.reverse();
        });
      }
    });

    // SWIPING TUTORIAL: side ways
    _swipingTutorialController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _swipingTutorialAnimation = Tween<double>(begin: 0, end: 1).animate(_swipingTutorialController)
      ..addListener(() {
        setState(() {
          dragPosition = tutorialDirection*100*_swipingTutorialAnimation.value;
          rotationAngle = dragPosition/800;
        });
      })
      ..addStatusListener((status) {

        // WE CAME BACK FROM THE SWIPE, EITHER WE DO THE NEXT ONE OR WERE GOOD TO GO
        if(status == AnimationStatus.dismissed){
          if(tutorialDirection == 1){
            tutorialDirection = -1;
            Future.delayed(const Duration(milliseconds: 600), () {
              _swipingTutorialController.forward();
            });
          } else {

            // PHOTOS TUTORIAL ANIMATION: start it
            // Start the animation after 3 seconds
            Future.delayed(const Duration(milliseconds: 600), () {
              tutorialDirection = 1;
              _verticalSwipingTutorialController.forward();
            });
          }

          // WE JUST REACHED THE TIP OF OUR SWIPE SHOWCASE
        } else if (status == AnimationStatus.completed) {
          Future.delayed(const Duration(seconds: 1), () {
            _swipingTutorialController.reverse();
          });
        }
      });

    // SWIPING TUTORIAL: up and down
    _verticalSwipingTutorialController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _verticalSwipingTutorialAnimation = Tween<double>(begin: 0, end: 1).animate(_verticalSwipingTutorialController)
      ..addListener(() {
        setState(() {
          verticalDragPosition = tutorialDirection*150*_verticalSwipingTutorialAnimation.value;
          //rotationAngle = dragPosition/800;
        });
      })
      ..addStatusListener((status) {

        // WE CAME BACK FROM THE SWIPE, EITHER WE DO THE NEXT ONE OR WERE GOOD TO GO
        if(status == AnimationStatus.dismissed){
          if(tutorialDirection == 1){
            tutorialDirection = -1;
            Future.delayed(const Duration(milliseconds: 600), () {
              _verticalSwipingTutorialController.forward();
            });
          } else {
            tutorialDirection = 1;

            // PHOTOS TUTORIAL ANIMATION: start it
            // Start the animation after 3 seconds
            Future.delayed(const Duration(milliseconds: 600), () {
              setState(() {
                showingTutorial = true;
              });
              _photosTutorialController.forward();
            });
          }

          // WE JUST REACHED THE TIP OF OUR SWIPE SHOWCASE
        } else if (status == AnimationStatus.completed) {
          Future.delayed(const Duration(seconds: 1), () {
            _verticalSwipingTutorialController.reverse();
          });
        }
      });



    // SWIPING TUTORIAL ANIMATION: start it
    Future.delayed(const Duration(milliseconds: 1000), () {
      tutorialDirection = 1;
      _swipingTutorialController.forward();
    });

  }

  @override
  void dispose() {
    cardImageController.dispose();
    _swipingTutorialController.dispose();
    _verticalSwipingTutorialController.dispose();
    _photosTutorialController.dispose();
    _descTutorialController.dispose();
    _detailController.dispose();
    _loadingController.dispose();
    _flingController.dispose();
    _verticalFlingController.dispose();
    _returnController.dispose();
    super.dispose();
  }

  void _startAnimation() {
    _loadingController.forward();
    _loadingController.repeat(reverse: true);
  }

  void _stopAnimation() {
    _loadingController.stop();
  }

  @override
  Widget build(BuildContext context) {
    print("setstated");
    return Container(
      height: Dimensions.screenHeight,
      color: AppColors.whiteIsh,
      child: SingleChildScrollView(
        child: Column(
          children: [

            // TASKBAR & CARDS:
            AnimatedBuilder(
                animation: _detailController,
                builder: (context, child) {
                  return Container(
                    height: Dimensions.screenHeight - _detailAnimation.value*(Dimensions.screenHeight - ((Dimensions.screenHeight-85) * 0.75)),
                    color: AppColors.whiteIsh,
                    child: Stack(
                      //key: const Key('card doesn\'t update  while going into detail view'),
                      children: [

                        // SECTION: task bar
                        Positioned(
                          top: 0,
                          height: 120,
                          left: 0,
                          right: 0,
                          child: Row(
                            children: [

                              // ICON: burger
                              Expanded(
                                flex: 1,
                                child: GestureDetector(
                                  onTap: (){
                                    collapseCard();
                                  },
                                  child: Container(
                                    color: Colors.transparent,
                                    child: Padding(
                                      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20, bottom: 10),
                                      child: Icon(isDetailedView ? Icons.arrow_back : Icons.menu, color: AppColors.main, size: 30),
                                    ),
                                  ),
                                ),
                              ),

                              // LOGO:
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20, bottom: 10),
                                  child: Image.asset(
                                    'assets/ahalal.png',
                                    width: 50,
                                    height: 50,
                                  ),
                                ),
                              ),

                              // ICON: filter
                              Expanded(
                                flex: 1,
                                child: GestureDetector(
                                  onTap: (){

                                  },
                                  child: Container(
                                    color: Colors.transparent,
                                    child: Padding(
                                      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20, bottom: 10),
                                      child: const Icon(
                                        Icons.filter_list_alt,
                                        size: 30,
                                        color: AppColors.main,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                            ],
                          ),
                        ),

                        // SECTION: page content
                        Positioned(
                          top: 0,
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.only(
                              top: 120,
                            ),
                            child: Stack(
                              children: [

                                // LOADING: underlay
                                cards.length <= 2
                                    ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [

                                    // LOADING: ICON
                                    AnimatedBuilder(
                                        animation: _loadingController,
                                        builder: (context, child) {
                                          return Opacity(
                                            opacity: _loadingController.value,
                                            child: Center(
                                                child:  Image.asset(
                                                  'assets/gray_ahalal.png',
                                                  width: 90,
                                                  height: 90,
                                                )
                                            ),
                                          );
                                        }
                                    ),

                                    const SizedBox(height: 5),

                                    // TEXT:
                                    MyText(text: "يجرى التحميل" + " " + "...", textDirection: TextDirection.rtl, fontSize: 20, color: AppColors.gray),

                                  ],
                                )
                                    : Container(),

                                // PEOPLE: cards
                                ...cards.toList().asMap().entries.map((entry) {
                                  int idx = cards.length-(entry.key+1);
                                  if (idx == 0) {
                                    return Align(
                                      alignment: Alignment.topCenter,
                                      child: GestureDetector(
                                        onPanUpdate: (details) {
                                          if (!isDetailedView && !showingTutorial) {
                                            _flingController.stop();
                                            _verticalFlingController.stop();
                                            _returnController.stop();
                                            setState(() {
                                              dragPosition += details.delta.dx;
                                              verticalDragPosition += details.delta.dy;
                                              rotationAngle = dragPosition / 800;
                                            });
                                          }
                                        },
                                        onPanEnd: (details) {
                                          if (!isDetailedView && !showingTutorial) {

                                            // CASE 1: USER WANTS TO SWIPE EITHER LEFT OR RIGHT, LETS FLING IT AWAY
                                            if (dragPosition.abs() > 100) {
                                              swipedOff = true;
                                              pulledHorizontally = true;
                                              _flingAnimation = Tween<double>(begin: 0, end: 500 * (dragPosition.sign))
                                                  .animate(_flingController);
                                              _flingController.forward(from: 0);

                                              // CASE 2: USER WANTS TO SWIPE EITHER UP OR DOWN, LETS FLING IT AWAY
                                            } else if (verticalDragPosition > 100 || verticalDragPosition < -150) {
                                              swipedOff = true;
                                              pulledHorizontally = false; // since we're in its else u know
                                              pulledVertically = true;
                                              _verticalFlingAnimation = Tween<double>(begin: 0, end: 500 * (verticalDragPosition.sign))
                                                  .animate(_verticalFlingController);
                                              _verticalFlingController.forward(from: 0);

                                              // CASE 3: user does not wanna swipe it anywhere, let's restore it back
                                            } else {
                                              pulledHorizontally = false;
                                              pulledVertically = false;
                                              _returnController.forward(from: 0);
                                            }
                                          }
                                        },
                                        child: Transform.translate(
                                          offset: Offset(dragPosition, verticalDragPosition),
                                          child: Transform.rotate(
                                            angle: rotationAngle,
                                            child: Card(idx),
                                          ),
                                        ),
                                      ),
                                    );
                                  } else if (idx == 1) {
                                    if(isDetailedView){ return Container(); } // don't draw the backcards when detailview is opening up

                                    return Align(
                                      alignment: Alignment.topCenter,
                                      child: ScaleTransition(
                                        scale: _comingToFrontAnimation,
                                        child: Card(idx),
                                      ),
                                    );
                                  } else {
                                    return Container(); // don't draw the backcards past the 2nd one
                                  }
                                }).toList(),

                              ],
                            ),
                          ),
                        ),

                      ],
                    ),
                  );
                }
            ),

            // EXPANDED CARD DESCRIPTION:
            isDetailedView
                ? Container(
                color: AppColors.whiteIsh,
                padding: const EdgeInsets.only(left: 10, right: 10),
                //height: 150*_detailAnimation.value,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [

                      // DATA: name
                      MyText(text: 'مروان', fontSize: 35, color: Colors.black, maxLines: 1),

                      // ROW-DATA: age / job
                      Padding(
                        padding: const EdgeInsets.only(left: 15, right: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [

                            MyText(text: 'دكتور', fontSize: 19, color: Colors.black, fontWeight: FontWeight.w500, maxLines: 1),

                            const SizedBox(width: 5),

                            const Padding(
                              padding: EdgeInsets.only(top: 5),
                              child: Icon(
                                Icons.circle,
                                color: Colors.black,
                                size: 6,
                              ),
                            ),

                            const SizedBox(width: 5),

                            MyText(text: '18' + ' ' + 'سنة' , fontSize: 19, color: Colors.black, textDirection: TextDirection.rtl, fontWeight: FontWeight.w500, maxLines: 1),

                          ],
                        ),
                      ),

                      // ROW-DATA: wilaya / commune
                      Padding(
                        padding: const EdgeInsets.only(left: 15, right: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [

                            MyText(text: 'الدار البيضاء', fontSize: 19, color: Colors.black, fontWeight: FontWeight.w500, maxLines: 1),

                            const SizedBox(width: 5),

                            const Padding(
                              padding: EdgeInsets.only(top: 5),
                              child: Icon(
                                Icons.circle,
                                color: Colors.black,
                                size: 6,
                              ),
                            ),

                            const SizedBox(width: 5),

                            MyText(text: 'العاصمة' , fontSize: 19, color: Colors.black, textDirection: TextDirection.rtl, fontWeight: FontWeight.w500, maxLines: 1),

                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      Padding(
                        padding: const EdgeInsets.only(left: 15, right: 15),
                        child: MyText(text: 'مروان شخص محترم ومثقف من ولايه الخشنه يعمل كطيار بعمر يناهز 35 سنه حافظ لنصف القران يفضل الزواج بدون تعدد يقول: "حاب وحدة محترمة و متكاملة"', textDirection: TextDirection.rtl, fontSize: 19, color: Colors.black, fontWeight: FontWeight.w500, maxLines: 100, textAlign: TextAlign.right,),
                      ),

                      const SizedBox(height: 200),

                    ]
                )
            )
                : Container(),

          ],
        ),
      ),
    );
  }


  Widget Card(int idx) {

    // SIDE-CASE: keep the cards on the back hidden if we're expanding the front one
    if(!(idx==0 || (!isDetailedView && _detailAnimation.value==0))) {
      return Container();
    }

    return SizedBox(
      height: (Dimensions.screenHeight-120-85) * (1 - ((idx==0 ? _detailAnimation.value : 0))*0.3),
      child: Stack(
        alignment: Alignment.center,
        children: [

          // CARD CONTENT:
          Positioned(top: 0, right: 0, left: 0, bottom: 0, child: _buildCardContent(idx)),

          // ACCEPT DENY OVERLAY:
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              children: [
                Expanded(flex: 1, child: Container()),
                Expanded(flex: 1, child: Stack(
                  children: [
                    Align(alignment: Alignment.center, child: _buildSwipeIndicator("رفض", Colors.red, dragPosition, 0.2, idx, false)),
                    Align(alignment: Alignment.center, child: _buildSwipeIndicator("قبول", Colors.green, dragPosition, -0.2, idx, false)),
                  ],
                )),
              ],
            ),
          ),

          // SAVE OR SUPERLIKE OVERLAY:
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              children: [
                Expanded(flex: 1, child: Align(alignment: Alignment.center, child: _buildSwipeIndicator("حِفْظ", Colors.white, verticalDragPosition, -0.2, idx, true))),
                Expanded(flex: 1, child: Align(alignment: Alignment.center, child: _buildSwipeIndicator("رائع", Colors.blue, verticalDragPosition, 0.2, idx, true))),
              ],
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildSwipeIndicator(String text, Color color, double position, double angle, int idx, bool verticalOrHorizontal) {
    double opacity = position.abs()*(verticalOrHorizontal && position<0 ? 0.75 : 1.5) / 100; // verticalOrHorizontal && position<0 means if user is swiping up, let's delay showing the ra2i3 message
    if (opacity > 1) opacity = 1;

    return Transform.rotate(
      angle: angle,
      child: Opacity(
        // CONDITION 0: only the one with the highest opacity is shown
        // CONDITION 1: we can only show the overlay text if user didn't alrdy pull it in another direction for example pulling to top right is showing both signs which is wrong
        // CONDITION 2: is to enforce only applying this to the first card only
        // CONDITION 3: only show the sign corresponding to its respective direction (left is red deny overlay, right is green accept)
        opacity: ((verticalOrHorizontal && dragPosition.abs() < verticalDragPosition.abs()) || (!verticalOrHorizontal && dragPosition.abs() >= verticalDragPosition.abs())) && ((verticalOrHorizontal && !pulledHorizontally) || (!verticalOrHorizontal && !pulledVertically)) && idx==0 && (((color == Colors.red || color == Colors.blue) && position < 0) || ((color == Colors.green || color == Colors.white) && position >= 0)) ? opacity : 0.0, // opacity
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.only(left: 20, right: 20),
              decoration: BoxDecoration(
                border: Border.all(color: color, width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: MyText(text: text, fontSize: 40, color: color, maxLines: 1),
            ),
          ],
        ),
      ),
    );
  }

  void expandCard(){
    setState(() {
      isDetailedView = true;
    });
    _detailController.forward();
  }

  void collapseCard(){
    setState(() {
      isDetailedView = false;
      _detailController.reverse();
    });
  }

  Widget _buildCardContent(int idx){
    return Container(
        margin: EdgeInsets.only(
          left: 10 * (1 - (idx==0 ? _detailAnimation.value : 0)),
          right: 10 * (1 - (idx==0 ? _detailAnimation.value : 0)),
        ),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20 * (1 - (idx==0 ? _detailAnimation.value : 0))),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 1), // changes the position of the shadow
            ),
          ],

        ),

        child: Stack(
          children: [

            // IMAGES SWIPER:
            PageView.builder(
                controller: idx==0 ? cardImageController : null,
                itemCount: idx==0 ? totalImages : (idx==1 ? 1 : 0), // third card should not have any images drawn, second card should only have one image drawn
                itemBuilder: (context, position){
                  return Imagio(position, idx);
                }
            ),

            // CLEAR UPPER SPACE TO GO LEFT AND RIGHT ON THE PHOTOS
            _detailAnimation.value==0
                ? Positioned(
              top: 0,
              bottom: 0,
              left: 0,
              right: 0,
              child: Row(
                  children: [

                    // GO LEFT IN PHOTOS
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: (){
                          if(cardImageController.page! > 0) {
                            setState(() {
                              cardImageController.jumpToPage((cardImageController.page!-1.0).toInt());
                            });
                          } else if(!isDetailedView) {
                            expandCard();
                          }
                        },
                        child: Container(
                          color: Colors.transparent,
                        ),
                      ),
                    ),

                    // GO RIGHT IN PHOTOS
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: (){
                          if(cardImageController.page! < totalImages-1) {
                            setState(() {
                              cardImageController.jumpToPage((cardImageController.page!+1.0).toInt());
                            });
                          } else if(!isDetailedView) {
                            expandCard();
                          }
                        },
                        child: Container(
                          color: Colors.transparent,
                        ),
                      ),
                    ),

                  ]
              ),
            )
                : Container(),

            // CARD INFO OVERLAY:
            _detailAnimation.value!=1
                ? Align(
              alignment: Alignment.bottomCenter,
              child: Opacity(
                opacity: (1 - (idx==0 ? _detailAnimation.value : 0)),
                child: GestureDetector(
                  onTap: (){
                    expandCard();
                  },
                  child: Container(
                      width: double.maxFinite,
                      height: Dimensions.screenHeight/3,
                      padding: const EdgeInsets.only(top: 10, bottom: 0, left: 15, right: 15),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Colors.black, Colors.transparent],
                        ),
                      ),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [

                            // DATA: name
                            MyText(text: 'مروان', fontSize: 35, color: Colors.white, maxLines: 1),

                            // ROW-DATA: age / job
                            Padding(
                              padding: const EdgeInsets.only(left: 15, right: 15),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [

                                  MyText(text: 'دكتور', fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500, maxLines: 1),

                                  const SizedBox(width: 5),

                                  const Padding(
                                    padding: EdgeInsets.only(top: 5),
                                    child: Icon(
                                      Icons.circle,
                                      color: Colors.white,
                                      size: 6,
                                    ),
                                  ),

                                  const SizedBox(width: 5),

                                  MyText(text: '18' + ' ' + 'سنة' , fontSize: 16, color: Colors.white, textDirection: TextDirection.rtl, fontWeight: FontWeight.w500, maxLines: 1),

                                ],
                              ),
                            ),

                            // ROW-DATA: wilaya / commune
                            Padding(
                              padding: const EdgeInsets.only(left: 15, right: 15),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [

                                  MyText(text: 'الدار البيضاء', fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500, maxLines: 1),

                                  const SizedBox(width: 5),

                                  const Padding(
                                    padding: EdgeInsets.only(top: 5),
                                    child: Icon(
                                      Icons.circle,
                                      color: Colors.white,
                                      size: 6,
                                    ),
                                  ),

                                  const SizedBox(width: 5),

                                  MyText(text: 'العاصمة' , fontSize: 16, color: Colors.white, textDirection: TextDirection.rtl, fontWeight: FontWeight.w500, maxLines: 1),

                                ],
                              ),
                            ),

                            // SHOW MORE:
                            GestureDetector(
                              onTap: (){
                                // TODO: expand to see more
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 9, top: 10),
                                child: Center(
                                  child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [

                                        MyText(text: 'معلومات', fontSize: 14, color: AppColors.gray, fontWeight: FontWeight.w500),

                                        const Icon(Icons.touch_app, color: AppColors.gray, size: 18),

                                      ]
                                  ),
                                ),
                              ),
                            )

                          ]
                      )
                  ),
                ),
              ),
            )
                : Container(),

            // IMAGE INDEX INDICATOR DOTS:
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 5,),
                child: DotsIndicator(
                  decorator: DotsDecorator(
                    size: const Size.square(9.0),
                    activeSize: const Size(18.0, 9.0),
                    color: Colors.white, // Inactive color
                    activeColor: AppColors.main,
                    activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                  ),
                  dotsCount: totalImages,
                  position: _currImageIndexValue,
                ),
              ),
            ),


            // PHOTOS TUTORIAL
            showingTutorial
                ? AnimatedBuilder(
                animation: _photosTutorialController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _photosTutorialAnimation.value,
                    child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20 * (1 - (idx==0 ? _detailAnimation.value : 0))),
                        ),
                        child: Column(
                          children: [

                            // TUTORIAL ICONS:
                            const Expanded(
                              flex: 1,
                              child: Row(
                                  children: [

                                    // PHOTOS ON LEFT TUTORIAL
                                    Expanded(
                                        flex: 1,
                                        child: Center(
                                            child: Icon(
                                              Icons.keyboard_arrow_left,
                                              color: Colors.white,
                                              size: 55,
                                            )
                                        )
                                    ),

                                    // PHOTOS ON RIGHT TUTORIAL
                                    Expanded(
                                        flex: 1,
                                        child: Center(
                                            child: Icon(
                                              Icons.keyboard_arrow_right,
                                              color: Colors.white,
                                              size: 55,
                                            )
                                        )
                                    ),

                                  ]
                              ),
                            ),

                            // TUTORIAL TITLE:
                            Expanded(
                                flex: 1,
                                child: MyText(text: "إضغط أعلى الصورة لرؤية صور أكثر", textDirection: TextDirection.rtl, fontSize: 22, color: Colors.white, overflow: null)
                            ),

                          ],
                        )
                    ),
                  );
                }
            )
                : Container(),


            // PHOTOS TUTORIAL
            showingTutorial
                ? AnimatedBuilder(
                animation: _descTutorialController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _descTutorialAnimation.value,
                    child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20 * (1 - (idx==0 ? _detailAnimation.value : 0))),
                        ),
                        child: Column(
                          children: [

                            // TUTORIAL TITLE:
                            Expanded(
                                flex: 1,
                                child: Center(child: MyText(text: "إضغط أسفل الصورة لمعلومات أكثر", textDirection: TextDirection.rtl, fontSize: 22, color: Colors.white, overflow: null))
                            ),

                            // TUTORIAL ICONS:
                            const Expanded(
                              flex: 1,
                              child: Center(
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 30),
                                    child: Icon(
                                      Icons.touch_app,
                                      color: Colors.white,
                                      size: 55,
                                    ),
                                  )
                              ),
                            ),

                          ],
                        )
                    ),
                  );
                }
            )
                : Container(),

          ],
        )

    );
  }

  Widget Imagio(int imageIndex, int cardIndex){
    return Container(

      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/profile_photos/_$imageIndex.jpg"),
          fit: BoxFit.cover,
        ),
        color: Colors.white,
        borderRadius: BorderRadius.circular(20 * (1 - (cardIndex==0 ? _detailAnimation.value : 0))),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 1), // changes the position of the shadow
          ),
        ],

      ),
    );
  }

}