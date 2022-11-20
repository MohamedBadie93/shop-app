import 'dart:html';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app_3/models/http_exeptions.dart';
import 'package:shop_app_3/providers/auth.dart';

enum AuthMode { Signup, Login }

class AuthScreen extends StatelessWidget {
  static const String routeName = '/auth-screen';
  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(215, 117, 255, 1).withOpacity(0.5),
                  Color.fromRGBO(255, 188, 117, 1).withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0, 1],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.only(bottom: 20),
                      padding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 94.0),
                      // transform: Matrix4.rotationZ(-8 * pi / 180)
                      //   ..translate(-10, 0),
                      decoration: BoxDecoration(
                          color: Colors.deepOrange.shade900,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ]),
                      child: Text(
                        "MyShop",
                        style: TextStyle(
                          fontSize: 50,
                          fontFamily: 'Anton',
                          color: Theme.of(context)
                              .accentTextTheme
                              .headline6!
                              .color,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: AuthCard(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  const AuthCard({Key? key}) : super(key: key);

  @override
  State<AuthCard> createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> with TickerProviderStateMixin {
  final GlobalKey<FormState> _formGolbalKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };

  Future<void> _showErrorDialog(String message) async {
    return showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text("An Error Occured !"),
              content: Text(message),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                    child: Text("Okay"))
              ],
            ));
  }

  void _submit() async {
    if (_formGolbalKey.currentState!.validate()) {
      _formGolbalKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });
      try {
        if (_authMode == AuthMode.Login) {
          await Provider.of<Auth>(context, listen: false).login(
            _authData['email'] as String,
            _authData['password'] as String,
          );
        } else {
          await Provider.of<Auth>(context, listen: false).signup(
            _authData['email'] as String,
            _authData['password'] as String,
          );
        }
      } on HttpExptions catch (error) {
        var errorMessage = "Authentication Fails !";
        if (error.toString().contains("EMAIL_EXISTS")) {
          errorMessage =
              "The email address is already in use by another account.";
        } else if (error.toString().contains("OPERATION_NOT_ALLOWED")) {
          errorMessage = "TPassword sign-in is disabled for this project.";
        } else if (error.toString().contains("TOO_MANY_ATTEMPTS_TRY_LATER")) {
          errorMessage =
              "We have blocked all requests from this device due to unusual activity. Try again later.";
        } else if (error.toString().contains("EMAIL_NOT_FOUND")) {
          errorMessage =
              "There is no user record corresponding to this identifier. The user may have been deleted.";
        } else if (error.toString().contains("INVALID_PASSWORD")) {
          errorMessage =
              "he password is invalid or the user does not have a password.";
        } else if (error.toString().contains("USER_DISABLED")) {
          errorMessage =
              "The user account has been disabled by an administrator.";
        }
        await _showErrorDialog(errorMessage);
      } catch (error) {
        var errorMessage = "Something gone wrong";
        await _showErrorDialog(errorMessage);
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  var _isLoading = false;
  final _passwordController = TextEditingController();
  late AnimationController _animationController;
  late Animation<Size> _heightAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  void _switchAutMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
      _animationController.forward();
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
      _animationController.reverse();
    }
  }

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));

    _heightAnimation = Tween<Size>(
            begin: Size(double.infinity, 230), end: Size(double.infinity, 290))
        .animate(CurvedAnimation(
            parent: _animationController, curve: Curves.fastOutSlowIn));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn));
    _slideAnimation = Tween<Offset>(begin: Offset(0, -1.5), end: Offset(0, 0))
        .animate(CurvedAnimation(
            parent: _animationController, curve: Curves.easeIn));

    // _heightAnimation.addListener(() {
    //   setState(() {});
    // });
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      elevation: 8.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.fastOutSlowIn,
        height: _authMode == AuthMode.Signup ? 290 : 230,
        //height: _heightAnimation.value.height,
        constraints:
            BoxConstraints(minHeight: _authMode == AuthMode.Signup ? 290 : 230),
        //BoxConstraints(minHeight: _heightAnimation.value.height),
        width: deviceSize.width * 0.75,
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Form(
            key: _formGolbalKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(labelText: "E-mail"),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (!value!.contains('@') || value.isEmpty) {
                        return "Please Enter a valid E-mail";
                      }
                      return null;
                    },
                    onSaved: (email) {
                      _authData['email'] = email as String;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: "Password"),
                    controller: _passwordController,
                    obscureText: true,
                    validator: (value) {
                      if (value!.isEmpty || value.length < 5) {
                        return "Password is too short !";
                      }
                      return null;
                    },
                    onSaved: (password) {
                      _authData['password'] = password as String;
                    },
                  ),
                  //if (_authMode == AuthMode.Signup)
                  AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    constraints: BoxConstraints(
                        minHeight: _authMode == AuthMode.Signup ? 60 : 0,
                        maxHeight: _authMode == AuthMode.Signup ? 100 : 0),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: TextFormField(
                          enabled: _authMode == AuthMode.Signup,
                          decoration:
                              InputDecoration(labelText: "Confirm password"),
                          obscureText: true,
                          validator: _authMode == AuthMode.Signup
                              ? (value) {
                                  if (value != _passwordController.text) {
                                    return "Passwords not the same !";
                                  }
                                  return null;
                                }
                              : null,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  if (_isLoading)
                    CircularProgressIndicator()
                  else
                    ElevatedButton(
                      onPressed: _submit,
                      child: Text(
                          _authMode == AuthMode.Login ? "LOGIN" : "SIGNUP"),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        primary: Theme.of(context).primaryColor,
                        textStyle: TextStyle(
                          color: Theme.of(context)
                              .primaryTextTheme
                              .headline6!
                              .color,
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 30.0, vertical: 8),
                      ),
                    ),
                  SizedBox(height: 10),
                  FlatButton(
                    child: Text(
                        '${_authMode == AuthMode.Login ? 'SIGNUP' : 'LOGIN'} INSTEAD'),
                    onPressed: _switchAutMode,
                    padding:
                        EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    textColor: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
