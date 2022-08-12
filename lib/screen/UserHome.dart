import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:invoice_sharing_app/model/App.dart';
import 'package:toast/toast.dart';

class UserHome extends StatefulWidget {
  @override
  _UserHomeState createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  Widget label(String text) {
    return Container(
      width: double.infinity,
      alignment: AlignmentDirectional.center,
      child: Text(
        text,
        style: TextStyle(color: Colors.white, fontSize: 20),
      ),
      decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10.0)), color: Colors.blueGrey),
      padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
    );
  }

  Widget button(String label, Color color, GestureTapCallback job) {
    return Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(5.0),
      color: color,
      child: MaterialButton(
        minWidth: 160,
        padding: EdgeInsets.all(20),
        onPressed: job,
        child: Text(label,
            textAlign: TextAlign.center,
            style:
                TextStyle(fontFamily: 'Montserrat', fontSize: 20.0, color: Colors.white, fontWeight: FontWeight.bold)),
      ),
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

  Widget invoiceView(Invoice invoice) {
    return Card(
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
                  Text(invoice.shopName, style: TextStyle(fontSize: 20)),
                  SizedBox(height: 5),
                  Text(invoice.timestamp, style: TextStyle(color: Colors.grey, fontSize: 15)),
                  SizedBox(height: 5),
                  Text('Address: ' + invoice.shopAddress, style: TextStyle(color: Colors.grey, fontSize: 15)),
                  SizedBox(height: 5),
                  Text('Phone: ' + invoice.contact, style: TextStyle(color: Colors.grey, fontSize: 15)),
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
                        .collection('userInvoices')
                        .where('id', isEqualTo: invoice.id)
                        .where('customerName', isEqualTo: invoice.customerName)
                        .where('phone', isEqualTo: invoice.phone)
                        .where('timestamp', isEqualTo: invoice.timestamp)
                        .get()
                        .then((value) {
                      value.docs.forEach((element) async {
                        await FirebaseFirestore.instance.collection('userInvoices').doc(element.id).delete();
                      });
                    });
                  })),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Invoice Sharing App"),
      ),
      body: Container(
        margin: EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            label("CUSTOMER DASHBOARD"),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                infoTile('Invoices\n' + invoices.length.toString(), Colors.orangeAccent),
                infoTile('Paid\n' + getTotalCost().toString() + 'TK', Colors.purpleAccent),
                infoTile('Products\n' + getTotalItem().toString(), Colors.indigo),
              ],
            ),
            SizedBox(height: 10),
            Expanded(
              child: Scrollbar(
                child: SingleChildScrollView(
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance.collection('userInvoices').snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Something went wrong'));
                      }

                      if (!snapshot.hasData) {
                        return Center(child: Text('No invoice saved!'));
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
                ),
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                button('Scan QR', Colors.blueAccent, () async {
                  try {
                    var qrCode = await BarcodeScanner.scan();
                    var id = FirebaseAuth.instance.currentUser.uid;
                    var data = await FirebaseFirestore.instance.collection('invoices').doc(qrCode.rawContent).get();
                    var copyInv = Invoice.fromMap(data.data());
                    copyInv.id = id;
                    await FirebaseFirestore.instance.collection('userInvoices').add(copyInv.getInvoice());
                    setState(() {});
                  } on PlatformException catch (e) {
                    Toast.show(e.message, duration: Toast.lengthShort, gravity: Toast.center);
                  } catch (e) {
                    Toast.show(e.runtimeType.toString(), duration: Toast.lengthShort, gravity: Toast.bottom);
                  }
                }),
                button('Logout', Colors.redAccent, () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacementNamed(context, '/LoginPage');
                }),
              ],
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
