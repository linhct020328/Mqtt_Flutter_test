import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:test_mqtt_ssl_tls_image/crypt/crypt.dart';
import 'package:test_mqtt_ssl_tls_image/utils/utils.dart' show ByteUtils, HexUtils;

enum MQTTAppConnectionState { connected, disconnected, connecting }
class MQTTAppState with ChangeNotifier{
  MQTTAppConnectionState _appConnectionState = MQTTAppConnectionState.disconnected;
  String _receivedText = '';
  String _historyText = '';

  Future<void> setReceivedText(String text) async {
    // if(text.length <= 24){
    //   var msgDecode = crypt.aesDecrypt(text);
    //   _receivedText = msgDecode;
    //   _historyText = _historyText + '\n' + _receivedText;
    //   notifyListeners();
    // }
    // else{
      // var imageHex = '';
      // var imageByte = '';


      var imgDecode = crypt.aesDecrypt(mesRes);
      // var imgByte = ByteUtils.hexToBytes(imgDecode);
      // final codec = await instantiateImageCodec(imgByte);
      // final frameInfo = await codec.getNextFrame();
      // = frameInfo.image;

      // var image = bytesToImage(imgByte);
      _receivedText = imgDecode;
      _historyText = _historyText + '\n' + _receivedText;
      notifyListeners();
      print('$imgDecode');
    }

  // }

  // static Future<ui.Image> bytesToImage(Uint8List imgBytes) async {
  //   ui.Codec codec = await ui.instantiateImageCodec(imgBytes);
  //   ui.FrameInfo frame = await codec.getNextFrame();
  //   return frame.image;
  // }

  void setAppConnectionState(MQTTAppConnectionState state) {
    _appConnectionState = state;
    notifyListeners();
  }

  String get getReceivedText => _receivedText;
  String get getHistoryText => _historyText;
  MQTTAppConnectionState get getAppConnectionState => _appConnectionState;

}