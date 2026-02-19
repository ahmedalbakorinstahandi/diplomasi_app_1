import 'package:flutter/foundation.dart';

@immutable
final class Assets {
  const Assets();
  static const MyIcons icons = MyIcons();
  static const Pictures pictures = Pictures();
  static const Sounds sounds = Sounds();
}

const String iconsImagesPath = 'assets/icons/images';
const String iconsSvgPath = 'assets/icons/svg';

@immutable
final class IconsImages {
  const IconsImages();

  final String logo = '$iconsImagesPath/logo.png';

  // location_pin_red.png
  final String locationPinRed = '$iconsImagesPath/location_pin_red.png';

  // location_pin_green.png
  final String locationPinGreen = '$iconsImagesPath/location_pin_green.png';
}

@immutable
final class IconsLottie {
  const IconsLottie();
}

@immutable
final class IconsSvg {
  const IconsSvg();

  final String ar = '$iconsSvgPath/ar.svg';
  final String en = '$iconsSvgPath/en.svg';

  final String logo = '$iconsSvgPath/logo.svg';

  // phone.svg
  final String phone = '$iconsSvgPath/phone.svg';

  // eye_off.svg
  final String eyeOff = '$iconsSvgPath/eye_off.svg';
  // eye_on.svg
  final String eyeOn = '$iconsSvgPath/eye_on.svg';

  // person.svg
  final String person = '$iconsSvgPath/person.svg';

  // crown.svg
  final String crown = '$iconsSvgPath/crown.svg';

  // fire_department.svg
  final String fireDepartment = '$iconsSvgPath/fire_department.svg';

  // terminology.svg
  final String terminology = '$iconsSvgPath/terminology.svg';

  // lock.svg
  final String lock = '$iconsSvgPath/lock.svg';

  // home.svg
  final String home = '$iconsSvgPath/home.svg';

  // map.svg
  final String map = '$iconsSvgPath/map.svg';

  // favorite.svg
  final String favorite = '$iconsSvgPath/favorite.svg';

  // add.svg
  final String add = '$iconsSvgPath/add.svg';

  // search.svg
  final String search = '$iconsSvgPath/search.svg';

  // filter.svg
  final String filter = '$iconsSvgPath/filter.svg';

  // share.svg
  final String share = '$iconsSvgPath/share.svg';

  // favorite_outline.svg
  final String favoriteOutline = '$iconsSvgPath/favorite_outline.svg';

  // favorite_filled.svg
  final String favoriteFilled = '$iconsSvgPath/favorite_filled.svg';

  // location.svg
  final String location = '$iconsSvgPath/location.svg';

  // insurance.svg
  final String insurance = '$iconsSvgPath/insurance.svg';

  // rooms.svg
  final String rooms = '$iconsSvgPath/rooms.svg';

  // furnished.svg
  final String furnished = '$iconsSvgPath/furnished.svg';

  // location_pin_red.svg
  final String locationPinRed = '$iconsSvgPath/location_pin_red.svg';

  // location_pin_green.svg
  final String locationPinGreen = '$iconsSvgPath/location_pin_green.svg';

  // plus.svg
  final String plus = '$iconsSvgPath/plus.svg';

  // minus.svg
  final String minus = '$iconsSvgPath/minus.svg';

  // edit_data.svg
  final String editData = '$iconsSvgPath/edit_data.svg';

  // edit_profile.svg
  final String editProfile = '$iconsSvgPath/edit_profile.svg';

  // change_password.svg
  final String changePassword = '$iconsSvgPath/change_password.svg';

  // my_listings.svg
  final String myListings = '$iconsSvgPath/my_listings.svg';

  // notification.svg
  final String notification = '$iconsSvgPath/notification.svg';

  // learn_lock.svg
  final String learnLock = '$iconsSvgPath/learn_lock.svg';

  // play.svg
  final String play = '$iconsSvgPath/play.svg';

  // badge.svg
  final String badge = '$iconsSvgPath/badge.svg';

  // book.svg
  final String book = '$iconsSvgPath/book.svg';

  // settings.svg
  final String settings = '$iconsSvgPath/settings.svg';

  // arrow_forward.svg
  final String arrowForward = '$iconsSvgPath/arrow_forward.svg';

  // arrow_left.svg
  final String arrowLeft = '$iconsSvgPath/arrow_left.svg';

  // star_rate_rounded.svg
  final String starRateRounded = '$iconsSvgPath/star_rate_rounded.svg';

  // star_outline_rounded.svg
  final String starOutlineRounded = '$iconsSvgPath/star_outline_rounded.svg';

  // about_app.svg
  final String aboutApp = '$iconsSvgPath/about_app.svg';

  // language.svg
  final String language = '$iconsSvgPath/language.svg';

  // logout.svg
  final String logout = '$iconsSvgPath/logout.svg';

  // whatsapp.svg
  final String whatsapp = '$iconsSvgPath/whatsapp.svg';

  // dot
  final String dot = '$iconsSvgPath/dot.svg';

