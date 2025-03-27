import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:hams/general/consts/consts.dart';
import 'package:hams/users/chat_view.dart';
import 'package:velocity_x/velocity_x.dart';
import 'appointment_details.dart';

class TotalAppointment extends StatefulWidget {
  const TotalAppointment({super.key});

  @override
  _TotalAppointmentState createState() => _TotalAppointmentState();
}

class _TotalAppointmentState extends State<TotalAppointment> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> _appointments = [];
  Map<String, String?> _userImages = {}; // Cache for user images
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      String? doctorId = _auth.currentUser?.uid;
      if (doctorId == null) {
        setState(() {
          _errorMessage = "No authenticated doctor found";
          _isLoading = false;
        });
        return;
      }

      QuerySnapshot snapshot = await _firestore
          .collection('appointments')
          .where('appWith', isEqualTo: doctorId)
          .get();
      List<Map<String, dynamic>> appointments = [];
      Set<String> userIds = {};

      // Collect appointments and user IDs
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>? ?? {};
        String userId = data['appBy']?.toString() ?? '';
        appointments.add({
          'id': doc.id,
          'appBy': userId,
          'appName': data['appName']?.toString() ?? 'Unknown Name',
          'appMobile': data['appMobile']?.toString() ?? 'Unknown Mobile',
          'appMsg': data['appMsg']?.toString() ?? 'No Message',
          'appDay': data['appDay']?.toString() ?? 'Unknown Day',
          'appTime': data['appTime']?.toString() ?? 'Unknown Time',
          'status': data['status']?.toString() ?? 'pending',
          'isReview': data['isReview']?.toString() ?? 'false',
        });
        if (userId.isNotEmpty) userIds.add(userId);
      }

      // Fetch user images in bulk
      if (userIds.isNotEmpty) {
        var userDocs = await Future.wait(
          userIds.map((id) => _firestore.collection('users').doc(id).get()),
        );
        for (var userDoc in userDocs) {
          if (userDoc.exists && userDoc.data() != null) {
            _userImages[userDoc.id] =
                (userDoc.data() as Map<String, dynamic>)['image']?.toString();
          }
        }
      }

      setState(() {
        _appointments = appointments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Error fetching appointments: $e";
        _isLoading = false;
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accept':
        return Colors.green.shade600;
      case 'reject':
        return Colors.red.shade600;
      case 'pending':
        return Colors.orange.shade600;
      case 'complete':
        return Colors.blue.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  // Reusable Appointment Card Widget
  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
    String userId = appointment['appBy'];
    String? userImage = _userImages[userId];
    bool canChat = appointment['status'] == 'accept' || appointment['status'] == 'complete';

    Widget avatarWidget = CircleAvatar(
      radius: 20.r,
      backgroundColor: Colors.grey.shade200,
      child: Icon(
        Icons.account_circle,
        size: 30.r,
        color: Colors.grey.shade600,
      ),
    );

    if (userImage != null && userImage.isNotEmpty) {
      avatarWidget = CircleAvatar(
        radius: 20.r,
        backgroundImage: NetworkImage(userImage),
        child: null, // Clear child to avoid overlap
      );
    }

    return GestureDetector(
      onTap: () async {
        var result = await Get.to(() => AppointmentDetails(
          appointment: appointment,
          appointmentId: appointment['id'],
        ));
        if (result == 'updated') {
          _fetchAppointments();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bgDarkColor,
          borderRadius: BorderRadius.circular(15.r),
        ),
        padding: EdgeInsets.all(12.w),
        margin: EdgeInsets.only(bottom: 8.h),
        child: Row(
          children: [
            avatarWidget,
            12.widthBox,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appointment['appName'],
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  4.heightBox,
                  Text(
                    appointment['appMobile'],
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.secondaryTextColor,
                    ),
                  ),
                  4.heightBox,
                  Text(
                    "${appointment['appDay']} - ${appointment['appTime']}",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: _getStatusColor(appointment['status']).withOpacity(0.1),
                    border: Border.all(
                      color: _getStatusColor(appointment['status']),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    appointment['status'].toString().toUpperCase(),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(appointment['status']),
                    ),
                  ),
                ),
                if (canChat) ...[
                  8.heightBox,
                  GestureDetector(
                    onTap: () {
                      Get.to(() => ChatView(
                        doctorId: _auth.currentUser!.uid,
                        doctorName: "Dr. ${appointment['appName']}", // Replace with actual doctor name
                        userId: appointment['appBy'],
                      ));
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primeryColor, AppColors.greenColor],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        "Chat",
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.whiteColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var upcomingAppointments =
    _appointments.where((app) => app['status'] != 'complete').toList();
    var completedAppointments = _appointments
        .where((app) => app['status'] == 'complete' && app['isReview'] == 'false')
        .toList();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primeryColor, AppColors.greenColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header Section
              Container(
                padding: EdgeInsets.all(8.w),
                color: AppColors.whiteColor,
                child: Row(
                  children: [
                    "Appointments"
                        .text
                        .size(AppFontSize.size16)
                        .fontWeight(FontWeight.bold)
                        .color(AppColors.primeryColor)
                        .make(),
                    const Spacer(),
                    IconButton(
                      icon: Icon(Icons.refresh, color: AppColors.primeryColor),
                      onPressed: _fetchAppointments,
                    ),
                  ],
                ),
              ),
              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _errorMessage != null
                        ? Center(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: AppColors.whiteColor,
                          fontSize: 16.sp,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                        : _appointments.isEmpty
                        ? Center(
                      child: Text(
                        "No appointments booked",
                        style: TextStyle(
                          color: AppColors.whiteColor,
                          fontSize: 16.sp,
                        ),
                      ),
                    )
                        : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (upcomingAppointments.isNotEmpty) ...[
                          "Upcoming Appointments"
                              .text
                              .color(AppColors.primeryColor)
                              .size(AppFontSize.size16)
                              .fontWeight(FontWeight.bold)
                              .make(),
                          10.heightBox,
                          ...upcomingAppointments
                              .map((appointment) =>
                              _buildAppointmentCard(appointment))
                              .toList(),
                        ],
                        if (completedAppointments.isNotEmpty) ...[
                          20.heightBox,
                          "Completed Appointments"
                              .text
                              .color(AppColors.primeryColor)
                              .size(AppFontSize.size16)
                              .fontWeight(FontWeight.bold)
                              .make(),
                          10.heightBox,
                          ...completedAppointments
                              .map((appointment) =>
                              _buildAppointmentCard(appointment))
                              .toList(),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}