/// menghandle kesalahan yang terjadi saat melakukan koneksi jaringan.
/// digunakan ketika aplikasi mengalami masalah dalam mengakses internet
/// atau layanan jaringan lainnya.
class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = 'A network error occurred']);
}

/// menghandle kesalahan yang terjadi saat proses transfer data.
/// digunakan untuk menangani kegagalan dalam proses pengiriman
/// atau penerimaan data antar sistem.
class TransferException implements Exception {
  final String message;
  TransferException([this.message = 'Transfer failed']);
}
