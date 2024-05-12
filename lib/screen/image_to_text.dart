import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ImageToText extends StatefulWidget {
  const ImageToText({Key? key}) : super(key: key);

  @override
  State<ImageToText> createState() => _ImageToTextState();
}

class _ImageToTextState extends State<ImageToText> {
  String result = "";
  late File image;
  late ImagePicker imagePicker;

  pickImageFromGallery() async {
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      image = File(pickedFile.path);
      setState(() {});
      performImageLabeling();
    }
  }

  captureImageCamera() async {
    final pickedFile = await imagePicker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      image = File(pickedFile.path);
      setState(() {});
      performImageLabeling();
    }
  }

  performImageLabeling() async {
    final inputImage = InputImage.fromFile(image);
    final textDetector = GoogleMlKit.vision.textRecognizer();

    try {
      final RecognizedText recognizedText =
          await textDetector.processImage(inputImage);

      result = recognizedText.text;
    } catch (e) {
      print("Error during text recognition: $e");
    } finally {
      textDetector.close();
    }

    setState(() {});
  }

  @override
  void initState() {
    imagePicker = ImagePicker();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Color.fromARGB(255, 240, 194, 126),),
        flexibleSpace: Container(
          decoration: BoxDecoration(
           image: DecorationImage(
                    image: AssetImage("assets/images/bg.png"),
                    fit: BoxFit.cover,
                  ),
          ),
        ),
        title: Text(
          "DJANI Lens",
          style: TextStyle(
            fontFamily: "Times New Roman",
            color: Color.fromARGB(255, 240, 194, 126),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: Image.asset(
              "assets/images/imagetext.png",
              color: Color.fromARGB(255, 240, 194, 126),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
           image: DecorationImage(
                    image: AssetImage("assets/images/bg.png"),
                    fit: BoxFit.cover,
                  ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                IconButton(
                  onPressed: () {
                    pickImageFromGallery();
                  },
                  icon: Icon(
                    Icons.add_photo_alternate,
                    color: Color.fromARGB(255, 240, 194, 126),
                    size: 90,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    captureImageCamera();
                  },
                  icon: Icon(
                    Icons.camera_alt,
                    color: Color.fromARGB(255, 240, 194, 126),
                    size: 90,
                  ),
                ),
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Texte extraire:",
                      style: TextStyle(
                        fontSize: 20,
                        color: Color.fromARGB(255, 240, 194, 126),
                        fontFamily: "Times New Roman",
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        if (result.isNotEmpty) {
                          Clipboard.setData(ClipboardData(text: result));
                          Fluttertoast.showToast(
                            msg: "Texte copié avec succès",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Texte copié avec succès"),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                        // Implement your copy logic here
                      },
                      icon: Icon(
                        Icons.copy,
                        color: Color.fromARGB(255, 240, 194, 126),
                        size: 40,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height/2,
                  padding: const EdgeInsets.only(
                   top: 40,
                    right: 20,
                    left: 20,
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 20).copyWith(
                    top: 30,
                  ),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                    image: AssetImage("assets/images/pin.png"),
                    fit: BoxFit.cover,
                  ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Text(
                        result.isNotEmpty ? result : "Pas de texte extraire",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontFamily: "Times New Roman",
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
