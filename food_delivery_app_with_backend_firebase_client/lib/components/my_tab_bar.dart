import 'dart:ui';
import 'package:flutter/material.dart';

class MyTabBar extends StatelessWidget implements PreferredSizeWidget {
  final TabController tabController;
  final List<String> categoryNames;

  const MyTabBar({
    super.key,
    required this.tabController,
    required this.categoryNames,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kToolbarHeight + 12,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(
        // color: Colors.white.withOpacity(0.6),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withOpacity(.1),
        //     blurRadius: 8,
        //     offset: Offset(0, 4),
        //   ),
        // ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: TabBar(
            controller: tabController,
            isScrollable: true,
            splashFactory: InkRipple.splashFactory,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey.shade700,
            labelStyle:
                const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            unselectedLabelStyle: const TextStyle(fontSize: 14),
            indicator: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Colors.deepOrangeAccent
                ],
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepOrange.withOpacity(0.4),
                  blurRadius: 6,
                  offset: Offset(0, 3),
                )
              ],
            ),
            tabs: categoryNames.map((name) {
              return Tab(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Text(name),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 12);
}
