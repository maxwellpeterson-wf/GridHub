library date_utils;


String getRelativeDate(DateTime eventTime) {
    DateTime now = new DateTime.now();
    Duration diff = now.difference(eventTime);

    if (diff.inMinutes < 0) {
        return '${diff.inSeconds} seconds ago';
    }
    else if (diff.inHours < 0) {
        return '${diff.inMinutes} minutes ago';
    }
    else if (diff.inDays < 0) {
        return '${diff.inHours} hours ago';
    }
    else if (diff.inDays > 30) {
        return 'on ${getMonthName(eventTime.month)} ${eventTime.day}';
    }
    else {
        return '${diff.inDays} days ago';
    }
}

String getMonthName(int month) {
    List<String> _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return _months[month - 1];
}
