import 'package:chat_app/utils/helpers/auth_helper.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({super.key});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            child: CircleAvatar(radius: 60),
          ),
          Spacer(),
          ListTile(
            title: Text("Log Out"),
            trailing: Icon(
              Icons.power_settings_new,
              color: Colors.white,
            ),
            tileColor: Colors.redAccent,
            textColor: Colors.white,
            onTap: () async {
              await AuthHelper.authHelper.signOut();

              Navigator.of(context)
                  .pushNamedAndRemoveUntil('login_page', (route) => false);
            },
          ),
        ],
      ),
    );
  }
}
