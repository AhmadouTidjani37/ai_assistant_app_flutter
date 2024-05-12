import 'package:iut_assistant/screen/auth/signup.dart';
import 'package:iut_assistant/screen/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signInWithEmailAndPassword(
      String email, String password) async {
    try {
      setState(() {
        _isLoading = true;
      });

      await _auth.signInWithEmailAndPassword(email: email, password: password);

      String userEmail = emailController.text.toLowerCase();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('isLoggedIn', true);
      prefs.setString('email', userEmail);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erreur de connexion !\nVeuillez vérifier vos informations.',
          ),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkLoggedInStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _checkLoggedInStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 5),
          child: Image.asset(
            "assets/images/leading.png",
            color:Color.fromARGB(255, 240, 194, 126),
          ),
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
          "Connexion",
          style: TextStyle(
            color: Color.fromARGB(255, 240, 194, 126),
            fontFamily: "Times New Roman",
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Color.fromARGB(255, 240, 194, 126),
          size: 30,
        ),
        actions: [
          PopupMenuButton(
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'aide',
                child: Text('Aide'),
              ),
              PopupMenuItem(
                value: 'mot_de_passe_oublie',
                child: Text('Mot de passe oublié'),
              ),
            ],
            onSelected: (String value) {
              // Handle menu item selection
              if (value == 'aide') {
                // Handle 'Aide' selection
                // You can navigate to a help screen or show a dialog, etc.
              } else if (value == 'mot_de_passe_oublie') {
                // Handle 'Mot de passe oublié' selection
                // You can navigate to a password reset screen or show a dialog, etc.
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 50, horizontal: 20),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 240, 194, 126),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
              Lottie.asset("assets/lottie/djani_gpt_typing.json",
              width: 100,
              height:150,
             ),
              SizedBox(
                height: 12,
              ),
                    Container(
                padding: EdgeInsets.only(left: 15),
                width: MediaQuery.of(context).size.width,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 0.8,
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Email",
                    hintStyle: TextStyle(
                       fontFamily: "Times New Roman",
            fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 1, 35, 87),
                    ),
                    prefixIcon: Icon(
                      Icons.email,
                      color: const Color.fromARGB(255, 1, 35, 87),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Container(
                padding: EdgeInsets.only(left: 15),
                width: MediaQuery.of(context).size.width,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 0.8,
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                   hintText: "Mot de passe",
                    hintStyle: TextStyle(
                       fontFamily: "Times New Roman",
            fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 1, 35, 87),
                    ),
                    prefixIcon: Icon(
                      Icons.lock,
                      color: const Color.fromARGB(255, 1, 35, 87),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Container(
                padding: EdgeInsets.only(top: 6),
                width: MediaQuery.of(context).size.width,
                height: 60,
                 decoration: BoxDecoration(
             image: DecorationImage(
              image: AssetImage("assets/images/bg.png"),
              fit: BoxFit.cover,
             ),
             borderRadius: BorderRadius.circular(20),
            ),
                child: InkWell(
                  onTap: () async {
                    String matricule = emailController.text;
                    String password = passwordController.text;
                    try {
                      setState(() {
                        _isLoading = true;
                      });
                      await _signInWithEmailAndPassword(matricule, password);
                    } catch (e) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Erreur"),
                            content: Text(
                              'Erreur de connexion !\nVeuillez vérifier vos informations.',
                            ),
                          );
                        },
                      );
                    } finally {
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  },
                  child: Center(
                    child: _isLoading
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ],
                          )
                        : Text(
                            "Se Connecter",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color.fromARGB(255, 240, 194, 126),
                              fontFamily: "Times New Roman",
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SignUpScreen()));
                },
                child: Text(
                  "J'ai pas un compte, créer un compte ?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color.fromARGB(255, 1, 35, 87),
                    fontFamily: "Times New Roman",
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(top: 15),
        width: MediaQuery.of(context).size.width,
        height: 50,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg.png"),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
          ),
        ),
        child: Text("DJANI AI | 2024",textAlign: TextAlign.center,style: TextStyle(
        color: Color.fromARGB(255, 240, 194, 126),
        ),),
      ),
    );
  }
}
