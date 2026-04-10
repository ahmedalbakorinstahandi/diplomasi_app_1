/// Backend returned billing.ios.already_linked_to_another_account.
class IapOwnershipConflictException implements Exception {
  IapOwnershipConflictException({this.maskedOwnerEmail});

  final String? maskedOwnerEmail;

  @override
  String toString() {
    if (maskedOwnerEmail != null && maskedOwnerEmail!.isNotEmpty) {
      return maskedOwnerEmail!;
    }
    return 'billing.ios.already_linked_to_another_account';
  }
}
