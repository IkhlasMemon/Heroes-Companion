import 'package:meta/meta.dart';

/// TODO refactor this to use [HeroBuild] when it has changed to use [Talent] rather than a list of talent names
class Build {
  final List<String> talentTreeIds;
  final DateTime submitted;
  final int heroId;
  final String tagline;
  final String md5;
  final String id;

  // Not always present
  final String description;
  final String source;
  final String url;

  Build({@required this.talentTreeIds, @required this.submitted, @required this.heroId, this.tagline, @required this.md5, @required this.id, this.description, this.source, this.url});

  factory Build.fromJson(Object json) {
    if (!(json is Map)) {
      throw new Exception('Unexpected JSON format');
    }
    Map map = json;
    if (!( map['Submitted'] is String && map['_id'] is String && map['Talents'] is List && map['HeroId'] is int && map['Md5'] is String)) {
      throw new Exception('Unexpected JSON format');
    }

    DateTime submitted = DateTime.parse(map['Submitted']);
    int heroId = map['HeroId'];
    String id = map['_id'];
    String md5 = map['Md5'];

    String description;
    if (map.containsKey('Description')){
      description = map['Description'];
    }
    String source;
    if (map.containsKey('Source')){
      source = map['Source'];
    }
    String url;
    if (map.containsKey('Url')){
      url = map['Url'];
    }

    String tagline;
    if (map.containsKey('Tagline')) {
      tagline = map['Tagline'];
    }

    List<Map> talentInfo = map['Talents'];
    talentInfo.sort((a, b) => a['level'].compareTo(b['level']));
    List<String> talentTreeIds = talentInfo
        .map((talent) => talent['TalentTreeId'])
        .toList();
    
    return new Build(talentTreeIds: talentTreeIds, submitted: submitted, heroId: heroId, id: id, md5: md5, description: description, source: source, url: url, tagline: tagline);
  }
}