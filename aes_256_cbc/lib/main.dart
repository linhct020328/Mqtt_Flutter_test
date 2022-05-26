import 'package:flutter/material.dart';
import 'package:aes_256_cbc/crypt.dart';

void main() => runApp(MyApp());
class MyApp extends StatelessWidget {
  var enStr = crypt.aesDecrypt("open");
 @override
 Widget build(BuildContext context) {

   return new MaterialApp(
     title: 'Welcome to Flutter',
     home: new Scaffold(
       appBar: new AppBar(
         title: new Text('Welcome to Flutter'),
       ),
       body: new Center(
         child: new Text(enStr),
       ),
     ),
   );
 }
}

//}
//   var text = '123';
//   print('明文：${text}');
//
//   var base = JhEncryptUtils.encodeBase64(text);
//   print('base64: ${base}');
//
//   var enStr = JhEncryptUtils.aesEncrypt(text);
//   print('AES 加密：${enStr}');
//   var deStr = JhEncryptUtils.aesDecrypt(enStr);
//   print('AES 解密：${deStr}');
//
//   var md5 = JhEncryptUtils.encodeMd5(text);
//   print('md5 ：${md5}');
