import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:invoice_sharing_app/screen/ShopHome.dart';
import 'package:invoice_sharing_app/screen/UserHome.dart';
import 'package:invoice_sharing_app/shared/shared_prefs.dart';
import 'package:toast/toast.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  bool isShopUser = false;
  double height = 690;
  var email = TextEditingController();
  var pass = TextEditingController();
  var shopName = TextEditingController();
  var address = TextEditingController();
  var contact = TextEditingController();

  TextField textBox(String hint, TextEditingController controller) {
    return TextField(
      obscureText: false,
      style: style,
      controller: controller,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);

    final passwordField = TextField(
      obscureText: true,
      style: style,
      controller: pass,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Password",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );

    final signButton = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Colors.blueAccent,
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
        onPressed: () async {
          try {
            await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email.text, password: pass.text);

            var user = FirebaseAuth.instance.currentUser;
            if (isShopUser == true) {
              await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
                'userType': 'SHOP',
                'shopName': shopName.text == "" ? "N/A" : shopName.text,
                'address': address.text == "" ? "N/A" : address.text,
                'contact': contact.text == "" ? "N/A" : contact.text
              });
              sharedPrefs.userType = "SHOP";
              Navigator.of(context)
                  .pushAndRemoveUntil(MaterialPageRoute(builder: (context) => ShopHome()), (route) => false);
            } else {
              await FirebaseFirestore.instance.collection('users').doc(user.uid).set({'userType': 'USER'});
              sharedPrefs.userType = "USER";
              Navigator.of(context)
                  .pushAndRemoveUntil(MaterialPageRoute(builder: (context) => UserHome()), (route) => false);
            }
          } on FirebaseAuthException catch (e) {
            if (e.code == 'weak-password') {
              Toast.show("The password provided is too weak.", duration: Toast.lengthShort, gravity: Toast.bottom);
            } else if (e.code == 'email-already-in-use') {
              Toast.show("The account already exists for that email.",
                  duration: Toast.lengthShort, gravity: Toast.bottom);
            } else {
              Toast.show('Something wrong! Try again..', duration: Toast.lengthShort, gravity: Toast.bottom);
            }
          }
        },
        child: Text("Sign Up",
            textAlign: TextAlign.center, style: style.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );

    final checkBox = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text("Are you a shop keeper?", style: style),
        Checkbox(
            value: isShopUser,
            onChanged: (value) {
              setState(() {
                isShopUser = value;
                if (isShopUser)
                  height = 920;
                else
                  height = 690;
              });
            }),
      ],
    );

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.all(20),
            height: height,
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
                  textBox("Email", email),
                  SizedBox(height: 25.0),
                  passwordField,
                  SizedBox(height: 25.0),
                  checkBox,
                  isShopUser == true ? SizedBox(height: 25.0) : SizedBox(),
                  isShopUser == true ? textBox("Shop Name", shopName) : SizedBox(),
                  isShopUser == true ? SizedBox(height: 25.0) : SizedBox(),
                  isShopUser == true ? textBox("Address", address) : SizedBox(),
                  isShopUser == true ? SizedBox(height: 25.0) : SizedBox(),
                  isShopUser == true ? textBox("Contact No.", contact) : SizedBox(),
                  SizedBox(height: 35.0),
                  signButton,
                  SizedBox(height: 25.0),
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("registered? login here")),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
