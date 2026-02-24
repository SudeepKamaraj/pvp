import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../views/dashboard_screen.dart';
import '../../../../data/services/database_service.dart';

class ProfileController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final DatabaseService _databaseService = DatabaseService();

  var userProfile = <String, dynamic>{}.obs;
  var isLoading = false.obs;
  var walletBalance = 0.0.obs;
  var rewardPoints = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      isLoading.value = true;
      try {
        DocumentSnapshot doc = await _db.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data() != null) {
          final data = doc.data() as Map<String, dynamic>;
          userProfile.value = data;
          walletBalance.value = (data['walletBalance'] as num? ?? 0.0).toDouble();
          rewardPoints.value = (data['rewardPoints'] as num? ?? 0).toInt();
          
          final profileImg = data['profileImage'] ?? '';
          print("Profile fetched: ${data['fullName']}, Wallet: ${walletBalance.value}");
          print("Profile Image URL: ${profileImg.isEmpty ? 'EMPTY' : profileImg.substring(0, 50)}...");
        }
      } catch (e) {
        print("Error fetching profile: $e");
        Get.snackbar("Error", "Failed to load profile");
      } finally {
        isLoading.value = false;
      }
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
    Get.offAll(() => const DashboardScreen());
  }
}
