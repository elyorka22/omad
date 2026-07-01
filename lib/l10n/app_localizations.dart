import 'package:flutter/material.dart';

import '../models/models.dart';

class AppLocalizations {
  const AppLocalizations(this.languageCode);

  final String languageCode;

  bool get isUzbek => languageCode == 'uz';

  static AppLocalizations of(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode;
    return AppLocalizations(code);
  }

  String get appTagline => isUzbek
      ? 'Tez. Qulay. Ishonchli.'
      : 'Быстро. Удобно. Надёжно.';

  String get whereToGo =>
      isUzbek ? 'Qayerga boramiz?' : 'Куда поедем?';

  String get whereGoing =>
      isUzbek ? 'Qayerga boramiz?' : 'Куда едем?';

  String get yourAddress =>
      isUzbek ? 'Sizning manzilingiz' : 'Ваш адрес';

  String get pickupPoint =>
      isUzbek ? 'Jo\'nash nuqtasi' : 'Точка посадки';

  String get destinationPoint =>
      isUzbek ? 'Borish punkti' : 'Пункт назначения';

  String get whereWillYouGo =>
      isUzbek ? 'Qayerga borasiz?' : 'Куда поедете?';

  String get mapButton => isUzbek ? 'Xarita' : 'Карта';

  String get taxi => isUzbek ? 'Taksi' : 'Такси';

  String pickupEtaLabel(int minutes) =>
      isUzbek ? 'Yetib kelish $minutes daq' : 'Подача $minutes мин';

  String get from => isUzbek ? 'Qayerdan' : 'Откуда';
  String get to => isUzbek ? 'Qayerga' : 'Куда';

  String get specifyPickup => isUzbek
      ? 'Jo\'nash manzilini kiriting'
      : 'Укажите адрес отправления';

  String get specifyDropoff => isUzbek
      ? 'Borish manzilini kiriting'
      : 'Укажите адрес назначения';

  String get detecting =>
      isUzbek ? 'Aniqlanmoqda...' : 'Определяем...';

  String get order => isUzbek ? 'Buyurtma' : 'Заказать';
  String get km => isUzbek ? 'km' : 'км';
  String get min => isUzbek ? 'daq' : 'мин';

  String get searchingDriver => isUzbek
      ? 'Haydovchi qidirilmoqda...'
      : 'Ищем водителя...';

  String get cancel => isUzbek ? 'Bekor qilish' : 'Отменить';

  String get driverComing => isUzbek
      ? 'Haydovchi sizga yo\'l oldi'
      : 'Водитель едет к вам';

  String get driverAssigned => isUzbek
      ? 'Haydovchi tayinlandi'
      : 'Водитель назначен';

  String get call => isUzbek ? 'Qo\'ng\'iroq' : 'Позвонить';
  String get chat => isUzbek ? 'Chat' : 'Чат';

  String get cancelRide =>
      isUzbek ? 'Safarni bekor qilish' : 'Отменить поездку';

  String get inProgress => isUzbek ? 'Yo\'lda' : 'В пути';
  String get arrival => isUzbek ? 'kelish' : 'прибытие';
  String get destination => isUzbek ? 'manzil' : 'назначения';

  String get rideCompleted =>
      isUzbek ? 'Safar tugadi' : 'Поездка завершена';

  String get done => isUzbek ? 'Tayyor' : 'Готово';

  String get rideCancelled =>
      isUzbek ? 'Safar bekor qilindi' : 'Поездка отменена';

  String get newOrder => isUzbek ? 'Yangi buyurtma' : 'Новый заказ';

  String get currentLocation =>
      isUzbek ? 'Joriy joylashuv' : 'Текущее местоположение';

  String get myLocation =>
      isUzbek ? 'Mening joylashuvim' : 'Моё местоположение';

  String get profile => isUzbek ? 'Profil' : 'Профиль';
  String get user => isUzbek ? 'Foydalanuvchi' : 'Пользователь';

  String get rideHistory =>
      isUzbek ? 'Safarlar tarixi' : 'История поездок';

  String get noRides =>
      isUzbek ? 'Hozircha safarlar yo\'q' : 'Пока нет поездок';

  String get payment =>
      isUzbek ? 'To\'lov usullari' : 'Способы оплаты';

  String get favorites =>
      isUzbek ? 'Sevimli manzillar' : 'Избранные адреса';

  String get support => isUzbek ? 'Yordam' : 'Поддержка';
  String get settings => isUzbek ? 'Sozlamalar' : 'Настройки';
  String get language => isUzbek ? 'Til' : 'Язык';
  String get russian => isUzbek ? 'Rus tili' : 'Русский';
  String get uzbek => 'O\'zbekcha';

  String get enterAddress =>
      isUzbek ? 'Manzilni kiriting' : 'Введите адрес';

  String get pickOnMap => isUzbek ? 'Xaritada' : 'На карте';

  String get confirmPoint => isUzbek ? 'Tasdiqlash' : 'Подтвердить';

  String get selectedOnMap =>
      isUzbek ? 'Xaritadagi nuqta' : 'Точка на карте';

  String mapPickHint(MapPickTarget target) {
    if (isUzbek) {
      return target == MapPickTarget.pickup
          ? 'Xaritada jo\'nash nuqtasini tanlang'
          : 'Xaritada borish nuqtasini tanlang';
    }
    return target == MapPickTarget.pickup
        ? 'Выберите точку отправления на карте'
        : 'Выберите точку назначения на карте';
  }

  String get mapPickTapOrMove => isUzbek
      ? 'Xaritaga bosing yoki surib, tasdiqlang'
      : 'Нажмите на карту или переместите и подтвердите';

  String get noLocationPermission => isUzbek
      ? 'Geolokatsiyaga ruxsat yo\'q'
      : 'Нет доступа к геолокации';

  String get locationFailed => isUzbek
      ? 'Joylashuvni aniqlab bo\'lmadi'
      : 'Не удалось определить местоположение';

  String rideClassName(RideClass rideClass) {
    switch (rideClass) {
      case RideClass.economy:
        return isUzbek ? 'Ekonom' : 'Эконом';
      case RideClass.comfort:
        return isUzbek ? 'Komfort' : 'Комфорт';
      case RideClass.comfortPlus:
        return isUzbek ? 'Komfort+' : 'Комфорт+';
      case RideClass.business:
        return isUzbek ? 'Biznes' : 'Бизнес';
    }
  }

  String rideClassDescription(RideClass rideClass) {
    switch (rideClass) {
      case RideClass.economy:
        return isUzbek ? 'Arzon safarlar' : 'Недорогие поездки';
      case RideClass.comfort:
        return isUzbek ? 'Yangi avtomobillar' : 'Новые автомобили';
      case RideClass.comfortPlus:
        return isUzbek ? 'Keng avtomobillar' : 'Просторные авто';
      case RideClass.business:
        return isUzbek ? 'Premium klass' : 'Премиум-класс';
    }
  }

  String formatPrice(int price) {
    if (isUzbek) {
      return '$price so\'m';
    }
    return '$price ₽';
  }

  String orderButtonLabel(int price) {
    return '$order · ${formatPrice(price)}';
  }

  String minutesLabel(int minutes) => '$minutes $min';

  String distanceLabel(double km) =>
      '${km.toStringAsFixed(1)} $this.km';

  String inProgressLabel(String place, int minutes) {
    if (isUzbek) {
      return '$place · ~$minutes $min';
    }
    return 'До $place · ~$minutes $min';
  }
}
