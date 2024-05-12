import 'package:iut_assistant/screen/auth/signin.dart';
import 'package:flutter/material.dart';

class splashScreen extends StatelessWidget {
  const splashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/splash.png"),
            fit: BoxFit.cover,
          ),
        ),
        
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton:   Container(
                padding: EdgeInsets.only(top: 15),
                width: MediaQuery.of(context).size.width/2,
                height: 60,
                 decoration: BoxDecoration(
            color: Color.fromARGB(255, 231, 183, 110),
             borderRadius: BorderRadius.circular(20),
            ),
            child: InkWell(
              onTap: (){
               Navigator.push(context, MaterialPageRoute(builder: ((context) => SignInScreen())));
              },
              child: Text("Commencer",textAlign: TextAlign.center,style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
                fontFamily: "Times New Roman",
              ),),
            ),
      ),
    );
  }
}
