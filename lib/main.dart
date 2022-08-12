import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:invoice_sharing_app/screen/AddInvoice.dart';
import 'package:invoice_sharing_app/screen/AddProduct.dart';
import 'package:invoice_sharing_app/screen/LoginPage.dart';
import 'package:invoice_sharing_app/screen/ShopHome.dart';
import 'package:invoice_sharing_app/screen/ShowInvoices.dart';
import 'package:invoice_sharing_app/screen/ShowProducts.dart';
import 'package:invoice_sharing_app/screen/UserHome.dart';
import 'package:invoice_sharing_app/shared/shared_prefs.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await sharedPrefs.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  bool isLoggedIn() {
    bool loggedin = false;
    if (FirebaseAuth.instance.currentUser != null) loggedin = true;
    return loggedin;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Invoice Sharing App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: isLoggedIn()
          ? sharedPrefs.userType == "SHOP"
              ? ShopHome()
              : UserHome()
          : LoginPage(),
      routes: {
        '/LoginPage': (context) => LoginPage(),
        '/ShopHome': (context) => ShopHome(),
        '/UserHome': (context) => UserHome(),
        '/AddProduct': (context) => AddProduct(),
        '/ShowProducts': (context) => ShowProducts(),
        '/AddInvoice': (context) => AddInvoice(),
        '/ShowInvoices': (context) => ShowInvoices(),
      },
    );
  }
}
