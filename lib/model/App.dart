class Product {
  String id, name;
  int price, sku;

  Product(this.id, this.name, this.price, this.sku);

  Map<String, dynamic> getProduct() => {'id': this.id, 'name': this.name, 'price': this.price, 'sku': this.sku};

  Product.fromMap(Map map) {
    this.id = map['id'];
    this.name = map['name'];
    this.price = map['price'];
    this.sku = map['sku'];
  }
}

List<Product> products = [];

//------------------------------------------------------------------

class Invoice {
  List<dynamic> items;
  List<dynamic> costs, counts;
  int totalCost, totalItem;
  String id, customerName, address, phone;
  String timestamp;
  String shopName, shopAddress, contact;

  Invoice(this.id, this.customerName, this.address, this.phone, this.items, this.costs, this.counts, this.timestamp,
      this.shopName, this.shopAddress, this.contact);

  Map<String, dynamic> getInvoice() => {
        'id': this.id,
        'customerName': this.customerName,
        'address': this.address,
        'phone': this.phone,
        'items': this.items,
        'costs': this.costs,
        'counts': this.counts,
        'totalCost': this.getTotalCost(),
        'totalItem': this.getTotalItem(),
        'timestamp': this.timestamp,
        'shopName': this.shopName,
        'shopAddress': this.shopAddress,
        'contact': this.contact
      };

  Invoice.fromMap(Map map) {
    this.id = map['id'];
    this.customerName = map['customerName'];
    this.address = map['address'];
    this.phone = map['phone'];
    this.items = map['items'];
    this.costs = map['costs'];
    this.counts = map['counts'];
    this.totalCost = map['totalCost'];
    this.totalItem = map['totalItem'];
    this.timestamp = map['timestamp'];
    this.shopName = map['shopName'];
    this.shopAddress = map['shopAddress'];
    this.contact = map['contact'];
  }

  int getTotalCost() {
    int cost = 0, i = 0;
    costs.forEach((element) => cost += (element * counts[i++]));
    return cost;
  }

  int getTotalItem() {
    int item = 0;
    counts.forEach((element) => item += element);
    return item;
  }
}

List<Invoice> invoices = [];

int getTotalCost() {
  int cost = 0;
  invoices.forEach((element) => cost += element.totalCost);
  return cost;
}

int getTotalItem() {
  int item = 0;
  invoices.forEach((element) => item += element.totalItem);
  return item;
}

int getAvailableStock() {
  int item = 0;
  products.forEach((element) => item += element.sku);
  return item;
}

//------------------------------------------------------------------
