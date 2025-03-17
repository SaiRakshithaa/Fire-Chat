import 'package:flutter/material.dart';
import 'Signup.dart';
import 'Firebase_auth.dart';
import 'ChatScreenList.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String errorMessage = "";

  void login() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    String? error = await AuthService().signIn(email, password);
    if (error == null) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => SearchUsersScreen()));
    } else {
      setState(() {
        errorMessage = error;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ✅ Preload image to avoid delays in rendering
    precacheImage(AssetImage("assets/background.png"), context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Fire Chat',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF075E54),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // ✅ Background Image
          Positioned.fill(
            child: Image.asset(
              "assets/background.png",
              fit: BoxFit.cover,
            ),
          ),

          // ✅ Transparent Overlay (if needed)
          Container(
            color: Colors.white.withOpacity(0.2), // Optional fade effect
          ),

          // ✅ Login Box
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: Container(
                padding: EdgeInsets.all(25),
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 12,
                      color: Colors.black26,
                      spreadRadius: 3,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "LOGIN",
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF075E54)),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color(0xFF075E54),
                              width: 2.0), // Green border on focus
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Password",
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color(0xFF075E54),
                              width: 2.0), // Green border on focus
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    if (errorMessage.isNotEmpty)
                      Text(errorMessage, style: TextStyle(color: Colors.red)),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        login();
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF25D366)),
                      child:
                          Text("Login", style: TextStyle(color: Colors.white)),
                    ),
                    SizedBox(height: 10),
                    GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignUpScreen()),
                          );
                        },
                        child: RichText(
                          text: TextSpan(
                            text: "Don't have an account? ",
                            style: TextStyle(color: Colors.black),
                            children: [
                              TextSpan(
                                text: "Sign up",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ))
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
/*import 'package:flutter/material.dart';
import 'Signup.dart';
import 'Firebase_auth.dart';
import 'ChatScreenList.dart'; // ✅ Ensure this is imported

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String errorMessage = "";

  /// ✅ Login Function
  void login() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = "Please enter email and password.";
      });
      return;
    }

    String? userId = await AuthService().signIn(email, password);

    if (userId != null) {
      // ✅ Navigate to SearchUsersScreen and pass `currentUserId`
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SearchUsersScreen(currentUserId: userId),
        ),
      );
    } else {
      setState(() {
        errorMessage = "Invalid credentials. Please try again.";
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage("assets/background.png"), context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'WhatsApp',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF075E54),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // ✅ Background Image
          Positioned.fill(
            child: Image.asset(
              "assets/background.png",
              fit: BoxFit.cover,
            ),
          ),

          // ✅ Transparent Overlay (optional)
          Container(color: Colors.white.withOpacity(0.2)),

          // ✅ Login Box
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Container(
                padding: const EdgeInsets.all(25),
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 12,
                      color: Colors.black26,
                      spreadRadius: 3,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "LOGIN",
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF075E54)),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color(0xFF075E54), width: 2.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "Password",
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color(0xFF075E54), width: 2.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (errorMessage.isNotEmpty)
                      Text(errorMessage, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: login,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF25D366)),
                      child: const Text("Login", style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignUpScreen()),
                        );
                      },
                      child: RichText(
                        text: const TextSpan(
                          text: "Don't have an account? ",
                          style: TextStyle(color: Colors.black),
                          children: [
                            TextSpan(
                              text: "Sign up",
                              style: TextStyle(
                                color: Colors.blue,
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
}*/

