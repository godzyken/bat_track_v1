import 'package:shared_models/shared_models.dart';

class PermissionService {
  static bool canRead<T extends UnifiedModel>(AppUser user, T entity) {
    return entity.canRead(user);
  }

  static bool canEdit<T extends UnifiedModel>(AppUser user, T entity) {
    return entity.canEdit(user);
  }

  static bool canDelete<T extends UnifiedModel>(AppUser user, T entity) {
    return entity.canDelete(user);
  }
}
