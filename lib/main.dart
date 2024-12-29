import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(ProductApp());
}

class ProductApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Product Info App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ProductScreen(),
    );
  }
}

class ProductScreen extends StatefulWidget {
  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final TextEditingController _productIdController = TextEditingController();
  bool showDetails = false;
  Map<String, dynamic>? currentProduct;
  Map<String, dynamic>? user;

  Future<void> findDetails(String id) async {
    try {
      final productDoc =
          await FirebaseFirestore.instance.collection('products').doc(id).get();

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc('U1001')
          .get();

      setState(() {
        currentProduct = productDoc.exists
            ? {
                ...productDoc.data()!,
                'id': productDoc.id,
              }
            : null;

        user = userDoc.exists ? userDoc.data() : null;

        showDetails = currentProduct != null;
      });
    } catch (e) {
      print('Error fetching details: $e');
      setState(() {
        showDetails = false;
        currentProduct = null;
        user = null;
      });
    }
  }

  Future<void> incrementStock() async {
    if (currentProduct != null) {
      setState(() {
        currentProduct!['stock'] += 1;
      });
      await FirebaseFirestore.instance
          .collection('products')
          .doc(currentProduct!['id'])
          .update({'stock': currentProduct!['stock']});
    }
  }

  Future<void> decrementStock() async {
    if (currentProduct != null && currentProduct!['stock'] > 0) {
      setState(() {
        currentProduct!['stock'] -= 1;
      });
      await FirebaseFirestore.instance
          .collection('products')
          .doc(currentProduct!['id'])
          .update({'stock': currentProduct!['stock']});
    }
  }

  void handleQrCode(String scannedId) {
    _productIdController.text = scannedId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      findDetails(scannedId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Center(
          child: Text(
            'Product Info App',
            style: GoogleFonts.roboto(
              textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
            ),
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 20.0,
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _productIdController,
                    style: TextStyle(fontSize: 18, color: Colors.black),
                    decoration: InputDecoration(
                      hintText: 'Enter Product ID',
                      labelStyle: TextStyle(color: Colors.black),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.qr_code, color: Colors.green),
                        onPressed: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  QRScannerScreen(onScanned: handleQrCode),
                            ),
                          );
                        },
                      ),
                    ),
                    maxLength: 5,
                    onChanged: (value) {
                      if (value.length == 5) {
                        findDetails(value);
                      }
                    },
                  ),
                ),
                SizedBox(height: 20),
                if (showDetails && currentProduct != null && user != null) ...[
                  Card(
                    elevation: 10,
                    shadowColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'User Info',
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Name: ${user!['username']}',
                            style: GoogleFonts.roboto(
                              textStyle: TextStyle(fontSize: 20),
                            ),
                          ),
                          Text(
                            'Designation: ${user!['designation']}',
                            style: GoogleFonts.roboto(
                              textStyle: TextStyle(fontSize: 20),
                            ),
                          ),
                          Text(
                            'Company: ${user!['company']}',
                            style: GoogleFonts.roboto(
                              textStyle: TextStyle(fontSize: 20),
                            ),
                          ),
                          Text(
                            'Device ID: ${user!['deviceId']}',
                            style: GoogleFonts.roboto(
                              textStyle: TextStyle(fontSize: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Card(
                    elevation: 10,
                    shadowColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.network(currentProduct!['photoUrl'],
                              height: 200, width: 350),
                          SizedBox(height: 10),
                          Text(
                            'Name: ${currentProduct!['name']}',
                            style: GoogleFonts.roboto(
                              textStyle: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Description: ${currentProduct!['description']}',
                            style: GoogleFonts.roboto(
                              textStyle: TextStyle(fontSize: 18),
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'First Inventory Date: ${currentProduct!['inventoryDate']}',
                            style: GoogleFonts.roboto(
                              textStyle: TextStyle(fontSize: 18),
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Supervisor: ${currentProduct!['supervisorName']}',
                            style: GoogleFonts.roboto(
                              textStyle: TextStyle(fontSize: 18),
                            ),
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Stocks:',
                                style: GoogleFonts.roboto(
                                  textStyle: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black),
                                    borderRadius: BorderRadius.circular(30)),
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon:
                                          Icon(Icons.remove, color: Colors.red),
                                      onPressed: decrementStock,
                                    ),
                                    Text(
                                      '${currentProduct!['stock']}',
                                      style: GoogleFonts.roboto(
                                        textStyle: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    IconButton(
                                      icon:
                                          Icon(Icons.add, color: Colors.green),
                                      onPressed: incrementStock,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else if (_productIdController.text.isNotEmpty) ...[
                  Center(
                    child: Text(
                      'No product found. Enter a valid Product ID.',
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class QRScannerScreen extends StatefulWidget {
  final Function(String) onScanned;

  QRScannerScreen({required this.onScanned});

  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code Scanner'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text('Scan a code'),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (mounted) {
        widget.onScanned(scanData.code ?? '');
        Navigator.pop(context);
      }
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