  // email.svg
  final String email = '$iconsSvgPath/email.svg';

  // medal_star.svg
  final String medalStar = '$iconsSvgPath/medal_star.svg';

  // shield_tick.svg
  final String shieldTick = '$iconsSvgPath/shield_tick.svg';

  // star.svg
  final String star = '$iconsSvgPath/star.svg';

  // ticket_star.svg
  final String ticketStar = '$iconsSvgPath/ticket_star.svg';

  // trash.svg
  final String trash = '$iconsSvgPath/trash.svg';

  // edit.svg
  final String edit = '$iconsSvgPath/edit.svg';

  // language_circle.svg
  final String languageCircle = '$iconsSvgPath/language_circle.svg';

  // help_circle.svg
  final String helpCircle = '$iconsSvgPath/help_circle.svg';

  // share_square.svg
  final String shareSquare = '$iconsSvgPath/share_square.svg';

  // file_signature.svg
  final String fileSignature = '$iconsSvgPath/file_signature.svg';

  // notification_bell.svg
  final String notificationBell = '$iconsSvgPath/notification_bell.svg';

  // notification_star.svg
  final String notificationStar = '$iconsSvgPath/notification_star.svg';

  // file_edit.svg
  final String fileEdit = '$iconsSvgPath/file_edit.svg';

  // night_mode.svg
  final String nightMode = '$iconsSvgPath/night_mode.svg';

  // terms_and_conditions.svg
  final String termsAndConditions = '$iconsSvgPath/terms_and_conditions.svg';

  // person_outline.svg
  final String personOutline = '$iconsSvgPath/person_outline.svg';

  // email_outline.svg
  final String emailOutline = '$iconsSvgPath/email_outline.svg';

  // phone_outline.svg
  final String phoneOutline = '$iconsSvgPath/phone_outline.svg';

  // age_outline.svg
  final String ageOutline = '$iconsSvgPath/age_outline.svg';

  // location_outline.svg
  final String locationOutline = '$iconsSvgPath/location_outline.svg';

  // job_title_outline.svg
  final String jobTitleOutline = '$iconsSvgPath/job_title_outline.svg';

  // edit_pencil_outline.svg
  final String editPencilOutline = '$iconsSvgPath/edit_pencil_outline.svg';

  // checkmark_square.svg
  final String checkmarkSquare = '$iconsSvgPath/checkmark_square.svg';

  // subscriptions.svg
  final String subscriptions = '$iconsSvgPath/subscriptions.svg';
}

@immutable
final class MyIcons {
  const MyIcons();
  final IconsImages images = const IconsImages();
  final IconsLottie lottie = const IconsLottie();
  final IconsSvg svg = const IconsSvg();
}

const String picturesImagesPath = 'assets/pictures/images';

@immutable
final class PicturesImages {
  const PicturesImages();

  final String onbording = '$picturesImagesPath/onbording.png';
  final String onbording1 = '$picturesImagesPath/onbording1.png';
  final String onbording2 = '$picturesImagesPath/onbording2.png';
  final String onbording3 = '$picturesImagesPath/onbording3.png';

  final String placeholderImage1 =
      'https://conference.nbasbl.org/wp-content/uploads/2022/05/placeholder-image-1.png';

  final String logo = '$picturesImagesPath/logo.png';
  final String logoWithName = '$picturesImagesPath/logo_with_name.png';
}

const String picturesLottiePath = 'assets/pictures/lottie';

@immutable
final class PicturesLottie {
  const PicturesLottie();

  final String search1 = '$picturesLottiePath/search1.json';
  final String notFound = '$picturesLottiePath/not_found.json';
  //active
  final String active = '$picturesLottiePath/active.json';

  //no_intrnet.json
  final String noInternet = '$picturesLottiePath/no_intrnet.json';
}

const String picturesSvgPath = 'assets/pictures/svg';

@immutable
final class PicturesSvg {
  const PicturesSvg();
  final String logo = '$picturesSvgPath/logo.svg';
  final String onbordingBGLinear = '$picturesSvgPath/onbording_bg_linear.svg';

  final String onbording = '$picturesSvgPath/onbording.svg';
  final String onbording2 = '$picturesSvgPath/onbording2.svg';
  final String onbording3 = '$picturesSvgPath/onbording3.svg';
  // pattern1
  final String pattern1 = '$picturesSvgPath/pattern1.svg';
  // logo_with_name.svg
  final String logoWithName = '$picturesSvgPath/logo_with_name.svg';

  final String favoritesIsEmpty = '$picturesSvgPath/favorites_is_empty.svg';
  final String filterResultEmpty = '$picturesSvgPath/filter_result_empty.svg';
}

@immutable
final class Pictures {
  const Pictures();
  final PicturesImages images = const PicturesImages();
  final PicturesLottie lottie = const PicturesLottie();
  final PicturesSvg svg = const PicturesSvg();
}

const String soundsPath = 'sounds';

@immutable
final class Sounds {
  const Sounds();
}
