class AppStrings {
  final String Function(int year) yearLabel;
  final List<String> months;
  final List<String> weekdaysShort;
  final List<String> weekdaysFull;
  final String appTitle;
  final String today;
  final String yesterday;
  final String tomorrow;

  const AppStrings({
    required this.yearLabel,
    required this.months,
    required this.weekdaysShort,
    required this.weekdaysFull,
    required this.appTitle,
    required this.today,
    required this.yesterday,
    required this.tomorrow,
  });
}

/// Returns UI language strings based on device locale.
/// Defaults to Ukrainian if neither Ukrainian nor Russian.
AppStrings getStrings(String localeCode) {
  if (localeCode.startsWith('ru')) return _ruStrings;
  return _ukStrings;
}

final _ukStrings = AppStrings(
  yearLabel: (y) => '$y рік',
  months: [
    'Січень', 'Лютий', 'Березень', 'Квітень', 'Травень', 'Червень',
    'Липень', 'Серпень', 'Вересень', 'Жовтень', 'Листопад', 'Грудень',
  ],
  weekdaysShort: ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Нд'],
  weekdaysFull: [
    'понеділок', 'вівторок', 'середа', 'четвер', "п'ятниця", 'субота', 'неділя',
  ],
  appTitle: 'Календар',
  today: 'Сьогодні',
  yesterday: 'Вчора',
  tomorrow: 'Завтра',
);

final _ruStrings = AppStrings(
  yearLabel: (y) => '$y год',
  months: [
    'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь',
    'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь',
  ],
  weekdaysShort: ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'],
  weekdaysFull: [
    'понедельник', 'вторник', 'среда', 'четверг', 'пятница', 'суббота', 'воскресенье',
  ],
  appTitle: 'Календарь',
  today: 'Сегодня',
  yesterday: 'Вчера',
  tomorrow: 'Завтра',
);
