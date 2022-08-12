import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:invoice_sharing_app/model/App.dart';

class ShopHome extends StatelessWidget {
  Widget label(String text) {
    return Container(
      width: double.infinity,
      alignment: AlignmentDirectional.center,
      child: Text(
        text,
        style: TextStyle(color: Colors.white),
      ),
      decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10.0)), color: Colors.blueGrey),
      padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
    );
  }

  Widget simpleButton(String buttLabel, Icon buttIcon, Color bgColor, GestureTapCallback job) {
    return Container(
      width: 150,
      height: 150,
      child: ElevatedButton(
        onPressed: job,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(bgColor),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[buttIcon, Text(buttLabel)],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Invoice Sharing App")),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var userID = FirebaseAuth.instance.currentUser.uid;

          await FirebaseFirestore.instance.collection('products').where('id', isEqualTo: userID).get().then((value) {
            value.docs.forEach((element) async {
              products.clear();
              await FirebaseFirestore.instance.collection('products').doc(element.id).get().then((value) {
                products.add(Product.fromMap(value.data()));
              });
            });
          });

          await FirebaseFirestore.instance.collection('invoices').where('id', isEqualTo: userID).get().then((value) {
            value.docs.forEach((element) async {
              invoices.clear();
              await FirebaseFirestore.instance.collection('invoices').doc(element.id).get().then((value) {
                invoices.add(Invoice.fromMap(value.data()));
              });
            });
          });
        },
        child: Icon(Icons.refresh),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            label("SHOP DASHBOARD"),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                simpleButton("Add Product", Icon(Icons.add, size: 55), Colors.purpleAccent, () {
                  Navigator.pushNamed(context, '/AddProduct');
                }),
                simpleButton("Crerate Invoice", Icon(Icons.create, size: 55), Colors.orangeAccent, () {
                  Navigator.pushNamed(context, '/AddInvoice');
                }),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                simpleButton("Show Products", Icon(Icons.beach_access, size: 55), Colors.indigoAccent, () {
                  Navigator.pushNamed(context, '/ShowProducts');
                }),
                simpleButton("Show Invoice", Icon(Icons.description_outlined, size: 55), Colors.deepPurpleAccent, () {
                  Navigator.pushNamed(context, '/ShowInvoices');
                }),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                simpleButton("LogOut", Icon(Icons.logout, size: 55), Colors.redAccent, () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacementNamed(context, '/LoginPage');
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
