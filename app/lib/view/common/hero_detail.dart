import 'package:flutter/material.dart' hide Hero;
import 'package:heroes_companion/models/overflow_choices.dart';
import 'package:heroes_companion/view/common/app_loading_container.dart';
import 'package:heroes_companion/view/common/build_card.dart';
import 'package:heroes_companion/view/common/build_prompt.dart';
import 'package:heroes_companion/view/common/build_swiper.dart';
import 'package:heroes_companion/view/common/loading_view.dart';
import 'package:heroes_companion_data/heroes_companion_data.dart';
import 'package:hots_dog_api/hots_dog_api.dart' hide Talent;
import 'package:meta/meta.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HeroDetail extends StatefulWidget {
  final Hero hero;
  final bool isCurrentBuild;
  final bool canOfferPreviousBuild;
  final WinLossCount winLossCount;
  final BuildWinRates buildWinRates;
  final String buildNumber;
  final dynamic favorite;
  final dynamic buildSwitch;
  final String patchNotesUrl;

  HeroDetail(
    this.hero, {
    key,
    @required this.canOfferPreviousBuild,
    @required this.favorite,
    this.winLossCount,
    this.buildWinRates,
    this.isCurrentBuild,
    this.buildNumber,
    this.buildSwitch,
    this.patchNotesUrl
  })
      : super(key: key);

  @override
  _HeroDetailState createState() => new _HeroDetailState();
}

class _HeroDetailState extends State<HeroDetail> with SingleTickerProviderStateMixin {
  TabController _tabController;
  List<Tab> _tabs = new List<Tab>();

  @override
  void initState() {
    super.initState();
    _buildTabs();
    _tabController = new TabController(vsync: this, length: _tabs.length);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new AppLoading(builder: (context, loading) {
      if (loading) {
        return new LoadingView();
      }
      return _buildDetail(context);
    });
  }

