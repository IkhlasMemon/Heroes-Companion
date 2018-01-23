import 'package:heroes_companion_data/src/models/ability.dart';
import 'package:heroes_companion_data/src/models/hero.dart';
import 'package:heroes_companion_data/src/models/talent.dart';

class UpdatePayload {
  final DateTime id;
  final String sha;
  final List<Hero> heroes;
  final List<Talent> talents;
  final List<Ability> abilities;

  UpdatePayload(this.date, this.sha, this.heroes, this.talents, this.abilities);

  factory UpdatePayload.fromJson(Object json) {
    if (!(json is Map)) {
      throw new Exception('Unexpected JSON format');
    }

    Map map = json;
    if (!(map['id'] is String &&
        map['heroes'] is List<Map> &&
        map['talents'] is List<Map> &&
        map['abilities'] is List<Map>)) {
      throw new Exception('Unexpected JSON format');
    }

    DateTime id = DateTime.parse(map['id']);
    String sha = map['sha'];
    List<Hero> heroes = map['heroes'].map((h) => new Hero.fromMap(h)).toList();
    List<Talent> talents =
        map['talents'].map((t) => new Talent.fromMap(t)).toList();
    List<Ability> abilities =
        map['abilities'].map((a) => new Ability.fromMap(a)).toList();
    return new UpdatePayload(id, sha, heroes, talents, abilities);
  }
}
