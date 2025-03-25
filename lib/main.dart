import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_place/google_place.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:latlong2/latlong.dart' as latlong;  // latlong import for latlong2
import 'dart:convert';  // for JSON datas
import 'package:http/http.dart' as http;  // For HTTP
import 'dart:math';
import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';  // Permission handler import
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // İkonlar için paket


double degreesToRadians(double degree) {
  return degree * (pi / 180);
}

double radiansToDegrees(double radian) {
  return radian * (180 / pi);
}

double calculateNewLatitude(double latitude, double distance) {
  const earthRadius = 6371000;  // meters
  double delta = distance / earthRadius;  // angular distance in radians
  return radiansToDegrees(degreesToRadians(latitude) + delta);
}

double calculateNewLongitude(double longitude, double latitude, double distance) {
  const earthRadius = 6371000;  // meters
  double delta = distance / earthRadius;  // angular distance in radians
  double latInRad = degreesToRadians(latitude);
  double deltaLon = radiansToDegrees(delta / cos(latInRad));
  return longitude + deltaLon;
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );


  runApp(MyApp());
}

// List for keeping user's information
List<Map<String, String>> users = [];

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          buildAnimatedBackground(),
          Opacity(
            opacity: 0.5, // opacity level
            child: Image.asset(
              'assets/blindlesslogo.jpg', // path of the photo
              fit: BoxFit.cover, // Ekranı doldurması için
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "BLINDLESS",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple[700],
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Let's Get",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "Started",
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple[700],
                  ),
                ),
                SizedBox(height: 40),
                _buildSignInButton(context),
                SizedBox(height: 20),
                buildRelativeSigninButton(context), // Relative Sign In butonu eklendi
                SizedBox(height: 20),
                Text(
                  "OR SIGN IN WITH",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                _buildSocialSignInButtons(),
                SizedBox(height: 40),
                _buildSignUpLink(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAnimatedBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  Widget _buildSignInButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => UserLoginPage()),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF880E4F),
        padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 100.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Text(
        "SIGN IN",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget buildRelativeSigninButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RelativeLoginPage()), // Relative Login sayfasına yönlendirme
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 100.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Text(
        "RELATIVE SIGN IN",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSocialSignInButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialButton(Icons.email, Colors.pink[900]!),
        SizedBox(width: 20),
        _buildSocialButton(Icons.phone, Colors.pink[900]!),
      ],
    );
  }

  Widget _buildSocialButton(IconData icon, Color color) {
    return CircleAvatar(
      backgroundColor: color,
      radius: 25,
      child: Icon(
        icon,
        color: Colors.white,
        size: 30,
      ),
    );
  }

  Widget _buildSignUpLink(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to the sign-up page
      },
      child: Text(
        "DON'T HAVE ACCOUNT? SIGN UP NOW",
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}


class UserLoginPage extends StatefulWidget {
  @override
  _UserLoginPageState createState() => _UserLoginPageState();
}