  Widget _buildPhoneTitleRow(BuildContext context) {
    return new Container(
      key: new Key(widget.hero.name + '_title_row'),
      padding: new EdgeInsets.only(left: 64.0, bottom: 8.0),
      color: Theme.of(context).primaryColor,
      child: new Row(
        children: <Widget>[
          new CircleAvatar(
            backgroundImage: widget.hero.have_assets
                ? new AssetImage('assets/images/heroes/${widget.hero.icon_file_name}')
                : new CachedNetworkImageProvider(
                    'https://s3.eu-west-1.amazonaws.com/data.heroescompanion.com/images/heroes/${widget.hero.icon_file_name}'),
            radius: 45.0,
          ),
          new Container(
            width: 40.0,
          ),
          new Padding(
            padding: new EdgeInsets.only(top: 4.0),
            child: new Column(children: [
              new Text(widget.hero.name,
                  style: Theme
                      .of(context)
                      .textTheme
                      .headline
                      .apply(color: Colors.white)),
              new Text(
                '${widget.hero.type} ${widget.hero.role}',
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
                widget.winLossCount != null
                    ? '${widget.winLossCount.winPercentange().toStringAsFixed(1)} Win %'
                    : ' ',
                style: Theme
                    .of(context)
                    .textTheme
                    .headline
                    .apply(color: Colors.white),
              ),
              new Text(
                  widget.winLossCount != null
                      ? '${(widget.winLossCount.wins + widget.winLossCount.losses).toString()} games played'
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

  Widget _buildTabletTitleRow(BuildContext context) {
    return new Container(
      key: new Key(widget.hero.name + '_title_row'),
      padding: new EdgeInsets.only(left: 64.0, bottom: 8.0, top: 8.0),
      color: Theme.of(context).primaryColor,
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          // This is the avatar and name
          new Container(
            child: new Row(
              children: <Widget>[
                new CircleAvatar(
                  backgroundImage: widget.hero.have_assets
                      ? new AssetImage(
                          'assets/images/heroes/${widget.hero.icon_file_name}')
                      : new CachedNetworkImageProvider(
                          'https://s3.eu-west-1.amazonaws.com/data.heroescompanion.com/images/heroes/${widget.hero.icon_file_name}'),
                  radius: 45.0,
                ),
                new Padding(
                  padding: new EdgeInsets.only(top: 4.0)
                      .add(new EdgeInsets.only(left: 40.0)),
                  child: new Column(children: [
                    new Text(widget.hero.name,
                        style: Theme
                            .of(context)
                            .textTheme
                            .headline
                            .apply(color: Colors.white)),
                    new Text(
                      '${widget.hero.type} ${widget.hero.role}',
                      style: Theme
                          .of(context)
                          .textTheme
                          .subhead
                          .apply(color: Colors.white),
                    )
                  ]),
                )
              ],
            ),
          ),
          // This is the winrate and number of games played
          new Padding(
            padding: new EdgeInsets.only(top: 4.0, right: 20.0),
            child: new Column(
              children: <Widget>[
                new Text(
                  widget.winLossCount != null
                      ? '${widget.winLossCount.winPercentange().toStringAsFixed(1)} Win %'
                      : ' ',
                  style: Theme
                      .of(context)
                      .textTheme
                      .headline
                      .apply(color: Colors.white),
                ),
                new Text(
                    widget.winLossCount != null
                        ? '${(widget.winLossCount.wins + widget.winLossCount.losses).toString()} games played'
                        : ' ',
                    style: Theme
                        .of(context)
                        .textTheme
                        .body1
                        .apply(color: Colors.white))
              ],
            ),
          )
        ],
      ),
    );
  }

  void _playBuild(BuildContext context, BuildStatistics buildStatistics) {
    Navigator.of(context).push(new PageRouteBuilder(
                              pageBuilder: (context, a1, a2) => new BuildSwiper(
                                    widget.hero,
                                    buildStatistics,
                                    key: new Key(
                                        '${widget.hero.name}_${build.hashCode}_build_swiper'),
                                  ),
                            ));
  }

  Widget _buildTalentCards(BuildContext context) {
    if (widget.buildWinRates != null) {
      // Map of build to build 'type'
      Map<BuildStatistics, String> classifiedBuilds = {};

      if (widget.buildWinRates.winning_builds != null) {
        List<BuildStatistics> interestingWinningBuilds =
            new List<BuildStatistics>.from(widget.buildWinRates.winning_builds
                .where((b) => b.talents_names.length == 7));
        if (interestingWinningBuilds.length > 0) {
          interestingWinningBuilds.forEach((BuildStatistics build) => classifiedBuilds[build] = 'Winning Build');
        }
      }

      if (widget.buildWinRates.popular_builds != null) {
        List<BuildStatistics> interestingPopularBuilds =
            new List<BuildStatistics>.from(widget.buildWinRates.popular_builds
                .where((b) => b.talents_names.length == 7));
        if (interestingPopularBuilds.length > 0) {
          interestingPopularBuilds.forEach((BuildStatistics build) => classifiedBuilds[build] = 'Popular Build');
        }
      }

      // Prevent duplicates (builds in popular *and* winning)
      List<BuildStatistics> builds = classifiedBuilds.keys.toSet().toList();
      // Sort builds by games played
      builds.sort((BuildStatistics a, BuildStatistics b) => -1 * a.total_games_played.compareTo(b.total_games_played));
      
      return new ListView(
        key: new Key(widget.hero.name + '_talent_rows'),
        children: builds.map((BuildStatistics b) => new BuildCard(b, classifiedBuilds[b], _playBuild, widget.hero, showTalentBottomSheet)).toList()
      );
    }
    //TODO Return empty state
    return new Container();
  }

  void showTalentBottomSheet(BuildContext context, Talent talent) {
    showModalBottomSheet<Null>(
        context: context,
        builder: (BuildContext context) {
          return new Container(
            key: new Key('${talent.tool_tip_id}_container'),
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
                        talent.have_asset
                            ? new Image.asset(
                                'assets/images/talents/${talent.icon_file_name}')
                            : new Image(
                                image: new CachedNetworkImageProvider(
                                    'https://s3.eu-west-1.amazonaws.com/data.heroescompanion.com/images/talents/${talent.icon_file_name}'))
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
        });
  }

  void _buildTabs() {
    this._tabs.add(new Tab(
      // key: new Key('build_tab'),
      text: 'Builds',
    ));
  }

  Widget _buildPhoneView(BuildContext context) {
    return new Container(
        child: new Column(
          children: <Widget>[
           widget.canOfferPreviousBuild ? new BuildPrompt(
              widget.isCurrentBuild,
              widget.winLossCount,
              widget.buildSwitch,
              key: new Key('${widget.hero.name}_previous_build_prompt'),
            ) : new Container(),
            _buildPhoneTitleRow(context),
            new Expanded(
              child: new TabBarView(
                controller: _tabController,
                key: new Key('${widget.hero.name}_tab_view'),
                children: <Widget>[
                  _buildTalentCards(context)
                ],
              ),
            )
            
          ],
        ));
  }

  Widget _buildTabletView(BuildContext context) {
    return new Column(
      children: <Widget>[
        widget.canOfferPreviousBuild ? new BuildPrompt(
              widget.isCurrentBuild,
              widget.winLossCount,
              widget.buildSwitch,
              key: new Key('${widget.hero.name}_previous_build_prompt'),
            ) : new Container(),
        _buildTabletTitleRow(context),
        new Expanded(child: _buildTalentCards(context))
      ],
    );
  }

  Widget _buildDetail(BuildContext context) {
    final List<OverflowChoice> overflowChoices = [OverflowChoice.HeroPatchNotes];
    return new Scaffold(
        appBar: new AppBar(
          title: new Text(widget.hero.name),
          actions: [
            new IconButton(
              tooltip: widget.hero.is_favorite
                  ? 'Unfavorite ${widget.hero.name}'
                  : 'Favorite ${widget.hero.name}',
              icon: new Icon(Icons.favorite,
                  color: widget.hero.is_favorite
                      ? Colors.red
                      : Theme.of(context).buttonColor),
              onPressed: () => widget.favorite(widget.hero),
            ),
            new PopupMenuButton(
                  onSelected: (OverflowChoice choice) => OverflowChoice
                      .handleChoice(choice, context, patchNotesUrl: widget.patchNotesUrl), // overflow menu
                  itemBuilder: (BuildContext context) {
                    return overflowChoices.map((OverflowChoice choice) {
                      return new PopupMenuItem(
                        value: choice,
                        child: new Text(choice.name),
                      );
                    }).toList();
                  },
                ),
          ],
        ),
        body: MediaQuery.of(context).size.width < 600
            ? _buildPhoneView(context)
            : _buildTabletView(context));
  }
}
