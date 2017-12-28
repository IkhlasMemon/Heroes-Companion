import 'package:flutter/material.dart' hide Hero;
import 'package:heroes_companion/view/common/app_loading_container.dart';
import 'package:heroes_companion/view/common/build_prompt.dart';
import 'package:heroes_companion/view/common/build_swiper.dart';
import 'package:heroes_companion/view/common/loading_view.dart';
import 'package:heroes_companion_data/heroes_companion_data.dart';
import 'package:hots_dog_api/hots_dog_api.dart' hide Talent;
import 'package:meta/meta.dart';

class HeroDetail extends StatelessWidget {
  final Hero hero;
  final bool isCurrentBuild;
  final WinLossCount winLossCount;
  final BuildWinRates buildWinRates;
  final String buildNumber;
  final dynamic favorite;
  final dynamic buildSwitch;

  HeroDetail(
    this.hero, {
    key,
    @required this.favorite,
    this.winLossCount,
    this.buildWinRates,
    this.isCurrentBuild,
    this.buildNumber,
    this.buildSwitch,
  })
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new AppLoading(builder: (context, loading) {
      return loading ? new LoadingView() : _buildDetail(context);
    });
  }

  Widget _buildTitleRow(BuildContext context) {
    return new Container(
      key: new Key(hero.name + '_title_row'),
      padding: new EdgeInsets.only(left: 64.0, bottom: 8.0),
      color: Theme.of(context).primaryColor,
      child: new Row(
        children: <Widget>[
          new CircleAvatar(
            backgroundImage: new AssetImage(
                'assets/images/heroes/${hero.icon_file_name}'),
            radius: 45.0,
          ),
          new Container(
            width: 40.0,
          ),
          new Padding(
            padding: new EdgeInsets.only(top: 4.0),
            child: new Column(children: [
              new Text(hero.name,
                  style: Theme
                      .of(context)
                      .textTheme
                      .headline
                      .apply(color: Colors.white)),
              new Text(
                '${hero.type} ${hero.role}',
                style: Theme
                    .of(context)
                    .textTheme
                    .subhead
                    .apply(color: Colors.white),
              ),
              new Container(
                height: 20.0,
              ),
              new Text(
                winLossCount != null
                    ? '${winLossCount.winPercentange().toStringAsFixed(1)} Win %'
                    : ' ',
                style: Theme
                    .of(context)
                    .textTheme
                    .headline
                    .apply(color: Colors.white),
              ),
              new Text(
                  winLossCount != null
                      ? '${(winLossCount.wins + winLossCount.losses).toString()} games played'
                      : ' ',
                  style: Theme
                      .of(context)
                      .textTheme
                      .body1
                      .apply(color: Colors.white))
            ]),
          )
        ],
      ),
    );
  }

  Widget _buildTalentRows(BuildContext context) {
    if (buildWinRates != null) {
      List<Widget> children = [];
      if (buildWinRates.winning_builds != null) {
        List<BuildStatistics> interestingWinningBuilds =
            new List<BuildStatistics>.from(buildWinRates.winning_builds
                .where((b) => b.talents_names.length == 7));
        if (interestingWinningBuilds.length > 0) {
          children.add(new ListView(
            children: interestingWinningBuilds
                .map((b) => _buildTalentRow(context, b))
                .toList(),
          ));
        }
      }

      if (buildWinRates.popular_builds != null) {
        List<BuildStatistics> interestingPopularBuilds =
            new List<BuildStatistics>.from(buildWinRates.popular_builds
                .where((b) => b.talents_names.length == 7));
        if (interestingPopularBuilds.length > 0) {
          children.add(new ListView(
            children: interestingPopularBuilds
                .map((b) => _buildTalentRow(context, b))
                .toList(),
          ));
        }
      }
      return new TabBarView(
        key: new Key(hero.name + '_talent_rows'),
        children: children,
      );
    }
    return new Container();
  }

  Widget _buildTalentRow(BuildContext context, BuildStatistics build) {
    return new Padding(
        key: new Key('${hero.name}_talent_row_${build.hashCode}'),
        padding: new EdgeInsets.all(4.0),
        child: new Column(
          children: [
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new Padding(
                  padding: new EdgeInsets.symmetric(horizontal: 4.0),
                  child: new Text(
                      '${(build.win_rate * 100).toStringAsFixed(2)} Win %'),
                ),
                new Padding(
                  padding: new EdgeInsets.symmetric(horizontal: 4.0),
                  child: new Text('${build.total_games_played} Games Played'),
                ),
                new Padding(
                    padding: new EdgeInsets.symmetric(horizontal: 4.0),
                    child: new IconButton(
                        icon: new Icon(Icons.play_circle_filled),
                        onPressed: () {
                          Navigator.of(context).push(new PageRouteBuilder(
                                pageBuilder: (context, a1, a2) =>
                                    new BuildSwiper(
                                      hero,
                                      build,
                                      key: new Key(
                                          '${hero.name}_${build.hashCode}_build_swiper'),
                                    ),
                              ));
                        }))
              ],
            ),
            new Container(
              height: 4.0,
            ),
            new Padding(
              padding: new EdgeInsets.symmetric(horizontal: 8.0),
              child: new Row(
                  children: build.talents_names
                      .map((a) => _buildTalent(context, a))
                      .toList()),
            ),
          ],
        ));
  }

  Widget _buildTalent(BuildContext context, String talentName) {
    Talent talent =
        hero.talents.firstWhere((t) => t.talent_tree_id == talentName);
    return new Flexible(
        child: new GestureDetector(
      onTap: () => showModalBottomSheet<Null>(
          context: context,
          builder: (BuildContext context) {
            return new Container(
              child: new Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: new Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Row(
                        children: <Widget>[
                          new Text(
                            talent.name,
                            style: Theme.of(context).textTheme.headline,
                          ),
                          new Image.asset(
                              'assets/images/talents/${talent.icon_file_name}')
                        ],
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      ),
                      new Container(
                        height: 16.0,
                      ),
                      new Text(talent.description)
                    ],
                  )),
            );
          }),
      child: new Image.asset(
        'assets/images/talents/${talent.icon_file_name}',
      ),
    ));
  }

  List<Widget> _buildTabs(BuildContext context) {
    List<Tab> tabs = new List<Tab>();
     if (buildWinRates != null && buildWinRates.winning_builds != null && buildWinRates.winning_builds.any((b) => b.talents_names.length == 7) ) {
      tabs.add(new Tab(
        key: new Key('winning_build_tab'),
        text: 'Winning Builds',
      ));
     }

     if (buildWinRates != null && buildWinRates.popular_builds != null && buildWinRates.popular_builds.any((b) => b.talents_names.length == 7)){
       tabs.add(new Tab(
        key: new Key('popular_build_tab'),
         text: 'Popular Builds',
       ));
     }

     return tabs;
  }

  Widget _buildDetail(BuildContext context) {
    List<Tab> tabs = _buildTabs(context);
    return new Scaffold(
        appBar: new AppBar(
          title: new Text(hero.name),
          actions: [
            new IconButton(
              tooltip: hero.is_favorite
                  ? 'Unfavorite ${hero.name}'
                  : 'Favorite ${hero.name}',
              icon: new Icon(Icons.favorite,
                  color: hero.is_favorite
                      ? Colors.red
                      : Theme.of(context).buttonColor),
              onPressed: () => favorite(hero),
            ),
          ],
        ),
        body: new DefaultTabController(
            key: new Key('tab_controller_${tabs.hashCode}'),
            length: tabs.length,
            initialIndex: 0,
            child: new Column(
              children: <Widget>[
                new BuildPrompt(
                  isCurrentBuild,
                  winLossCount,
                  buildSwitch,
                  key: new Key('${hero.name}_previous_build_prompt'),
                ),
                _buildTitleRow(context),
                new TabBar(
                  key: new Key('tab_bar_${tabs.hashCode}'),
                  tabs: tabs,
                  labelColor: Theme.of(context).textTheme.body2.color,
                ),
                new Expanded(
                  child: _buildTalentRows(context),
                ),
              ],
            )));
  }
}
