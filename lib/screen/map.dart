// import 'package:flutter/material.dart';

// class MapPage extends StatefulWidget {
//   const MapPage({super.key});

//   @override
//   State<MapPage> createState() => _MapPageState();
// }

// class _MapPageState extends State<MapPage> with SingleTickerProviderStateMixin {
//   late AnimationController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(vsync: this);
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         body: Container(
//             height: MediaQuery.of(context).size.height,
//             width: MediaQuery.of(context).size.width,
//             child: InteractiveViewer(
//                 child: Stack(
//               children: [
//                 Image.asset(
//                   'assets/png/map.png',
//                   width: MediaQuery.of(context).size.width,
//                   height: MediaQuery.of(context).size.height,
//                 ),
//                 Image.asset(
//                   'assets/png/administration to football.png',
//                   width: MediaQuery.of(context).size.width,
//                   height: MediaQuery.of(context).size.height,
//                 ),
//                 Image.asset(
//                   'assets/png/civil to node12.png',
//                   width: MediaQuery.of(context).size.width,
//                   height: MediaQuery.of(context).size.height,
//                 ),
//               ],
//             ))));
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:route_master/data.dart';
import 'package:route_master/dijkstra_algorithm.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

// particular point ma kasari change render hunxa
class _MapPageState extends State<MapPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
// drop down menu ma kk dekhaune tesko list ho
  List<String> locations = [
    "",
    'Administration',
    'Agriculture Department',
    'Applied Science Department',
    'Architecture Department',
    'Back Gate',
    'Boys Hostel',
    'Canteen',
    'Civil Department',
    'Electronic and Computer Department',
    'Electrical Department',
    'Fabrication Shop',
    'Farm Machinery',
    'Football Ground',
    'Four Lamp',
    'GCR Block',
    'Girls Hostel',
    'Jungle',
    'Library',
    'Main Gate',
    'Mechaninal Department'
  ];
// suru ma drop down menu ma khali dekhaune ho yo
  String currentselectedLocation = '';
  String destselectedLocation = '';
  List<Widget> mapImage = []; // overlay image ko list yaha liyara rakhne ho

  @override
  void initState() {
    //state widget banda kheri  suru ma k kaam garne  consturctor
    super
        .initState(); // stateful widget banda kheri initial state kasto banxa bhanera bhanxa
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    // app close bhayesi kk cleanup garne ho
    _controller.dispose();
    super.dispose();
  }

  void _showErrorToast(BuildContext context, String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  Future<bool> checkAssetExists(String assetPath) async {
    try {
      // Attempt to load the asset to see if it exists
      await rootBundle.load(assetPath);
      // If load succeeds, asset exists
      return true;
    } catch (e) {
      // If load fails, asset doesn't exist
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // screen ma dekhine white portion
      appBar: AppBar(
        title: Text('Route Master'),
      ),
      body: Container(
        // screen ko size aanusar le hight width change hunxa
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ' FROM ',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            SizedBox(
              height: 5,
            ),
            DropdownButton<String>(
              value: currentselectedLocation,
              onChanged: (String? newValue) {
                setState(() {
                  currentselectedLocation = newValue ?? '';
                });
              },
              items: locations.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            Text(
              ' TO ',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            SizedBox(
              height: 5,
            ),
            DropdownButton<String>(
              value: destselectedLocation,
              onChanged: (String? newValue) {
                setState(() {
                  destselectedLocation = newValue ?? '';
                });
              },
              items: locations.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            Container(
              height: MediaQuery.of(context).size.height * 0.06,
              width: MediaQuery.of(context).size.width * 0.3,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.orange,
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.grey.withOpacity(0.5), // Color of the shadow
                      spreadRadius: 3, // Spread radius
                      blurRadius: 4, // Blur radius
                      offset: Offset(0, 0), // Offset of the shadow
                    ),
                  ]),
              child: InkWell(
                onTap: () async {
                  if (currentselectedLocation == '' ||
                      destselectedLocation == '') {
                    _showErrorToast(
                        context, 'Provide Valid Source and Destination');
                  } else if (currentselectedLocation == destselectedLocation) {
                    _showErrorToast(
                        context, "Source and Destination shouldn't be same");
                  } else {
                    Graph graph = Graph(distanceMap);
                    List<String> spath = graph.shortestPath(
                        AvailableMappedLocations[currentselectedLocation]!,
                        AvailableMappedLocations[destselectedLocation]!);

                    mapImage.clear();
                    for (var i = 0; i < spath.length - 1; i++) {
                      String filePath = '';

                      if (await checkAssetExists(
                          'assets/png/${spath[i]} to ${spath[i + 1]}.png')) {
                        filePath =
                            'assets/png/${spath[i]} to ${spath[i + 1]}.png';
                      } else {
                        filePath =
                            'assets/png/${spath[i + 1]} to ${spath[i]}.png';
                      }

                      mapImage.add(Image.asset(
                        filePath,
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                      ));
                    }
                    setState(() {});
                  }
                },
                child: Center(
                  child: Text(
                    'Search',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Expanded(
              child: InteractiveViewer(
                  child: Stack(children: [
                Image.asset(
                  'assets/png/map.png',
                  width: double.infinity,
                  height: double.infinity,
                ),
                ...mapImage
              ])),
            ),
          ],
        ),
      ),
    );
  }
}
