class Game {
  int id;
  String title;
  String description;
  String boxColor;
  int mediaId;
  String platform;
  String genres; //List of genres joined by commas
  int maxPlayers;
  String developer;
  String publisher;
  String region;
  String file;
  DateTime? releaseDate = DateTime.now();
  double rating;
  int favorite; //boolean
  int playTime;
  DateTime? lastPlayed = DateTime.now();
  String tags; //List of tags joined by commas also

  Game({
    this.id = 0,
    required this.title,
    this.description = '',
    this.boxColor = '',
    this.mediaId = 0,
    this.platform = '',
    this.genres = '',
    this.maxPlayers = 1,
    this.developer = '',
    this.publisher = '',
    this.region = '',
    this.file = '',
    this.releaseDate,
    this.rating = 0.0,
    this.favorite = 0,
    this.playTime = 0,
    this.lastPlayed,
    this.tags = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'boxColor': boxColor,
      'mediaId': mediaId,
      'platform': platform,
      'genres': genres,
      'maxPlayers': maxPlayers,
      'developer': developer,
      'publisher': publisher,
      'region': region,
      'file': file,
      'releaseDate': releaseDate?.toLocal(),
      'rating': rating,
      'favorite': favorite,
      'playTime': playTime,
      'lastPlayed': lastPlayed?.toLocal(),
      'tags': tags,
    };
  }

  @override
  String toString() {
    return 'Game{id: $id, title: $title, description: $description,boxColor: $boxColor, mediaId: $mediaId, platform: $platform, genres: $genres, maxPlayers: $maxPlayers, developer: $developer, publisher: $publisher, region: $region, file: $file, releaseDate: $releaseDate, rating: $rating, favorite: $favorite, playTime: $playTime, lastPlayed: $lastPlayed, tags: $tags}';
  }

  static Game fromMap(Map<String, dynamic> map) {
    return Game(
      id: map['id'] ?? 0,
      title: map['title'] ?? '',
      description: map['description'],
      boxColor: map['boxColor'] ?? '',
      mediaId: map['mediaId'] ?? '',
      platform: map['platform'] ?? '',
      genres: map['genres'] ?? '',
      maxPlayers: map['maxPlayers'] ?? '',
      developer: map['developer'] ?? '',
      publisher: map['publisher'] ?? '',
      region: map['region'] ?? '',
      file: map['file'] ?? '',
      releaseDate: map['releaseDate'] ?? DateTime.now(),
      rating: map['rating'] ?? '',
      favorite: map['favorite'] ?? '',
      playTime: map['playTime'] ?? '',
      lastPlayed: map['lastPlayed'] ?? DateTime.now(),
      tags: map['tags'] ?? '',
    );
  }
}
