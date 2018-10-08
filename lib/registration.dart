import 'package:flutter/material.dart';
import 'dart:async';
import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class MyForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Erickshaw',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MyCustomForm(),
    );
  }
}
class MyCustomForm extends StatefulWidget {
  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

class MyCustomFormState extends State<MyCustomForm> {
 
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(title: Text('djdd')),
      body: Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              hintText: "Name",
              labelText: "Name of Driver",
            ),
            validator: (value) {
              //check on server
              if (value.isEmpty) {
                return 'Please enter some text';
              }
            }),  
            TextFormField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "PIN",
            ),
            validator: (value) {
              if (value != '9999') {
                return 'Enter correct PIN';
              }
            },


          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: RaisedButton(
              onPressed: () {
              
                if (_formKey.currentState.validate()) {
                  print("done");
                  //update on server
                  //update local name
                  //change isdriver
             //     MyHomePageState state = context.ancestorStateOfType(TypeMatcher<MyHomePageState>());
              //    state.isDriver = true;
                  //  Navigator.pop(context);
                }
              },
              child: Text('Submit'),
            ),
          ),
        ],
      ),
    ));
  }
}