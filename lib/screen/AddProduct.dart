import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:invoice_sharing_app/model/App.dart';
import 'package:toast/toast.dart';

class AddProduct extends StatefulWidget {
  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  var productName = TextEditingController();
  var price = TextEditingController();
  var sku = TextEditingController();

  Widget label(String text) {
    return Container(
      width: double.infinity,
      alignment: AlignmentDirectional.center,
      child: Text(
        text,
        style: TextStyle(color: Colors.white, fontSize: 25),
      ),
      decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10.0)), color: Colors.blueGrey),
      padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
    );
  }

  Widget button(String label, Color color, GestureTapCallback job) {
    return Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: color,
      child: MaterialButton(
        minWidth: 150,
        padding: EdgeInsets.all(20),
        onPressed: job,
        child: Text(label,
            textAlign: TextAlign.center,
            style:
                TextStyle(fontFamily: 'Montserrat', fontSize: 20.0, color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget textbox(String hint, TextInputType key, TextEditingController txt) {
    return TextField(
      keyboardType: key,
      style: TextStyle(fontFamily: 'Montserrat', fontSize: 20.0),
      controller: txt,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                label("Add new product"),
                SizedBox(height: 20),
                textbox("Product Name", TextInputType.text, productName),
                SizedBox(height: 20),
                textbox("Product Price", TextInputType.number, price),
                SizedBox(height: 20),
                textbox("Product SKU", TextInputType.number, sku),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    button("Cancel", Colors.redAccent, () {
                      SystemChannels.textInput.invokeMethod('TextInput.hide');
                      Navigator.pop(context);
                    }),
                    button("Add", Colors.blueAccent, () {
                      try {
                        SystemChannels.textInput.invokeMethod('TextInput.hide');
                        var item = Product(FirebaseAuth.instance.currentUser.uid, productName.text,
                            int.parse(price.text), int.parse(sku.text));

                        var data = FirebaseFirestore.instance.collection('products');
                        data.add(item.getProduct());

                        Navigator.pop(context);
                        Toast.show('A new product added.', duration: Toast.lengthLong, gravity: Toast.bottom);
                      } catch (ex) {
                        Toast.show("Error: " + ex.runtimeType.toString(),
                            duration: Toast.lengthShort, gravity: Toast.bottom);
                      }
                    }),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
