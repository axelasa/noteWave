import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:note_wave/home.dart';
import 'package:note_wave/pages/authentication/signin.dart';
import 'package:note_wave/pages/authentication/signup.dart';
import 'package:note_wave/provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

 Future<void> main() async{
   WidgetsFlutterBinding.ensureInitialized();
   await Hive.initFlutter();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
   await Hive.openBox('storage');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Note Wave',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.yellow),
          primarySwatch: Colors.yellow,
          useMaterial3: true,
        ),
        home: const MyHomePage(title: 'Note Wave',),
        routes: {
          '/signup':(context)=> const SignUpPage(),
          '/signin':(context)=>const SignInPage(),
          '/home':(context)=>const HomePage(),
        },
      ),
    );
  }
}


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          return const HomePage();
        }
        if (snapshot.hasError) {
          return Center(child: Text('${snapshot.error}'));
        }
        return const SignInPage();
      },
    );
  }
}

