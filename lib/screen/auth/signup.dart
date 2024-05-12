import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iut_assistant/screen/auth/signin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; 

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;
  Future<void> _signUpWithEmailAndPassword(
  String name, String email, String password) async {
  try {
    bool isEmailRegistered = await _checkIfEmailRegistered(email);
          
    if (isEmailRegistered) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Vous avez déjà un compte. Veuillez vous connecter.'),
        ),
      );
      return;
    }

    UserCredential authResult = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);

    String userId = authResult.user!.uid;

    await _firestore.collection('users').doc(userId).set({
      'name': name,
      'email': email,
      'searchHistory': [],
    });
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignInScreen()),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('Erreur lors de la création du compte. Veuillez réessayer.'),
      ),
    );
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}


  Future<bool> _checkIfEmailRegistered(String email) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    return querySnapshot.docs.isNotEmpty;
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
          "Inscription",
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
              if (value == 'aide') {
              } else if (value == 'mot_de_passe_oublie') {
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
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
                  controller: nameController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Nom",
                    hintStyle: TextStyle(
                      fontFamily: "Times New Roman",
                      color:const Color.fromARGB(255, 1, 35, 87),
                    ),
                    prefixIcon: Icon(
                      Icons.person,
                      color: const Color.fromARGB(255, 1, 35, 87),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
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
                    String name = nameController.text;
                    String email = emailController.text;
                    String password = passwordController.text;

                    try {
                      setState(() {
                        _isLoading = true;
                      });
                      await _signUpWithEmailAndPassword(name, email, password);
                    } catch (e) {
                      // Handle the error
                    } finally {
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  },
                  child: _isLoading
                      ? Column(
                          children: [
                            CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ],
                        )
                      : Center(
                          child: Text('Créer un compte',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              )),
                        ),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SignInScreen()));
                },
                child: Text(
                  "J'ai un compte, se connecter ?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color.fromARGB(255, 1, 35, 87),
                    fontFamily: "Times New Roman",
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

                  ],
                ),
              ),
              
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
