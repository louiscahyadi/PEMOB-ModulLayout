class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = 'A network error occurred']);
}

class TransferException implements Exception {
  final String message;
  TransferException([this.message = 'Transfer failed']);
}
