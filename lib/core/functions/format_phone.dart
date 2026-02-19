import 'package:phone_numbers_parser/phone_numbers_parser.dart';

formatPhone(String phoneNumber) {
  try {
    final parsedPhone = PhoneNumber.parse(phoneNumber);
    // ignore: deprecated_member_use
    final formattedPhone = parsedPhone.getFormattedNsn();
    final countryCode = parsedPhone.countryCode;
    return "+$countryCode $formattedPhone";
  } catch (e) {
    return phoneNumber;
  }
}
