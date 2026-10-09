abstract class Failure {
  final String message;
  final int? statusCode;

  const Failure(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.statusCode});
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Koneksi internet terputus. Beralih ke mode offline.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Gagal membaca atau menyimpan data ke database lokal.']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Sesi telah berakhir atau autentikasi gagal.']);
}
