import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '0_diaSalvo.dart';
import '0_utilityFunctions.dart';
import '0_viewModelGlobal.dart';
import '1_firebaseServices.dart';

class RegistrarDiaView extends StatefulWidget {
  final DateTime selectedDay;

  const RegistrarDiaView({super.key, required this.selectedDay});

  @override
  RegistrarDiaViewState createState() => RegistrarDiaViewState();

}

class RegistrarDiaViewState extends State<RegistrarDiaView> with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  TextEditingController _controller = TextEditingController();
  FocusNode _focusNode = FocusNode();
  int happyNumber = 0;
  int peaceNumber = 0;
  int angryNumber = 0;
  int fearNumber = 0;
  int sadNumber = 0;
  double registerDayOpacity = 1.0;
  double _previousBottomInset = 0.0;
  bool _keyboardVisible = false;
  late AnimationController _animationController;
  late Animation<Color?> _animation;
  bool _flashing = false;


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _animationController.stop();
        setState(() {
          _flashing = false;
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAnimation();
    });
  }

  void _initializeAnimation() {
    setState(() {
      _animation = ColorTween(
        begin: Theme.of(context).colorScheme.onPrimary,
        end: Colors.red,
      ).animate(_animationController);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_animationController.isAnimating || _animationController.isCompleted || _animationController.isDismissed) {
      _initializeAnimation();
    }
  }


  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _focusNode.dispose();
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final bottomInset = WidgetsBinding.instance.platformDispatcher.views.first.viewInsets.bottom;
    if (bottomInset > 0.0) {
      _keyboardVisible = true;
    } else if (_keyboardVisible && bottomInset == 0.0) {
      // Keyboard was visible and is now dismissed
      _keyboardVisible = false;
      if (_focusNode.hasFocus) {
        _focusNode.unfocus();
        setState(() {}); // Rebuild the widget when the focus changes
      }
    }
    _previousBottomInset = bottomInset;
  }

  int get totalNumber {
    return happyNumber + peaceNumber + angryNumber + fearNumber + sadNumber;
  }

  bool canChangeNumber(int currentNumber, bool increase) {
    if (increase) {
      return totalNumber < 5;
    } else {

      return currentNumber > 0;
    }
  }

  int changeNumber(int currentNumber, bool increase) {
    if (canChangeNumber(currentNumber, increase)) {
      if (increase) {
        return currentNumber + 1;
      } else {
        return currentNumber - 1;
      }
    } else {
      if (increase) {
        HapticFeedback.heavyImpact();
        setState(() {
          _flashing = true;
        });
        _animationController.forward();
      }
    }
    return currentNumber;
  }


  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ViewModelGlobal>(context);
    final AppLocalizations? loc = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    String formattedDate = DateFormat.yMMMMd(locale).format(widget.selectedDay);
    var brightness = Theme.of(context).brightness;
    final FirebaseServices firebaseServices = FirebaseServices();

    Widget welcomeExplanation = Dialog(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            Text(loc?.welcome ?? '',
              style: TextStyle(fontSize: fontSize(24, viewModel), fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            Text(loc?.useTheBlueButtons ?? '', style: TextStyle(fontSize: fontSize(16, viewModel))),

            const SizedBox(height: 7),

            Row(mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 40, // Width of the circular background
                      height: 40, // Height of the circular background
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color.fromRGBO(5, 65, 149, 1.0), // Change this color if you want a visible circle
                      ),
                    ),
                    Positioned(left: 0, right: 3,
                        child:  Icon(CupertinoIcons.chevron_left, size: 30, color: Colors.white)),
                  ],
                ),

                const SizedBox(width: 10),

                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 40, // Width of the circular background
                      height: 50, // Height of the circular background
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color.fromRGBO(5, 65, 149, 1.0), // Change this color if you want a visible circle
                      ),
                    ),
                    Positioned(left: 3, right: 0,
                        child: Icon(CupertinoIcons.chevron_right, size: 30, color: Colors.white)),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 7),

            Text(loc?.toUseYourPoints ?? '', style: TextStyle(fontSize: fontSize(16, viewModel))),

            const SizedBox(height: 7),

          ],
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(formattedDate, style: TextStyle(fontSize: fontSize(22, viewModel))),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: Theme.of(context).colorScheme.onSecondary,
      body: Center(
        child: ListView(
          children: [
            Column(
              children: [

                ExplanationPopCheck(explanationCheck: () {
                  if (!viewModel.hasSeenExplanation) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return welcomeExplanation;
                      },
                    ).then((_) {
                      viewModel.saveHasSeenExplanation();
                    });

                  }
                }),

                const SizedBox(height: 10),

                Text(loc?.howWasYourDay ?? '', style: TextStyle(fontSize: fontSize(28, viewModel),
                    fontWeight: FontWeight.w600),),

                const SizedBox(height: 15),

                Text(loc?.useUpToFivePoints ?? '', style: TextStyle(fontSize: fontSize(20, viewModel), color:
                Theme.of(context).colorScheme.onPrimary, height: 0.9), ),

                const SizedBox(height: 10),

                Builder(
                  builder: (context) {
                    final mediaQuery = MediaQuery.of(context);
                    if (_animation == null) {
                      _initializeAnimation();
                    }
                    return AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Text(
                          '$totalNumber/5',
                          style: TextStyle(
                            fontSize: fontSize(25, viewModel),
                            fontWeight: FontWeight.w700,
                            color: _flashing ? _animation?.value : Theme.of(context).colorScheme.onPrimary,
                          ),
                        );
                      },
                    );
                  },
                ),



                EmojiDotsRow(
                  topPadding: false,
                  emoji: 'happy',
                  number: happyNumber,
                  leftButtonAction: () {
                    setState(() {
                      happyNumber = changeNumber(happyNumber, false);
                    });
                  },
                  rightButtonAction: () {
                    setState(() {
                      happyNumber = changeNumber(happyNumber, true);
                    });
                  }, description: loc?.joy ?? '',
                ),
                EmojiDotsRow(
                  emoji: 'peace',
                  number: peaceNumber,
                  leftButtonAction: () {
                    setState(() {
                      peaceNumber = changeNumber(peaceNumber, false);
                    });
                  },
                  rightButtonAction: () {
                    setState(() {
                      peaceNumber = changeNumber(peaceNumber, true);
                    });
                  }, description: loc?.peace ?? '',
                ),
                EmojiDotsRow(
                  emoji: 'angry',
                  number: angryNumber,
                  leftButtonAction: () {
                    setState(() {
                      angryNumber = changeNumber(angryNumber, false);
                    });
                  },
                  rightButtonAction: () {
                    setState(() {
                      angryNumber = changeNumber(angryNumber, true);
                    });
                  }, description: loc?.anger ?? '',
                ),
                EmojiDotsRow(
                  emoji: 'afraid',
                  number: fearNumber,
                  leftButtonAction: () {
                    setState(() {
                      fearNumber = changeNumber(fearNumber, false);
                    });
                  },
                  rightButtonAction: () {
                    setState(() {
                      fearNumber = changeNumber(fearNumber, true);
                    });
                  }, description: loc?.worry ?? '',
                ),
                EmojiDotsRow(
                  emoji: 'sad',
                  number: sadNumber,
                  leftButtonAction: () {
                    setState(() {
                      sadNumber = changeNumber(sadNumber, false);
                    });
                  },
                  rightButtonAction: () {
                    setState(() {
                      sadNumber = changeNumber(sadNumber, true);
                    });
                  }, description: loc?.sadness ?? '',
                ),

                const SizedBox(height: 35),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: TextField(
                    keyboardType: TextInputType.multiline,
                    onTapOutside: (_) {
                      _focusNode.unfocus();
                    },
                    controller: _controller,
                    focusNode: _focusNode,
                    maxLines: null,
                    cursorColor: const Color.fromRGBO(5, 65, 149, 1.0),
                    style: TextStyle(fontSize: fontSize(17, viewModel)),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Theme.of(context).colorScheme.onPrimary,)),
                      hintText: loc?.hinTextNotes ?? '',
                      hintMaxLines: 5,
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: brightness == Brightness.dark ? const Color.fromRGBO(5, 65, 149, 1.0) : Colors.black, width: 2)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Theme.of(context).colorScheme.onPrimary, width: 3)),

                    ),
                  ),
                ),

                const SizedBox(height: 45),

                GestureDetector(
                  onTap: () {
                    logEvent('inside registrarDiaView - register day button tapped\nsaving current dia');

                    setState(() {
                      registerDayOpacity = 1.0;
                    });

                    String formattedDiaDate = DateFormat('yyyy-MM-dd').format(widget.selectedDay);

                    DiaSalvo currentDia = DiaSalvo(
                        date: formattedDiaDate,
                        emotions: [happyNumber, peaceNumber, angryNumber, fearNumber, sadNumber],
                        notes: _controller.text);

                    firebaseServices.saveDiaSalvoToFirebase(currentDia);
                    viewModel.addDiaSalvo(currentDia);
                    print('saved $currentDia');

                    Navigator.of(context).pop();

                  },
                  onTapCancel: () {
                    setState(() {
                      registerDayOpacity = 1.0;
                    });
                  },
                  onTapDown: (_) {
                    setState(() {
                      registerDayOpacity = 0.8;
                    });
                  },
                  child:
                  Opacity(opacity: registerDayOpacity,
                    child:
                        Container(padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
                         decoration: BoxDecoration(
                           borderRadius: BorderRadius.circular(20),
                            color: const Color.fromRGBO(5, 65, 149, 1.0),
                          ), child:
                            Text(loc?.saveMyDay ?? '', style: TextStyle(fontSize: fontSize(17, viewModel),
                                fontWeight: brightness == Brightness.dark ? FontWeight.w500 : null,
                                color: Colors.white))
                        ),
                  ),
                ),

                const SizedBox(height: 65),
              ],
            ),
          ],
        ),
      ),
    );

  }


}





