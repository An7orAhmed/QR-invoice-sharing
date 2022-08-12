import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:invoice_sharing_app/model/App.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:toast/toast.dart';

class AddInvoice extends StatefulWidget {
  @override
  _AddInvoiceState createState() => _AddInvoiceState();
}

class _AddInvoiceState extends State<AddInvoice> {
  var customerName = TextEditingController();
  var address = TextEditingController();
  var phone = TextEditingController();
  var qty = TextEditingController();
  List<Product> items = [];
  List<int> counts = [];
  List<int> costs = [];

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

  void qtyInputDialog(Product e) {;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Enter quantity:'),
            content: Container(
                height: 140,
                width: 300,
                child: Center(
                  child: Column(
                    children: [
                      textbox('quantity', TextInputType.number, qty),
                      SizedBox(height: 20),
                      button('Done', Colors.redAccent[200], () {
                        try {
                          int val = int.parse(qty.text);
                          if (val <= e.sku) {
                            counts.add(val);
                            costs.add(e.price);
                            setState(() => items.add(e));
                          } else {
                            Toast.show('Stock not available!',
                                duration: Toast.lengthShort, gravity: Toast.bottom);
                          }
                          Navigator.pop(context);
                        } catch (ex) {
                          SnackBar(content: Text(ex.runtimeType.toString()));
                        }
                      })
                    ],
                  ),
                )),
          );
        });
  }

  void itemListDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Pick a item'),
            content: Container(
              height: 400,
              width: 300,
              child: ListView(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                children: products.map((e) {
                  return ListTile(
                    title: Text(e.name),
                    subtitle: Text('Price: ' + e.price.toString() + ' | SKU: ' + e.sku.toString()),
                    onTap: () {
                      Navigator.pop(context);
                      qtyInputDialog(e);
                    },
                  );
                }).toList(),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    int x = 0;
    ToastContext().init(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                label("Create new invoice"),
                SizedBox(height: 20),
                textbox("Customer Name", TextInputType.text, customerName),
                SizedBox(height: 20),
                textbox("Address", TextInputType.text, address),
                SizedBox(height: 20),
                textbox("Contact No.", TextInputType.phone, phone),
                SizedBox(height: 20),
                items.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text('No item added yet!'),
                      )
                    : Container(
                        height: 150,
                        child: Card(
                          child: Scrollbar(
                            child: ListView(
                                children: items.map((e) {
                              return ListTile(
                                title: Text(e.name + '  ' + counts[x++].toString() + 'pcs'),
                                subtitle: Text('Price: ' + e.price.toString()),
                              );
                            }).toList()),
                          ),
                        ),
                      ),
                SizedBox(height: 20),
                button("Add item", Colors.grey, () {
                  SystemChannels.textInput.invokeMethod('TextInput.hide');
                  itemListDialog();
                }),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    button("Cancel", Colors.redAccent, () {
                      SystemChannels.textInput.invokeMethod('TextInput.hide');
                      Navigator.pop(context);
                    }),
                    button("Create", Colors.blueAccent, () async {
                      DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
                      SystemChannels.textInput.invokeMethod('TextInput.hide');
                      try {
                        var id = FirebaseAuth.instance.currentUser.uid;
                        var shop = await FirebaseFirestore.instance.collection('users').doc(id).get();
                        var invoice = Invoice(
                            id,
                            customerName.text,
                            address.text,
                            phone.text,
                            items.map((e) => e.name).toList(),
                            costs,
                            counts,
                            dateFormat.format(DateTime.now()),
                            shop.data()['shopName'],
                            shop.data()['address'],
                            shop.data()['contact']);
                        var data = FirebaseFirestore.instance.collection('invoices');
                        int i = 0;
                        await data.add(invoice.getInvoice()).then((value) {
                          Toast.show('A new invoice created.',
                              duration: Toast.lengthLong, gravity: Toast.bottom);

                          items.forEach((element) async {
                            await FirebaseFirestore.instance
                                .collection('products')
                                .where('id', isEqualTo: id)
                                .where('name', isEqualTo: element.name)
                                .where('price', isEqualTo: element.price)
                                .get()
                                .then((value) {
                              value.docs.forEach((data) async {
                                var doc = await FirebaseFirestore.instance.collection('products').doc(data.id).get();
                                await FirebaseFirestore.instance
                                    .collection('products')
                                    .doc(data.id)
                                    .update({'sku': (doc.data()['sku'] - counts[i++])});
                              });
                            });
                          });

                          Navigator.pop(context);
                          showQR(value.id);
                        });
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
