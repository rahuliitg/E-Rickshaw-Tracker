import 'package:flutter/material.dart';
import 'package:location/location.dart' as Location2 ;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:map_view/map_view.dart';
var myKey ="AIzaSyBAOG9vtHBgcci0zmhzRX_FBJT_a9-DMYs";
void main() {
  MapView.setApiKey(myKey);
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Erickshaw',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  MyHomePageState createState() => new MyHomePageState();
}

class Driver {
  GeoPoint location;
  String phoneNumber;
  DateTime lastActive;
  Driver(d, e, f) {
    location = d;
    phoneNumber = e;
    lastActive = f;
  }
}

class MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  String name;
  bool isDriver;
  String phoneNumber;
  var location = new Location2.Location();
  DateTime currentTime = DateTime.now();
  Map<String, Driver> loc = {
    'tempo': Driver(GeoPoint(1.0, 1.0), "9999999999", DateTime.now()),
  };
  String currentDriver;
  SharedPreferences pref;
  int currentIndex = 0;
  MapView mapView = new MapView();
   void initialiseVariables() async {
    pref = await SharedPreferences.getInstance();
    bool first = pref.getBool('first') ?? true;
    if (first) {
      pref.setBool('first', false);
      pref.setBool('isDriver', isDriver);
      pref.setString('name', name);
      pref.setString('phoneNumber', phoneNumber);
    } else {
      isDriver = pref.getBool('isDriver');
      if (isDriver) {
        name = pref.getString('name');
        phoneNumber = pref.getString('phoneNumber');
        startSharing();
      }
      setState(() {
        name;
        isDriver;
        phoneNumber;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    name = 'NA';
    phoneNumber = '9999999999';
    isDriver = false;
    currentDriver = 'No Driver Selected';
    initialiseVariables();
    startGettinglocation();
    Timer.periodic(Duration(seconds: 1), (a) {
      setState(() {
        currentTime = DateTime.now();
      });
    });
  }

  void startSharing() {
    print(DateTime.now());

    print("Location sharing on!");
    location.onLocationChanged().listen((Map<String, double> currloc) {
      print(isDriver ? "yes" : "no");
      Firestore.instance
          .collection('driverdetails')
          .where("name", isEqualTo: name)
          .getDocuments()
          .then((data) {
        print("Your location is changed!");
        print(DateTime.now());
        data.documents[0].reference.updateData({
          'lastActive': DateTime.now(),
          'location': GeoPoint(currloc['latitude'], currloc['longitude'])
        });
      });
    });
  }

  Widget formPage() {
    return Form(
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
                bool flag = false;
                loc.forEach((key, val) {
                  if (key.toString() == value.toString()) flag = true;
                });
                if (flag) return 'Username already taken';
                if (value.isEmpty) return 'Please enter some text';
                setState(() {
                  name = value;
                });
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
          TextFormField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "Phone Number",
            ),
            validator: (value) {
              if (value.length != 10) {
                return 'Enter correct number';
              }
              phoneNumber = value;
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: RaisedButton(
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  print("Validation done! Updating on server!");
                  Firestore.instance.collection('driverdetails').add({
                    'name': name,
                    'location': GeoPoint(26.196624, 91.695386),
                    'phonenumber': phoneNumber,   
                    'lastActive': DateTime.now(),
                  });
                  pref.setBool('isDriver', true);
                  pref.setString('name', name);
                  pref.setString('phoneNumber', phoneNumber);
                  setState(() {
                    isDriver = true;
                    currentIndex = 0;
                  });
                  print("coming here");
                  startSharing();
                }
              },
              child: Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }


  void startGettinglocation() {
    CollectionReference reference =
        Firestore.instance.collection('driverdetails');
    reference.snapshots().listen((querySnapshot) {
      querySnapshot.documentChanges.forEach((change) {
        var d = change.document.data;
        print("Location of a driver updated");
        setState(() {
          loc[d['name']] =
              Driver(d['location'], d['phonenumber'], d['lastActive']);
        });
      });
    });
  }
  displayMap(){
    mapView.show(MapOptions(
      mapViewType:MapViewType.normal,
      initialCameraPosition:CameraPosition(Location(26.189634, 91.691845),15.0),
      showUserLocation:false,
      title:'google map',


    )
    );
  }
  Widget mapPage() {
    print(DateTime.now());
    return Column(mainAxisSize: MainAxisSize.max, children: <Widget>[
      Container(
        child: Row(
          children: <Widget>[
            Icon((isDriver) ? Icons.airport_shuttle : Icons.accessibility_new),
            Expanded(
              child: Align(
                  child: Text(currentDriver,
                      style: TextStyle(
                        fontSize: 30.0,
                        color: Colors.blue,
                      )),
                  alignment: FractionalOffset.topCenter),
            ),
            FlatButton(
                child: Icon(Icons.access_alarms),
                onPressed: () =>
                    launch("tel://" + loc[currentDriver].phoneNumber)),
          ],
        ),
        height: 30.0,
      ),
      Container(
        child: RaisedButton(
          child:Text("hello"),
          onPressed: displayMap,
        ),
        height: 563.0,
      ),
    ]);
  }

  Widget driverPage() {
    return Container(
      color: Colors.blueGrey,
      child: Column(
        children: <Widget>[
          Center(
            child: Text(name),
          ),
          Center(
            child: Text(phoneNumber),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("E-Rickshaw App"),
      ),
      body: (currentIndex == 0)
          ? mapPage()
          : (isDriver) ? driverPage() : formPage(),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        currentIndex: currentIndex,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.map), title: Text("Map")),
          BottomNavigationBarItem(
              icon: Icon(Icons.event), title: Text("Register")),
        ],
      ),
    );
  }
}