class _UserLoginPageState extends State<UserLoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Firebase Authentication ile giriş işlemi
  void _login() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Başarılı giriş sonrası yönlendirme
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => UserDashboard()),
      );
    } on FirebaseAuthException catch (e) {
      // Hata durumunda kullanıcıya mesaj göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "There is an error")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF4A00E0), // Dark blue
                  Color(0xFF8E2DE2), // Purple
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Semi-transparent background image
          Opacity(
            opacity: 0.4,
            child: Image.asset(
              'assets/blindlesslogo.jpg', // Replace with your image path
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),

          // Main content
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(children: [
                      IconButton(
                        icon:Icon(
                            Icons.arrow_back,color:Colors.pink[900]
                        ),
                        onPressed: (){
                          Navigator.pop(context);
                        },
                      )
                    ],),
                    Text(
                      "Welcome Back!",
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),



                    // Email TextField
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          hintText: 'Email Address',
                          prefixIcon: Icon(Icons.email, color: Colors.white),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),

                        ),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Password TextField
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          prefixIcon: Icon(Icons.lock, color: Colors.white),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),

                        ),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Remember me and Forgot Password
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: false,
                              onChanged: (value) {},
                              activeColor: Colors.white,
                            ),
                            Text(
                              'Remember me',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),

                    // Login Button
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 100),
                        backgroundColor: Color(0xFF880E4F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'LOG IN',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    // Sign up link
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => UserSignUpPage()),
                        );
                      },
                      child: RichText(
                        text: TextSpan(
                          text: "Don't have an account? ",
                          style: TextStyle(color: Colors.white),
                          children: [
                            TextSpan(
                              text: 'Sign up',
                              style: TextStyle(
                                color: Colors.pink,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
Widget _buildTextField(String hint, TextEditingController controller, {bool obscure = false}) {
  return TextField(
    controller: controller,
    obscureText: obscure,
    decoration: InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(),
      filled: true,
      fillColor: Colors.white,
    ),
  );
}


class UserDashboard extends StatefulWidget {
  @override
  _UserDashboardState createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  final FlutterTts flutterTts = FlutterTts();
  int? currentDistance;
  Timer? timer;
  bool isCalculating = false;
  bool isFirstCalculation = true;

  @override
  void initState() {
    super.initState();
    flutterTts.setSpeechRate(0.7); // Konuşma hızı (daha hızlı)
    flutterTts.setLanguage("en-US");
  }

  @override
  void dispose() {
    timer?.cancel();
    flutterTts.stop();
    super.dispose();
  }

  void _startDistanceSimulation() async {
    if (isCalculating) return; // Zaten çalışıyorsa tekrar başlatma
    setState(() {
      isCalculating = true;
      isFirstCalculation = true;
    });
    await flutterTts.speak("Start calculating");
    timer = Timer.periodic(Duration(seconds: 10), (timer) {
      setState(() {
        currentDistance = Random().nextInt(100); // Rastgele mesafe (0-99)
        isFirstCalculation = false; // İlk hesaplama tamamlandı
      });
      _speakDistance();
    });
  }

  void _stopDistanceSimulation() async {
    if (!isCalculating) return; // Çalışmıyorsa işlem yapma
    setState(() {
      isCalculating = false;
      currentDistance = null;
    });
    timer?.cancel();
    await flutterTts.speak("Stop calculating");
  }

  Future<void> _speakDistance() async {
    if (currentDistance != null) {
      String message;
      if (currentDistance! < 15) {
        message = "Warning. You are ${currentDistance!} meters close to the obstacle.";
      } else if (currentDistance! >= 15 && currentDistance! < 50) {
        message = "There are ${currentDistance!} meters far away.";
      } else {
        message = "Safe. You are ${currentDistance!} meters far away.";
      }
      await flutterTts.speak(message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple, Colors.blue],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 0.3,
              child: Image.asset(
                'assets/blindlesslogo.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDashboardButton(
                    context,
                    "Information of Transportation",
                    Icons.directions_bus,
                        () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PublicTransportPage()),
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildDashboardButton(
                    context,
                    "Navigation",
                    Icons.navigation,
                        () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => NavigationPage()),
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildDashboardButton(
                    context,
                    "Information of Environment",
                    Icons.location_on,
                        () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EnvironmentInfoPage()),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 70,
            left: 10,
            right: 10,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 5,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Distance Warning",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    isCalculating
                        ? (isFirstCalculation
                        ? "Calculating..."
                        : "$currentDistance meters")
                        : "Press start to calculate",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _startDistanceSimulation,
                  child: Text("Start Calculating"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
                ElevatedButton(
                  onPressed: _stopDistanceSimulation,
                  child: Text("Stop Calculating"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardButton(
      BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.4),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.blue),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class NavigationPage extends StatefulWidget {
  @override
  _NavigationPageState createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  final MapController _mapController = MapController();
  LatLng? _currentLocation;
  LatLng? _destination;
  List<LatLng> _routePoints = [];
  String? _duration;
  String _selectedMode = 'foot-walking'; // Walking mode
  final List<String> _modes = ['driving-car', 'foot-walking']; // Walking and car modes
  bool _isNavigationStarted = false;
  List<String> _directions = []; // List to hold the directions

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
      print("Current Location: $_currentLocation");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Konum izni verilmedi.')));
    }
  }

  Future<LatLng?> _getCoordinatesFromAddress(String address) async {
    final String apiKey = '0d54942a17774e8caa73685cf098098c'; // OpenCage API key
    final String url =
        'https://api.opencagedata.com/geocode/v1/json?q=${Uri.encodeComponent(address)}&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['results'].isNotEmpty) {
          final firstResult = data['results'][0];
          final geometry = firstResult['geometry'];
          return LatLng(geometry['lat'], geometry['lng']);
        } else {
          print('Adres bulunamadı.');
          return null;
        }
      } else {
        print('Geocoding başarısız: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Geocoding hatası: $e');
      return null;
    }
  }

  Future<void> _getRouteAndDuration(LatLng destination) async {
    if (_currentLocation == null) return;

    final String apiKey = '5b3ce3597851110001cf62488ec18986bae14957aa2f9ef172cb0956'; // OpenRouteService API key
    final String url =
        'https://api.openrouteservice.org/v2/directions/$_selectedMode?api_key=$apiKey&start=${_currentLocation!.longitude},${_currentLocation!.latitude}&end=${destination.longitude},${destination.latitude}';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final route = data['features'][0]['geometry']['coordinates'] as List;
        final duration = (data['features'][0]['properties']['segments'][0]['duration'] / 60).toStringAsFixed(1);

        // Fetching detailed directions from the response
        List<String> directions = [];
        final steps = data['features'][0]['properties']['segments'][0]['steps'] as List;
        for (var step in steps) {
          String instruction = step['instruction'];
          directions.add(instruction);  // Adding instruction in English
        }

        setState(() {
          _routePoints = route.map((point) => LatLng(point[1], point[0])).toList();
          _duration = '$duration minutes';
          _destination = destination;
          _directions = directions;  // Store the detailed directions in English
        });
      } else {
        print('Route calculation failed: ${response.body}');
      }
    } catch (e) {
      print('Route error: $e');
    }
  }

  // Define _startNavigation method to handle starting navigation
  Future<void> _startNavigation() async {
    if (_routePoints.isEmpty) return;

    setState(() {
      _isNavigationStarted = true; // Mark the navigation as started
    });

    // In a real-world scenario, you would trigger navigation (e.g., using a package or GPS)
    print("Navigation started");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: TextField(
            decoration: InputDecoration(
              hintText: "Write your destination",
              suffixIcon: Icon(Icons.search),
            ),
            onSubmitted: (value) async {
              final destination = await _getCoordinatesFromAddress(value);
              if (destination != null) {
                await _getRouteAndDuration(destination);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Adres bulunamadı. Lütfen farklı bir adres deneyin.')),
                );
              }
            },
          ),
        ),
        body: Stack(
            children: [
              if (_currentLocation != null)
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    center: _currentLocation,
                    zoom: 13.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                      "https://tile.thunderforest.com/outdoors/{z}/{x}/{y}.png?apikey=4d8dd10ae227452283eec21edef16bd5",
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _currentLocation!,
                          builder: (ctx) => Icon(Icons.location_pin, color: Colors.blue, size: 40),
                        ),
                        if (_destination != null)
                          Marker(
                            point: _destination!,
                            builder: (ctx) => Icon(Icons.flag, color: Colors.red, size: 40),
                          ),
                      ],
                    ),
                    if (_routePoints.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _routePoints,
                            strokeWidth: 4.0,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                  ],
                ),
              if (_duration != null)
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Tahmini Süre: $_duration",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              // Start button for navigation
              if (_routePoints.isNotEmpty && !_isNavigationStarted)
                Positioned(
                  bottom: 80,
                  left: 20,
                  right: 20,
                  child: ElevatedButton(
                    onPressed: _startNavigation,
                    child: Text('Start'),
                  ),
                ),
              // Directions when navigation is started
              if (_isNavigationStarted)
                Positioned(
                  bottom: 120,
                  left: 20,
                  right: 20,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _directions
                            .map((direction) => Text(direction, style: TextStyle(fontSize: 16)))
                            .toList(),
                      ),
                    ),
                  ),
                ),
            ],
            ),
        );
    }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const DashboardCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
            width: double.infinity,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 5,
                  offset: Offset(2, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 40, color: Colors.blue),
                SizedBox(width: 20),
                Text(
                  title,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ],
            ),
           ),
        );
    }
}
class PublicTransportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Information of Transportation"),
          backgroundColor: Colors.blue,
        ),
        body: Stack(
            children: [
              // Arka plan animasyonu ve GIF
              AnimatedBackground(),
              Positioned.fill(
                child: Opacity(
                  opacity: 0.2, // Şeffaflık değeri
                  child: Image.asset(
                    'assets/worldmap.gif', // Görselin yolu
                    fit: BoxFit.cover, // Görselin ekranı kaplamasını sağlar
                  ),
                ),
              ),
              // Burada geri butonunu kaldırdık
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Transportation Information",
                        style: TextStyle(
                          fontSize: 25, // Küçük font boyutu
                          fontWeight: FontWeight.bold,
                          color: Colors.black, // Koyu siyah renk
                        ),
                      ),
                      SizedBox(height: 30),
                      // Tram Information Butonu
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TramInfoPage(),
                            ),
                          );
                        },
                        icon: FaIcon(
                          FontAwesomeIcons.train,
                          size: 45,
                          color: Colors.white, // Tramvay ikonu beyaz
                        ),
                        label: Text(
                          "Tram Information",
                          style: TextStyle(
                            fontSize: 20, // Buton metni biraz daha büyük
                            color: Colors.white, // Koyu siyah renk
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent, // Şeffaf arka plan
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40), // Butonun büyüklüğü
                        ),
                      ),
                      SizedBox(height: 20),
                      // Bus Information Butonu
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BusInfoPage(),
                            ),
                          );
                        },
                        icon: FaIcon(
                          FontAwesomeIcons.bus,
                          size: 45,
                          color: Colors.white, // Otobüs ikonu beyaz
                        ),
                        label: Text(
                          "Bus Information",
                          style: TextStyle(
                            fontSize: 20, // Buton metni biraz daha büyük
                            color: Colors.white, // Koyu siyah renk
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent, // Şeffaf arka plan
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40), // Butonun büyüklüğü
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            ),
       );
    }
}
class TramSchedulePage extends StatelessWidget {
  final String tramLine;

  TramSchedulePage({required this.tramLine});

