import 'package:heroes_companion/models/hero_filter.dart';
import 'package:heroes_companion_data/heroes_companion_data.dart';
import 'package:meta/meta.dart';
import 'package:hots_dog_api/hots_dog_api.dart';

@immutable
class AppState {
  final List<Hero> heroes;
  final List<Patch> patches;

  /// BuildNumber => WinRates
  final Map<String, WinRates> winRates;
  final bool isLoading;
  final bool heroBuildWinRatesLoading;
  final bool isUpdating;

  /// heroCompanionId => <BuildNumber, BuildWinRates>
  final Map<int, Map<String, BuildWinRates>> heroBuildWinRates;
  final String searchQuery;
  final HeroFilter filter;

  AppState({
    this.isLoading = false,
    this.heroBuildWinRatesLoading = false,
    this.isUpdating = false,
    this.heroes,
    this.patches,
    this.winRates,
    this.heroBuildWinRates,
    this.searchQuery = '',
    this.filter = HeroFilter.all
  });

  factory AppState.initial() => new AppState(
      isLoading: true, heroBuildWinRatesLoading: false, isUpdating: false);

  AppState copyWith({
    bool isLoading,
    Hero hero,
    List<Patch> patches,
    Map<String, WinRates> winRates,
    bool heroBuildWinRatesLoading,
    bool isUpdating,
    Map<int, Map<String, BuildWinRates>> heroBuildWinRates,
    String searchQuery,
    HeroFilter filter
  }) {
    return new AppState(
      isLoading: isLoading ?? this.isLoading,
      heroes: hero ?? this.heroes,
      patches: patches ?? this.patches,
      winRates: winRates ?? this.winRates,
      isUpdating: isUpdating ?? this.isUpdating,
      heroBuildWinRatesLoading: heroBuildWinRatesLoading ?? this.heroBuildWinRatesLoading,
      heroBuildWinRates: heroBuildWinRates ?? this.heroBuildWinRates,
      searchQuery: searchQuery ?? this.searchQuery,
      filter: filter ?? this.filter,
    );
  }

  @override
  int get hashCode =>
      isLoading.hashCode ^
      heroes.hashCode ^
      patches.hashCode ^
      winRates.hashCode ^
      heroBuildWinRatesLoading.hashCode ^
      heroBuildWinRates.hashCode ^
      searchQuery.hashCode ^
      isUpdating.hashCode ^
      filter.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppState &&
          runtimeType == other.runtimeType &&
          isLoading == other.isLoading &&
          heroes == other.heroes &&
          patches == other.patches &&
          winRates == other.winRates &&
          heroBuildWinRatesLoading == other.heroBuildWinRatesLoading &&
          heroBuildWinRates == other.heroBuildWinRates &&
          searchQuery == other.searchQuery &&
          isUpdating == other.isUpdating &&
          filter == other.filter;

  @override
  String toString() {
    return 'AppState{isLoading: $isLoading}';
  }
}
