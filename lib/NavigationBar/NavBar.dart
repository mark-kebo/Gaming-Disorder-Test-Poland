import 'package:flutter/material.dart';

class NavBar extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _NavBarState();
  final Function mainTouched;
  final Function formsTouched;
  final Function statisticsTouched;
  final Function settingsTouched;

  NavBar(
      {this.mainTouched,
      this.formsTouched,
      this.settingsTouched,
      this.statisticsTouched});
}

class _NavBarState extends State<NavBar> {
  List<bool> selected = [true, false, false, false];

  void select(int n) {
    for (int i = 0; i < selected.length; i++) {
      if (i != n) {
        selected[i] = false;
      } else {
        selected[i] = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350.0,
      child: Column(
        children: [
          NavBarItem(
            active: selected[0],
            icon: Icons.apps,
            touched: () {
              setState(() {
                select(0);
                widget.mainTouched();
              });
            },
          ),
          NavBarItem(
            active: selected[1],
            icon: Icons.create_new_folder,
            touched: () {
              setState(() {
                select(1);
                widget.formsTouched();
              });
            },
          ),
          NavBarItem(
            active: selected[2],
            icon: Icons.bar_chart,
            touched: () {
              setState(() {
                select(2);
                widget.statisticsTouched();
              });
            },
          ),
          NavBarItem(
            active: selected[3],
            icon: Icons.settings,
            touched: () {
              setState(() {
                select(3);
                widget.settingsTouched();
              });
            },
          )
        ],
      ),
    );
  }
}

class NavBarItem extends StatefulWidget {
  final IconData icon;
  final Function touched;
  final bool active;

  NavBarItem({this.active, this.icon, this.touched});

  @override
  State<StatefulWidget> createState() => _NavBatItemState();
}

class _NavBatItemState extends State<NavBarItem> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          widget.touched();
        },
        splashColor: Colors.white,
        hoverColor: Colors.white12,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 3.0),
          child: Row(
            children: [
              Container(
                height: 60.0,
                width: 80.8,
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: Duration(microseconds: 475),
                      height: 35.0,
                      width: 5.0,
                      decoration: BoxDecoration(
                          color: widget.active
                              ? Colors.deepPurple[400]
                              : Colors.transparent,
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(10.0),
                              bottomRight: Radius.circular(10.0))),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 30.0),
                      child: Icon(
                        widget.icon,
                        color: widget.active
                            ? Colors.deepPurple[200]
                            : Colors.white70,
                        size: 19.0,
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
