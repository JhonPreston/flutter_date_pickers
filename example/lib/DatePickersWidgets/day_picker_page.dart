import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_date_picker/event.dart';
import 'package:flutter_date_picker/color_picker_dialog.dart';
import 'package:flutter_date_picker/color_selector_btn.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart' as dp;

class DayPickerPage extends StatefulWidget {
  final List<Event> events;
  final List<DateTime> disabledDate;

  const DayPickerPage({
    Key key,
    this.events,
    this.disabledDate
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DayPickerPageState();
}

class _DayPickerPageState extends State<DayPickerPage> {
  DateTime _selectedDate;
  DateTime _firstDate;
  DateTime _lastDate;
  DateTime _monthPageDate;
  Color selectedDateStyleColor;
  Color selectedSingleDateDecorationColor;
  String _item;

  @override
  void initState() {
    super.initState();

    _selectedDate = DateTime.now();
    _monthPageDate = DateTime.now();
    _firstDate = DateTime.now().subtract(Duration(days: 9843759834675931));
    _lastDate = DateTime.now().add(Duration(days: 9843759834675931));
    _item = '1';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // defaults for styles
    selectedDateStyleColor = Theme.of(context).accentTextTheme.body2.color;
    selectedSingleDateDecorationColor = Theme.of(context).accentColor;
  }

  @override
  Widget build(BuildContext context) {
    // add selected colors to default settings
    dp.DatePickerStyles styles = dp.DatePickerRangeStyles(
//        disabledDateStyle: Theme.of(context)
//            .accentTextTheme
//            .body2
//            .copyWith(color: Colors.red),
        currentDateStyle: Platform.isAndroid
            ? Theme.of(context)
            .accentTextTheme
            .body2
            .copyWith(color: Color(0xff8dc641))
            : Theme.of(context)
            .accentTextTheme
            .body2
            .copyWith(color: Colors.black87),
        selectedDateStyle: Theme.of(context)
            .accentTextTheme
            .body2
            .copyWith(color: selectedDateStyleColor),
        selectedSingleDateDecoration: BoxDecoration(
            color: Color(0xff8dc641),
//            color: selectedSingleDateDecorationColor,
            shape: BoxShape.circle));

    return Flex(
      direction: MediaQuery.of(context).orientation == Orientation.portrait
          ? Axis.vertical
          : Axis.horizontal,
      children: <Widget>[
        Expanded(
          child: dp.DayPicker(
            selectedDate: _selectedDate,
            monthPageDate: _monthPageDate,
            onChanged: _onSelectedDateChanged,
            onVisibleMonthChanged: (date) {print('onPageChanged --> $date');},
            firstDate: _firstDate,
            lastDate: _lastDate,
            datePickerStyles: styles,
            datePickerLayoutSettings: dp.DatePickerLayoutSettings(maxDayPickerRowCount: 2),
            selectableDayPredicate: _isSelectableCustom,
            eventDecorationBuilder: _eventDecorationBuilder,
            showHeaderNavigation: false,
          ),
        ),
        Container(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Selected date styles",
                  style: Theme.of(context).textTheme.subhead,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ColorSelectorBtn(
                        title: "Text",
                        color: selectedDateStyleColor,
                        showDialogFunction: _showSelectedDateDialog,
                        colorBtnSize: 42.0,
                      ),
                      SizedBox(
                        width: 12.0,
                      ),
                      ColorSelectorBtn(
                        title: "Background",
                        color: selectedSingleDateDecorationColor,
                        showDialogFunction: _showSelectedBackgroundColorDialog,
                        colorBtnSize: 42.0,
                      ),
                      DropdownButton<String>(
                        value: _item,
                        icon: Icon(
                          Icons.arrow_drop_down,
                        ),

                        onChanged: (val){
                          print(val);

                          _item=val;
                          DateTime _temp;
                          if(val == '1'){
                            _temp = DateTime.now();
                          }
                          if(val == '2'){
                            _temp = DateTime(2019,2, 11);
                          }
                          if(val == '3'){
                            _temp = DateTime(2021,5, 11);
                          }
                          print(_temp);
                          setState(() {
                            _monthPageDate = _temp;
//                            _selectedDate = _temp;
                          });
                        },
                        selectedItemBuilder: (BuildContext context) {
                          return ['1','2','3'].map<DropdownMenuItem<String>>((value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList();
                        },
                        items: ['1','2','3'].map<DropdownMenuItem<String>>((value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      )
                    ],
                  ),
                ),
                Text("Selected: $_selectedDate")
              ],
            ),
          ),
        ),
      ],
    );
  }

  // select text color of the selected date
  void _showSelectedDateDialog() async {
    Color newSelectedColor = await showDialog(
        context: context,
        builder: (_) => ColorPickerDialog(
              selectedColor: selectedDateStyleColor,
            ));

    if (newSelectedColor != null)
      setState(() {
        selectedDateStyleColor = newSelectedColor;
      });
  }

  // select background color of the selected date
  void _showSelectedBackgroundColorDialog() async {
    Color newSelectedColor = await showDialog(
        context: context,
        builder: (_) => ColorPickerDialog(
              selectedColor: selectedSingleDateDecorationColor,
            ));

    if (newSelectedColor != null)
      setState(() {
        selectedSingleDateDecorationColor = newSelectedColor;
      });
  }

  void _onSelectedDateChanged(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
    });
  }

  bool _isSelectableCustom (DateTime day) {
    List<DateTime> dates = [DateTime(2020, 04, 21),DateTime(2020, 04, 23), DateTime(2020, 06, 25)];
    if(dates.indexOf(day) != -1){
      return false;
    }
    return true;
//    return day.weekday < 6;
  }

  dp.EventDecoration _eventDecorationBuilder(DateTime date) {
//    print('_eventDecorationBuilder---> $date');
    List<DateTime> eventsDates = widget.events?.map<DateTime>((Event e) => e.date)?.toList();
    bool isEventDate = eventsDates?.any((DateTime d) => date.year == d.year && date.month == d.month && d.day == date.day) ?? false;

    BoxDecoration roundedBorder = BoxDecoration(
        border: Border.all(
          color: Colors.deepOrange,
        ),
        borderRadius: BorderRadius.all(Radius.circular(3.0))
    );

    return isEventDate
        ? dp.EventDecoration(boxDecoration: roundedBorder)
        : null;
  }

}

