import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TotalAppointmentController extends GetxController {
  // Reactive variables for state management
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final RxList<Map<String, dynamic>> appointments = <Map<String, dynamic>>[].obs;
  final RxList<String> appointmentIds = <String>[].obs;
  final RxString userImage = ''.obs;

  // Cache for appointments
  QuerySnapshot<Map<String, dynamic>>? _cachedAppointments;
  DateTime? _lastFetchTime;

  @override
  void onInit() {
    super.onInit();
    fetchAppointments(); // Fetch appointments when the controller is initialized
  }

  Future<void> fetchAppointments() async {
    isLoading.value = true;
    errorMessage.value = '';
    appointments.clear();
    appointmentIds.clear();

    try {
      final now = DateTime.now();
      // Check if we have a valid cached result
      if (_cachedAppointments != null &&
          _lastFetchTime != null &&
          now.difference(_lastFetchTime!).inSeconds < 30) {
        _updateAppointmentsFromSnapshot(_cachedAppointments!);
        isLoading.value = false;
        return;
      }

      // Get current user ID
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception("User not authenticated. Please log in.");
      }

      print("Fetching appointments for user ID: $userId");

      // Fetch appointments from Firestore
      final query = FirebaseFirestore.instance
          .collection('appointments')
          .where('appWith', isEqualTo: userId); // Adjust query based on your role (doctor/patient)

      final result = await query.get();

      print("Found ${result.docs.length} appointments");

      if (result.docs.isEmpty) {
        print("No appointments found for user ID: $userId");
      } else {
        print("First appointment data: ${result.docs.first.data()}");
      }

      // Update cache
      _cachedAppointments = result;
      _lastFetchTime = now;

      // Update reactive lists
      _updateAppointmentsFromSnapshot(result);
    } catch (e) {
      print("Error fetching appointments: $e");
      errorMessage.value = "Failed to fetch appointments: $e";
    } finally {
      isLoading.value = false;
    }
  }

  void _updateAppointmentsFromSnapshot(QuerySnapshot<Map<String, dynamic>> snapshot) {
    appointments.clear();
    appointmentIds.clear();
    for (var doc in snapshot.docs) {
      appointments.add(doc.data());
      appointmentIds.add(doc.id);
    }
  }

  Future<String?> getUserImage(String userId) async {
    if (userId.isEmpty) {
      return null;
    }

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

      if (userDoc.exists && userDoc.data() != null) {
        var data = userDoc.data() as Map<String, dynamic>;
        return data['image'] as String?;
      }
      return null;
    } catch (e) {
      print("Error fetching user image: $e");
      return null;
    }
  }

  void clearCache() {
    _cachedAppointments = null;
    _lastFetchTime = null;
  }
}