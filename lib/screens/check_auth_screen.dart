import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app_3/providers/auth.dart';
import 'package:shop_app_3/screens/auth_screen.dart';
import 'package:shop_app_3/screens/products_overview_screen.dart';

class CheckAuthScreen extends StatefulWidget {
  const CheckAuthScreen({Key? key}) : super(key: key);

  @override
  _CheckAuthScreenState createState() => _CheckAuthScreenState();
}

class _CheckAuthScreenState extends State<CheckAuthScreen> {
  var _successAutoLogin = false;
  var _isLoaing = true;

  @override
  void initState() {
    Future.delayed(Duration.zero).then((value) async {
      // setState(() {
      //   _isLoaing = true;
      // });
      final canAutoLogin =
          await Provider.of<Auth>(context, listen: false).tryAutoLogin();
      setState(() {
        if (canAutoLogin) {
          _successAutoLogin = true;
        }
        _isLoaing = false;
      });
      // if (canAutoLogin) {
      //   setState(() {
      //     _successAutoLogin = true;
      //   });
      // }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoaing
        ? Center(
            child: Text("xxxxxxxxxxxxx.........."),
          )
        : _successAutoLogin
            ? ProductsOverviewScreen()
            : AuthScreen();
  }
}
