import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mailer2/mailer.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
      theme: ThemeData.dark(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  File _image;

  var _issending = false;

  TextEditingController _ct1 = new TextEditingController();
  TextEditingController _ct2 = new TextEditingController();
  TextEditingController _ct3 = new TextEditingController();
  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      _image = image;
    });
  }

  _Send(String reci, String subject, String body) async {
    setState(() {
      _issending = true;
    });
    var options = new GmailSmtpOptions()
      ..username = 'mprimalka@gmail.com'
      ..password = 'dglayrznsvdvefpa';
    var emailTransport = new SmtpTransport(options);
    var envelope = new Envelope()
      ..from = 'foo@bar.com'
      ..recipients.add('$reci')
      ..attachments.add(new Attachment(file: _image))
      ..subject = '$subject'
      ..html = '<h3>$body</h3>';

    await emailTransport
        .send(envelope)
        .then((envelope) => setState(() {
              _issending = false;
              _ct1.text = "";
              _ct2.text = "";
              _ct3.text = "";
              _image = null;
            }))
        .catchError((e) => setState(() {
              _issending = false;
            }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      appBar: AppBar(
        title: Text("Email Sender"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 30,
            ),
            _image != null
                ? Image.file(
                    _image,
                    width: 130,
                    height: 120,
                  )
                : Text("Select Image"),
            IconButton(
              icon: Icon(Icons.camera),
              onPressed: () {
                getImage();
              },
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: new TextField(
                controller: _ct1,
                decoration: new InputDecoration(
                  labelText: "Enter Email",
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: new TextField(
                controller: _ct2,
                decoration: new InputDecoration(
                  labelText: "Enter Subject",
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: new TextField(
                controller: _ct3,
                decoration: new InputDecoration(
                  labelText: "Enter Body",
                ),
              ),
            ),
            _issending
                ? CircularProgressIndicator()
                : RaisedButton(
                    elevation: 20,
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0)),
                    color: Colors.blueAccent,
                    child: new Text("Send"),
                    onPressed: () {
                      String recipent = _ct1.text;
                      String subject = _ct2.text;
                      String body = _ct3.text;
                      _Send(recipent, subject, body);
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
