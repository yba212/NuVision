import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';

List<CameraDescription> cameras = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(CurrencyDetectorApp());
}

class CurrencyDetectorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NuVision',
      home: WelcomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WelcomePage extends StatefulWidget {
  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _speakWelcomeMessage();
  }

  Future<void> _speakWelcomeMessage() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.4);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(
        "Welcome to NuVision. Swipe left to detect your bank note and swipe right to do summation.");
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! > 0) {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => SummationPage()));
        } else if (details.primaryVelocity! < 0) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      ScannerPage(title: "Classify Bank Note")));
        }
      },
      child: Scaffold(
        backgroundColor: Color(0xFFFBB03B),
        body: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: CustomPaint(
                size: Size(MediaQuery.of(context).size.width, 200),
                painter: TopWavePainter(),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: CustomPaint(
                size: Size(MediaQuery.of(context).size.width, 140),
                painter: BottomWavePainter(),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/currency.png', height: 200),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 12),
                      ),
                      child: const Text('NuVision',
                          style:
                              TextStyle(color: Colors.white, fontSize: 20)),
                    ),
                    const SizedBox(height: 20),
                    const Text('Kuzuzangpo',
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.brown)),
                    const SizedBox(height: 10),
                    const Text(
                      '“Empowering visually impaired\nindividuals in Bhutan to identify\nNgultrum denominations through a\nmobile app with real-time audio\nfeedback”',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: Colors.brown),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ScannerPage extends StatefulWidget {
  final String title;

  ScannerPage({required this.title});

  @override
  _ScannerPageState createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  CameraController? _controller;
  final FlutterTts flutterTts = FlutterTts();
  String _predictionResult = "Prediction will appear here.";

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    _controller = CameraController(cameras[0], ResolutionPreset.medium);
    await _controller!.initialize();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    flutterTts.stop();
    super.dispose();
  }

  void _processFrame() {
    // TODO: Add AI model logic here.
    setState(() {
      _predictionResult = "Detected: 100 Ngultrum";
    });
    speakPrediction(_predictionResult);
  }

  Future<void> speakPrediction(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.brown.shade800,
      ),
      body: Column(
        children: [
          _controller == null || !_controller!.value.isInitialized
              ? Expanded(child: Center(child: CircularProgressIndicator()))
              : Expanded(
                  flex: 3,
                  child: CameraPreview(_controller!),
                ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              _predictionResult,
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w600, color: Colors.brown),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class SummationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScannerPage(title: "Sum Bank Notes");
  }
}

class TopWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.brown.shade800
      ..style = PaintingStyle.fill;

    final path = Path();
    path.lineTo(0, size.height * 0.8);
    path.quadraticBezierTo(
        size.width * 0.25, size.height, size.width * 0.5, size.height * 0.8);
    path.quadraticBezierTo(
        size.width * 0.75, size.height * 0.6, size.width, size.height * 0.8);
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class BottomWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.brown.shade900
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);
    path.quadraticBezierTo(
        size.width * 0.25, size.height * 0.4, size.width * 0.5, size.height * 0.2);
    path.quadraticBezierTo(
        size.width * 0.75, 0, size.width, size.height * 0.3);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
