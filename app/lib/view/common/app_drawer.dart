import 'package:flutter/material.dart';
import 'package:heroes_companion/routes.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Drawer(
              child: new ListView(
                children: <Widget>[
                  new DrawerHeader(
                    decoration: new BoxDecoration(
                      color: Theme.of(context).primaryColor
                    ),
                    child: new Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        new Text('Heroes Companion', style: Theme.of(context).textTheme.title.apply(color: Colors.white, fontSizeFactor: 1.2),),
                      ],
                    )
                  ),
                  new ListTile(
                    leading: new Icon(Icons.supervisor_account),
                    title: new Text('Heroes'),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushNamed(Routes.home);
                    },
                  ),
                  new ListTile(
                    leading: new Icon(Icons.dashboard),
                    title: new Text('Maps'),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushNamed(Routes.maps);
                    },
                  )
                ],
              ),
            );
  }
}