import 'dart:developer';
import 'package:pinger/pingora.dart';

/// Model class for the pinger
class PingoraModelExample extends Pingora {
  int count = 0;

  increaseCounter() {
    count++;
    log('Count Increased $count');
    ping();
  }
}
