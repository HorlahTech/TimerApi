import 'dart:async';
import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'networkapi.dart';

// void postDataInBackground() async {
//   var network = await NetworkHelper(
//       'http://ffms.nuceratiles.com:57582/api/Attendance/SendUserLocation');
//   await network.postData();
// }

// const task = 'firstTask';
// void callbackDispatcher() {
//   Workmanager().executeTask((taskName, inputData) {
//     switch (taskName) {
//       case task:
//         postDataInBackground();
//         break;
//       default:
//     }
//     return Future.value(true);
//   });
// }

Future<void> main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // await Workmanager().initialize(
  //     callbackDispatcher, // The top level function, aka callbackDispatcher
  //     isInDebugMode:
  //         true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
  //     );
  //
  // var uniqueId = DateTime.now().second.toString();
  // await Workmanager().registerOneOffTask(uniqueId, task,
  //     initialDelay: Duration(seconds: 10),
  //     constraints: Constraints(networkType: NetworkType.connected));

  WidgetsFlutterBinding.ensureInitialized();
  await initializeService();

  runApp(const MyApp());
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will be executed when app is in foreground or background in separated isolate
      onStart: onStart,

      // auto start service
      autoStart: true,
      isForegroundMode: true,
    ),
    iosConfiguration: IosConfiguration(
      // auto start service
      autoStart: true,

      // this will be executed when app is in foreground in separated isolate
      onForeground: onStart,

      // you have to enable background fetch capability on xcode project
      onBackground: onIosBackground,
    ),
  );
  service.startService();
}

bool onIosBackground(ServiceInstance service) {
  WidgetsFlutterBinding.ensureInitialized();
  print('FLUTTER BACKGROUND FETCH');

  return true;
}

void onStart(ServiceInstance service) async {
  // Only available for flutter 3.0.0 and later
  DartPluginRegistrant.ensureInitialized();

  // For flutter prior to version 3.0.0
  // We have to register the plugin manually

  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.setString("hello", "world");

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // bring to foreground
  Timer.periodic(const Duration(seconds: 1), (timer) async {
    final hello = preferences.getString("hello");
    print(hello);

    if (service is AndroidServiceInstance) {
      service.setForegroundNotificationInfo(
        title: "My App Service",
        content: "Updated at ${DateTime.now()}",
      );
    }
    var network = await NetworkHelper(
            'http://ffms.nuceratiles.com:57582/api/Attendance/SendUserLocation')
        .postData();
    // await network.postData();

    /// you can see this log in logcat
    print('FLUTTER BACKGROUND SERVICE: ${DateTime.now()}');

    // test using external plugin
    final deviceInfo = DeviceInfoPlugin();
    String? device;
    // if (Platform.isAndroid) {
    //   final androidInfo = await deviceInfo.androidInfo;
    //   device = androidInfo.model;
    // }
    //
    // if (Platform.isIOS) {
    //   final iosInfo = await deviceInfo.iosInfo;
    //   device = iosInfo.model;
    // }

    service.invoke(
      'update',
      {
        "current_date": DateTime.now().toIso8601String(),
        "device": device,
      },
    );
  });
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    FlutterBackgroundService().invoke("setAsBackground");
  }

  String text = "Stop Service";
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Service App'),
        ),
        body: Column(
          children: [
            StreamBuilder<Map<String, dynamic>?>(
              stream: FlutterBackgroundService().on('update'),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final data = snapshot.data!;
                String? device = data["device"];
                DateTime? date = DateTime.tryParse(data["current_date"]);
                return Column(
                  children: [
                    Text(device ?? 'Unknown'),
                    Text(date.toString()),
                  ],
                );
              },
            ),
            ElevatedButton(
              child: const Text("Foreground Mode"),
              onPressed: () {
                FlutterBackgroundService().invoke("setAsForeground");
              },
            ),
            ElevatedButton(
              child: const Text("Background Mode"),
              onPressed: () {
                FlutterBackgroundService().invoke("setAsBackground");
              },
            ),
            ElevatedButton(
              child: Text(text),
              onPressed: () async {
                final service = FlutterBackgroundService();
                var isRunning = await service.isRunning();
                if (isRunning) {
                  service.invoke("stopService");
                } else {
                  service.startService();
                }

                if (!isRunning) {
                  text = 'Stop Service';
                } else {
                  text = 'Start Service';
                }
                setState(() {});
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: const Icon(Icons.play_arrow),
        ),
      ),
    );
  }


}

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);
//
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: LoadingScreen(),
//     );
//   }
// }
//
// class MyHomePage extends StatefulWidget {
//   MyHomePage({Key? key, required this.title, this.network});
//
//   final String title;
//   var network;
//
//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   update(dynamic addess) async {
//     setState(
//       () {
//         if (addess == null) {
//           location = 'Unable to access Location Check your connection';
//           lat = 'Error';
//           long = 'Error';
//           UserId = 0;
//           AttendanceId = 0;
//
//           return;
//         }
//         var lati = jsonDecode(addess)['Latitude'];
//         lat = lati.toString();
//         var longi = jsonDecode(addess)['Longitude'];
//         long = longi.toString();
//         var loc = jsonDecode(addess)['Location'];
//         location = loc.toString();
//         var user = jsonDecode(addess)['UserId'];
//         UserId = user.toInt();
//         var attendance = jsonDecode(addess)['AttendanceId'];
//         AttendanceId = attendance.toInt();
//       },
//     );
//   }
//
//   void _timeee() {
//     var oneSec = Duration(minutes: 1);
//     Timer.periodic(oneSec, (timer) {
//       setState(() {
//         pust++;
//         update(widget.network);
//
//         // var network = await NetworkHelper(
//         //     'http://ffms.nuceratiles.com:57582/api/Attendance/SendUserLocation');
//         // network.postData();
//       });
//     });
//   }
//
//   @override
//   void initState() {
//     update(widget.network);
//     _timeee();
//   }
//
//   int pust = 1;
//   String? long, lat, location;
//   int? AttendanceId, UserId;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Text(
//               'We have Sent Location to the Api this many time: $pust',
//             ),
//             Text(
//               'Response data from api = ',
//             ),
//             Text(
//               'Longitude = ${long}',
//               style: Theme.of(context).textTheme.headline4,
//             ),
//             Text(
//               'Latitude = ${lat}',
//               style: Theme.of(context).textTheme.headline4,
//             ),
//             Text(
//               'AttendanceId = ${AttendanceId}',
//               style: Theme.of(context).textTheme.headline4,
//             ),
//             Text(
//               'UserId = ${UserId}',
//               style: Theme.of(context).textTheme.headline4,
//             ),
//             Text(
//               'Location address ${location}',
//               style: Theme.of(context).textTheme.headline4,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
