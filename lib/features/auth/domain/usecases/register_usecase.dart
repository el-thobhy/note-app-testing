import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;
  RegisterUseCase(this.repository);

  Future<bool> call(String email, String password, String name) =>
      repository.register(email, password, name);
}