  final Map<String, List<String>> schedule = {
    'Weekday': [
      "06:10", "06:30", "06:40", "06:50", "07:00", "07:10", "07:20", "07:30", "07:40", "07:50", "08:00",
      "08:10", "08:20", "08:30", "08:40", "08:50", "09:00", "09:10", "09:20", "09:30", "09:40", "09:50",
      "10:00", "10:10", "10:20", "10:30", "10:40", "10:50", "11:00", "11:10", "11:20", "11:30", "11:40",
      "11:50", "12:00", "12:10", "12:20", "12:30", "12:40", "12:50", "13:00", "13:10", "13:20", "13:30",
      "13:40", "13:50", "14:00", "14:10", "14:20", "14:30", "14:40", "14:50", "15:00", "15:10", "15:20",
      "15:30", "15:40", "15:50", "16:00", "16:10", "16:20", "16:30", "16:40", "16:50", "17:00", "17:10",
      "17:20", "17:30", "17:40", "17:50", "18:00", "18:10", "18:20", "18:30", "18:40", "18:50", "19:00",
      "19:10", "19:20", "19:30", "19:40", "19:50", "20:00", "20:10", "20:20", "20:30"
    ],
    'Saturday': [
      "06:10", "06:30", "06:45", "07:00", "07:10", "07:20", "07:30", "07:40", "07:50", "08:00", "08:10",
      "08:20", "08:30", "08:40", "08:50", "09:00", "09:15", "09:30", "09:45", "10:00", "10:15", "10:30",
      "10:45", "11:00", "11:15", "11:30", "11:45", "12:00", "12:15", "12:30", "12:45", "13:00", "13:15",
      "13:30", "13:45", "14:00", "14:15", "14:30", "14:45", "15:00", "15:10", "15:20", "15:30", "15:40",
      "15:50", "16:00", "16:10", "16:20", "16:30", "16:40", "16:50", "17:00", "17:10", "17:20", "17:30",
      "17:40", "17:50", "18:00", "18:10", "18:20", "18:30", "18:40", "18:50", "19:00", "19:10", "19:20",
      "19:30", "19:40", "19:50", "20:00", "20:10", "20:20", "20:30"
    ],
    'Sunday': [
      "07:00", "07:20", "08:00", "08:20", "08:40", "09:00", "09:20", "09:40", "10:00", "10:20", "10:40",
      "11:00", "11:15", "11:30", "11:45", "12:00", "12:15", "12:30", "12:45", "13:00", "13:15", "13:30",
      "13:45", "14:00", "14:15", "14:30", "14:45", "15:00", "15:15", "15:30", "15:45", "16:00", "16:15",
      "16:30", "16:45", "17:00", "17:15", "17:30", "17:45", "18:00", "18:15", "18:30", "18:45", "19:00",
      "19:10", "19:20", "19:30", "19:40", "19:50", "20:00", "20:10", "20:20", "20:30"
    ]
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/tramphoto.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            AppBar(
              title: Text("Schedule - $tramLine"),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildScheduleHeader('Weekday'),
                          _buildScheduleHeader('Saturday'),
                          _buildScheduleHeader('Sunday'),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildScheduleColumn(schedule['Weekday']!),
                          _buildScheduleColumn(schedule['Saturday']!),
                          _buildScheduleColumn(schedule['Sunday']!),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleHeader(String day) {
    return Expanded(
      child: Text(
        day,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.black,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildScheduleColumn(List<String> times) {
    return Expanded(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: times.map((time) {
              return Container(
                margin: EdgeInsets.symmetric(vertical: 3.0), // Her saat için aralık
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7), // Yumuşak bir beyaz arka plan
                  borderRadius: BorderRadius.circular(8), // Yuvarlatılmış köşeler
                ),
                child: Text(
                  time,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold, // Kalın font
                    color: Colors.black, // Siyah renk
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }).toList(),
           ),
       );
   }
}




// AnimatedBackground widget'ı
class AnimatedBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue, Colors.purple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}

class TramDetailsPage extends StatelessWidget {
  final String tramLine;

  TramDetailsPage({required this.tramLine});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Tram Line - $tramLine Details"),
          backgroundColor: Colors.blue,
        ),
        body: Stack(
            children: [
              // Arka plan resmi
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/tramphoto.jpg"), // tramphoto.jpg dosyasını assets klasörüne eklemeyi unutmayın
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Butonlar
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                          elevation: 5,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TramSchedulePage(tramLine: tramLine),
                            ),
                          );
                        },
                        child: Text(
                          "Schedule",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                          elevation: 5,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TramRoutePage(tramLine: tramLine),
                            ),
                          );
                        },
                        child: Text(
                          "Route",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            ),
        );
    }
}

class TramInfoPage extends StatefulWidget {
  @override
  _TramInfoPageState createState() => _TramInfoPageState();
}

