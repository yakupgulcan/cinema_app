import 'package:flutter/material.dart';
import 'package:sinema_yonetim_sistemi/models/CinemaHall.dart';
import 'package:sinema_yonetim_sistemi/models/Movie.dart';
import 'package:sinema_yonetim_sistemi/models/Session.dart';
import 'package:sinema_yonetim_sistemi/services/ApiConnection/GetMovies.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:sinema_yonetim_sistemi/widgets/Loading.dart';
import 'package:sinema_yonetim_sistemi/services/ApiConnection/Sessions.dart';
import 'package:intl/intl.dart';

import '../../services/ApiConnection/CinemaHall.dart';

class SessionPage extends StatefulWidget {
  @override
  _SessionPageState createState() => _SessionPageState();
}

class _SessionPageState extends State<SessionPage> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  List<Hall> _salons = [];
  final List<String> _sessionTimes = ['13:00', '16:00', '19:00'];
  List<Movie> _movies = [];
  List<Session?> _sessions = [];

  UniqueKey _key = UniqueKey();

  Future<void> _initializeSessionData() async {
    _sessions = await getSessionsByDate(
          DateFormat('yyyy-MM-dd').format(_selectedDay),
        ) ??
        [];
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    setmovies();
  }

  void setmovies() async {
    _movies = await getMovies(null) ?? [];
    setState(() {});
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _key = UniqueKey();
    });
  }

  void _previousDay() {
    setState(() {
      _selectedDay = _selectedDay.subtract(Duration(days: 1));
      _focusedDay = _selectedDay;
      _key = UniqueKey();
    });
  }

  void _nextDay() {
    setState(() {
      _selectedDay = _selectedDay.add(Duration(days: 1));
      _focusedDay = _selectedDay;
      _key = UniqueKey();
    });
  }

  void _onSessionTap(Hall salon, int sessionIndex, Session? session) {
    if(session == null)
      _showMovieSelectionDialog(salon, sessionIndex);
    else
      _cancelSession(salon, sessionIndex, session);
  }

  void _cancelSession(Hall salon, int sessionIndex, Session session) async {
    await deleteSession(session.sessionID!);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              '${salon.hallName} - ${_sessionTimes[sessionIndex]} seansı iptal edildi.')),
    );
    setState(() {
      _key = UniqueKey();
    });
  }

  void _showMovieSelectionDialog(Hall salon, int sessionIndex) {
    showDialog(
      context: context,
      builder: (ctx) {
        return MovieSelectionDialog(
          movies: _movies,
          onMovieSelected: (movie) async{
            if(movie.movieType == '3D' && salon.hallType != '3D'){
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Seçilen film 3D özelliktedir. Yalnızca 3D destekli bir salonda oynatılabilir.'),
                ),
              );
            }
            else{
              await createSession(movieID: movie.movieID, hallId: salon.hallID!, date: DateFormat('yyyy-MM-dd').format(_selectedDay), sessionNo: sessionIndex.toString());
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      '${salon.hallName} - ${_sessionTimes[sessionIndex]} için ${movie.movieName} seçildi.'),
                ),
              );
              setState(() {
                _key = UniqueKey();
              });
            }

          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Seans Yönetimi')),
      body: Loadingscreen(
        task: () async{
          _salons = await getCinemaHalls() ?? [];
          setState(() {});
        },
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2023, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: _onDaySelected,
              calendarFormat: CalendarFormat.week,
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _previousDay,
                    child: Text('Önceki Gün'),
                  ),
                  Text(
                    DateFormat('dd MMMM yyyy').format(_selectedDay),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton(
                    onPressed: _nextDay,
                    child: Text('Sonraki Gün'),
                  ),
                ],
              ),
            ),
            Loadingscreen(
              key: _key,
              task: () async {
                await _initializeSessionData();
              },
              child: Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.all(8),
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    childAspectRatio: 1,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _salons.length,
                  itemBuilder: (context, index) {
                    Hall salon = _salons[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                salon.hallName!,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if(salon.hallType == '3D')
                              Text(
                                " (3D destekli)",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w100,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Column(
                            children: List.generate(_sessionTimes.length,
                                (sessionIndex) {
                              Session? session;
                              Movie? movie;
                                  try {
                                    session = _sessions.firstWhere((sess) =>
                                          sess!.hallID == index+1 &&
                                          sess.date == DateFormat('yyyy-MM-dd').format(_selectedDay) &&
                                          sess.sessionNo == sessionIndex.toString(),
                                    );
                                    movie = _movies.firstWhere(
                                            (movie) => movie.movieID == session!.movieID);
                                  } catch (e) {
                                  }
                              return GestureDetector(
                                onTap: () => _onSessionTap(salon, sessionIndex, session),
                                child: Container(
                                  margin: EdgeInsets.symmetric(vertical: 4),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: session != null
                                        ? Colors.red
                                        : Colors.green,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        _sessionTimes[sessionIndex],
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                      if (session != null && movie != null)
                                        Text(
                                          movie.movieName,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontStyle: FontStyle.italic,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MovieSelectionDialog extends StatefulWidget {
  final List<Movie> movies;
  final Function(Movie) onMovieSelected;

  MovieSelectionDialog({required this.movies, required this.onMovieSelected});

  @override
  _MovieSelectionDialogState createState() => _MovieSelectionDialogState();
}

class _MovieSelectionDialogState extends State<MovieSelectionDialog> {
  String _searchQuery = '';
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredMovies = widget.movies
        .where((movie) =>
            movie.movieName.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return AlertDialog(
      title: Text('Film Seç'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Film ara...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Container(
            constraints: BoxConstraints(maxHeight: 300),
            child: SingleChildScrollView(
              child: Column(
                children: filteredMovies.isEmpty
                    ? [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Sonuç bulunamadı'),
                        )
                      ]
                    : filteredMovies
                        .map((movie) => ListTile(
                              title: Text(movie.movieName),
                              onTap: () {
                                widget.onMovieSelected(movie);
                                Navigator.pop(context);
                              },
                            ))
                        .toList(),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('İptal'),
        ),
      ],
    );
  }
}
