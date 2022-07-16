import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import './login.dart';
import './send.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

var userData = {};
List<dynamic> transactionsList = [];

void main() async {
  await dotenv.load(fileName: ".env");
  final storage = new FlutterSecureStorage();
  var sessionToken = await storage.read(key: 'sessionToken');
  if (sessionToken != null) {
    var url = Uri.parse(dotenv.env['SERVER_URL']! + '/api/auth/');
    var response = await http.get(url, headers: {
      HttpHeaders.authorizationHeader: sessionToken,
    });
    userData = jsonDecode(response.body);
    transactionsList = userData["transactions"];
    if (userData["status"] == 200) {
      runApp(const MyApp());
    } else {
      runApp(const LoginPage());
    }
  } else {
    runApp(const LoginPage());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flux Wallet',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MyHomePage(title: 'Flux Wallet'),
        debugShowCheckedModeBanner: false);
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void _incrementCounter() async {
    final storage = new FlutterSecureStorage();
    var sessionToken = await storage.read(key: 'sessionToken');
    if (sessionToken != null) {
      var url =
          Uri.parse(dotenv.env['SERVER_URL']! + '/api/wallet/deposit/sandbox');
      var response = await http.get(url, headers: {
        HttpHeaders.authorizationHeader: sessionToken,
      });
    }
    setState(() {
      userData["balance"] += 1000;
    });
  }

  void _refreshTransactions() async {
    setState(() {
      userData = userData;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            children: [
              Center(
                child: Column(
                  children: <Widget>[
                    Text(
                      '\$' + userData["balance"].toString(),
                      style: Theme.of(context).textTheme.headline4,
                    ),
                    const Text(
                      'My Balance',
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          child: const Text('Send'),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SendPage()),
                            );
                          },
                        ),
                        SizedBox(width: 25),
                        ElevatedButton(
                          child: const Text('Withdraw'),
                          onPressed: () {},
                        ),
                        SizedBox(width: 25),
                        ElevatedButton(
                          child: const Text('Deposit'),
                          onPressed: () {},
                        ),
                      ],
                    )
                  ],
                ),
              ),
              SizedBox(height: 100),
              Text(
                'Transactions',
                style: Theme.of(context).textTheme.headline5,
              ),
              DataTable(
                  columns: const <DataColumn>[
                    DataColumn(
                      label: Text(
                        'Transaction ID',
                        style: TextStyle(fontStyle: FontStyle.normal),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Amount',
                        style: TextStyle(fontStyle: FontStyle.normal),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Recipient',
                        style: TextStyle(fontStyle: FontStyle.normal),
                      ),
                    ),
                  ],
                  rows: transactionsList
                      .map((e) => DataRow(
                            cells: <DataCell>[
                              DataCell(Text(e["transactionID"].toString())),
                              DataCell(Text(e["amount"].toString())),
                              DataCell(Text(e["recipient"].toString())),
                            ],
                          ))
                      .toList())
            ],
          )),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "btnRefresh",
            onPressed: _refreshTransactions,
            tooltip: 'Refresh Transactions',
            child: const Icon(Icons.refresh_outlined),
          ),
          SizedBox(
            width: 10,
          ),
          FloatingActionButton(
            heroTag: "btnDeposit",
            onPressed: _incrementCounter,
            tooltip: 'Deposit',
            child: const Icon(Icons.add),
          )
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
