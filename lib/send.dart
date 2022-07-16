import 'package:flutter/material.dart';
import 'main.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SendPage extends StatelessWidget {
  const SendPage({super.key});

  @override
  Widget build(BuildContext context) {
    const appTitle = 'Flux Wallet';

    return MaterialApp(
      title: appTitle,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          appBar: AppBar(
            title: const Text(appTitle),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.pop(context);
              main();
            },
            tooltip: 'Back to Home',
            child: const Icon(Icons.arrow_back),
          ),
          body: Center(
            // Center is a layout widget. It takes a single child and positions it
            // in the middle of the parent.
            child: Column(
              // Column is also a layout widget. It takes a list of children and
              // arranges them vertically. By default, it sizes itself to fit its
              // children horizontally, and tries to be as tall as its parent.
              //
              // Invoke "debug painting" (press "p" in the console, choose the
              // "Toggle Debug Paint" action from the Flutter Inspector in Android
              // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
              // to see the wireframe for each widget.
              //
              // Column has various properties to control how it sizes itself and
              // how it positions its children. Here we use mainAxisAlignment to
              // center the children vertically; the main axis here is the vertical
              // axis because Columns are vertical (the cross axis would be
              // horizontal).
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[const MyCustomForm()],
            ),
          )),
    );
  }
}

// Create a Form widget.
class MyCustomForm extends StatefulWidget {
  const MyCustomForm({super.key});

  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class MyCustomFormState extends State<MyCustomForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a GlobalKey<FormState>,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();
  var username;
  var amount;
  String message = "";

  Future<void> sendAmount() async {
    var url = Uri.parse(dotenv.env['SERVER_URL']! + '/api/wallet/send');
    final storage = new FlutterSecureStorage();
    var sessionToken = await storage.read(key: 'sessionToken');
    var response = await http.post(url, body: {
      'email': username,
      'amount': amount
    }, headers: {
      HttpHeaders.authorizationHeader: sessionToken!,
    });
    var res = jsonDecode(response.body);
    message = res["message"];
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 500,
            child: TextFormField(
              // The validator receives the text that the user has entered.
              onSaved: (String? value) {
                username = value;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
              decoration: const InputDecoration(
                icon: Icon(Icons.person),
                hintText: 'What is your Flux Wallet Username?',
                labelText: 'Username *',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ),
          SizedBox(
            width: 500,
            child: TextFormField(
              // The validator receives the text that the user has entered.
              onSaved: (String? value) {
                amount = value;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
              decoration: const InputDecoration(
                icon: Icon(Icons.attach_money),
                hintText: 'How much would you like to send?',
                labelText: 'Amount *',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    await sendAmount();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(message)),
                    );
                  }
                },
                child: const Text('Send'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
