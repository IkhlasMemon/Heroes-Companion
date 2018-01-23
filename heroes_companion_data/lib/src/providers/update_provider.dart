import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:heroes_companion_data/src/api/DTO/update_info.dart';
import 'package:heroes_companion_data/src/api/DTO/update_payload.dart';
import 'package:heroes_companion_data/src/data_provider.dart';
import 'package:heroes_companion_data/src/models/ability.dart';
import 'package:heroes_companion_data/src/models/hero.dart';
import 'package:heroes_companion_data/src/models/talent.dart';
import 'package:sqflite/sqflite.dart';
import 'package:heroes_companion_data/src/tables/ability_table.dart'
    as ability_table;
import 'package:heroes_companion_data/src/tables/hero_table.dart' as hero_table;
import 'package:heroes_companion_data/src/tables/talent_table.dart'
    as talent_table;
import 'package:heroes_companion_data/src/api/api.dart' as api;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:heroes_companion_data/src/shared_preferences_keys.dart'
    as pref_keys;

class UpdateProvider {
  Database _database;
  UpdateProvider(this._database);

  Future<bool> doesNeedUpdate() {
    return new Future.sync(() async {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String unparsedId = (preferences.getString(pref_keys.update_id) ?? '');
      DateTime currentId =
          unparsedId == '' ? new DateTime(1970) : DateTime.parse(unparsedId);
      UpdateInfo updateInfo = await api.getUpdateInfo();
      return updateInfo.id.isAfter(currentId);
    });
  }

  Future doUpdate() async {
    debugPrint('Doing Update!');
    UpdatePayload updatePayload = await api.getUpdate();
    Stopwatch stopwatch = new Stopwatch()..start();

    // Hero Update
    List<Map<String, dynamic>> existingHeroes = await _database.query(
        hero_table.table_name,
        columns: [hero_table.column_hero_id, hero_table.column_sha3_256, hero_table.column_heroes_companion_hero_id]);
    await Future.wait(updatePayload.heroes.map((Hero hero) async {
    Map<String, dynamic> existingHero = existingHeroes
        .firstWhere((h) => h[hero_table.column_hero_id] == hero.hero_id, orElse: () => {});
    return _updateHero(hero, existingHero);
    }));


    // Section: Update a hero's have assets property if any of its talents have changed
    // Group talents by heroes
    Map<int, List<Talent>> talentsByHeroId =
        groupBy(updatePayload.talents, (Talent t) => t.hero_id);
    Function equals = const UnorderedIterableEquality().equals;
    List<int> needAssetUpdate = await Future.wait(talentsByHeroId.keys.map(
        (int heroId) => _findNeedAssetUpdate(talentsByHeroId, heroId, equals)));
    await _database.update(
        hero_table.table_name,
        {
          hero_table.column_modified_date:  new DateTime.now().toIso8601String(),
          hero_table.column_have_assets: 0
        },
        where: "${hero_table.column_hero_id} IN (?)",
        whereArgs: [needAssetUpdate.join(',')]);

    debugPrint('${stopwatch.elapsed} Starting Talent Update');
    // Talent update
    List<Map<String, dynamic>> existingTalents = await _database
        .query(talent_table.table_name, columns: [talent_table.column_id, talent_table.column_hero_id, talent_table.column_tool_tip_id, talent_table.column_sha3_256]);
    await Future.wait(updatePayload.talents.map((Talent talent) async {
    Map<String, dynamic> existingTalent = existingTalents.firstWhere((t) =>
        t[talent_table.column_tool_tip_id] == talent.tool_tip_id &&
        t[talent_table.column_hero_id] == talent.hero_id, orElse: () => {});
    return _updateTalent(talent, existingTalent);
    }));

    debugPrint('${stopwatch.elapsed} Talent Update Done');

    // Ability update
    List<Map<String, dynamic>> abilities = await _database
        .query(ability_table.table_name, columns: [ability_table.column_id, ability_table.column_ability_id, ability_table.column_sha3_256]);
    await Future.wait(updatePayload.abilities.map((Ability ability) async {
    Map<String, dynamic> existingAbilities = abilities.firstWhere(
        (a) => a[ability_table.column_ability_id] == ability.ability_id, orElse: () => {});
    return _updateAbility(ability, existingAbilities);
    }));

    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(
        pref_keys.update_id, updatePayload.id.toIso8601String());
    debugPrint('${stopwatch.elapsed} elapsed');
    debugPrint('Update done');
  }

  Future _updateHero(Hero hero, Map<String, dynamic> existingHero)  {
    if (existingHero == null || !existingHero.containsKey(hero_table.column_heroes_companion_hero_id) || existingHero[hero_table.column_heroes_companion_hero_id] == null) {
      return _database.insert(hero_table.table_name, hero.toUpdateMap());
    } else if (!existingHero.containsKey(hero_table.column_sha3_256) || existingHero[hero_table.column_sha3_256] != hero.sha3_256) {
      return _database.update(hero_table.table_name, hero.toUpdateMap(),
          where: "${hero_table.column_heroes_companion_hero_id} = ?",
          whereArgs: [
            existingHero[hero_table.column_heroes_companion_hero_id]
          ]);
    }
    return new Future.value();
  }

  // TODO change this to handle talents images on a talent by talent basis
  Future<int> _findNeedAssetUpdate(Map<int, List<Talent>> talentsByHeroId,
      int heroId, Function equals) async {
    List<Talent> talents = talentsByHeroId[heroId];
    List<Talent> existingTalents =
        await DataProvider.talentProvider.getTalentsForHero(heroId);
    if (existingTalents != null &&
            existingTalents.isNotEmpty &&
            // Do SHA comparison
            (existingTalents.first.sha3_256 != null &&
                existingTalents.first.sha3_256 != '' &&
                !equals(talents.map((t) => t.sha3_256),
                    existingTalents.map((t) => t.sha3_256))) ||
        // Do regular comparison
        !equals(talents, existingTalents)) {
      return heroId;
    } else {
      return null;
    }
  }

  Future _updateTalent(
    Talent talent, Map<String, dynamic> existingTalent) {
    if (existingTalent == null || !existingTalent.containsKey(talent_table.column_id) || existingTalent[talent_table.column_id] == null) {
      return _database.insert(talent_table.table_name, talent.toUpdateMap());
    } else if (!existingTalent.containsKey(talent_table.column_sha3_256) || existingTalent[talent_table.column_sha3_256] !=
        talent.sha3_256) {
      return _database.update(talent_table.table_name, talent.toUpdateMap(),
          where: "${talent_table.column_id} = ?",
          whereArgs: [existingTalent[talent_table.column_id]]);
    }
    return new Future.value();
  }

  Future _updateAbility(
      Ability ability, Map<String, dynamic> existingAbility) {
    if (existingAbility == null || !existingAbility.containsKey(ability_table.column_id)) {
      return _database.insert(ability_table.table_name, ability.toUpdateMap());
    } else if (!existingAbility.containsKey(ability_table.column_sha3_256) || existingAbility[ability_table.column_sha3_256] !=
        ability.sha3_256) {
      return _database.update(ability_table.table_name, ability.toUpdateMap(),
          where: "${ability_table.column_id} = ?",
          whereArgs: [existingAbility[ability_table.column_ability_id]]);
    }
    return new Future.value();
  }
}