class _TramInfoPageState extends State<TramInfoPage> {
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Stack(
        children: [
          // Arka plan resmi
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/tramphoto.jpg"), // tramphoto.jpg dosyasını assets klasörüne eklemeyi unutmayın
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 0.2, // Şeffaflık değeri
              child: Image.asset(
                'assets/tramphoto.jpg', // Görselin yolu
                fit: BoxFit.cover, // Görselin ekranı kaplamasını sağlar
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context); // Önceki sayfaya dön
              },
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Search for Tram Line",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // Koyu siyah renk
                    ),
                  ),
                  SizedBox(height: 20),
                  // TextField için şeffaf, yuvarlak köşeli kutu
                  Container(
                    width: double.infinity, // Sayfaya tam sığması için
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        labelText: "Enter Tram Line (e.g., T1, T2, T3, T4)",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15), // Yuvarlak köşeler
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.5), // Beyaz şeffaf arka plan
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Search Butonu
                  ElevatedButton(
                    onPressed: () {
                      String tramLine = searchController.text.toUpperCase();

                      if (tramLine == 'T1' || tramLine == 'T2' || tramLine == 'T3' || tramLine == 'T4') {
                        // TramDetailsPage'e yönlendir
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TramDetailsPage(tramLine: tramLine),
                          ),
                        );
                      } else {
                        // Hata mesajı
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Tram line not found.")),
                        );
                      }
                    },
                    child: Text(
                      "Search",
                      style: TextStyle(fontSize: 20),
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                      elevation: 5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// AnimatedBackground widget'ı

// TramSchedulePage, TramRoutePage, and TramStopsPage now accept 'tramLine' parameter




class TramRoutePage extends StatelessWidget {
  final String tramLine;

  TramRoutePage({required this.tramLine});

  // Define the routes for each tram line
  final Map<String, List<String>> tramRoutes = {
    'T1': [
      "Organize Sanayi", "Tınaz Tepe", "Ondokuz Mayıs", "Belsin Kürsü",
      "Selimiye", "Anafartalar", "Keykubat", "Sakarya", "Stadyum",
      "Köprülü Kavşak", "Yazı Bağları", "Esentepe", "DSI-Yeni Sanayi",
      "Osman Kavuncu", "Karayolları", "Aydınlıkevler", "Eski Sanayi",
      "Düvenönü", "Cumhuriyet Meydanı", "Hunat", "Büyükşehir Belediyesi",
      "Fuzuli", "Alpaslan", "Tuna", "Erciyes Evler", "Çifte Kümbet",
      "Yıldız Evler", "Doğu Terminali", "Mimarsinan Kavşağı", "Gökkent",
      "Kumarlı", "Harikalar Diyarı", "Cırgalan", "Ahi Evran",
      "Gesi Kavşağı", "Beyazşehir", "Toki Kavşağı", "Millet", "İldem1",
      "İldem2", "İldem3", "İldem4", "İldem5"
    ],
    'T2': [
      "Talas Cemil Baba", "Talas Belediyesi", "Bahçelievler", "Yurtlar Bölgesi",
      "Kızılay Kan Merkezi", "Lojmanlar", "Hastaneler", "Erciyes Üniversitesi",
      "Teknopark", "Şehit Furkan Doğan", "Şehit Mustafa Şimşek",
      "Sema Yazar Parkı", "Tuna", "Alpaslan", "Fuzuli", "Büyükşehir Belediyesi",
      "Hunat", "Cumhuriyet Meydanı"
    ],
    'T3': [
      "Cumhuriyet Meydanı", "İZZET BAYRAKTAR CAMİİ", "TURGUT ÖZAL",
      "ANAYURT PAZAR YERİ", "HALEF HOCA", "KAYSERİ Üniversitesi",
      "GERMİRALTI", "DEDEMAN İMAM HATİP LİSESİ", "KEÇİTEPESİ",
      "YILDIRIM BEYAZIT", "Şehit Mustafa Şimşek", "Sema Yazar Parkı",
      "Tuna", "Alpaslan", "Fuzuli", "Büyükşehir Belediyesi", "Hunat",
      "Cumhuriyet Meydanı"
    ],
    'T4': [
      "Cumhuriyet Meydanı", "İZZET BAYRAKTAR CAMİİ", "TURGUT ÖZAL",
      "ANAYURT PAZAR YERİ", "HALEF HOCA", "KAYSERİ Üniversitesi",
      "GERMİRALTI", "DEDEMAN İMAM HATİP LİSESİ", "KEÇİTEPESİ",
      "YILDIRIM BEYAZIT", "Şehit Mustafa Şimşek", "Sema Yazar Parkı",
      "Tuna", "Alpaslan", "Fuzuli", "Büyükşehir Belediyesi", "Hunat",
      "Cumhuriyet Meydanı"
    ],
  };

  @override
  Widget build(BuildContext context) {
    List<String> routeStops = tramRoutes[tramLine] ?? ["Route not found"];

    return Scaffold(
        body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/tramphoto.jpg"),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              children: [
                AppBar(
                  title: Text("Route - $tramLine"),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: routeStops.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 4.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: ListTile(
                          title: Text(
                            routeStops[index],
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            ),
        );
    }
}



class BusInfoPage extends StatefulWidget {
  @override
  _BusInfoPageState createState() => _BusInfoPageState();
}
class _BusInfoPageState extends State<BusInfoPage> {
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bus Information"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Search for Bus Line",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: "Enter Bus Line (e.g., T15, 485)",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String busLine = searchController.text.toUpperCase();

                if (busLine == 'T15' || busLine == '485' ) {
                  // Navigate to TramDetailsPage and pass the tramLine
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BusDetailsPage(busLine: busLine),
                    ),
                  );
                } else {
                  // Show error message if the tram line is not found
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Bus line not found.")),
                  );
                }
              },
              child: Text("Search"),
            ),
          ],
        ),
      ),
    );
  }
}

class BusDetailsPage extends StatelessWidget {
  final String busLine;

  BusDetailsPage({required this.busLine});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bus Line - $busLine Details"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BusSchedulePage(busLine: busLine),
                  ),
                );
              },
              child: Text("Schedule"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BusRoutePage(busLine: busLine),
                  ),
                );
              },
              child: Text("Route"),
            ),
          ],
        ),
      ),
    );
  }
}

class BusSchedulePage extends StatelessWidget {
  final String busLine;

  BusSchedulePage({required this.busLine});

  // Haftalık otobüs saat bilgisi
  final Map<String, List<String>> schedule = {
    'Weekday': [
      "06:10", "06:30", "06:40", "06:50", "07:00", "07:10", "07:20", "07:30", "07:40", "07:50", "08:00",
      "08:10", "08:20", "08:30", "08:40", "08:50", "09:00", "09:10", "09:20", "09:30", "09:40", "09:50",
      "10:00", "10:10", "10:20", "10:30", "10:40", "10:50", "11:00", "11:10", "11:20", "11:30", "11:40",
      "11:50", "12:00", "12:10", "12:20", "12:30", "12:40", "12:50", "13:00", "13:10", "13:20", "13:30",
      "13:40", "13:50", "14:00", "14:10", "14:20", "14:30", "14:40", "14:50", "15:00", "15:10", "15:20",
      "15:30", "15:40", "15:50", "16:00", "16:10", "16:20", "16:30", "16:40", "16:50", "17:00", "17:10",
      "17:20", "17:30", "17:40", "17:50", "18:00", "18:10", "18:20", "18:30", "18:40", "18:50", "19:00",
      "19:10", "19:20", "19:30", "19:40", "19:50", "20:00", "20:10", "20:20", "20:30"
    ],
    'Saturday': [
      "06:10", "06:30", "06:45", "07:00", "07:10", "07:20", "07:30", "07:40", "07:50", "08:00", "08:10",
      "08:20", "08:30", "08:40", "08:50", "09:00", "09:15", "09:30", "09:45", "10:00", "10:15", "10:30",
      "10:45", "11:00", "11:15", "11:30", "11:45", "12:00", "12:15", "12:30", "12:45", "13:00", "13:15",
      "13:30", "13:45", "14:00", "14:15", "14:30", "14:45", "15:00", "15:10", "15:20", "15:30", "15:40",
      "15:50", "16:00", "16:10", "16:20", "16:30", "16:40", "16:50", "17:00", "17:10", "17:20", "17:30",
      "17:40", "17:50", "18:00", "18:10", "18:20", "18:30", "18:40", "18:50", "19:00", "19:10", "19:20",
      "19:30", "19:40", "19:50", "20:00", "20:10", "20:20", "20:30"
    ],
    'Sunday': [
      "07:00", "07:20", "08:00", "08:20", "08:40", "09:00", "09:20", "09:40", "10:00", "10:20", "10:40",
      "11:00", "11:15", "11:30", "11:45", "12:00", "12:15", "12:30", "12:45", "13:00", "13:15", "13:30",
      "13:45", "14:00", "14:15", "14:30", "14:45", "15:00", "15:15", "15:30", "15:45", "16:00", "16:15",
      "16:30", "16:45", "17:00", "17:15", "17:30", "17:45", "18:00", "18:15", "18:30", "18:45", "19:00",
      "19:10", "19:20", "19:30", "19:40", "19:50", "20:00", "20:10", "20:20", "20:30"
    ]
  };
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Schedule - $busLine"),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView( // Wrap the body with SingleChildScrollView to allow scrolling
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Weekday:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              _buildScheduleList(schedule['Weekday']!),
              SizedBox(height: 10),
              Text(
                'Saturday:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              _buildScheduleList(schedule['Saturday']!),
              SizedBox(height: 10),
              Text(
                'Sunday:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              _buildScheduleList(schedule['Sunday']!),
            ],
          ),
        ),
      ),
    );
  }

// Helper method to display the schedule list
  Widget _buildScheduleList(List<String> times) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: times.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(times[index]),
        );
      },
    );
  }
}

class BusRoutePage extends StatelessWidget {
  final String busLine;

  BusRoutePage({required this.busLine});

