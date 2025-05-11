import 'package:flutter/material.dart';
import '../models/account.dart';
import '../models/transaction.dart';
import '../services/auth_service.dart';
import '../services/account_service.dart';
import '../utils/currency_formatter.dart';
import '../utils/logger.dart';
import '../screens/login_screen.dart';
import '../screens/transaction_history_screen.dart';
import '../screens/transfer_screen.dart';
import '../screens/deposit_screen.dart';
import '../screens/payment_screen.dart';
import '../screens/loan_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/settings_screen.dart';
import '../widgets/transaction_item.dart';

// menampilkan layar beranda aplikasi
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final AccountService _accountService = AccountService();

  Account? _account;
  List<Transaction> _recentTransactions = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // mengambil data rekening dan transaksi dari server
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      Logger.info('HomeScreen: Memuat data rekening dan transaksi');

      final account = await _accountService.getCurrentUserAccount();

      if (account != null) {
        final transactions =
            await _accountService.getTransactions(account.id, limit: 5);

        setState(() {
          _account = account;
          _recentTransactions = transactions;
          _isLoading = false;
        });

        Logger.info(
            'HomeScreen: Data berhasil dimuat untuk rekening: ${account.id}');
      } else {
        // menampilkan pesan error jika rekening tidak ditemukan
        setState(() {
          _errorMessage =
              'Tidak dapat memuat data rekening. Silakan coba lagi.';
          _isLoading = false;
        });

        Logger.warning('HomeScreen: Gagal memuat data rekening');
      }
    } catch (e) {
      Logger.error('HomeScreen: Error saat memuat data: $e');
      setState(() {
        _errorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
        _isLoading = false;
      });
    }
  }

  // menjalankan proses logout pengguna
  Future<void> _logout() async {
    try {
      Logger.info('HomeScreen: Melakukan logout');
      await _authService.logout();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    } catch (e) {
      Logger.error('HomeScreen: Error saat logout: $e');
    }
  }

  // mengarahkan pengguna ke layar yang dipilih
  void _navigateToScreen(Widget screen) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(builder: (_) => screen),
        )
        .then((_) => _loadData()); // refresh data saat kembali dari layar lain
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // membuat komponen app bar
            _buildAppBar(),

            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFF1F2937)),
                      ),
                    )
                  : _errorMessage != null
                      ? _buildErrorView()
                      : RefreshIndicator(
                          onRefresh: _loadData,
                          color: const Color(0xFF1F2937),
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // membuat kartu informasi profil pengguna
                                _buildUserProfileCard(),

                                const SizedBox(height: 16.0),

                                // menyusun menu dalam bentuk grid
                                _buildMenuGrid(),

                                const SizedBox(height: 16.0),

                                // menampilkan daftar transaksi terbaru
                                _buildRecentTransactions(),

                                const SizedBox(height: 16.0),

                                // menyusun bagian bantuan pengguna
                                _buildHelpSection(),
                              ],
                            ),
                          ),
                        ),
            ),

            // membuat navigasi bagian bawah
            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  // membuat komponen app bar
  Widget _buildAppBar() {
    return Container(
      color: const Color(0xFF1F2937), // Main dark color for app bar
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 16.0,
        horizontal: 16.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Koperasi Undiksha',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.share,
              color: Colors.white,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  // menampilkan pesan kesalahan
  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Color(0xFF1F2937),
              size: 80.0,
            ),
            const SizedBox(height: 16.0),
            Text(
              _errorMessage ?? 'Terjadi kesalahan',
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Coba Lagi'),
            ),
            const SizedBox(height: 12.0),
            TextButton(
              onPressed: _logout,
              child: const Text('Kembali ke Login'),
            ),
          ],
        ),
      ),
    );
  }

  // membuat kartu informasi profil pengguna
  Widget _buildUserProfileCard() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          // gambar pengguna
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.asset(
              'assets/images/user.png',
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16.0),

          // informasi pengguna
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nasabah',
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _authService.currentUser?.name ?? 'Pengguna',
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: const Color(
                        0xFF374151), // Lighter shade for balance box
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Saldo Anda',
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        CurrencyFormatter.format(_account?.balance ?? 0),
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // menyusun menu dalam bentuk grid
  Widget _buildMenuGrid() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 3,
        mainAxisSpacing: 16.0,
        crossAxisSpacing: 16.0,
        children: [
          _buildMenuItem(
            icon: Icons.account_balance_wallet,
            label: 'Cek Saldo',
            onTap: () {
              _showBalanceDialog();
            },
          ),
          _buildMenuItem(
            icon: Icons.swap_horiz,
            label: 'Transfer',
            onTap: () {
              if (_account != null) {
                _navigateToScreen(TransferScreen(account: _account!));
              }
            },
          ),
          _buildMenuItem(
            icon: Icons.savings,
            label: 'Deposito',
            onTap: () {
              if (_account != null) {
                _navigateToScreen(DepositScreen(account: _account!));
              }
            },
          ),
          _buildMenuItem(
            icon: Icons.payment,
            label: 'Pembayaran',
            onTap: () {
              if (_account != null) {
                _navigateToScreen(PaymentScreen(account: _account!));
              }
            },
          ),
          _buildMenuItem(
            icon: Icons.account_balance,
            label: 'Pinjaman',
            onTap: () {
              if (_account != null) {
                _navigateToScreen(LoanScreen(account: _account!));
              }
            },
          ),
          _buildMenuItem(
            icon: Icons.history,
            label: 'Mutasi',
            onTap: () {
              if (_account != null) {
                _navigateToScreen(TransactionHistoryScreen(account: _account!));
              }
            },
          ),
        ],
      ),
    );
  }

  // menampilkan daftar transaksi terbaru
  Widget _buildRecentTransactions() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Transaksi Terbaru',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  if (_account != null) {
                    _navigateToScreen(
                        TransactionHistoryScreen(account: _account!));
                  }
                },
                child: const Text(
                  'Lihat Semua',
                  style: TextStyle(
                    color: Color(0xFF374151),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          _recentTransactions.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Belum ada transaksi',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _recentTransactions.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    return TransactionItem(
                      transaction: _recentTransactions[index],
                    );
                  },
                ),
        ],
      ),
    );
  }

  // menyusun bagian bantuan pengguna
  Widget _buildHelpSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Butuh Bantuan?',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8.0),
          Row(
            children: [
              Text(
                '0878-1234-1024',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(width: 16.0),
              InkWell(
                onTap: () {
                  // call phone number
                },
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1F2937),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.phone,
                    color: Colors.white,
                    size: 24.0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // membuat navigasi bagian bawah
  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4B5563)
                .withOpacity(0.3), // Shadow color for bottom nav
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildBottomNavItem(
            icon: Icons.settings,
            label: 'Setting',
            onTap: () {
              _navigateToScreen(const SettingsScreen());
            },
          ),
          _buildQrButton(context),
          _buildBottomNavItem(
            icon: Icons.person,
            label: 'Profile',
            onTap: () {
              _navigateToScreen(const ProfileScreen());
            },
          ),
        ],
      ),
    );
  }

  // membuat item menu dengan ikon dan label
  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: const Color(0xFF1F2937), // Dark background for menu items
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Icon(
              icon,
              color: Colors.white, // Updated color
              size: 28.0,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF424769), // Updated color
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // membuat item navigasi bawah
  Widget _buildBottomNavItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: const Color(0xFF1F2937),
          ),
          const SizedBox(height: 4.0),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.0,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  // membuat tombol scan qr code
  Widget _buildQrButton(BuildContext context) {
    return InkWell(
      onTap: () {
        // QR code functionality
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1F2937),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16.0),
        child: const Icon(
          Icons.qr_code,
          color: Colors.white,
          size: 28.0,
        ),
      ),
    );
  }

  // menampilkan dialog informasi saldo
  void _showBalanceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Informasi Saldo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Saldo Anda saat ini:'),
            const SizedBox(height: 8.0),
            Text(
              CurrencyFormatter.format(_account?.balance ?? 0),
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              'Tutup',
              style: TextStyle(color: Color(0xFF1F2937)),
            ),
          ),
        ],
      ),
    );
  }
}