class EmojiDotsRow extends StatefulWidget {
  final String emoji;
  final int number;
  final double size;
  final VoidCallback? leftButtonAction;
  final VoidCallback? rightButtonAction;
  final bool topPadding;
  final String description;

  EmojiDotsRow({required this.emoji, required this.number, this.size = 28, this.leftButtonAction, this.rightButtonAction, this.topPadding = true, required this.description});

  @override
  EmojiDotsRowState createState() => EmojiDotsRowState();
}

class EmojiDotsRowState extends State<EmojiDotsRow> {

  double leftButtonOpacity = 1.0;
  double rightButtonOpacity = 1.0;

  void flashButtons() {
    int flashes = 0;
    Timer.periodic(Duration(milliseconds: 200), (timer) {
      setState(() {
        leftButtonOpacity = leftButtonOpacity == 1.0 ? 0.4 : 1.0;
        rightButtonOpacity = rightButtonOpacity == 1.0 ? 0.4 : 1.0;
      });
      flashes++;
      if (flashes == 4) {
        timer.cancel();
        setState(() {
          leftButtonOpacity = 1.0;
          rightButtonOpacity = 1.0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ViewModelGlobal>(context);
    var brightness = Theme.of(context).brightness;

    List<Widget> dots(int number, double size) {
      List<Widget> dotList = [];
      for (int i = 0; i < 5; i++) {
        dotList.add(GestureDetector(onTap: flashButtons,
          child: Icon(i < number ? Icons.circle : Icons.circle_outlined, size: size, color: i < number ? Theme.of(context).colorScheme.onPrimary :
          brightness == Brightness.dark ? Theme.of(context).colorScheme.onPrimary : Colors.black,),
        ),);
        if (i < 4) {
          dotList.add(const SizedBox(width: 5)); // Add SizedBox only if i is not the last index
        }
      }
      return dotList;
    }

    return Padding(
      padding: EdgeInsets.only(top: widget.topPadding ? 15 : 0, bottom: 23),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(alignment: Alignment.bottomCenter,
            clipBehavior: Clip.none,
            children: [
              Image.asset('assets/vectorEmojis/${widget.emoji}.png', width: 65),

              Positioned(bottom: -22,
                  child: Text(widget.description, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w500,
                  fontSize: fontSize(14, viewModel)),)
              )
            ],
          ),

          const SizedBox(width: 10),

          ...dots( widget.number,  widget.size),


          SizedBox(width: 10),

          GestureDetector(
            onTap: () {
              setState(() {
                leftButtonOpacity = 1.0;
                widget.leftButtonAction?.call();
                // HapticFeedback.mediumImpact();
              });
            },
            onTapCancel: () {
              setState(() {
                leftButtonOpacity = 1.0;
              });
            },
            onTapDown: (_) {
              setState(() {
                leftButtonOpacity = 0.4;
              });
            },
            child:
              Opacity(opacity: leftButtonOpacity,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 40, // Width of the circular background
                      height: 40, // Height of the circular background
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color.fromRGBO(5, 65, 149, 1.0), // Change this color if you want a visible circle
                      ),
                    ),
                    Positioned(left: 0, right: 3,
                        child:  Icon(CupertinoIcons.chevron_left, size: 30, color: Colors.white)),
                  ],
                ),
              ),
          ),

          SizedBox(width: 8),

          GestureDetector(
              onTap: () {
                setState(() {
                  rightButtonOpacity = 1.0;
                  widget.rightButtonAction?.call();
                  // HapticFeedback.mediumImpact();
                });
              },
              onTapCancel: () {
                setState(() {
                  rightButtonOpacity = 1.0;
                });
              },
              onTapDown: (_) {
                setState(() {
                  rightButtonOpacity = 0.4;
                });
              },
              child:
              Opacity(opacity: rightButtonOpacity,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 40, // Width of the circular background
                      height: 50, // Height of the circular background
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color.fromRGBO(5, 65, 149, 1.0), // Change this color if you want a visible circle
                      ),
                    ),
                    Positioned(left: 3, right: 0,
                        child: Icon(CupertinoIcons.chevron_right, size: 30, color: Colors.white)),
                  ],
                ),
              ),
          )
        ],
      ),
    );
  }
}

class ExplanationPopCheck extends StatefulWidget {
  final VoidCallback explanationCheck;

  const ExplanationPopCheck({super.key, required this.explanationCheck});

  @override
  ExplanationPopCheckState createState() => ExplanationPopCheckState();
}

class ExplanationPopCheckState extends State<ExplanationPopCheck> {

  @override
  void initState() {
    super.initState();
    logEvent('explanation pop check initialized');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      logEvent('addPostFrameCallback called');
      checkHasSeenExplanation();
    });
  }

  void checkHasSeenExplanation()  {
    widget.explanationCheck();
  }


  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}