// import 'package:flutter/material.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:untitled1/main.dart';
// import 'package:untitled1/networkapi.dart';
//
// class LoadingScreen extends StatefulWidget {
//   @override
//   _LoadingScreenState createState() => _LoadingScreenState();
// }
//
// class _LoadingScreenState extends State<LoadingScreen> {
//   @override
//   void initState() {
//     // super.initState();
//     getCurentlocation();
//   }
//
//   void getCurentlocation() async {
//     var aaddess;
//     var network = await NetworkHelper(
//         'http://ffms.nuceratiles.com:57582/api/Attendance/SendUserLocation');
//     aaddess = await network.postData();
//     setState(() {});
//
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) {
//           return MyHomePage(
//             title: 'Flutter Demo Home Page',
//             network: aaddess,
//           );
//         },
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Center(
//           child: SpinKitWave(
//             color: Colors.black,
//             size: 80.0,
//           ),
//         ),
//       ),
//     );
//   }
// }
