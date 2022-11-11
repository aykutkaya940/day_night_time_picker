import 'package:day_night_time_picker/lib/ampm.dart';
import 'package:day_night_time_picker/lib/common/action_buttons.dart';
import 'package:day_night_time_picker/lib/common/display_value.dart';
import 'package:day_night_time_picker/lib/common/wrapper_container.dart';
import 'package:day_night_time_picker/lib/common/wrapper_dialog.dart';
import 'package:day_night_time_picker/lib/daynight_banner.dart';
import 'package:day_night_time_picker/lib/common/filter_wrapper.dart';
import 'package:day_night_time_picker/lib/state/state_container.dart';
import 'package:day_night_time_picker/lib/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

TextEditingController hourCtrl = TextEditingController();
TextEditingController minCtrl = TextEditingController();
late FocusNode hourFocus;
late FocusNode minFocus;

/// Private class. [StatefulWidget] that renders the content of the picker.
// ignore: must_be_immutable
class DayNightTimePickerAndroid extends StatefulWidget {
  const DayNightTimePickerAndroid({Key? key}) : super(key: key);

  @override
  DayNightTimePickerAndroidState createState() =>
      DayNightTimePickerAndroidState();
}

/// Picker state class
class DayNightTimePickerAndroidState extends State<DayNightTimePickerAndroid> {
  @override
  void initState() {
    hourFocus = FocusNode();
    minFocus = FocusNode();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final timeState = TimeModelBinding.of(context);
    double min = getMinMinute(
        timeState.widget.minMinute, timeState.widget.minuteInterval);
    double max = getMaxMinute(
        timeState.widget.maxMinute, timeState.widget.minuteInterval);

    int minDiff = (max - min).round();
    int divisions =
        getMinuteDivisions(minDiff, timeState.widget.minuteInterval);

    if (timeState.hourIsSelected) {
      min = timeState.widget.minHour!;
      max = timeState.widget.maxHour!;
      divisions = (max - min).round();
    }

    final color =
        timeState.widget.accentColor ?? Theme.of(context).colorScheme.secondary;

    var hourValue = timeState.widget.is24HrFormat
        ? timeState.time.hour
        : timeState.time.hourOfPeriod;

    final ltrMode =
        timeState.widget.ltrMode ? TextDirection.ltr : TextDirection.rtl;

    final hideButtons = timeState.widget.hideButtons;
    final color1 =
        timeState.widget.accentColor ?? Theme.of(context).colorScheme.secondary;
    Orientation currentOrientation = MediaQuery.of(context).orientation;
    final _commonTimeStyles = Theme.of(context)
        .textTheme
        .headline2!
        .copyWith(fontSize: 60, fontWeight: FontWeight.bold, color: color1);

    final unselectedColor = timeState.widget.unselectedColor ?? Colors.grey;

    return Center(
      child: SingleChildScrollView(
        physics: currentOrientation == Orientation.portrait
            ? const NeverScrollableScrollPhysics()
            : const AlwaysScrollableScrollPhysics(),
        child: FilterWrapper(
          child: WrapperDialog(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const DayNightBanner(),
                WrapperContainer(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const AmPm(),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                width: 90,
                                child: TextField(
                                  maxLength: 2,
                                  focusNode: hourFocus,
                                  controller: hourCtrl,
                                  onTap: () {
                                    setState(() {
                                      timeState.hourIsSelected = true;
                                      timeState.widget.disableHour!
                                          ? null
                                          : () {
                                              timeState
                                                  .onHourIsSelectedChange(true);
                                            };
                                    });
                                  },
                                  onEditingComplete: () {
                                    setState(() {
                                      hourCtrl.value.text.isNotEmpty &&
                                              int.parse(hourCtrl.value.text) >=
                                                  0 &&
                                              int.parse(hourCtrl.value.text) <=
                                                  23
                                          ? timeState.onHourChange(
                                              double.parse(hourCtrl.value.text))
                                          : timeState.onHourChange(
                                              DateTime.now().hour.toDouble());
                                      hourCtrl.clear();
                                    });
                                  },
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  style: _commonTimeStyles.copyWith(
                                      color: hourFocus.hasFocus
                                          ? color
                                          : unselectedColor),
                                  decoration: InputDecoration(
                                      counterText: "",
                                      enabledBorder: const UnderlineInputBorder(
                                        borderSide: BorderSide.none,
                                      ),
                                      focusedBorder: const UnderlineInputBorder(
                                        borderSide: BorderSide.none,
                                      ),
                                      hintStyle: _commonTimeStyles.copyWith(
                                          color: timeState.hourIsSelected
                                              ? color
                                              : unselectedColor),
                                      hintText:
                                          hourValue.toString().padLeft(2, '0')),
                                ),
                              ),
                              SizedBox(
                                  width: 30,
                                  child: IgnorePointer(
                                    ignoring: true,
                                    child: TextField(
                                      style: _commonTimeStyles.copyWith(
                                          color: hourFocus.hasFocus
                                              ? color
                                              : unselectedColor),
                                      decoration: InputDecoration(
                                          enabledBorder:
                                              const UnderlineInputBorder(
                                            borderSide: BorderSide.none,
                                          ),
                                          focusedBorder:
                                              const UnderlineInputBorder(
                                            borderSide: BorderSide.none,
                                          ),
                                          hintStyle: _commonTimeStyles.copyWith(
                                              color: unselectedColor),
                                          hintText: ":"),
                                    ),
                                  )),
                              // DisplayValue(
                              //   onTap: timeState.widget.disableHour!
                              //       ? null
                              //       : () {
                              //           timeState.onHourIsSelectedChange(true);
                              //         },
                              //   value: hourValue.toString().padLeft(2, '0'),
                              //   isSelected: timeState.hourIsSelected,
                              // ),

                              SizedBox(
                                width: 90,
                                child: TextField(
                                  maxLength: 2,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  controller: minCtrl,
                                  onTap: () {
                                    setState(() {
                                      minCtrl.text = "";
                                      timeState.hourIsSelected = false;
                                      timeState.widget.disableMinute!
                                          ? null
                                          : () {
                                              timeState.onHourIsSelectedChange(
                                                  false);
                                            };
                                      minCtrl.clear();
                                    });
                                  },
                                  onEditingComplete: () {
                                    setState(() {
                                      minCtrl.text.isNotEmpty &&
                                              int.parse(minCtrl.value.text) >=
                                                  0 &&
                                              int.parse(minCtrl.value.text) <=
                                                  59
                                          ? timeState.onMinuteChange(
                                              double.parse(minCtrl.value.text))
                                          : timeState.onMinuteChange(
                                              DateTime.now().minute.toDouble());
                                      minCtrl.text = "";
                                    });
                                  },
                                  style: _commonTimeStyles,
                                  decoration: InputDecoration(
                                      counterText: "",
                                      enabledBorder: const UnderlineInputBorder(
                                        borderSide: BorderSide.none,
                                      ),
                                      focusedBorder: const UnderlineInputBorder(
                                        borderSide: BorderSide.none,
                                      ),
                                      hintStyle: _commonTimeStyles.copyWith(
                                          color: timeState.hourIsSelected
                                              ? unselectedColor
                                              : color),
                                      hintText: timeState.time.minute
                                          .toString()
                                          .padLeft(2, '0')),
                                ),
                              ),
                              // const DisplayValue(
                              //   value: ":",
                              // ),
                              // DisplayValue(
                              //   onTap: timeState.widget.disableMinute!
                              //       ? null
                              //       : () {
                              //           timeState.onHourIsSelectedChange(false);
                              //         },
                              //   value: timeState.time.minute
                              //       .toString()
                              //       .padLeft(2, '0'),
                              //   isSelected: !timeState.hourIsSelected,
                              // ),
                            ],
                          ),
                        ),
                      ),
                      Slider(
                        onChangeEnd: (value) {
                          setState(() {
                            timeState.hourIsSelected
                                ? hourCtrl.text = ""
                                : minCtrl.text = "";
                          });
                          if (timeState.widget.isOnValueChangeMode) {
                            timeState.onOk();
                          }
                        },
                        value: timeState.hourIsSelected
                            ? timeState.time.hour.roundToDouble()
                            : timeState.time.minute.roundToDouble(),
                        onChanged: timeState.onTimeChange,
                        min: min,
                        max: max,
                        divisions: divisions,
                        activeColor: color,
                        inactiveColor: color.withAlpha(55),
                      ),
                      if (!hideButtons) const ActionButtons(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
