import 'package:ntp/ntp.dart';
int serverTimeOffset = 0;
Future<void> syncTime() async {
  try {
    serverTimeOffset = await NTP.getNtpOffset(lookUpAddress: 'time.google.com');
  } catch (e) {
    serverTimeOffset = 0; 
  }
}

DateTime get trueCurrentTime {
  final localNow = DateTime.now();
  return localNow.add(Duration(milliseconds: serverTimeOffset));
}