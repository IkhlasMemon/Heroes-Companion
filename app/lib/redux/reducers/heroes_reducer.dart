import 'package:heroes_companion_data/heroes_companion_data.dart';
import 'package:redux/redux.dart';
import 'package:heroes_companion/redux/actions/actions.dart';

final heroesReducer = combineTypedReducers<List<Hero>>([
  new ReducerBinding<List<Hero>, FetchHeroesSucceededAction>(_setLoadedHeroes),
  new ReducerBinding<List<Hero>, UpdateHeroAction>(_updateHero),
]);

List<Hero> _setLoadedHeroes(
    List<Hero> hero, FetchHeroesSucceededAction action) {
  return action.heroes;
}

List<Hero> _updateHero(List<Hero> heroes, UpdateHeroAction action) {
  return heroes
      .map((Hero hero) =>
          hero.hero_id == action.hero.hero_id ? action.hero : hero)
      .toList();
}
