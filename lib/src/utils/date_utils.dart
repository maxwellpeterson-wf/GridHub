library gridhub.src.utils.date_utils;

String getRelativeDate(DateTime eventTime) {
  DateTime now = new DateTime.now();
  Duration diff = now.difference(eventTime);

  if (diff.inMinutes <= 0) {
    return '${diff.inSeconds} seconds ago';
  }
  else if (diff.inHours <= 0) {
    return '${diff.inMinutes} minutes ago';
  }
  else if (diff.inDays <= 0) {
    return '${diff.inHours} hours ago';
  }
  else if (diff.inDays > 30) {
    return 'on ${getMonthName(eventTime.month)} ${eventTime.day}';
  }
  else if (diff.inDays == 1) {
    return '${diff.inDays} day ago';
  }
  else {
    return '${diff.inDays} days ago';
  }
}

String getMonthName(int month) {
  List<String> _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return _months[month - 1];
}

String getWeekdayName(int weekday) {
  List<String> _weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  return _weekdays[weekday - 1];
}

String getRelativeDueDate(DateTime dueDate) {
  DateTime now = new DateTime.now();
  Duration diff = dueDate.difference(now);
  DateTime nowMidnight = new DateTime.utc(now.year, now.month, now.day + 1, 0, 0, 0, 0);
  Duration tillMidnight = nowMidnight.difference(now);

  if (diff.inDays < 0) {
    return getRelativeDate(dueDate);
  }
  else if (diff.inHours < tillMidnight.inHours) {
    return 'today';
  }
  else if (diff.inHours < tillMidnight.inHours + 24) {
    return 'tomorrow';
  }
  else if (diff.inDays <= 6) {
    return getWeekdayName(dueDate.weekday);
  }
  else if (diff.inDays == 7) {
    return 'a week from today';
  }
  else {
    return 'by ${getMonthName(dueDate.month)} ${dueDate.day}';
  }
}
