
import 'package:flutter/material.dart';


/// Helps format date and time.

abstract class DateTimeFormator {

  static String _zeroPad(int value) =>
    value < 10 ? '0$value' : '$value';

  static String formatDateTime(DateTime dt) =>
    formatTime(TimeOfDay(hour: dt.hour, minute: dt.minute)) + ', ' + formatDate(dt);

  static String formatTime(TimeOfDay t) {
    final Map<int, String> hourMapper = {
      24: '0',
      23: '11',
      22: '10',
      21: '9',
      20: '8',
      19: '7',
      18: '6',
      17: '5',
      16: '4',
      15: '3',
      14: '2',
      13: '1'
    };
    final String hour = t.hour <= 12 ? _zeroPad(t.hour) : hourMapper[t.hour];

    return hour + ':' + _zeroPad(t.minute) + (t.hour <= 11 ? ' AM' : ' PM');
  }

  static String formatDate (DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'June',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  ///
	/// Timespan
	///
	/// Returns a span of seconds in this format:
	///	10 days 14 hours 36 minutes 47 seconds
	///
	/// [datetime]	The datetime
  /// 
	/// [otherDateTime]	Unix timestamp
  ///
	/// [units] The number of display units
  ///
	static String timespan(DateTime datetime, {DateTime otherDateTime, int units: 1})
	{
    final List<String> str = [];
    
    int time = datetime.millisecondsSinceEpoch ~/ 1000;
    String style = '';

		int otherTime = otherDateTime != null ?
      otherDateTime.millisecondsSinceEpoch ~/ 1000 :
      DateTime.now().millisecondsSinceEpoch ~/ 1000 ;

	//	time = (otherTime <= time) ? 1 : otherTime - time;

    if (otherTime <= time){
      time =  time - otherTime;
      style = 'in ';
    }
    else if(otherTime > time){
      time = otherTime - time;
      style = ' ago';
    }
    else {
      style = ' ago';
    }


		int years = (time / 31557600).floor();

		if (years > 0)
		{
			str.add( years.toString() + ' ' + (years > 1 ? 'years' : 'year') );
		}

		time -= years * 31557600;
		int months = (time / 2629743).floor();

		if (str.length < units && (years > 0 || months > 0))
		{
			if (months > 0)
			{
				str.add( months.toString() + ' ' + (months > 1 ? 'months' : 'month') );
			}

			time -= months * 2629743;
		}

		int weeks = (time / 604800).floor();

		if (str.length < units && (years > 0 || months > 0 || weeks > 0))
		{
			if (weeks > 0)
			{
				str.add( weeks.toString() + ' ' + (weeks > 1 ? 'weeks' : 'week') );
			}

			time -= weeks * 604800;
		}

		int days = (time / 86400).floor();

		if (str.length < units && (months > 0 || weeks > 0 || days > 0))
		{
			if (days > 0)
			{
				str.add( days.toString() + ' ' + (days > 1 ? 'days' : 'day') );
			}

			time -= days * 86400;
		}

		int hours = (time / 3600).floor();

		if (str.length < units && (days > 0 || hours > 0))
		{
			if (hours > 0)
			{
				str.add( hours.toString() + ' ' + (hours > 1 ? 'hours' : 'hour') );
			}

			time -= hours * 3600;
		}

		int minutes = (time / 60).floor();

		if (str.length < units && (days > 0 || hours > 0 || minutes > 0))
		{
			if (minutes > 0)
			{
				str.add( minutes.toString() + ' ' + (minutes > 1 ? 'minutes' : 'minute') );
			}

			time -= minutes * 60;
		}

		if (str.length == 0)
		{
			str.add( time.toString() + ' ' + (time > 1 ? 'seconds' : 'second') );
		}

		return (style == 'in ' ? style : '') + str.join(', ') + (style == ' ago' ? style : '');
	}
}