  // T15 otobüs hattı durak bilgileri
  final Map<String, List<Map<String, String>>> busRoutes = {
    '485': [
      {"Stop Number": "4733", "Stop Name": "GÜRPINAR OKUL 2"},
      {"Stop Number": "4752", "Stop Name": "GÜRPINAR YEŞİL MAHALLE"},
      {"Stop Number": "4757", "Stop Name": "ŞABAN BAYRAM SOKAK"},
      {"Stop Number": "4764", "Stop Name": "ÇOÇUK PARKI"},
      {"Stop Number": "4758", "Stop Name": "OYUN ALANI"},
      {"Stop Number": "4722", "Stop Name": "GÜRPINAR TAVUK ÇİFTLİĞİ"},
      {"Stop Number": "4724", "Stop Name": "DÖRTYOL"},
      {"Stop Number": "4750", "Stop Name": "GÜRPINAR MEYDAN 1"},
      {"Stop Number": "4723", "Stop Name": "ÇAMURLUK 2"},
      {"Stop Number": "4704", "Stop Name": "ÇAMURLUK 4"},
      {"Stop Number": "4687", "Stop Name": "ÇAMURLUK SON DURAK"},
      {"Stop Number": "18272", "Stop Name": "MİMARSİNAN 2. CD. - 1"},
      {"Stop Number": "18271", "Stop Name": "MİMARSİNAN 2. CD."},
      {"Stop Number": "4750", "Stop Name": "GÜRPINAR MEYDAN 1"},
      {"Stop Number": "4742", "Stop Name": "DERİNGÖZ PARKI"},
      {"Stop Number": "4732", "Stop Name": "GÜRPINAR OKUL 1"},
      {"Stop Number": "4729", "Stop Name": "GÜRPINAR 11"},
      {"Stop Number": "4717", "Stop Name": "GÜRPINAR 9"},
      {"Stop Number": "4703", "Stop Name": "GÜRPINAR 7"},
      {"Stop Number": "4702", "Stop Name": "GÜRPINAR 5"},
      {"Stop Number": "4690", "Stop Name": "GÜRPINAR 3"},
      {"Stop Number": "4682", "Stop Name": "GÜRPINAR 1"},
      {"Stop Number": "4656", "Stop Name": "GÜRPINAR GİRİŞİ 1"},
      {"Stop Number": "19047", "Stop Name": "GÜRPINAR YEŞİLPINAR CD."},
      {"Stop Number": "16336", "Stop Name": "GÜRPINAR GİRİŞİ 3"},
      {"Stop Number": "4651", "Stop Name": "İLKSU CAD. 2"},
      {"Stop Number": "4599", "Stop Name": "SU DEPOSU 1"},
      {"Stop Number": "4587", "Stop Name": "ÇİFTLİK 1"},
      {"Stop Number": "4589", "Stop Name": "GÜZELKÖY VİLALAR 2"},
      {"Stop Number": "4590", "Stop Name": "GÜZELKÖY ÇIKIŞI 2"},
      {"Stop Number": "4593", "Stop Name": "GÜZELKÖY PARK 2"},
      {"Stop Number": "4573", "Stop Name": "GÜZELKÖY MEYDAN"},
      {"Stop Number": "4592", "Stop Name": "GÜZELKÖY PARK 1"},
      {"Stop Number": "4588", "Stop Name": "GÜZELKÖY ÇIKIŞI 1"},
      {"Stop Number": "4559", "Stop Name": "GÜZELKÖY GİRİŞİ 1"},
      {"Stop Number": "4530", "Stop Name": "SUSAM HAYRATI 1"},
      {"Stop Number": "4522", "Stop Name": "KİLİSE 1"},
      {"Stop Number": "4506", "Stop Name": "KAYABAĞ KÖYÜ 1"},
      {"Stop Number": "4513", "Stop Name": "İLK SU CAD 1"},
      {"Stop Number": "7592", "Stop Name": "İLK SU CADDESİ 11"},
      {"Stop Number": "4508", "Stop Name": "İLK SU CADDESİ3"},
      {"Stop Number": "4502", "Stop Name": "ASFALT ŞANTİYE 1"},
      {"Stop Number": "4494", "Stop Name": "MESİRE ALANI 1"},
      {"Stop Number": "4480", "Stop Name": "EFKERE 1"},
      {"Stop Number": "4479", "Stop Name": "EFKERE OKUL 1"},
      {"Stop Number": "4497", "Stop Name": "EFKERE 3"},
      {"Stop Number": "4512", "Stop Name": "GESİ P.T.T 1"},
      {"Stop Number": "4495", "Stop Name": "GESİ MEZARLIK 1"},
      {"Stop Number": "4459", "Stop Name": "KAYSERİ CAD 1"},
      {"Stop Number": "4430", "Stop Name": "KAYSERİ CAD 3"},
      {"Stop Number": "4414", "Stop Name": "KAYSERİ CAD.5"},
      {"Stop Number": "4402", "Stop Name": "MÜHİMAT DEPO 1"},
      {"Stop Number": "4370", "Stop Name": "DERİN DERE 1"},
      {"Stop Number": "4324", "Stop Name": "DERİN DERE 3"},
      {"Stop Number": "4276", "Stop Name": "ALPARSLAN TÜRKEŞ BUL.1"},
      {"Stop Number": "4242", "Stop Name": "ALPARSLAN TÜRKEŞ BUL.3"},
      {"Stop Number": "4203", "Stop Name": "ALPARSLAN TÜRKEŞ BUL.5"},
      {"Stop Number": "4158", "Stop Name": "ALPARSLAN TÜRKEŞ BUL.7"},
      {"Stop Number": "4110", "Stop Name": "ALPARSLAN TÜRKEŞ BUL.9"},
      {"Stop Number": "4078", "Stop Name": "ALPARSLAN TÜRKEŞ BUL.11"},
      {"Stop Number": "4044", "Stop Name": "GESİ YOLU 1 MİMOZA SİTESİ"},
      {"Stop Number": "3779", "Stop Name": "BEYAZ ŞEHİR SOBALILAR 1"},
      {"Stop Number": "3714", "Stop Name": "İ.M.K.B 1"},
      {"Stop Number": "3648", "Stop Name": "TOKİ GİRİŞİ 1"},
      {"Stop Number": "3497", "Stop Name": "TRAMVAY BEYAZ ŞEHİR 1"},
      {"Stop Number": "3336", "Stop Name": "GESİ YOLU 1"},
      {"Stop Number": "3230", "Stop Name": "BEYAZŞEHİR ÇIKIŞI"},
      {"Stop Number": "3066", "Stop Name": "ÖMER HALİS DEMİR LİSESİ 1"},
      {"Stop Number": "2852", "Stop Name": "YEMCİ"},
      {"Stop Number": "2723", "Stop Name": "KUMARLI PARKI 1"},
      {"Stop Number": "2510", "Stop Name": "SALTUK BUĞRA 1"},
      {"Stop Number": "2378", "Stop Name": "P.T.T DEPO 1"},
      {"Stop Number": "2160", "Stop Name": "ABDULHAMİT HAN 1"},
      {"Stop Number": "1919", "Stop Name": "MİMARSİNAN KAVŞAK 1"},
      {"Stop Number": "15887", "Stop Name": "DOĞU GARAJI 1"},
      {"Stop Number": "1457", "Stop Name": "SİVAS CD 1"},
      {"Stop Number": "1400", "Stop Name": "YILDIZ EVLER 1"},
      {"Stop Number": "1340", "Stop Name": "YILDIZ EVLER 3"},
      {"Stop Number": "1084", "Stop Name": "ÇİFTE KÜMBET 1"},
      {"Stop Number": "1056", "Stop Name": "SERHAT SHOP"},
      {"Stop Number": "1014", "Stop Name": "KIZILIRMAK CD.1"},
      {"Stop Number": "850", "Stop Name": "SEVGİ HAST.1"},
      {"Stop Number": "755", "Stop Name": "KIZILIRMAK CD.3"},
      {"Stop Number": "460", "Stop Name": "BEYAZÇI 1"}
    ],
    'T15': [
      {"Stop Number": "3505","Stop Name": "HACI ŞİRİN OPERATION HEADQUARTERS 1"},
      {"Stop Number": "22108","Stop Name": "ERKİLET BULVARI HACI ŞİRİN JUNCTION 2"},
      {"Stop Number": "3370", "Stop Name": "İSMAİL TARMAN PARK"},
      {"Stop Number": "13447", "Stop Name": "İSMAİL TARMAN PARK 1"},
      {"Stop Number": "3144", "Stop Name": "ERKİLET PTT 1"},
      {"Stop Number": "3005", "Stop Name": "ERKİLET BULVARI 1"},
      {"Stop Number": "3009", "Stop Name": "DERE MAH 1"},
      {"Stop Number": "17447","Stop Name": "ERKİLET BULVARI 18 MARCH VICTORY PARK 1"},
      {"Stop Number": "2737", "Stop Name": "ERKİLET FIRE STATION 2"},
      {"Stop Number": "2632", "Stop Name": "ERKİLET BULVARI 3"},
      {"Stop Number": "2476", "Stop Name": "ERKİLET BULVARI 7"},
      {"Stop Number": "2364", "Stop Name": "ERKİLET BULVARI 9"},
      {"Stop Number": "2248", "Stop Name": "POLICE SCHOOL 1"},
      {"Stop Number": "2050", "Stop Name": "ERKİLET BULVARI 11"},
      {"Stop Number": "1947", "Stop Name": "KAYSERİ TEXTILES 1"},
      {"Stop Number": "1760", "Stop Name": "BUS TERMINAL 1"},
      {"Stop Number": "1645", "Stop Name": "HOSPICE 1"},
      {"Stop Number": "1563", "Stop Name": "KAYSERİSPOR FACILITIES 1"},
      {"Stop Number": "1392", "Stop Name": "ERKİLET BULVARI 13"},
      {"Stop Number": "21270", "Stop Name": "ERKİLET BULV. MITHAT PAŞA 1"},
      {"Stop Number": "1215", "Stop Name": "ERKİLET BULVARI 15"},
      {"Stop Number": "1120", "Stop Name": "GREEN NEIGHBORHOOD SQUARE 1"},
      {"Stop Number": "960", "Stop Name": "MITHATPAŞA CENTRAL MOSQUE 1"},
      {"Stop Number": "833", "Stop Name": "GREEN NEIGHBORHOOD ENTRANCE 1"},
      {"Stop Number": "682", "Stop Name": "MITHATPAŞA BRIDGE STOP 1"},
      {"Stop Number": "573", "Stop Name": "OFFICER HOUSING 1"},
      {"Stop Number": "449", "Stop Name": "NEW NEIGHBORHOOD PTT 1"},
      {"Stop Number": "7548", "Stop Name": "ERKİLET BULV. AGÜ 1"},
      {"Stop Number": "288", "Stop Name": "NEW POLICE STATION 1"},
      {"Stop Number": "169", "Stop Name": "COURTHOUSE 1"},
      {"Stop Number": "64","Stop Name": "STATION STREET JUNCTION OF THE BYPASS"},
      {"Stop Number": "20", "Stop Name": "STATION STREET HACI KILIÇ MOSQUE"},
      {"Stop Number": "2", "Stop Name": "MEDRESE 1"},
      {"Stop Number": "5", "Stop Name": "KALEÖNÜ TRANSFER STOP"},
      {"Stop Number": "82", "Stop Name": "AHİEVRAN ZAVİYESİ 1"},
      {"Stop Number": "155", "Stop Name": "MARTYRDOM 2"},
      {"Stop Number": "282", "Stop Name": "MIMARSINAN HIGH SCHOOL 2"},
      {"Stop Number": "358", "Stop Name": "MINISTRY OF NATIONAL EDUCATION 4"},
      {"Stop Number": "623", "Stop Name": "BUS OPERATIONS DIRECTORATE 6"},
      {"Stop Number": "809", "Stop Name": "THEOLOGY ENTRANCE 8"},
      {"Stop Number": "965", "Stop Name": "FACULTY ENTRANCE 10"},
      {"Stop Number": "1117", "Stop Name": "SABANCI CULTURE CENTER 12"},
      {"Stop Number": "1245", "Stop Name": "HOUSING 14"},
      {"Stop Number": "1463", "Stop Name": "TALAS BULV. 41"},
      {"Stop Number": "1582", "Stop Name": "TALAS BULV. 39"},
      {"Stop Number": "1748", "Stop Name": "ATATÜRK BULVARI 2"},
      {"Stop Number": "1837", "Stop Name": "ATATÜRK BULVARI 4"},
      {"Stop Number": "1974", "Stop Name": "ATATÜRK BULV KAYMAKAMLIK 6"},
      {"Stop Number": "2128", "Stop Name": "ATATÜRK BULVARI 8"},
      {"Stop Number": "2210", "Stop Name": "ATATÜRK BULVARI 10"},
      {"Stop Number": "2317", "Stop Name": "ATATÜRK BULVARI 12"},
      {"Stop Number": "2422", "Stop Name": "ATATÜRK BULVARI 14"},
      {"Stop Number": "2448", "Stop Name": "ATATÜRK BULVARI 16"},
      {"Stop Number": "2468", "Stop Name": "ATATÜRK BULVARI 18"},
      {"Stop Number": "2477", "Stop Name": "ATATÜRK BULVARI 20"},
      {"Stop Number": "2438", "Stop Name": "TUT JUNCTION 22"},
      {"Stop Number": "2337", "Stop Name": "HALEF HOCA 2"},
      {"Stop Number": "2358", "Stop Name": "SAYAR STREET 4"},
      {"Stop Number": "2405", "Stop Name": "TALAS FINAL STATION"}
    ]
  };

