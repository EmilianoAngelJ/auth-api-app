import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:auth_api_app/theme/colors.dart';

/// Custom form field widget for picking and displaying a birthdate.
/// - Shows a read-only text field with a date picker dialog on tap.
/// - Validates that a date is selected.
/// - Supports optional autovalidation and onChanged callback.
class BirthdateFormField extends FormField<DateTime> {
  BirthdateFormField({
    super.key,
    super.onSaved,
    super.initialValue,
    bool autovalidate = false,
    void Function(DateTime?)? onChanged,
  }) : super(
    // Validator: require a non-null date
    validator: (value) {
      if (value == null) {
        return 'Date of birth is required.';
      }
      return null;
    },

    // Toggle auto validation mode based on parameter
    autovalidateMode: autovalidate
        ? AutovalidateMode.always
        : AutovalidateMode.disabled,

    // Build the form field UI
    builder: (FormFieldState<DateTime> state) {
      // Controller displays formatted date or empty string
      final TextEditingController controller = TextEditingController(
        text: state.value != null
            ? DateFormat.yMd().format(state.value!)
            : '',
      );

      return Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              // Input decoration with error and focus styles
              decoration: InputDecoration(
                labelText: 'Date of birth',
                labelStyle: TextStyle(
                  color: state.hasError ? Colors.red[900] : Colors.grey[800],
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: state.hasError
                        ? Colors.red[900]!
                        : AppColors.primaryColor,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: state.hasError
                        ? Colors.red[900]!
                        : Colors.grey[700]!,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: state.hasError
                        ? Colors.red[900]!
                        : Colors.grey[700]!,
                  ),
                ),
                prefixIcon: const Icon(Icons.calendar_today),
              ),
              readOnly: true, // Prevent manual input
              onTap: () async {
                // Show date picker dialog on tap
                DateTime? pickedDate = await showDatePicker(
                  context: state.context,
                  initialDate: state.value ?? DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                  builder: (BuildContext context, Widget? child) {
                    // Custom themed date picker dialog
                    return Theme(
                      data: ThemeData.light().copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: AppColors.secondaryColor, // Header color
                          onSurface: Colors.black, // Text color
                        ),
                        dialogTheme: const DialogThemeData(
                          backgroundColor: AppColors.backgroundColor, // Background
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (pickedDate != null) {
                  // Update form state with selected date
                  state.didChange(pickedDate);
                  controller.text = DateFormat.yMd().format(pickedDate);
                  // Call onChanged callback if provided
                  onChanged?.call(pickedDate);
                }
              },
              controller: controller,
            ),

            // Show validation error text if any
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 5.0, left: 10.0),
                child: Text(
                  state.errorText!,
                  style: TextStyle(color: Colors.red[900], fontSize: 12),
                ),
              ),
          ],
        ),
      );
    },
  );
}
