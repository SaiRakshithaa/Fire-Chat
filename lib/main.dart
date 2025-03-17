import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'Login.dart';

Future main() async{
  WidgetsFlutterBinding.ensureInitialized();
  if(kIsWeb){
    await Firebase.initializeApp(options: FirebaseOptions(apiKey: "AIzaSyBdyRQsTvJsL9KWlPLUyBL6HaUfy5tJUvo", appId: "1:707649266589:web:11be5a11a29e7be07cc574", messagingSenderId: "707649266589", projectId:"chatapplication-d1917"));
  }
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home:SignInScreen(),
     
    );
  }
}




