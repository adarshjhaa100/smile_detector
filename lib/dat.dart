import 'dart:ui' as ui;
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';

enum Detector{face,text,label,cloudLabel } 

class FaceDetectorPainter extends CustomPainter{
  FaceDetectorPainter(this.absoluteImageSize,this.faces);
  final Size absoluteImageSize;
  final List<Face> faces;
  
  @override
  void paint(Canvas canvas,Size size){
    final double scaleX=size.width/absoluteImageSize.width;
    final double scaleY=size.height/absoluteImageSize.height;
    
    final Paint paint =Paint()
    ..style=PaintingStyle.stroke
    ..strokeWidth=2.0
    ..color=Colors.red;   
  final ui.ParagraphBuilder builder = ui.ParagraphBuilder(
      ui.ParagraphStyle(
          textAlign: TextAlign.left,
          fontSize: 20.0,
          textDirection: TextDirection.ltr,
         fontWeight: FontWeight.bold,)
    );
    
   builder.pushStyle(ui.TextStyle(color: Colors.deepPurple,decorationStyle: TextDecorationStyle.double));
  builder.addText('\nSmiling Probablities for face numbers \n(from left to right, if multiple faces)\n');
  int i=0;
  for (Face face in faces) {
   i++;
 
   canvas.drawRect(Rect.fromLTRB(
   face.boundingBox.left * scaleX, 
   face.boundingBox.top*scaleY, 
   face.boundingBox.right * scaleX,
   face.boundingBox.bottom * scaleY,), paint); 
   
 
    final double smileProb = face.smilingProbability;
     
 
  
  builder.addText('\n$i: $smileProb\n');
  if(smileProb<=0.3){
  builder.addText('Not Smiling\n');  
  } 
  else builder.addText('Smiling');
  }
  i=0;
  builder.pop();
  
    canvas.drawParagraph(
      builder.build()
        ..layout(ui.ParagraphConstraints(
          width: size.width,
        )),
      const Offset(0.0, 0.0),
    );
  }
  

  @override
  bool shouldRepaint(FaceDetectorPainter oldDelegate){
      return oldDelegate.absoluteImageSize != absoluteImageSize ||
        oldDelegate.faces != faces;
  }
}