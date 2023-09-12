import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../../utils/colors.dart';
import '../../utils/consts.dart';
import '../../utils/dimensions.dart';
import '../../widgets/spinner.dart';
import '../../widgets/text.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({Key? key}) : super(key: key);

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> with WidgetsBindingObserver, TickerProviderStateMixin  {

  // DETECT SCROLLING TO DISMISS FOCUSES
  late ScrollController _scrollController;


  // NAME:
  final TextEditingController _nameInputController = TextEditingController();
  FocusNode myFocusNode = FocusNode();
  int focusedTimestamp = 0; // when keyboard was focused
  int minFocusedTime = 300; // keyboard needs to be focused for at least 500ms
  String name = "مروان";

  // AGE
  late AnimationController _ageController;
  late Animation<double> _ageAnimation;
  String age = "18";
  final TextEditingController _ageInputController = TextEditingController();

  // LOCATION:
  late AnimationController _locationController;
  late Animation<double> _locationAnimation;

  // SAVE:
  bool saveVisible = false;
  late AnimationController _saveController;
  late Animation<double> _saveAnimation;

  // STEP 2:
  // COMMUNES:
  String selectedCommune = unselectedCommune;
  // WILAYAS:
  String selectedWilaya = unselectedWilaya;
  // COUNTRIES:
  String selectedCountry = unselectedCountry;
  // AUTOMATIC LOCATION:


  // STEP 3:
  // JOB:
  String selectedJob = unselectedJob;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // NAME:
    _nameInputController.text = name;

    // NAME INPUT:
    myFocusNode.addListener(() {
      if (myFocusNode.hasFocus) {
        focusedTimestamp = DateTime.now().millisecondsSinceEpoch;
      } else {

        // SIDE CASE: if user tries to save an empty name we'll recover the original one
        if(_nameInputController.text.isEmpty) _nameInputController.text = name;

      }
    });
    _nameInputController.addListener(() {
      textSaveButton();
    });

    // KEYBOARD: CLOSED DETECTOR
    // buggy
    /*WidgetsBinding.instance.addObserver(
      LifecycleEventHandler(
        onKeyboardClosed: () {
          if(focusedTimestamp!= 0 && DateTime.now().millisecondsSinceEpoch - focusedTimestamp >= minFocusedTime){ // keyboard needs to be focused for at least 500ms
            FocusScope.of(context).unfocus();
          }
        },
      ),
    );*/

    // DETECT SCROLLING SO WE CAN DISMISS ANY FOCUSES
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection != ScrollDirection.idle) {
        FocusScope.of(context).unfocus();
      }
    });


    // EXPAND ANIMATIONS
    _saveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _saveAnimation = CurvedAnimation(
      parent: _saveController,
      curve: Curves.easeInOut,
    );


    // EXPAND ANIMATION: age
    _ageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _ageAnimation = CurvedAnimation(
      parent: _ageController,
      curve: Curves.easeInOut,
    );
    // AGE INPUT
    _ageInputController.text = age;
    _ageInputController.addListener(() { 
      textSaveButton();
    });


    // EXPAND ANIMATION: location
    _locationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _locationAnimation = CurvedAnimation(
      parent: _locationController,
      curve: Curves.easeInOut,
    );


  }

  textSaveButton(){
    if(_nameInputController.text == name && _ageInputController.text == age ){
      hideSaveButton();
    } else {
      showSaveButton();
    }
  }

  void showSaveButton(){
    if(saveVisible) return;

    setState(() {
      saveVisible = true;
      _saveController.forward();
    });
  }

  void hideSaveButton(){
    if(!saveVisible) return;

    setState(() {
      saveVisible = false;
      _saveController.reverse();
    });
  }

  @override
  void dispose() {
    _ageController.dispose();
    _locationController.dispose();
    _saveController.dispose();
    _ageInputController.dispose();
    _scrollController.dispose();
    _nameInputController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // STEP 2: location
  void updateSelected(String newSelected, String type){
    switch(type){
      case "country":
        setState((){
          selectedCountry = newSelected;
        });
        break;
      case "wilaya":
        setState((){
          selectedWilaya = newSelected;
        });
        break;
      case "commune":
        setState((){
          selectedCommune = newSelected;
        });
        break;
      case "job":
        setState((){
          selectedJob = newSelected;
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [

        // PAGE CONTENT
        Container(
          height: Dimensions.screenHeight,
          width: double.maxFinite,
          color: AppColors.whiteIsh,
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [

                SizedBox(height: MediaQuery.of(context).padding.top+20),

                // PROFILE PHOTO / NAME
                Padding(
                  padding: const EdgeInsets.only(left: 25, right: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [


                      // NAME / EDIT NAME
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap: () {
                            myFocusNode.requestFocus();
                          },
                          child: Container(
                            color: Colors.transparent,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [

                                // EDIT NAME ICONS
                                const Icon(
                                  Icons.edit,
                                  color: AppColors.gray,
                                  size: 25,
                                ),

                                const SizedBox(width: 3),

                                // NAME
                                Flexible(
                                  child: IntrinsicWidth(
                                    child: Container(
                                      constraints: const BoxConstraints(
                                        minWidth: 50, // Set minimum width here
                                      ),
                                      child: TextField(
                                        maxLines: 1,
                                        textAlign: TextAlign.right,
                                        textDirection: TextDirection.rtl,
                                        focusNode: myFocusNode,
                                        controller: _nameInputController,
                                        decoration: const InputDecoration(
                                          hintStyle: TextStyle(color: Colors.black),
                                          border: InputBorder.none,
                                        ),
                                        style: const TextStyle(
                                          fontFamily: 'Janna',
                                          color: Colors.black,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 26,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                              ],
                            ),
                          ),
                        ),
                      ),


                      const SizedBox(width: 8),

                      // PROFILE PHOTO (changeable if you tap)
                      GestureDetector(
                        onTap: (){

                        },
                        child: Container(
                          color: Colors.transparent,
                          child: Stack(
                            children: [

                              // PHOTO
                              Container(
                                width: Dimensions.screenWidth/5,
                                height: Dimensions.screenWidth/5,

                                decoration: BoxDecoration(
                                  image: const DecorationImage(
                                    image: AssetImage("assets/profile_photos/profile_0.jpg"),
                                    fit: BoxFit.cover,
                                  ),
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(50),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 1,
                                      blurRadius: 5,
                                      offset: const Offset(0, 1), // changes the position of the shadow
                                    ),
                                  ],

                                ),
                              ),

                              // CHANGE PHOTO INDICATOR
                              Positioned(
                                bottom: 0,
                                left: 0,
                                child: Container(

                                  decoration: BoxDecoration(
                                    color: AppColors.whiteIsh,
                                    borderRadius: BorderRadius.circular(50),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 1,
                                        blurRadius: 5,
                                        offset: const Offset(0, 1), // changes the position of the shadow
                                      ),
                                    ],

                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: AppColors.main,
                                    size: 19,
                                  )
                                ),
                              ),

                            ],
                          ),
                        ),
                      ),

                    ],
                  ),
                ),

                const SizedBox(height: 5),

                Align(alignment: Alignment.centerRight, child: Padding(
                  padding: const EdgeInsets.only(right: 35),
                  child: MyText(text: 'ولي أمر' , fontSize: 15, color: AppColors.main, textDirection: TextDirection.rtl, textAlign: TextAlign.right, maxLines: 1, fontWeight: FontWeight.w700,),
                )),

                const SizedBox(height: 25),

                // SETTINGS: first one, age
                Column(
                    children: [

                      // AGE VISIBLE
                      GestureDetector(
                        onTap: (){
                          // EXPAND:
                          if(_ageAnimation.value == 0){
                            _ageController.forward();

                            // COLLAPSE:
                          } else {
                            _ageController.reverse();
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border(
                              bottom: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 25, right: 25, top: 10, bottom: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [

                                const Icon(
                                  Icons.edit,
                                  color: AppColors.gray,
                                  size: 25,
                                ),

                                const SizedBox(width: 10),

                                Flexible(child: IntrinsicWidth(child: MyText(text: '18' , fontSize: 23, color: Colors.black, textDirection: TextDirection.rtl, textAlign: TextAlign.right, maxLines: 1, fontWeight: FontWeight.w500,))),

                                const SizedBox(width: 5),

                                MyText(text: 'العمر:' , fontSize: 23, color: Colors.black, textDirection: TextDirection.rtl, textAlign: TextAlign.right, maxLines: 1, fontWeight: FontWeight.w700,),

                              ],
                            ),
                          ),
                        ),
                      ),

                      // EXPANDABLE AGE SETTING
                      AnimatedBuilder(
                          animation: _ageController,
                          builder: (context, child) {
                          return ClipRect(
                            child: Align(
                              heightFactor: _ageAnimation.value,
                              child: Container(
                                padding: const EdgeInsets.only(right: 20, left: 20),
                                decoration: BoxDecoration(
                                  color: AppColors.whiteIsh,
                                  border: Border(
                                    top: BorderSide(color: Colors.grey.withOpacity(0.2), width: 2),
                                    bottom: BorderSide(color: Colors.grey.withOpacity(0.2), width: 2),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 1,
                                      blurRadius: 5,
                                      offset: const Offset(0, 1), // changes the position of the shadow
                                    ),
                                  ],

                                ),
                                child: Row(
                                  children: [

                                    // BUTTON: increase age
                                    Expanded(
                                      flex: 1,
                                      child: GestureDetector(
                                        onTap: (){
                                          _ageInputController.text = (int.parse(_ageInputController.text) + 1).toString();
                                        },
                                        child: Container(
                                            color: Colors.transparent,
                                            child: const Icon(
                                              Icons.add,
                                              color: AppColors.main,
                                              size: 30,
                                            )
                                        ),
                                      ),
                                    ),

                                    // INPUT: age
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        padding: const EdgeInsets.only(bottom: 3),
                                        height: 50,
                                        child: TextField(
                                          keyboardType: TextInputType.number, // Set the keyboard type to number
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter.digitsOnly, // Allow only digits
                                          ],
                                          textAlign: TextAlign.center, // Center text horizontally
                                          controller: _ageInputController, // Add the controller here
                                          decoration: const InputDecoration(
                                            hintStyle: TextStyle(color: AppColors.main), // Hint text color
                                            border: InputBorder.none,
                                          ),
                                          style: const TextStyle(
                                            color: AppColors.main, // Input text color
                                            fontWeight: FontWeight.w500,
                                            fontSize: 26, // Text size
                                          ),
                                        ),
                                      ),
                                    ),

                                    // BUTTON: decrease age
                                    Expanded(
                                      flex: 1,
                                      child: GestureDetector(
                                        onTap: (){
                                          int age = int.parse(_ageInputController.text);
                                          if(age == 1) return;
                                          if(age < 1) _ageInputController.text = "1";
                                          _ageInputController.text = (age - 1).toString();
                                        },
                                        child: Container(
                                          color: Colors.transparent,
                                          child: const Icon(
                                            Icons.remove,
                                            color: AppColors.main,
                                            size: 30,
                                          )
                                        ),
                                      ),
                                    ),

                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                      ),

                    ]
                ),

                // SETTINGS: second one, location
                Column(
                    children: [

                      // LOCATION VISIBLE
                      GestureDetector(
                        onTap: (){
                          // EXPAND:
                          if(_locationAnimation.value == 0){
                            _locationController.forward();

                            // COLLAPSE:
                          } else {
                            _locationController.reverse();
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border(
                              bottom: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 25, right: 25, top: 10, bottom: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [

                                // edit button: location
                                const Icon(
                                  Icons.edit,
                                  color: AppColors.gray,
                                  size: 25,
                                ),

                                const SizedBox(width: 10),

                                // location: value
                                Flexible(child: IntrinsicWidth(child: MyText(text: 'الدار البيضاء' , fontSize: 23, color: Colors.black, textDirection: TextDirection.rtl, textAlign: TextAlign.right, maxLines: 1, fontWeight: FontWeight.w500,))),

                                const SizedBox(width: 5),

                                // location title
                                MyText(text: 'الموقع:' , fontSize: 23, color: Colors.black, textDirection: TextDirection.rtl, textAlign: TextAlign.right, maxLines: 1, fontWeight: FontWeight.w700,),

                              ],
                            ),
                          ),
                        ),
                      ),

                      // EXPANDABLE LOCATION SETTING
                      AnimatedBuilder(
                          animation: _locationController,
                          builder: (context, child) {
                            return ClipRect(
                              child: Align(
                                heightFactor: _locationAnimation.value,
                                child: Container(
                                  padding: const EdgeInsets.only(right: 20, left: 20),
                                  decoration: BoxDecoration(
                                    color: AppColors.whiteIsh,
                                    border: Border(
                                      top: BorderSide(color: Colors.grey.withOpacity(0.2), width: 2),
                                      bottom: BorderSide(color: Colors.grey.withOpacity(0.2), width: 2),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 1,
                                        blurRadius: 5,
                                        offset: const Offset(0, 1), // changes the position of the shadow
                                      ),
                                    ],

                                  ),
                                  child: Column(
                                    children: [

                                      const SizedBox(height: 15),

                                      // BUTTON: auto location
                                      /*GestureDetector(
                onTap: (){
                  setState(() {
                  });
                },
                child: Container(
                  padding: EdgeInsets.only(right: 23, left: 27, bottom: 10, top: 10, ),
                  decoration: BoxDecoration(
                    color: AppColors.main,
                    borderRadius: const BorderRadius.all(Radius.circular(50)),
                    border: Border.all(color: AppColors.main, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: Offset(0, 1), // changes the position of the shadow
                      ),
                    ],

                  ),
                  child: Row(
                    children: [

                      Icon(
                        Icons.location_on_outlined,
                        color: Colors.white,
                      ),

                      Expanded(
                          flex: 1,
                          child: Text(
                            textAlign: TextAlign.right,
                            'إقتناء تلقائي',
                            style: TextStyle(
                              fontFamily: 'Janna',
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 23,
                            ),
                          )
                      ),

                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                textAlign: TextAlign.center,
                'أو',
                style: TextStyle(
                  fontFamily: 'Janna',
                  color: AppColors.main,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),

              const SizedBox(height: 20),*/

                                      // SPINNER: which country?
                                      Spinner(list: countries, selected: selectedCountry, unselected: unselectedCountry, updateSelected: updateSelected, type: "country", color: AppColors.whiteIsh),

                                      const SizedBox(height: 15),

                                      // SPINNER: which wilaya?
                                      (selectedCountry != unselectedCountry && selectedCountry == algeria)
                                          ? Spinner(list: wilaya_list, selected: selectedWilaya, unselected: unselectedWilaya, updateSelected: updateSelected, type: "wilaya", color: AppColors.whiteIsh)
                                          : Container(),

                                      const SizedBox(height: 15),

                                      // SPINNER: which baladiya?
                                      selectedWilaya != unselectedWilaya
                                          ? Spinner(optional: true, list: (commune_list[selectedWilaya]?["commune_name"] as List<String>), selected: selectedCommune, unselected: unselectedCommune, updateSelected: updateSelected, type: "commune", color: AppColors.whiteIsh)
                                          : Container(),

                                      selectedWilaya != unselectedWilaya ? const SizedBox(height: 15) : Container(),

                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                      ),

                    ]
                ),

                // SETTINGS: third one, job
                Column(
                    children: [

                      // JOB VISIBLE
                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 25, right: 25, top: 10, bottom: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [

                              // edit button: job
                              const Icon(
                                Icons.edit,
                                color: AppColors.gray,
                                size: 25,
                              ),

                              const SizedBox(width: 10),

                              // job: value
                              Flexible(child: IntrinsicWidth(child: MyText(text: 'طبيب' , fontSize: 23, color: Colors.black, textDirection: TextDirection.rtl, textAlign: TextAlign.right, maxLines: 1, fontWeight: FontWeight.w500,))),

                              const SizedBox(width: 5),

                              // job title
                              MyText(text: 'العمل:' , fontSize: 23, color: Colors.black, textDirection: TextDirection.rtl, textAlign: TextAlign.right, maxLines: 1, fontWeight: FontWeight.w700,),

                            ],
                          ),
                        ),
                      ),

                    ]
                ),

                // SETTINGS: fourth one, negative habits
                Column(
                    children: [

                      // negative habits VISIBLE
                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 25, right: 25, top: 10, bottom: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [

                              // edit button: negative habits
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Icon(
                                  Icons.edit,
                                  color: AppColors.gray,
                                  size: 25,
                                ),
                              ),

                              const SizedBox(width: 10),

                              // negative habits: value
                              Flexible(child: IntrinsicWidth(child: MyText(text: '4 إختيارات' , fontSize: 23, color: Colors.black, textDirection: TextDirection.rtl, textAlign: TextAlign.right, maxLines: 1, fontWeight: FontWeight.w500,))),

                              const SizedBox(width: 5),

                              // negative habits title
                              MyText(text: 'الآفات:' , fontSize: 23, color: Colors.black, textDirection: TextDirection.rtl, textAlign: TextAlign.right, maxLines: 1, fontWeight: FontWeight.w700,),

                            ],
                          ),
                        ),
                      ),

                    ]
                ),


                const SizedBox(height: 1000),

              ],
            ),
          )
        ),

        // SAVE OVERLAY:
        Positioned(
          left: 0,
          right: 0,
          bottom: 60,
          child: AnimatedBuilder(
            animation: _saveController,
            builder: (context, child) {
              return ClipRect(
                child: Align(
                heightFactor: _saveAnimation.value,
                  child: GestureDetector(
                    onTap: (){
                      // TODO: show a loading circle until server responds with success
                      hideSaveButton();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.main,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 1), // changes the position of the shadow
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 10),
                        child: Center(
                          child: MyText(text: 'حِفْظ التعديلات' , fontSize: 22, color: Colors.white, textDirection: TextDirection.rtl, textAlign: TextAlign.right, maxLines: 1, fontWeight: FontWeight.w700),
                        ),
                      )
                    ),
                  ),
                ),
              );
            }
          )
        ),

      ],
    );
  }
}
