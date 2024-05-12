import 'dart:io' as io;
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:iut_assistant/screen/propos.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iut_assistant/screen/auth/signin.dart';
import 'package:iut_assistant/screen/image_to_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/services.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:iut_assistant/apiServices/services.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _advancedDrawerController = AdvancedDrawerController();
  TextEditingController textController = TextEditingController();
  final speechToText = SpeechToText();
  final flutterTts = FlutterTts();
  String lastWords = '';
  String result = "";
  late OpenAIService openAIService;
  String? generatedContent;
  String? generatedImageUrl;
  bool isProcessing = false;
  int start = 200;
  int delay = 200;
  bool isAudioEnabled = false;
   List<String> searchHistory = [];
   bool showSearchHistory = false;
  @override
  void initState() {
    super.initState();
    openAIService = OpenAIService();
    initSpeechToText();
    initTextToSpeech();
    checkConnectivity();
    imagePicker = ImagePicker();
    loadSearchHistory();
    fetchUserData().then((_) {
    });
    
  }

  Future<void> checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de connexion à DJANI AI'),
        ),
      );
    }
  }
  
  Future<void> processQuestion(String question) async {
  setState(() {
    generatedImageUrl = null;
    generatedContent = 'Réponse en cours...';
    textController.clear();
    isProcessing = true;
  });

  var connectivityResult = await Connectivity().checkConnectivity();
  if (connectivityResult == ConnectivityResult.none) {
    // Handle no internet connection
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Erreur de connexion à DJANI AI'),
      ),
    );
    if (question.isNotEmpty) {
    updateUserSearchHistory(question);
  }
  }

  if (question.toLowerCase().contains("comment tu t'appelle ?") ||
      question.toLowerCase().contains("quel est ton nom ?")||question.toLowerCase().contains("Quel est ton nom ?")
      ||question.toLowerCase().contains("Quel est ton nom")||question.toLowerCase().contains("Comment tu t'appelle ?")
      ||question.toLowerCase().contains("Comment tu t'appelle")) {
    // Response specufique
    final nameResponse =
        "Je suis DJANI AI, une des meilleures créations de Monsieur Ahmadou Tidjani.";
    
    setState(() {
      generatedImageUrl = null;
      generatedContent = nameResponse;
      isProcessing = false;
    });

    await systemSpeak(nameResponse);
  } else {
    final speech = await openAIService.chatGPTAPI(question);

    setState(() {
        generatedImageUrl = null;
        generatedContent = speech;
        isProcessing = false;
    });

    if (isProcessing) {
      await systemSpeak(speech);
    }
  }
}

  void copyToClipboard() {
    if (generatedContent != null) {
      Clipboard.setData(ClipboardData(text: generatedContent!));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Résultat copié')),
      );
    }
  }

  Future<void> initTextToSpeech() async {
    await flutterTts.setSharedInstance(true);
  }

  Future<void> initSpeechToText() async {
    await speechToText.initialize();
  }

  Future<void> startListening() async {
    await speechToText.listen(onResult: onSpeechResult);
  }

  Future<void> stopListening() async {
    await speechToText.stop();
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
    });
  }

  Future<void> systemSpeak(String content) async {
    await flutterTts.speak(content);
  }

  Future<void> _signOut() async {
    try {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Déconnexion"),
            content: Text("Êtes-vous sûr de vouloir vous déconnecter ?"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text("Annuler"),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop(); // Close the dialog
                  await _auth.signOut();
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.setBool('isLoggedIn', false);
                  prefs.remove('email');
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => SignInScreen()),
                  );
                },
                child: Text("Confirmer"),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print("Erreur de déconnexion: $e");
    }
  }

 late String userName = '***';
late String userEmail = '***';

Future<void> fetchUserData() async {
  try {
    var userId = _auth.currentUser?.uid;
    if (userId != null) {
      var userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userData.exists) {
        setState(() {
          userName = userData.get('name') ?? '***';
          userEmail = userData.get('email') ?? '***';
        });
      }
    } else {
      setState(() {
        userName = '';
        userEmail = '';
      });
    }
  } catch (e) {
    print("Error fetching user data: $e");
  }
}


 Future<void> generatePdf(String content) async {
  bool confirmed = await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Confirmation"),
        content: Text("Êtes-vous sûr de vouloir enregistrer le fichier dans le dossier 'DJANI AI'?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Text("Annuler"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: Text("Confirmer"),
          ),
        ],
      );
    },
  );

  if (confirmed) {
    final pdf = pw.Document();
    pdf.addPage(pw.Page(
      build: (context) {
        return pw.Center(
          child: pw.Text(content),
        );
      },
    ));

    final dir = await getApplicationDocumentsDirectory();
    final folder = io.Directory('${dir.path}/DJANI AI');
    await folder.create(recursive: true);

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = io.File('${folder.path}/resultat_assis_$timestamp.pdf');
    await path.writeAsBytes(await pdf.save());

  }
}

