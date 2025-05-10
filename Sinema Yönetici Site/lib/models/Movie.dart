class Movie {
  final int movieID;
  final String movieName;
  final int? duration;
  final int? ratingCount;
  final String? movieGenre;
  final String? movieType;
  final String? description;
  final String? director;
  final double? customerRatings;
  final double? purchasePrice;
  final double? trendingPoint;
  final double? averagePoint;

  Movie({
    required this.movieID,
    required this.movieName,
    this.duration,
    this.movieGenre,
    this.movieType,
    this.ratingCount,
    this.customerRatings,
    this.purchasePrice,
    this.trendingPoint,
    this.averagePoint,
    this.description,
    this.director,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      movieID: json['movieID'],
      movieName: json['movieName'],
      duration: json['duration'],
      movieGenre: json['movieGenre'],
      movieType: json['movieType'],
      description: json['description'],
      director: json['director'],
      ratingCount: json['rating_count'],
      customerRatings: (json['customerRatings'] as num?)?.toDouble(),
      purchasePrice: (json['purchasePrice'] as num?)?.toDouble(),
      trendingPoint: (json['trendingPoint'] as num?)?.toDouble(),
      averagePoint: (json['averagePoint'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'movieID': movieID,
      'movieName': movieName,
      'duration': duration,
      'movieGenre': movieGenre,
      'movieType': movieType,
      'customerRatings': customerRatings,
      'purchasePrice': purchasePrice,
      'trendingPoint': trendingPoint,
      'averagePoint': averagePoint,
    };
  }
}
