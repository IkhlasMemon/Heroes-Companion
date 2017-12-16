import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Hero;
import 'package:heroes_companion_data/heroes_companion_data.dart';

class HeroGridItem extends StatelessWidget {
  final dynamic onTap;
  final Hero hero;

  HeroGridItem({
    this.onTap,
    @required this.hero,
  });

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
        onTapUp: (TapUpDetails tap) => this.onTap(context, this),
        child: 
          new Container(
            padding: new EdgeInsets.symmetric(vertical: 8.0),
            child: new Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                new Image.asset('assets/images/heroes/${hero.icon_file_name}'),
                new Container(
                  height: 4.0,
                ),
                new Text(hero.name,
                    style: new TextStyle(
                      fontSize: 18.0,
                    )),
                new Text(hero.role),
                new Container(
                  margin: new EdgeInsets.only(top: 8.0),
                  height: 2.0,
                  width: 18.0,
                  color: Colors.deepPurpleAccent
                )
            ],
          ),
        )
      );
  }
}
