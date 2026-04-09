import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    super.displayName,
    required super.emailVerified,
  });

  factory UserModel.fromFirebase(User user) {
    return UserModel(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      emailVerified: user.emailVerified,
    );
  }
}
