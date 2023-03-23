import 'package:firebase_auth/firebase_auth.dart';
import 'package:hikers_dash/services/database.dart';
import 'package:hikers_dash/services/models/client.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //to get client from firebase user

  Client? _userFromFirebaseUser(User? user, bool signUp) {
    return user != null
        ? Client(
            uid: user.uid,
            clientName: '',
            clientEmail: user.email!,
            verified: signUp ? false : true,
            role: '',
          )
        : null;
  }

  // UserAuth stream to listen to auth changes
  Stream<Client?> get auth {
    return _auth
        .authStateChanges()
        .map((user) => _userFromFirebaseUser(user, false));
  }

//register with email & password
  Future<Client?> registerWithEmailAndPassword(
      String name, String email, String password, String role) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User user = result.user!;
      // Saved registered user data
      final client = Client(
        uid: user.uid,
        clientName: name,
        clientEmail: user.email!,
        verified: false,
        role: role,
      );
      Database.saveClientData(client);
      return client;
    } catch (e) {
      return null;
    }
  }

  //sign in with email & password
  Future<Client?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return await Database.getClientData(email);
    } catch (e) {
      return null;
    }
  }

  // Sign out Method
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      return null;
    }
  }
}
