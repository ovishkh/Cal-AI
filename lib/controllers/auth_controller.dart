import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';
import '../models/recipe.dart';

class AuthController extends GetxController {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirestoreService _firestoreService = FirestoreService();
  
  final Rx<User?> _user = Rx<User?>(null);
  final RxBool _isLoggedIn = false.obs;

  User? get user => _user.value;
  bool get isLoggedIn => _isLoggedIn.value;

  @override
  void onInit() {
    super.onInit();
    // Bind the user stream to our Rx variable
    _user.bindStream(_authService.authStateChanges);
    
    // Ever listener to update isLoggedIn whenever user changes
    ever(_user, (User? user) {
      _isLoggedIn.value = user != null;
    });
  }

  Future<void> loginWithEmail(String email, String password) async {
    try {
      await _authService.signIn(email: email, password: password);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signupWithEmail(String email, String password, String name) async {
    try {
      final userCredential = await _authService.signUp(
        email: email, 
        password: password, 
        name: name,
      );
      
      // Save profile to Firestore
      if (userCredential.user != null) {
        await _firestoreService.saveUserProfile(
          uid: userCredential.user!.uid,
          name: name,
          email: email,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> saveRecipe(Recipe recipe) async {
    try {
      if (user != null) {
        await _firestoreService.saveRecipe(uid: user!.uid, recipe: recipe);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _authService.signOut();
    } catch (e) {
      rethrow;
    }
  }
}