  @override
  Widget build(BuildContext context) {
    // Bus route information for the selected bus line (T15)
    List<Map<String, String>> route = busRoutes[busLine] ?? [{"Stop Number": "N/A", "Stop Name": "Route not found"}];

    return Scaffold(
        appBar: AppBar(
          title: Text("Route - $busLine"),
          backgroundColor: Colors.blue,
        ),
        body: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: route.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(route[index]["Stop Name"]!),
                subtitle: Text("Stop No: ${route[index]["Stop Number"]!}"),
              );
            },
            ),
        );
    }
}
class EnvironmentInfoPage extends StatefulWidget {
  @override
  _EnvironmentInfoPageState createState() => _EnvironmentInfoPageState();
}

class _EnvironmentInfoPageState extends State<EnvironmentInfoPage> {
  Position? _currentPosition;
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  // Kullanıcının konumunu almak için _initializeLocation metodu
  Future<void> _initializeLocation() async {
    _currentPosition =
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      // Harita işaretçisini ekleyin
      _markers.add(Marker(
        width: 80.0,
        height: 80.0,
        point: latlong.LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        builder: (ctx) =>
            Icon(Icons.location_pin, color: Colors.blue, size: 40),
      ));
    });
  }

  // Mesafe hesaplama fonksiyonu
  double _calculateDistance(double lat1, double lon1, double lat2,
      double lon2) {
    const earthRadius = 6371000; // in meters
    var dLat = _degreesToRadians(lat2 - lat1);
    var dLon = _degreesToRadians(lon2 - lon1);
    var a = (sin(dLat / 2) * sin(dLat / 2)) +
        (cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) * sin(dLon / 2));
    var c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c; // Distance in meters
  }

  double _degreesToRadians(double degree) {
    return degree * (pi / 180);
  }

  Future<void> _searchNearbyPlaces(String keyword) async {
    final kayseriLat = 38.736;  // Kayseri'nin enlemi
    final kayseriLon = 35.485;  // Kayseri'nin boylamı
    final maxDistance = 10000.0;  // double olarak tanımladık

    if (_currentPosition != null) {
      final minLat = calculateNewLatitude(
          kayseriLat, -maxDistance); // Alt sınır
      final maxLat = calculateNewLatitude(kayseriLat, maxDistance); // Üst sınır
      final minLon = calculateNewLongitude(
          kayseriLon, kayseriLat, -maxDistance); // Sol sınır
      final maxLon = calculateNewLongitude(
          kayseriLon, kayseriLat, maxDistance); // Sağ sınır

      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=$keyword&format=json&addressdetails=1&limit=10&lat=${_currentPosition!
              .latitude}&lon=${_currentPosition!
              .longitude}&bounded=1&viewbox=$minLon,$maxLat,$maxLon,$minLat&countrycodes=TR&accept-language=tr');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        setState(() {
          _searchResults = data.map((result) {
            return {
              'lat': double.tryParse(result['lat'].toString()) ?? 0.0,
              'lon': double.tryParse(result['lon'].toString()) ?? 0.0,
              'display_name': result['display_name'] ?? 'No name',
              'address': result['address'] != null
                  ? result['address']['road'] ?? 'No address'
                  : 'No address',
            };
          }).toList();

          // Harita işaretçilerini ekleyin
          _markers = _searchResults.map((result) {
            return Marker(
              width: 80.0,
              height: 80.0,
              point: latlong.LatLng(result['lat'], result['lon']),
              builder: (ctx) =>
                  Icon(
                    Icons.location_pin,
                    color: Colors.red,
                    size: 30,
                  ),
            );
          }).toList();
        });
      } else {
        print("Error: ${response.statusCode}");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search... (exp: cafe, hospital)',
              suffixIcon: IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  _searchNearbyPlaces(_searchController.text);
                },
              ),
            ),
          ),
        ),
        body: Stack(
            children: [
              _currentPosition == null
                  ? Center(child: CircularProgressIndicator())
                  : FlutterMap(
                options: MapOptions(
                  center: latlong.LatLng(
                      _currentPosition!.latitude, _currentPosition!.longitude),
                  zoom: 14.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: ['a', 'b', 'c'],
                  ),
                  MarkerLayer(
                    markers: _markers,
                  ),
                ],
              ),
              if (_searchResults.isNotEmpty)
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    color: Colors.white,
                    height: 200,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        var place = _searchResults[index];
                        return ListTile(
                          title: Text(place['display_name'] ?? 'No name'),
                          subtitle: Text(place['address'] ?? 'No address'),
                          onTap: () {
                            // Kafe seçildiğinde yapılacak işlemler
                          },
                        );
                      },
                    ),
                  ),
                ),
            ],
           ),
       );
    }
}
class RelativeLoginPage extends StatefulWidget {
  @override
  _RelativeLoginPageState createState() => _RelativeLoginPageState();
}