late File image;
late ImagePicker imagePicker;

pickImageFromGallery() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.image,
  );

  if (result != null) {
    image = File(result.files.single.path!);
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
      textController.text = result;
    } catch (e) {
      print("Error during text recognition: $e");
    } finally {
      textDetector.close();
    }

    setState(() {});
  }

Future<void> updateUserSearchHistory(String question) async {
  try {
    var userId = _auth.currentUser?.uid;
    if (userId != null) {
      var userRef = FirebaseFirestore.instance.collection('users').doc(userId);
      var userData = await userRef.get();
      List<String>? existingHistory = userData.get('searchHistory')?.cast<String>();
      if (existingHistory == null) {
        existingHistory = [question];
      } else {
        existingHistory.add(question);
      }
      await userRef.update({'searchHistory': existingHistory});
    }
  } catch (e) {
    print("Error updating search history: $e");
  }
}
Future<void> loadSearchHistory() async {
  try {
    var userId = _auth.currentUser?.uid;
    if (userId != null) {
      var userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      List<String>? history = userData.get('searchHistory')?.cast<String>();

      if (history != null) {
        setState(() {
          searchHistory = List.from(history.reversed);
        });
      }
    }
  } catch (e) {
    print("Error loading search history: $e");
  }
}

  @override
  Widget build(BuildContext context) {
    return AdvancedDrawer(
      backdrop: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
                    image: AssetImage("assets/images/bg.png"),
                    fit: BoxFit.cover,
                  ),
        ),
      ),
      controller: _advancedDrawerController,
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 300),
      animateChildDecoration: true,
      rtlOpening: false,
      // openScale: 1.0,
      disabledGestures: false,
      childDecoration: const BoxDecoration(
        // NOTICE: Uncomment if you want to add shadow behind the page.
        // Keep in mind that it may cause animation jerks.
        // boxShadow: <BoxShadow>[
        //   BoxShadow(
        //     color: Colors.black12,
        //     blurRadius: 0.0,
        //   ),
        // ],
        borderRadius: const BorderRadius.all(Radius.circular(16)),
      ),
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Color.fromARGB(255, 240, 194, 126),
        ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
             image: DecorationImage(
                    image: AssetImage("assets/images/bg.png"),
                    fit: BoxFit.cover,
                  ),
            ),
          ),
          title: Text(
            "DJANI GPT",
            style: TextStyle(
              fontFamily: "Times New Roman",
              color: Color.fromARGB(255, 240, 194, 126),
              fontWeight: FontWeight.bold,
              fontSize: 24,
        ),
            ),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ImageToText()));
              },
              icon:
                  Icon(Icons.camera_alt, color: Color.fromARGB(255, 240, 194, 126), size: 30),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  isAudioEnabled = !isAudioEnabled;
                  if (isAudioEnabled && generatedContent != null) {
                    systemSpeak(generatedContent!);
                  } else {
                    flutterTts.stop(); 
                  }
                });
              },
              icon: Image.asset(
                isAudioEnabled
                    ? "assets/images/sound.png"
                    : "assets/images/mute.png",
                    color:Color.fromARGB(255, 240, 194, 126),
              ),
            ),
          ],
          leading: IconButton(
            onPressed: _handleMenuButtonPressed,
            icon: ValueListenableBuilder<AdvancedDrawerValue>(
              valueListenable: _advancedDrawerController,
              builder: (_, value, __) {
                return AnimatedSwitcher(
                  duration: Duration(milliseconds: 250),
                  child: Icon(
                    value.visible ? Icons.clear : Icons.menu,
                    key: ValueKey<bool>(value.visible),
                  ),
                );
              },
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 15,
              ),
              ZoomIn(
                child: Lottie.asset("assets/lottie/djani_gpt_typing.json",
              width: 200,
              height:150,
             ),
              ),
              FadeInRight(
                child: Visibility(
                  visible: generatedImageUrl == null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 40).copyWith(
                      top: 30,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color.fromARGB(255, 240, 194, 126),
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(20).copyWith(
                        topLeft: Radius.zero,
                      ),
                      image: DecorationImage(
                    image: AssetImage("assets/images/bg.png",
                    ),
                    fit: BoxFit.cover,
                  ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              IconButton(
                                onPressed: copyToClipboard,
                                icon: Icon(
                                  Icons.copy,
                                  size: 30,
                                  color: Color.fromARGB(255, 240, 194, 126),
                                ),
                              ),
                              IconButton(
                                onPressed: () async {
                                  await generatePdf(generatedContent ?? '');
                                },
                                icon: Icon(
                                  Icons.picture_as_pdf,
                                  size: 30,
                                  color: Color.fromARGB(255, 240, 194, 126),
                                ),
              
                              )
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            generatedContent == null
                                ? 'Bonjour, quelle tâche puis-je faire pour vous ?'
                                :"Conditions d'utilisations:\nLire attentivement afin de mieu comprendre les réponses:\n\n\t $generatedContent",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: generatedContent == null ? 24 : 18,
                              fontFamily: "Times New Roman",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 100,
              ),
             
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
       floatingActionButton:  Container(
        padding: EdgeInsets.only(top: 10,bottom: 10,left: 10),
  margin: EdgeInsets.symmetric(horizontal: 20),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(20),
    image: DecorationImage(
      image: AssetImage("assets/images/bg.png"),
      fit: BoxFit.cover,
    ),
  ),
  child: IntrinsicHeight(
    child: Row(
      children: [
        IconButton(
          onPressed:(){
            setState(() {
              generatedContent=null;
            });
          },
          icon:Icon(Icons.cleaning_services,color: Color.fromARGB(255, 240, 194, 126),size: 30,),
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
            child: TextField(
              textAlignVertical: TextAlignVertical.center,
              controller: textController,
              keyboardType: TextInputType.multiline,
               maxLines: 5,
               minLines: 1,
               decoration: InputDecoration(
                prefixIcon: Icon(Icons.keyboard),
                hintText: "Rechercher...",
                enabledBorder: InputBorder.none,
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: Colors.black,
                  fontFamily: "Times New Roman",
                ),
                labelStyle: TextStyle(
                  color: Colors.black,
                  fontFamily: "Times New Roman",
                ),
                suffixIcon: 
                    IconButton(onPressed: (){
                     pickImageFromGallery();
                    }, icon: Icon(Icons.add_a_photo_outlined,)),
                  
              ),
            ),
          ),
        ),
        SizedBox(
          width: 8,
        ),

        Container(
          width: 60,
          height: MediaQuery.of(context).size.height * 0.1, // Adjust this value as needed
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: DecorationImage(
              image: AssetImage("assets/images/bg.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: InkWell(
            onTap: () async {
              String question = textController.text;
              if (question.isNotEmpty) {
                setState(() {
                  processQuestion(question);
                });

                final speech = await openAIService.chatGPTAPI(question);
                generatedImageUrl = null;
                generatedContent = speech;
                setState(() {
                  isProcessing = true;
                });
              }
            },
            child: Icon(
              Icons.send,
              color: Color.fromARGB(255, 240, 194, 126),
              size: 30,
            ),
          ),
        ),
      ],
    ),
  ),
  ),
  ),
      drawer: SafeArea(
        child: Container(
          child: ListTileTheme(
            textColor: Colors.white,
            iconColor: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  width: 128.0,
                  height: 128.0,
                  margin: const EdgeInsets.only(
                    top: 24.0,
                    bottom: 64.0,
                  ),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    shape: BoxShape.circle,
                  ),
                  child: Lottie.asset("assets/lottie/djani_gpt_typing.json",
              width: 200,
              height:150,
             ),
                ),
                ListTile(
                  onTap: () {},
                  leading:
                      Icon(Icons.account_circle_rounded, color: Color.fromARGB(255, 240, 194, 126)),
                  title: Text(userName),
                ),
                ListTile(
                  onTap: () {},
                  leading: Icon(Icons.email, color: Color.fromARGB(255, 240, 194, 126)),
                  title: Text(userEmail),
                ),
                ListTile(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Propos()));
                  },
                  leading: Icon(
                    Icons.info,
                    color: Color.fromARGB(255, 240, 194, 126),
                  ),
                  title: Text('Propos'),
                ),
                ListTile(
                  onTap: () {
                    _signOut();
                  },
                  leading: Icon(
                    Icons.logout,
                    color: Color.fromARGB(255, 240, 194, 126),
                  ),
                  title: Text('Se déconnecter'),
                ),
                ExpansionTile(
        leading: Icon(
          Icons.history,
          color: Color.fromARGB(255, 240, 194, 126),
        ),
        title: Text('Historique de recherche',style: TextStyle(color: Colors.white),),
        onExpansionChanged: (expanded) {
          setState(() {
            showSearchHistory = expanded;
          });
        },
        children: [
          for (var search in searchHistory)
            ListTile(
              title: Text(search),
          
            ),
        ],
      ),
        Spacer(),
                DefaultTextStyle(
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white54,
                  ),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 16.0,
                    ),
                    child: Text(
                      'DJANI GPT | 2024',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleMenuButtonPressed() {
    _advancedDrawerController.showDrawer();
  }
}
