mixin HiveCovertible<T> {
  T toModel();
  HiveCovertible<T> fromModel(T model);
}
