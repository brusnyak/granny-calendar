class AppStrings {
  final String Function(int year) yearLabel;
  final List<String> months;
  final List<String> weekdaysShort;
  final List<String> weekdaysFull;
  final String appTitle;
  final String today;
  final String yesterday;
  final String tomorrow;
  final String noEvents;
  final String addEvent;
  final String editEvent;
  final String deleteEvent;
  final String save;
  final String cancel;
  final String eventHint;
  final String timeLabel;
  final String noTime;
  final String reminderLabel;
  final String reminderOn;
  final String reminderNoTime;
  final String eventsForDay;
  final String tapToAdd;
  final String ok;
  final String aboutTitle;
  final String aboutText;

  const AppStrings({
    required this.yearLabel,
    required this.months,
    required this.weekdaysShort,
    required this.weekdaysFull,
    required this.appTitle,
    required this.today,
    required this.yesterday,
    required this.tomorrow,
    required this.noEvents,
    required this.addEvent,
    required this.editEvent,
    required this.deleteEvent,
    required this.save,
    required this.cancel,
    required this.eventHint,
    required this.timeLabel,
    required this.noTime,
    required this.reminderLabel,
    required this.reminderOn,
    required this.reminderNoTime,
    required this.eventsForDay,
    required this.tapToAdd,
    required this.ok,
    required this.aboutTitle,
    required this.aboutText,
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
  noEvents: 'Немає подій',
  addEvent: 'Додати подію',
  editEvent: 'Редагувати подію',
  deleteEvent: 'Видалити подію',
  save: 'Зберегти',
  cancel: 'Скасувати',
  eventHint: 'Що плануєте?',
  timeLabel: 'Час',
  noTime: 'Без часу',
  reminderLabel: 'Нагадування',
  reminderOn: 'Отримати сповіщення',
  reminderNoTime: 'Вкажіть час для сповіщення',
  eventsForDay: 'Події на',
  tapToAdd: 'Натисніть + щоб додати',
  ok: 'Гаразд',
  aboutTitle: 'Про програму',
  aboutText: 'v1.0.0\n\nПростий календар для щоденних справ.',
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
  noEvents: 'Нет событий',
  addEvent: 'Добавить событие',
  editEvent: 'Редактировать событие',
  deleteEvent: 'Удалить событие',
  save: 'Сохранить',
  cancel: 'Отмена',
  eventHint: 'Что планируете?',
  timeLabel: 'Время',
  noTime: 'Без времени',
  reminderLabel: 'Напоминание',
  reminderOn: 'Получить уведомление',
  reminderNoTime: 'Укажите время для уведомления',
  eventsForDay: 'События на',
  tapToAdd: 'Нажмите + чтобы добавить',
  ok: 'Ок',
  aboutTitle: 'О программе',
  aboutText: 'v1.0.0\n\nПростой календарь для ежедневных дел.',
);
