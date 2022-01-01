import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/models/http_exception.dart';
import 'package:shop_app/providers/auth.dart';

enum AuthMode { Signup, Login }

class AuthScreen extends StatelessWidget {
  static const ID = "AuthScreen";

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
              width: deviceSize.width,
              height: deviceSize.height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom: 20),
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 94),
                    transform: Matrix4.rotationZ(-8 * pi / 180)
                      ..translate(-10.0),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.deepOrange.shade900,
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
                        fontFamily: "Anton",
                        fontSize: 50,
                        color:
                            Theme.of(context).accentTextTheme.headline6!.color,
                      ),
                    ),
                  ),
                  AuthCard(),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    "email": "",
    "password": "",
  };

  var _isLoading = false;
  final _passwordController = TextEditingController();

  AnimationController? _controller;
  Animation<Offset>? _slideAnimation;
  Animation<double>? _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, -1.5),
      end: Offset(0, 0),
    ).animate(CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      parent: _controller!.view,
    ));
    // _heightAnimation!.addListener(() => setState(() {}));
    _opacityAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller!.view,
      curve: Curves.easeIn,
    ));
  }

  @override
  void dispose() {
    super.dispose();
    _controller!.dispose();
  }

  _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("An Error Occurred!"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Okay"),
          )
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });
      try {
        if (_authMode == AuthMode.Login) {
          await Provider.of<Auth>(context, listen: false)
              .signin(_authData["email"], _authData["password"]);
        } else {
          await Provider.of<Auth>(context, listen: false).signup(
            _authData["email"],
            _authData["password"],
          );
        }
      } on HttpException catch (error) {
        var errorMessage = "Authentication Failed.";
        if (error.toString().contains("EMAIL_EXISTS")) {
          errorMessage = "This email address is already in use.";
        } else if (error.toString().contains("INVALID_EMAIL")) {
          errorMessage = "This is not a valid email address.";
        } else if (error.toString().contains("WEAK_PASSWORD")) {
          errorMessage = "The password is too weak.";
        } else if (error.toString().contains("EMAIL_NOT_FOUND")) {
          errorMessage = "Could not find a user with this email.";
        } else if (error.toString().contains("INVALID_PASSWORD")) {
          errorMessage = "Invalid password.";
        }
        _showErrorDialog(errorMessage);
      } catch (error) {
        const errorMessage = "Could not authenticate. Try again later.";
        _showErrorDialog(errorMessage);
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
      _controller!.forward();
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
      _controller!.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 8,
      child: AnimatedContainer(
        height: _authMode == AuthMode.Login ? 260 : 320,
        width: deviceSize.width * 0.75,
        padding: EdgeInsets.all(16),
        alignment: Alignment.center,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: "E-mail"),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value!.isEmpty || !value.contains("@"))
                      return "Invalid email!";
                  },
                  onSaved: (value) {
                    _authData["email"] = value!;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: "Password"),
                  obscureText: true,
                  controller: _passwordController,
                  validator: (value) {
                    if (value!.isEmpty || value.length < 5)
                      return "Password is too short!";
                  },
                  onSaved: (value) {
                    _authData["password"] = value!;
                  },
                ),
                if (_authMode == AuthMode.Signup)
                  FadeTransition(
                    opacity: _opacityAnimation!,
                    child: SlideTransition(
                      position: _slideAnimation!,
                      child: TextFormField(
                        decoration:
                            InputDecoration(labelText: "Confirm Password"),
                        obscureText: true,
                        validator: (value) {
                          if (value != _passwordController.text) {
                            return "Passwords do not match!";
                          }
                        },
                      ),
                    ),
                  ),
                SizedBox(
                  height: 20,
                ),
                if (_isLoading)
                  CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: _submit,
                    child:
                        Text(_authMode == AuthMode.Login ? "LOGIN" : "SIGNUP"),
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      padding: MaterialStateProperty.all(
                        EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),
                TextButton(
                  onPressed: _switchAuthMode,
                  child: Text(
                      "${_authMode == AuthMode.Login ? "SIGNUP" : "LOGIN"} INSTEAD"),
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all(
                      EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
