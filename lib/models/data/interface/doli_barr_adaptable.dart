abstract class DolibarrAdaptable<T> {
  Map<String, dynamic> toDolibarrJson();

  T fromDolibarrJson(Map<String, dynamic> json);
}

class DolibarrAdapter<T extends DolibarrAdaptable> {
  final T Function() builder;

  DolibarrAdapter(this.builder);

  Map<String, dynamic> toDolibarr(T entity) {
    return entity.toDolibarrJson();
  }

  T fromDolibarr(Map<String, dynamic> json) {
    return builder().fromDolibarrJson(json) as T;
  }
}
