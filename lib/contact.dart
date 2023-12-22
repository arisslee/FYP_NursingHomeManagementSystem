import 'package:flutter/material.dart';
//import 'package:google_maps_flutter/google_maps_flutter.dart';

class ContactUsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // // Define the initial camera position for the Google Map
    // CameraPosition initialPosition = CameraPosition(
    //   target: LatLng(1.12345, 2.67890), // Replace with your actual coordinates
    //   zoom: 15.0, // Adjust the initial zoom level as needed
    // );

    return Scaffold(
      appBar: AppBar(
        title: Text('Contact Us'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Logo image at the top
              Image.asset(
                'assets/logo.png', // Replace with the actual path to your logo image
                width: 250.0, // Adjust the width as needed
                height: 250.0, // Adjust the height as needed
              ),
              // Container with rounded border and shadow
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                      20.0), // Adjust the radius as needed
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(
                          0.5), // Adjust the shadow color and opacity
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3), // Adjust the offset of the shadow
                    ),
                  ],
                ),
                margin: EdgeInsets.symmetric(
                    horizontal: 20.0), // Add horizontal margin
                padding: EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ListTile(
                      leading: Icon(Icons.access_time),
                      title: Text(
                        'Office Hours',
                        style: TextStyle(fontSize: 18.0),
                      ),
                      subtitle: Text(
                        'Mon-Fri\n9:00 AM - 5:00 PM',
                        style: TextStyle(fontSize: 18.0),
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.phone),
                      title: Text(
                        'Phone',
                        style: TextStyle(fontSize: 18.0),
                      ),
                      subtitle: Text(
                        '+607 513 0034',
                        style: TextStyle(fontSize: 18.0),
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.email),
                      title: Text(
                        'Email',
                        style: TextStyle(fontSize: 18.0),
                      ),
                      subtitle: Text(
                        'lifespring@gmail.com',
                        style: TextStyle(fontSize: 18.0),
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.location_on),
                      title: Text(
                        'Address',
                        style: TextStyle(fontSize: 18.0),
                      ),
                      subtitle: Text(
                        '2, Jalan Nusa Perintis 4/10, Taman Nusa Perintis 1, Gelang Patah, Johor 81550 Malaysia',
                        style: TextStyle(fontSize: 18.0),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.0),
              // // Google Map
              // Container(
              //   width: 300.0,
              //   height: 300.0,
              //   margin: EdgeInsets.only(top: 16.0),
              //   child: GoogleMap(
              //     onMapCreated: (GoogleMapController controller) {
              //       // You can add custom logic here if needed.
              //     },
              //     initialCameraPosition: CameraPosition(
              //       target: LatLng(
              //           1.12345, 2.67890), // Replace with your coordinates
              //       zoom: 15.0,
              //     ),
              //     markers: Set<Marker>.of([
              //       Marker(
              //         markerId: MarkerId('lifespring_location'),
              //         position: LatLng(
              //             1.12345, 2.67890), // Replace with your coordinates
              //       ),
              //     ]),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
