import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Future<String> customDatePicker(BuildContext context) async {
  final scheme = Theme.of(context).colorScheme;
  DateTime? selectedDate = await showDatePicker(
    context: context,
    initialDate: DateTime.now().subtract(const Duration(days: 365 * 10)),
    firstDate: DateTime(1900),
    lastDate: DateTime.now(),
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: scheme.primary,
                onPrimary: scheme.onPrimary,
                onSurface: scheme.onSurface,
              ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: scheme.primary,
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          dialogTheme: DialogThemeData(backgroundColor: scheme.surface),
        ),
        child: child!,
      );
    },
  );

  if (selectedDate != null) {
    return DateFormat('yyyy-MM-dd').format(selectedDate);
  } else {
    return '';
  }
}
