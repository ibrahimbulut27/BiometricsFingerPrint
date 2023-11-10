import 'package:flutter/material.dart';
// kimlik doğrulama eklentisi
import 'package:local_auth/local_auth.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const MyHomePage(title: 'Parmak İzi Doğrulaması'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // localauthentication sınıfı oluşturuldu
  final LocalAuthentication _localAuthentication = LocalAuthentication();
  // cihazınızın kimlik doğrulama araçlarını destekleyip desteklemediğini görmek için değişken
  // parmak izi veya yüz tanıma sensörü var mı yok mu
  bool _hasFingerPrintSupport = false;
  String _authorizedOrNot = "Not Authorized";
  final LocalAuthentication auth = LocalAuthentication();
  late List<BiometricType> _availableBuimetricType;

  Future<void> _getBiometricsSupport() async {
    // cihazınızın parmak izi desteği olup olmadığını kontrol eder
    bool hasFingerPrintSupport = false;
    try {
      hasFingerPrintSupport = await _localAuthentication.canCheckBiometrics;
    } catch (e) {
      debugPrint(e.toString());
    }
    if (!mounted) return;
    setState(() {
      _hasFingerPrintSupport = hasFingerPrintSupport;
    });
  }

  Future<void> _getAvailableSupport() async {
    // cihazın mevcut tüm biyometrik desteklerini getirir
    List<BiometricType> availableBuimetricType = await auth.getAvailableBiometrics();
    try {
      availableBuimetricType =
      await _localAuthentication.getAvailableBiometrics();
    } catch (e) {
      debugPrint(e.toString());
    }
    if (!mounted) return;
    setState(() {
      _availableBuimetricType = availableBuimetricType;
    });
  }

  Future<void> _authenticateMe() async {
    // parmak izi kimlik doğrulaması için bir iletişim kutusu açar.
    // bir iletişim kutusu oluşturmanıza gerek yok.
    bool authenticated = false;
    try {
      authenticated = await _localAuthentication.authenticate(
        localizedReason: "Parmak izi test",
        options: const AuthenticationOptions(useErrorDialogs: true,
          stickyAuth: true,)
      );
    } catch (e) {
      debugPrint(e.toString());
    }
    if (!mounted) return;
    setState(() {
      _authorizedOrNot = authenticated ? "Authorized" : "Not Authorized";
    });
  }

  @override
  void initState() async{
    _getBiometricsSupport();
    _getAvailableSupport();
    _availableBuimetricType = await auth.getAvailableBiometrics();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: <Widget>[
          Text("Parmak izi desteği : $_hasFingerPrintSupport"),
          Text("Biyometrik türü: ${_availableBuimetricType.toString()}"),
          Text(" $_authorizedOrNot"),
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber,),
              onPressed: _authenticateMe,
              child: const Text("DOĞRULAMA"),
            ),
          ),
        ],
      ),
    );
  }
}