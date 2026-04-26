class FormStateModel {
  final Map<String, dynamic> values;
  final Map<String, String?> errors;
  final Set<String> touched;

  const FormStateModel({
    required this.values,
    required this.errors,
    required this.touched,
  });

  FormStateModel copyWith({
    Map<String, dynamic>? values,
    Map<String, String?>? errors,
    Set<String>? touched,
  }) {
    return FormStateModel(
      values: values ?? this.values,
      errors: errors ?? this.errors,
      touched: touched ?? this.touched,
    );
  }

  bool get isValid => errors.values.every((e) => e == null);

  bool get isDirty => touched.isNotEmpty;
}