class _RelativeLoginPageState extends State<RelativeLoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _signIn() async {
    try {
      // Firebase giriş işlemi
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Giriş başarılı ise konum sayfasına yönlendirme
      if (userCredential.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => RelativeTrackingPage()), // Konum sayfasına yönlendirme
        );
      }
    } on FirebaseAuthException catch (e) {
      // Hata durumunda kullanıcıya mesaj gösterme
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "There is an error")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradyan Arka Plan
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Üstteki Yarı Şeffaf Görsel
          Positioned.fill(
            child: Opacity(
              opacity: 0.4,
              child: Image.asset(
                'assets/blindlesslogo.jpg', // Görselinizin yolu
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 40, // Butonun üstten konumu
            left: 10, // Butonun soldan konumu
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.pink[900]),
              onPressed: () {
                Navigator.pop(context); // Bir önceki sayfaya dön
              },
            ),
          ),
          // İçerik
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Başlık
                    Text(
                      "Welcome Relatives!",
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 20),
                    // Giriş Kartı
                    _buildTextField(
                      context,
                      "Email Address",
                      emailController,
                      Icons.email,
                    ),
                    SizedBox(height: 20),
                    _buildTextField(
                      context,
                      "Password",
                      passwordController,
                      Icons.lock,
                      obscureText: true,
                    ),
                    SizedBox(height: 20),
                    // "Remember Me" ve "Forgot Password"
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: false,
                              onChanged: (value) {},
                              activeColor: Colors.white,
                            ),
                            Text(
                              "Remember for 30 days",
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: Text(
                            "Forgot Password?",
                            style: TextStyle(
                              color: Colors.white,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    // Giriş Butonu
                    ElevatedButton(
                      onPressed: _signIn, // Giriş işlemi
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            horizontal: 100, vertical: 15),
                        backgroundColor: Color(0xFF880E4F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        "LOG IN",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Kayıt Linki
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RelativeSignUpPage(), // Sign Up sayfasına yönlendirme
                          ),
                        );
                      },
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Don't have an account? ",
                              style: TextStyle(color: Colors.white),
                            ),
                            TextSpan(
                              text: "Sign Up",
                              style: TextStyle(
                                color: Colors.pink,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Giriş Alanı Widget'ı
  Widget _buildTextField(BuildContext context, String hint,
      TextEditingController controller, IconData icon,
      {bool obscureText = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white),
          prefixIcon: Icon(icon, color: Colors.white),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
      ),
    );
  }
}

class RelativeDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedBackground(),
          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RelativeTrackingPage extends StatefulWidget {
  @override
  _RelativeTrackingPageState createState() => _RelativeTrackingPageState();
}

