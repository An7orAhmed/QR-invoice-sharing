import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:invoice_sharing_app/model/App.dart';

class ShowProducts extends StatefulWidget {
  @override
  _ShowProductsState createState() => _ShowProductsState();
}

class _ShowProductsState extends State<ShowProducts> {
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

  Widget productView(Product product) {
    return Card(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(color: Colors.indigo, borderRadius: BorderRadius.all(Radius.circular(5))),
              height: 50,
              margin: EdgeInsets.all(10),
              child: Center(
                  child: Text(
                product.price.toString() + 'TK',
                style: TextStyle(color: Colors.white, fontSize: 20),
              )),
            ),
          ),
          Expanded(
            flex: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: TextStyle(fontSize: 20)),
                SizedBox(height: 5),
                Text('SKU: ' + product.sku.toString(), style: TextStyle(color: Colors.grey, fontSize: 15)),
              ],
            ),
          ),
          Expanded(
              flex: 1,
              child: IconButton(
                  icon: Icon(
                    Icons.delete,
                    color: Colors.redAccent,
                  ),
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('products')
                        .where('id', isEqualTo: product.id)
                        .where('name', isEqualTo: product.name)
                        .where('price', isEqualTo: product.price)
                        .get()
                        .then((value) {
                      value.docs.forEach((element) async {
                        await FirebaseFirestore.instance.collection('products').doc(element.id).delete();
                      });
                    });
                  })),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                label("All products list"),
                SizedBox(height: 20),
                StreamBuilder(
                  stream: FirebaseFirestore.instance.collection('products').snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Something went wrong'));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: RefreshProgressIndicator());
                    }

                    products.clear();
                    snapshot.data.docs.forEach((element) {
                      if (element.data()['id'] == FirebaseAuth.instance.currentUser.uid)
                        products.add(Product.fromMap(element.data()));
                    });

                    return Column(children: products.map((e) => productView(e)).toList());
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
