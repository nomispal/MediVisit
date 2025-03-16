import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:hams/general/consts/consts.dart';
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
      List<Map<String, dynamic>> appointments = snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>? ?? {};
        return {
          'id': doc.id,
          'appBy': data['appBy']?.toString() ?? '',
          'appName': data['appName']?.toString() ?? 'Unknown Name',
          'appMobile': data['appMobile']?.toString() ?? 'Unknown Mobile',
          'appMsg': data['appMsg']?.toString() ?? 'No Message',
          'appDay': data['appDay']?.toString() ?? 'Unknown Day',
          'appTime': data['appTime']?.toString() ?? 'Unknown Time',
          'status': data['status']?.toString() ?? 'pending',
          'isReview': data['isReview']?.toString() ?? 'false',
        };
      }).toList();

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

  Future<String?> _getUserImage(String userId) async {
    if (userId.isEmpty) return null;
    try {
      DocumentSnapshot userDoc =
      await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists && userDoc.data() != null) {
        return (userDoc.data() as Map<String, dynamic>)['image']?.toString();
      }
      return null;
    } catch (e) {
      print("Error fetching user image: $e");
      return null;
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

  @override
  Widget build(BuildContext context) {
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
              // Header Section (White AppBar-like section at the top)
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
                        ? Center(child: Text(_errorMessage!))
                        : _appointments.isEmpty
                        ? const Center(child: Text("No appointments booked"))
                        : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        "Upcoming Appointments"
                            .text
                            .color(AppColors.primeryColor)
                            .size(AppFontSize.size16)
                            .fontWeight(FontWeight.bold)
                            .make(),
                        10.heightBox,
                        ..._appointments.map((appointment) {
                          return FutureBuilder<String?>(
                            future: _getUserImage(appointment['appBy']),
                            builder: (context, imageSnapshot) {
                              Widget avatarWidget = CircleAvatar(
                                radius: 20.r,
                                backgroundColor: Colors.grey.shade200,
                                child: Icon(
                                  Icons.account_circle,
                                  size: 30.r,
                                  color: Colors.grey.shade600,
                                ),
                              );
                              if (imageSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                avatarWidget = CircleAvatar(
                                  radius: 20.r,
                                  backgroundColor: Colors.grey.shade200,
                                  child: const CircularProgressIndicator(),
                                );
                              } else if (imageSnapshot.hasData &&
                                  imageSnapshot.data!.isNotEmpty) {
                                avatarWidget = CircleAvatar(
                                  radius: 20.r,
                                  backgroundImage:
                                  NetworkImage(imageSnapshot.data!),
                                  onBackgroundImageError: (e, s) => Icon(
                                    Icons.account_circle,
                                    size: 30.r,
                                    color: Colors.grey.shade600,
                                  ),
                                );
                              }

                              return GestureDetector(
                                onTap: () async {
                                  var result = await Get.to(() =>
                                      AppointmentDetails(
                                          appointment: appointment,
                                          appointmentId:
                                          appointment['id']));
                                  if (result == 'updated') {
                                    _fetchAppointments();
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.bgDarkColor,
                                    borderRadius:
                                    BorderRadius.circular(15.r),
                                  ),
                                  padding: EdgeInsets.all(12.w),
                                  margin: EdgeInsets.only(bottom: 8.h),
                                  child: Row(
                                    children: [
                                      avatarWidget,
                                      12.widthBox,
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              appointment['appName'],
                                              style: TextStyle(
                                                fontSize: 16.sp,
                                                fontWeight:
                                                FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                              overflow:
                                              TextOverflow.ellipsis,
                                            ),
                                            4.heightBox,
                                            Text(
                                              appointment['appMobile'],
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                color: AppColors
                                                    .secondaryTextColor,
                                              ),
                                            ),
                                            4.heightBox,
                                            Text(
                                              "${appointment['appDay']} - ${appointment['appTime']}",
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                color: AppColors
                                                    .secondaryTextColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 12.w,
                                            vertical: 6.h),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(
                                              appointment['status'])
                                              .withOpacity(0.1),
                                          border: Border.all(
                                            color: _getStatusColor(
                                                appointment['status']),
                                            width: 1.5,
                                          ),
                                          borderRadius:
                                          BorderRadius.circular(
                                              20.r),
                                        ),
                                        child: Text(
                                          appointment['status']
                                              .toString()
                                              .toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            fontWeight:
                                            FontWeight.w600,
                                            color: _getStatusColor(
                                                appointment['status']),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        }).toList(),
                        if (_appointments.any((app) =>
                        app['status'] == 'complete' &&
                            app['isReview'] == 'false')) ...[
                          20.heightBox,
                          "Completed Appointments"
                              .text
                              .color(AppColors.primeryColor)
                              .size(AppFontSize.size16)
                              .fontWeight(FontWeight.bold)
                              .make(),
                          10.heightBox,
                          ..._appointments
                              .where((app) =>
                          app['status'] == 'complete' &&
                              app['isReview'] == 'false')
                              .map((appointment) {
                            return FutureBuilder<String?>(
                              future: _getUserImage(appointment[
                              'appBy']), // Fetch user image
                              builder: (context, imageSnapshot) {
                                Widget avatarWidget = CircleAvatar(
                                  radius: 20.r,
                                  backgroundColor:
                                  Colors.grey.shade200,
                                  child: Icon(
                                    Icons.account_circle,
                                    size: 30.r,
                                    color: Colors.grey.shade600,
                                  ),
                                );
                                if (imageSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  avatarWidget = CircleAvatar(
                                    radius: 20.r,
                                    backgroundColor:
                                    Colors.grey.shade200,
                                    child:
                                    const CircularProgressIndicator(),
                                  );
                                } else if (imageSnapshot.hasData &&
                                    imageSnapshot.data!.isNotEmpty) {
                                  avatarWidget = CircleAvatar(
                                    radius: 20.r,
                                    backgroundImage: NetworkImage(
                                        imageSnapshot.data!),
                                    onBackgroundImageError: (e, s) =>
                                        Icon(
                                          Icons.account_circle,
                                          size: 30.r,
                                          color: Colors.grey.shade600,
                                        ),
                                  );
                                }

                                return GestureDetector(
                                  onTap: () async {
                                    var result = await Get.to(() =>
                                        AppointmentDetails(
                                            appointment: appointment,
                                            appointmentId:
                                            appointment['id']));
                                    if (result == 'updated') {
                                      _fetchAppointments();
                                    }
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.bgDarkColor,
                                      borderRadius:
                                      BorderRadius.circular(
                                          15.r),
                                    ),
                                    padding: EdgeInsets.all(12.w),
                                    margin:
                                    EdgeInsets.only(bottom: 8.h),
                                    child: Row(
                                      children: [
                                        avatarWidget,
                                        12.widthBox,
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
                                            children: [
                                              Text(
                                                appointment[
                                                'appName'],
                                                style: TextStyle(
                                                  fontSize: 16.sp,
                                                  fontWeight:
                                                  FontWeight
                                                      .bold,
                                                  color:
                                                  Colors.white,
                                                ),
                                                overflow: TextOverflow
                                                    .ellipsis,
                                              ),
                                              4.heightBox,
                                              Text(
                                                appointment[
                                                'appMobile'],
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                  color: AppColors
                                                      .secondaryTextColor,
                                                ),
                                              ),
                                              4.heightBox,
                                              Text(
                                                "${appointment['appDay']} - ${appointment['appTime']}",
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                  color: AppColors
                                                      .secondaryTextColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding:
                                          EdgeInsets.symmetric(
                                              horizontal: 12.w,
                                              vertical: 6.h),
                                          decoration:
                                          BoxDecoration(
                                            color: _getStatusColor(
                                                appointment[
                                                'status'])
                                                .withOpacity(0.1),
                                            border: Border.all(
                                              color: _getStatusColor(
                                                  appointment[
                                                  'status']),
                                              width: 1.5,
                                            ),
                                            borderRadius:
                                            BorderRadius
                                                .circular(
                                                20.r),
                                          ),
                                          child: Text(
                                            appointment['status']
                                                .toString()
                                                .toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              fontWeight:
                                              FontWeight.w600,
                                              color: _getStatusColor(
                                                  appointment[
                                                  'status']),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          }).toList(),
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