class _RelativeTrackingPageState extends State<RelativeTrackingPage> {
  String _apiKey = "0d54942a17774e8caa73685cf098098c"; // API Key
  Position? _currentPosition;
  late MapController _mapController;
  bool _isLocationPermissionGranted = false; // Konum izni kontrolü
  bool _isLocationServiceEnabled = false; // Konum servisi kontrolü

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _checkLocationService(); // Konum servisi kontrolü
  }

  Future<void> _checkLocationService() async {
    // Konum servisini kontrol et
    _isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!_isLocationServiceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Location services are disabled. Please enable them.")),
      );
      return;
    }

    // Konum izni kontrolü
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    // Konum iznini kontrol et
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Location permission is denied. Please grant permission.")),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Location permission is permanently denied. Please enable it in settings.")),
      );
      return;
    }

    // Konum izni verildiyse, konumu al ve harita üzerinde göster
    setState(() {
      _isLocationPermissionGranted = true;
    });
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to get location: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
            children: [
              // Arka plan (isteğe bağlı)
              AnimatedBackground(),
              Positioned(
                top: 40,
                left: 10,
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Where is my relative?",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 100,
                left: 0,
                right: 0,
                bottom: 0,
                child: _currentPosition == null
                    ? (!_isLocationServiceEnabled
                    ? Center(
                    child: Text(
                      "Please enable location services.",
                      style: TextStyle(color: Colors.white),
                    ))
                    : _isLocationPermissionGranted
                    ? Center(child: CircularProgressIndicator()) // Konum alınırken yükleme göstergesi
                    : Center(
                    child: Text(
                      "Please enable location permission.",
                      style: TextStyle(color: Colors.white),
                    )))
                    : FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    center: LatLng(
                        _currentPosition!.latitude,
                        _currentPosition!.longitude),
                    zoom: 16.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: ['a', 'b', 'c'],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          width: 80.0,
                          height: 80.0,
                          point: LatLng(
                              _currentPosition!.latitude,
                              _currentPosition!.longitude),
                          builder: (ctx) =>
                              Icon(Icons.location_on, color: Colors.red),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            ),
        );
   }
}


class UserSignUpPage extends StatefulWidget {
  @override
  _UserSignUpPageState createState() => _UserSignUpPageState();
}

class _UserSignUpPageState extends State<UserSignUpPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  String userType = 'user';

  void _signUp() async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Passwords do not match")));
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      String userId = userCredential.user?.uid ?? '';
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'name': nameController.text.trim(),
        'surname': surnameController.text.trim(),
        'username': usernameController.text.trim(),
        'email': emailController.text.trim(),
        'phoneNumber': phoneNumberController.text.trim(),
        'userType': userType,
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => UserLoginPage()),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? "Error")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
            children: [
              // Gradyan Arka Plan
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              // Şeffaf Resim
              Positioned.fill(
                child: Opacity(
                  opacity: 0.3, // Şeffaflık seviyesi
                  child: Image.asset(
                    'blindlesslogo.jpg', // Görselin yolu
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // İçerik
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Başlık
                        Text(
                          "Create an Account!",
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 20),
                        // Form Alanları
                        _buildTextField(
                          hint: "Name",
                          icon: Icons.person,
                          controller: nameController,
                        ),
                        SizedBox(height: 15),
                        _buildTextField(
                          hint: "Surname",
                          icon: Icons.person,
                          controller: surnameController,
                        ),
                        SizedBox(height: 15),
                        _buildTextField(
                          hint: "Username",
                          icon: Icons.person_outline,
                          controller: usernameController,
                        ),
                        SizedBox(height: 15),
                        _buildTextField(
                          hint: "Email",
                          icon: Icons.email,
                          controller: emailController,
                        ),
                        SizedBox(height: 15),
                        _buildTextField(
                          hint: "Password",
                          icon: Icons.lock,
                          controller: passwordController,
                          obscureText: true,
                        ),
                        SizedBox(height: 15),
                        _buildTextField(
                          hint: "Confirm Password",
                          icon: Icons.lock,
                          controller: confirmPasswordController,
                          obscureText: true,
                        ),
                        SizedBox(height: 15),
                        _buildTextField(
                          hint: "Phone Number",
                          icon: Icons.phone,
                          controller: phoneNumberController,
                        ),
                        SizedBox(height: 30),
                        // Kayıt Butonu
                        ElevatedButton(
                          onPressed: () {
                            // Kayıt işlemi
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: 100,
                              vertical: 15,
                            ),
                            backgroundColor: Color(0xFF880E4F),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            "LOG IN",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        // Giriş Linki
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context); // Giriş sayfasına dön
                          },
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "Already have an account? ",
                                  style: TextStyle(color: Colors.white),
                                ),
                                TextSpan(
                                  text: "Sign In",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            ),
        );
   }
  Widget _buildTextField({
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool obscureText = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white),
          prefixIcon: Icon(icon, color: Colors.white),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
      ),
    );
  }
}

class RelativeSignUpPage extends StatefulWidget {
  @override
  _RelativeSignUpPageState createState() => _RelativeSignUpPageState();
}

class _RelativeSignUpPageState extends State<RelativeSignUpPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController relatedUsernameController = TextEditingController();
  String userType = 'relative';

  void _signUp() async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Passwords do not match")));
      return;
    }

    try {
      // Firestore'dan ilgili kullanıcıyı bulma
      var userQuery = await FirebaseFirestore.instance
          .collection('users') // Burada 'users' koleksiyonunda username ile arama yapıyoruz
          .where('username', isEqualTo: relatedUsernameController.text.trim())
          .get();

      if (userQuery.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Related user not found")));
        return;
      }

      // Kullanıcıyı bulduktan sonra sign up işlemi
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      String userId = userCredential.user?.uid ?? '';
      await FirebaseFirestore.instance.collection('relatives').doc(userId).set({
        'name': nameController.text.trim(),
        'surname': surnameController.text.trim(),
        'email': emailController.text.trim(),
        'phoneNumber': phoneNumberController.text.trim(),
        'userType': userType,
        'relatedUsername': relatedUsernameController.text.trim(),
      });

      // Relative dashboard'a yönlendirme
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => RelativeDashboard()),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? "Error")));
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradyan arka plan
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Şeffaf arka plan resmi
          Positioned.fill(
            child: Opacity(
              opacity: 0.3,
              child: Image.asset(
                'assets/blindlesslogo.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Geri ok butonu
          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white, size: 30),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),

          // Sayfa içeriği
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Create an\nAccount!",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  _buildTextField(
                    hint: "Name",
                    icon: Icons.person,
                    controller: nameController,
                  ),
                  SizedBox(height: 15),
                  _buildTextField(
                    hint: "Surname",
                    icon: Icons.person,
                    controller: surnameController,
                  ),
                  SizedBox(height: 15),
                  _buildTextField(
                    hint: "Email",
                    icon: Icons.email,
                    controller: emailController,
                  ),
                  SizedBox(height: 15),
                  _buildTextField(
                    hint: "Password",
                    icon: Icons.lock,
                    controller: passwordController,
                    obscureText: true,
                  ),
                  SizedBox(height: 15),
                  _buildTextField(
                    hint: "Confirm Password",
                    icon: Icons.lock,
                    controller: confirmPasswordController,
                    obscureText: true,
                  ),
                  SizedBox(height: 15),
                  _buildTextField(
                    hint: "Phone Number",
                    icon: Icons.phone,
                    controller: phoneNumberController,
                  ),
                  SizedBox(height: 15),
                  _buildTextField(
                    hint: "Related User's Username",
                    icon: Icons.person_outline,
                    controller: relatedUsernameController,
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _signUp,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 100),
                      backgroundColor: Color(0xFF880E4F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      "LOG IN",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Already have an account? ",
                            style: TextStyle(color: Colors.white),
                          ),
                          TextSpan(
                            text: "Sign In",
                            style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool obscureText = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white),
          prefixIcon: Icon(icon, color: Colors.white),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
      ),
    );
  }
}
class AnimatedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const AnimatedButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(text),
    );
  }
}

Widget buildAnimatedBackground() {
  return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.purple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
         ),
      );
}
