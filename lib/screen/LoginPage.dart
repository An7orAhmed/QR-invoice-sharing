import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:invoice_sharing_app/screen/UserHome.dart';
import 'package:invoice_sharing_app/shared/shared_prefs.dart';
import 'package:toast/toast.dart';
import 'ShopHome.dart';
import 'SignUpPage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  var email = new TextEditingController();
  var pass = new TextEditingController();
  bool isShopUser = false;

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);

    final emailField = TextField(
      obscureText: false,
      style: style,
      controller: email,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Email",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );

    final passwordField = TextField(
      obscureText: true,
      style: style,
      controller: pass,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Password",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );

    final loginButton = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Colors.blueAccent,
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
        onPressed: () async {
          try {
            await FirebaseAuth.instance.signInWithEmailAndPassword(email: email.text, password: pass.text);
            var user = FirebaseAuth.instance.currentUser;
            var data = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

            var userType = data.data()['userType'];
            isShopUser = (userType == 'SHOP');
            sharedPrefs.userType = userType;

            if (isShopUser == true)
              Navigator.of(context)
                  .pushAndRemoveUntil(MaterialPageRoute(builder: (context) => ShopHome()), (route) => false);
            else
              Navigator.of(context)
                  .pushAndRemoveUntil(MaterialPageRoute(builder: (context) => UserHome()), (route) => false);
          } on FirebaseAuthException catch (e) {
            if (e.code == 'user-not-found') {
              Toast.show('No user found for that email.', duration: Toast.lengthShort, gravity: Toast.bottom);
            } else if (e.code == 'wrong-password') {
              Toast.show('Wrong password provided for that user.', duration: Toast.lengthShort, gravity: Toast.bottom);
            } else {
              Toast.show('Something wrong! Try again..', duration: Toast.lengthShort, gravity: Toast.bottom);
            }
          }
        },
        child: Text("Login",
            textAlign: TextAlign.center, style: style.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.all(20),
            height: 620,
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.all(36.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 155.0,
                    child: ClipOval(
                      child: Image.asset(
                        "logo.png",
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  SizedBox(height: 30.0),
                  Text("INVOICE SHARING APP", style: style),
                  SizedBox(height: 30.0),
                  emailField,
                  SizedBox(height: 25.0),
                  passwordField,
                  SizedBox(height: 35.0),
                  loginButton,
                  SizedBox(height: 25.0),
                  TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignUpPage()),
                        );
                      },
                      child: Text("Not registered? Sign Up here")),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
