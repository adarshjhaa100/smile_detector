import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'dat.dart';
void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Face Detector ',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
        
      ),
      home: new MyHomePage(title: 'Face Detector',),
    );
  }
} 


class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  
  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File _image;
  Size _imageSize;
  List<dynamic> _scanResults;
  Detector _currentDetector = Detector.face;

  Future <void> _getImage() async {
    
    setState((){
      _image=null;
      _imageSize=null;

    });
    final File image=await ImagePicker.pickImage(source:ImageSource.gallery);
    if(image!=null){
      _getSize(image);
      _scan(image);
    }
    setState(() {
          _image=image;
        });
  }
  
  Future<void> _getSize(File imageS) async{
    final Completer<Size> completer = Completer<Size>();
    final Image image=Image.file(imageS);
    image.image.resolve(const ImageConfiguration()).addListener(
      (ImageInfo info, bool_){
        completer.complete(Size(
          info.image.width.toDouble(),
          info.image.height.toDouble()));
      }
    );
    final Size imageSize=await completer.future;
    setState(() {
          _imageSize=imageSize;
        });
  }

  Future<void> _scan(File image) async{
    setState(() {
          _imageSize=null;
        });
    
    final FirebaseVisionImage visionImage=FirebaseVisionImage.fromFile(image);
    FirebaseVisionDetector detector;
    if(_currentDetector==Detector.face){
      detector=FirebaseVision.instance.faceDetector(FaceDetectorOptions(
       enableClassification: true,
       enableTracking: true
      ));
    }
    final List<dynamic> results=await detector.detectInImage(visionImage)?? <dynamic>[];

    setState(() {
          _scanResults=results; 
        });
  }
  
  CustomPaint _buildResults(Size imageSize,List<dynamic> results){
    CustomPainter painter;

    if(_currentDetector==Detector.face){
      painter=FaceDetectorPainter(_imageSize,results);
    }
    return CustomPaint(painter: painter,);
  }

  Widget _buildImage(){
    return Container(
     constraints: const BoxConstraints.expand(),
     decoration: BoxDecoration(
       image: DecorationImage(
         image: Image.file(_image).image,
         fit:BoxFit.fill
       )
     ),
     child: _imageSize==null || _scanResults==null?
     const Center(
       child: Text('Scanning....',style: TextStyle( color: Colors.green,fontSize: 30.0) ,),
     ):_buildResults(_imageSize,_scanResults),
    );
  }  
  
  
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      /*appBar: new AppBar(
        title: new Text('Face Detector'),
        actions: <Widget>[
          PopupMenuButton<Detector>(
           onSelected: (Detector result){
             _currentDetector=result;
             if(_image!=null) _scan(_image);
           },
           itemBuilder: (BuildContext context)=><PopupMenuEntry<Detector>>[
             const PopupMenuItem<Detector>(
                    child: Text('Detect Face'),
                    value: Detector.face,
                  ),
           ],
          )
        ],
      ),*/
      
     
       backgroundColor: Colors.white ,

      body:
      
      _image==null?Center(child:Scaffold(
       body: Image(
         image: new AssetImage('assets/smile.jpg'),
         fit: BoxFit.cover,
          colorBlendMode: BlendMode.darken,
          color: Colors.tealAccent,
       ),
      
      )
      ):_buildImage(),
       
      floatingActionButton: new FloatingActionButton(
        onPressed:_getImage,
        tooltip: 'Increment',
        child: new Icon(Icons.add_a_photo),
        foregroundColor: Colors.limeAccent,
       backgroundColor: Colors.transparent,
      ), );
  }
} 
