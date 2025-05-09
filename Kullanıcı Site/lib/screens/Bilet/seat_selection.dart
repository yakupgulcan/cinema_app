import 'package:cinema_app/models/Movie.dart';
import 'package:cinema_app/models/Session.dart';
import 'package:cinema_app/models/SessionSeat.dart';
import 'package:cinema_app/models/Ticket.dart';
import 'package:cinema_app/services/ApiConnection/Ticketing.dart';
import 'package:cinema_app/services/Auth/auth.dart';
import 'package:cinema_app/widgets/Loading.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cinema_app/globals/globals.dart';
import 'package:cinema_app/widgets/Loading.dart';
import 'package:provider/provider.dart';

import '../../providers/userProvider.dart';

class SeatSelectionPage extends StatefulWidget {
  final Session session;
  final Movie movie;

  const SeatSelectionPage({
    Key? key,
    required this.session,
    required this.movie,
  }) : super(key: key);

  @override
  State<SeatSelectionPage> createState() => _SeatSelectionPageState();
}

class _SeatSelectionPageState extends State<SeatSelectionPage> {
  late List<List<int>> _seatStatus; // 0: boş, 1: dolu, 2: seçili
  late int _rows;
  late int _cols;
  final Map<String, SessionSeat> _selectedSeats =
      {}; // Koltuk etiketi -> SessionSeat
  List<SessionSeat> _sessionSeats = [];

  Future<void> _fetchData() async {
    _sessionSeats = await getSessionSeats(widget.session.sessionID!) ?? [];

    _initializeSeatLayout();
    _initializeSeatStatus();
    setState(() {});
  }

  void _initializeSeatLayout() {
    // Sabit sütun sayısı: 10
    _cols = 20;
    // Satır sayısı: Toplam koltuk sayısına bağlı
    _rows = (_sessionSeats.length / _cols).ceil();
    // Koltuk durumlarını başlat
    _seatStatus = List.generate(_rows, (_) => List.filled(_cols, 0));
  }

  void _initializeSeatStatus() {
    // SessionSeat verilerinden koltuk durumlarını ayarla
    for (var i = 0; i < _sessionSeats.length; i++) {
      final seat = _sessionSeats[i];
      final row = i ~/ _cols;
      final col = i % _cols;

      if (row < _rows && col < _cols) {
        _seatStatus[row][col] = seat.isAvailable == true ? 0 : 1;
      }
    }
  }

  String _getRowLabel(int row) {
    return String.fromCharCode(65 + row); // A'dan başlayarak
  }

  void _toggleSeatSelection(int row, int col) {
    if (_seatStatus[row][col] == 1) return; // Dolu koltuk seçilemez

    setState(() {
      final seatLabel = '${_getRowLabel(row)}${col + 1}';
      // seatID'yi hesapla: (row * _cols) + col + 1
      final seatID = (row * _cols) + col;
      final sessionSeat = _sessionSeats[seatID];

      if (_seatStatus[row][col] == 0) {
        // Boş koltuğu seçili yap
        _seatStatus[row][col] = 2;
        _selectedSeats[seatLabel] = sessionSeat;
      } else {
        // Seçili koltuğu boş yap
        _seatStatus[row][col] = 0;
        _selectedSeats.remove(seatLabel);
      }
    });
  }

  Future<void> _purchaseTickets() async {
    // Seçilen koltukları sunucuya gönder
    final selectedSeatIDs =
        _selectedSeats.values.map((seat) => seat.sessionSeatID!).toList();
    var customerProvider =
        Provider.of<CustomerProvider>(context, listen: false);
    bool error = false;
    for (int seatID in selectedSeatIDs) {
      Ticket ticket = Ticket(
          customerID: customerProvider.customerID,
          sessionID: widget.session.sessionID,
          sessionSeatID: seatID);
      int? ticketId = await buyTicket(ticket: ticket);
      if (ticketId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bilet satın alınırken hata oluştu')),
        );
        error = true;
      }
    }

    if (!error) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${widget.movie.movieName} için ${_selectedSeats.length} adet bilet alındı. Koltuklar: ${_selectedSeats.keys.join(', ')}',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Koltuk Seçimi', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: Colors.black,
        child: Loadingscreen(
          task: _fetchData,
          child: _sessionSeats.isEmpty
              ? const Center(
                  child: Text(
                    'Veriler yüklenemedi',
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : Row(
            crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              "$serverAddress/images/${widget.session.movieID}",
                              width: 200,
                              height: 300,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                width: 200,
                                height: 300,
                                color: Colors.grey,
                                child: const Icon(Icons.error,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.movie.movieName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Salon: ${widget.session.hallID! + 1} ',
                                style: const TextStyle(color: Colors.white70),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${DateFormat('dd MMM yyyy').format(DateFormat('yyyy-MM-dd').parse(widget.session.date!))} - ${widget.session.sessionNo}',
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.8,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade800,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(100),
                                topRight: Radius.circular(100),
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                'PERDE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Koltuk açıklamaları
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildLegendItem(Colors.grey.shade600, 'Boş'),
                                const SizedBox(width: 16),
                                _buildLegendItem(Colors.red, 'Dolu'),
                                const SizedBox(width: 16),
                                _buildLegendItem(Colors.green, 'Seçili'),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Koltuk düzeni
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  // Sütun numaraları
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        ...List.generate(_cols, (col) {
                                          return Container(
                                            width: 24,
                                            height: 24,
                                            margin: const EdgeInsets.all(2),
                                            alignment: Alignment.center,
                                            child: Text(
                                              '${col + 1}',
                                              style: const TextStyle(
                                                  color: Colors.white),
                                            ),
                                          );
                                        }),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  // Koltuklar
                                  ...List.generate(_rows, (row) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 5),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 20,
                                            child: Text(
                                              _getRowLabel(row),
                                              style: const TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                          ...List.generate(_cols, (col) {
                                            return GestureDetector(
                                              onTap: () => _toggleSeatSelection(
                                                  row, col),
                                              child: Container(
                                                margin: const EdgeInsets.all(2),
                                                width: 24,
                                                height: 24,
                                                decoration: BoxDecoration(
                                                  color:
                                                      _getSeatColor(row, col),
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                ),
                                                child: Icon(
                                                  Icons.chair,
                                                  size: 16,
                                                  color: _getSeatIconColor(
                                                      row, col),
                                                ),
                                              ),
                                            );
                                          }),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ),

                          // Seçilen koltuklar ve bilet al butonu
                          Container(
                            padding: const EdgeInsets.all(16),
                            color: Colors.grey.shade900,
                            child: Column(
                              children: [
                                if (_selectedSeats.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: Text(
                                      'Seçilen Koltuklar: ${_selectedSeats.keys.join(', ')}',
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _selectedSeats.isNotEmpty
                                        ? _purchaseTickets
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 15),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      disabledBackgroundColor: Colors.grey,
                                    ),
                                    child: const Text(
                                      'BİLET AL',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
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
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Icon(
            Icons.chair,
            size: 14,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.white)),
      ],
    );
  }

  Color _getSeatColor(int row, int col) {
    switch (_seatStatus[row][col]) {
      case 0:
        return Colors.grey.shade600; // Boş
      case 1:
        return Colors.red; // Dolu
      case 2:
        return Colors.green; // Seçili
      default:
        return Colors.grey.shade600;
    }
  }

  Color _getSeatIconColor(int row, int col) {
    return Colors.white.withOpacity(0.7);
  }
}
