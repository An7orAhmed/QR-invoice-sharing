import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:invoice_sharing_app/model/App.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ShowInvoices extends StatefulWidget {
  @override
  _ShowInvoicesState createState() => _ShowInvoicesState();
}

class _ShowInvoicesState extends State<ShowInvoices> {
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

  Widget infoTile(String txt, Color color) {
    return Container(
      height: 100,
      width: 115,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.all(Radius.circular(10))),
      child: Center(
          child: Text(
        txt,
        style: TextStyle(color: Colors.white, fontSize: 20),
        textAlign: TextAlign.center,
      )),
    );
  }

  void showQR(String id) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Center(child: Text('Scan this QR from User App')),
            content: Container(
              height: 320,
              width: 400,
              child: QrImage(
                data: id,
                version: QrVersions.auto,
                size: 320.0,
              ),
            ),
          );
        });
  }

  Widget invoiceView(Invoice invoice) {
    return InkWell(
      onLongPress: () async {
        var id = '';
        await FirebaseFirestore.instance
            .collection('invoices')
            .where('id', isEqualTo: invoice.id)
            .where('customerName', isEqualTo: invoice.customerName)
            .where('phone', isEqualTo: invoice.phone)
            .where('totalCost', isEqualTo: invoice.totalCost)
            .where('totalItem', isEqualTo: invoice.totalItem)
            .get()
            .then((value) {
          id = value.docs.first.id;
        });
        showQR(id);
      },
      child: Card(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(color: Colors.indigo, borderRadius: BorderRadius.all(Radius.circular(5))),
                height: 80,
                margin: EdgeInsets.all(10),
                child: Center(
                    child: Text(
                  invoice.totalCost.toString() + '\nTAKA',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                  textAlign: TextAlign.center,
                )),
              ),
            ),
            Expanded(
              flex: 4,
              child: Container(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(invoice.customerName, style: TextStyle(fontSize: 20)),
                    SizedBox(height: 5),
                    Text(invoice.timestamp, style: TextStyle(color: Colors.grey, fontSize: 15)),
                    SizedBox(height: 5),
                    Text('Address: ' + invoice.address, style: TextStyle(color: Colors.grey, fontSize: 15)),
                    SizedBox(height: 5),
                    Text('Phone: ' + invoice.phone, style: TextStyle(color: Colors.grey, fontSize: 15)),
                  ],
                ),
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
                          .collection('invoices')
                          .where('id', isEqualTo: invoice.id)
                          .where('customerName', isEqualTo: invoice.customerName)
                          .where('phone', isEqualTo: invoice.phone)
                          .where('timestamp', isEqualTo: invoice.timestamp)
                          .get()
                          .then((value) {
                        value.docs.forEach((element) async {
                          await FirebaseFirestore.instance.collection('invoices').doc(element.id).delete();
                        });
                      });
                    })),
          ],
        ),
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
                label("All invoices list"),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    infoTile('Invoices\n' + invoices.length.toString(), Colors.orangeAccent),
                    infoTile('Paid\n' + getTotalCost().toString() + 'TK', Colors.purpleAccent),
                    infoTile('Products\n' + getAvailableStock().toString(), Colors.indigo),
                  ],
                ),
                SizedBox(height: 20),
                StreamBuilder(
                  stream: FirebaseFirestore.instance.collection('invoices').snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Something went wrong'));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: RefreshProgressIndicator());
                    }

                    invoices.clear();
                    snapshot.data.docs.forEach((element) {
                      if (element.data()['id'] == FirebaseAuth.instance.currentUser.uid)
                        invoices.add(Invoice.fromMap(element.data()));
                    });

                    return Column(children: invoices.map((e) => invoiceView(e)).toList());
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
