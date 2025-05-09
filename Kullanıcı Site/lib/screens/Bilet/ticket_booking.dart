import 'package:cinema_app/models/Movie.dart';
import 'package:cinema_app/models/Session.dart';
import 'package:cinema_app/services/ApiConnection/Ticketing.dart';
import 'package:cinema_app/services/Auth/auth.dart';
import 'package:cinema_app/widgets/Loading.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../globals/globals.dart';
import 'seat_selection.dart';

class TicketBookingPage extends StatefulWidget {
  final Movie movie;
  const TicketBookingPage({
    Key? key,
    required this.movie,
  }) : super(key: key);

  @override
  State<TicketBookingPage> createState() => _TicketBookingPageState();
}

class _TicketBookingPageState extends State<TicketBookingPage> {
  List<Session> sessions = [];
  Map<DateTime, List<Session>> _availableShowtimes = {};
  int _selectedDayIndex = 0;
  Session? _selectedShowtime;
  late List<DateTime> _availableDays;
  final List<String> _showTimes = ['13:00', '16:00', '19:00'];

  @override
  void initState() {
    super.initState();
    _availableDays = [];
  }

  Map<DateTime, List<Session>> filterAndGroupSessionsByDate(List<Session> sessions) {
    final dateFormatter = DateFormat('yyyy-MM-dd');
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final Map<DateTime, List<Session>> groupedSessions = {};

    for (var session in sessions) {
      if (session.date != null) {
        try {
          final sessionDate = dateFormatter.parse(session.date!);
          if (sessionDate.isAfter(todayDate)) {
            final dateKey = DateTime(sessionDate.year, sessionDate.month, sessionDate.day);
            groupedSessions.putIfAbsent(dateKey, () => []);
            groupedSessions[dateKey]!.add(session);
          }
        } catch (e) {
          continue;
        }
      }
    }

    groupedSessions.forEach((date, sessionList) {
      sessionList.sort((a, b) {
        if (a.sessionNo == null || b.sessionNo == null) {
          return 0;
        }
        return a.sessionNo!.compareTo(b.sessionNo!);
      });
    });

    final sortedKeys = groupedSessions.keys.toList()..sort();
    final sortedMap = {for (var key in sortedKeys) key: groupedSessions[key]!};
    return sortedMap;
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Pzt';
      case 2:
        return 'Sal';
      case 3:
        return 'Çar';
      case 4:
        return 'Per';
      case 5:
        return 'Cum';
      case 6:
        return 'Cmt';
      case 7:
        return 'Paz';
      default:
        return '';
    }
  }

  String _formatDayDisplay(DateTime date) {
    final dateFormatter = DateFormat('dd MMM');
    final dayName = _getDayName(date.weekday);
    return '${dateFormatter.format(date)}\n$dayName';
  }

  Future<void> _fetchSessions() async {
      // Auth sınıfından session'ları çek
      sessions = await getSessions(widget.movie.movieID) ?? [];
      _availableShowtimes = filterAndGroupSessionsByDate(sessions);
      _availableDays = _availableShowtimes.keys.toList()..sort();
      setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bilet Al', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: Colors.black,
        child: Loadingscreen(
          task: _fetchSessions,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Film bilgisi
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        "$serverAddress/images/${widget.movie.movieID}",
                        width: 100,
                        height: 150,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 100,
                          height: 150,
                          color: Colors.grey,
                          child: const Icon(Icons.error, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.movie.movieName,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Format: ${widget.movie.movieType}', // Sabit 2D, veya movie.format varsa onu kullan
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Lütfen bir tarih ve seans seçin',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(color: Colors.grey),

              // Tarih seçimi
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tarih Seçin',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 80,
                      child: _availableDays.isEmpty
                          ? const Center(
                        child: Text(
                          'Uygun tarih bulunamadı',
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                          : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _availableDays.length,
                        itemBuilder: (context, index) {
                          final date = _availableDays[index];
                          final isSelected = _selectedDayIndex == index;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedDayIndex = index;
                                _selectedShowtime = null;
                              });
                            },
                            child: Container(
                              width: 70,
                              margin: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.red
                                    : Colors.grey.shade800,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  _formatDayDisplay(date),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.white70,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Seans seçimi
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Seans Seçin',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _selectedDayIndex >= _availableDays.length
                        ? const Text(
                      'Seans bulunamadı',
                      style: TextStyle(color: Colors.white70),
                    )
                        : Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _availableShowtimes[_availableDays[_selectedDayIndex]]!
                          .map((session) {
                        final isSelected = _selectedShowtime == session;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedShowtime = session;
                            });
                          },
                          child: Container(
                            width: 80,
                            height: 40,
                            decoration:BoxDecoration(
                          color: isSelected
                          ? Colors.red
                              : Colors.grey.shade800,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              _showTimes[int.parse(session.sessionNo!)],
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white70,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Devam et butonu
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _selectedShowtime != null
                        ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SeatSelectionPage(
                            session: _selectedShowtime!,
                            movie: widget.movie,
                          ),
                        ),
                      );
                    }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      disabledBackgroundColor: Colors.grey,
                    ),
                    child: const Text(
                      'Devam Et',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}