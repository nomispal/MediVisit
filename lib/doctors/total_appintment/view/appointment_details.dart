import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:hams/general/consts/consts.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:url_launcher/url_launcher.dart'; // For contact functionality
import 'package:flutter/services.dart'; // For clipboard functionality
import 'package:hams/users/chat_view.dart'; // Import your chat view
import 'package:firebase_auth/firebase_auth.dart'; // For getting current user ID

class AppointmentDetails extends StatefulWidget {
  final Map<String, dynamic> appointment;
  final String appointmentId;

  const AppointmentDetails({
    Key? key,
    required this.appointment,
    required this.appointmentId,
  }) : super(key: key);

  @override
  _AppointmentDetailsState createState() => _AppointmentDetailsState();
}

class _AppointmentDetailsState extends State<AppointmentDetails> {
  late String _selectedStatus;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.appointment['status']?.toString() ?? 'pending';
  }

  Future<void> _updateStatus(String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(widget.appointmentId)
          .update({'status': newStatus});
      setState(() {
        _selectedStatus = newStatus;
      });
      Get.snackbar('Success', 'Status updated to $newStatus',
          snackPosition: SnackPosition.TOP, duration: Duration(seconds: 2));
      print('Status updated to $newStatus for appointment ID: ${widget.appointmentId}');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update status: $e',
          snackPosition: SnackPosition.TOP, duration: Duration(seconds: 2));
      print('Error updating status: $e');
    }
  }

  // Function to validate and format the phone number
  String _formatPhoneNumber(String phoneNumber) {
    // Remove any non-digit characters (e.g., spaces, dashes)
    String cleanedNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');

    // Check if the number already starts with a '+'
    if (!cleanedNumber.startsWith('+')) {
      // If not, prepend a default country code (e.g., +92 for Pakistan)
      cleanedNumber = '+92$cleanedNumber';
    }

    return cleanedNumber;
  }

  // Function to launch URLs (tel: for calls)
  Future<void> _launchURL(String scheme, String path) async {
    // Validate and format the phone number if the scheme is 'tel'
    String formattedPath = path;
    if (scheme == 'tel') {
      formattedPath = _formatPhoneNumber(path);
    }

    // Basic validation: ensure the number has at least 10 digits (excluding the country code)
    if (scheme == 'tel') {
      String digitsOnly = formattedPath.replaceAll(RegExp(r'\D'), '');
      if (digitsOnly.length < 10) {
        Get.snackbar(
          'Error',
          'Invalid phone number: $path',
          snackPosition: SnackPosition.TOP,
          duration: Duration(seconds: 2),
          backgroundColor: AppColors.primeryColor,
          colorText: AppColors.whiteColor,
        );
        return;
      }
    }

    final Uri uri = Uri(scheme: scheme, path: formattedPath);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        // Fallback: Copy the phone number to the clipboard
        await Clipboard.setData(ClipboardData(text: formattedPath));
        Get.snackbar(
          'Error',
          'Could not launch $scheme:$formattedPath. Number copied to clipboard.',
          snackPosition: SnackPosition.TOP,
          duration: Duration(seconds: 2),
          backgroundColor: AppColors.primeryColor,
          colorText: AppColors.whiteColor,
        );
      }
    } catch (e) {
      // Fallback: Copy the phone number to the clipboard
      await Clipboard.setData(ClipboardData(text: formattedPath));
      Get.snackbar(
        'Error',
        'Failed to launch $scheme:$formattedPath: $e. Number copied to clipboard.',
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 2),
        backgroundColor: AppColors.primeryColor,
        colorText: AppColors.whiteColor,
      );
    }
  }

  void _showContactOptions() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Text(
            "Call Patient",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.primeryColor,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.phone, color: AppColors.primeryColor),
                title: Text('Call'),
                onTap: () {
                  Navigator.pop(context);
                  String phoneNumber = widget.appointment['appMobile']?.toString() ?? '';
                  if (phoneNumber.isEmpty) {
                    Get.snackbar(
                      'Error',
                      'Phone number not available',
                      snackPosition: SnackPosition.TOP,
                      duration: Duration(seconds: 2),
                      backgroundColor: AppColors.primeryColor,
                      colorText: AppColors.whiteColor,
                    );
                    return;
                  }
                  _launchURL('tel', phoneNumber);
                },
              ),
            ],
          ),
        );
      },
    );
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
    // Determine if the "Chat" button should be shown
    bool canChat = _selectedStatus == 'accept' || _selectedStatus == 'complete';

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4A90E2), Color(0xFF50E3C2)], // Teal gradient from the image
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom AppBar
              Container(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Get.back(result: 'updated'),
                    ),
                    Expanded(
                      child: Text(
                        "Appointment Details",
                        style: TextStyle(
                          fontSize: AppFontSize.size18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48), // Balance the back button
                  ],
                ),
              ),
              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                    child: Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow(
                            icon: Icons.account_circle,
                            label: "Patient Name",
                            value: widget.appointment['appName']?.toString() ?? 'Unknown',
                          ),
                          10.heightBox,
                          _buildDetailRow(
                            icon: Icons.phone,
                            label: "Contact",
                            value: widget.appointment['appMobile']?.toString() ?? 'Unknown',
                          ),
                          10.heightBox,
                          _buildDetailRow(
                            icon: Icons.message,
                            label: "Message",
                            value: widget.appointment['appMsg']?.toString() ?? 'No message',
                          ),
                          10.heightBox,
                          _buildDetailRow(
                            icon: Icons.calendar_today,
                            label: "Day",
                            value: widget.appointment['appDay']?.toString() ?? 'Unknown day',
                          ),
                          10.heightBox,
                          _buildDetailRow(
                            icon: Icons.access_time,
                            label: "Time",
                            value: widget.appointment['appTime']?.toString() ?? 'Unknown time',
                          ),
                          20.heightBox,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: DropdownButton<String>(
                                  value: _selectedStatus,
                                  icon: Icon(Icons.arrow_drop_down, color: AppColors.primeryColor),
                                  iconSize: 24.w,
                                  elevation: 16,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.black87,
                                  ),
                                  underline: Container(
                                    height: 2.h,
                                    color: AppColors.primeryColor.withOpacity(0.3),
                                  ),
                                  onChanged: (String? newValue) {
                                    if (newValue != null && newValue != _selectedStatus) {
                                      _updateStatus(newValue);
                                    }
                                  },
                                  items: <String>['pending', 'accept', 'reject', 'complete']
                                      .map<DropdownMenuItem<String>>((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value.toUpperCase()),
                                    );
                                  }).toList(),
                                ),
                              ),
                              10.widthBox,
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12.w, vertical: 6.h),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(_selectedStatus)
                                      .withOpacity(0.1),
                                  border: Border.all(
                                    color: _getStatusColor(_selectedStatus),
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                child: Text(
                                  _selectedStatus.toString().toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: _getStatusColor(_selectedStatus),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          20.heightBox,
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25.r),
                              ),
                              elevation: 0,
                              padding: EdgeInsets.zero,
                            ),
                            onPressed: _showContactOptions,
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [AppColors.primeryColor, AppColors.greenColor],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(25.r),
                              ),
                              child: Center(
                                child: Text(
                                  "Call Patient",
                                  style: TextStyle(
                                    color: AppColors.whiteColor,
                                    fontSize: 16.sp,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Add the "Chat" button if the status is 'accept' or 'complete'
                          if (canChat) ...[
                            20.heightBox,
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25.r),
                                ),
                                elevation: 0,
                                padding: EdgeInsets.zero,
                              ),
                              onPressed: () {
                                String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
                                if (currentUserId.isEmpty) {
                                  Get.snackbar(
                                    'Error',
                                    'Doctor not logged in. Please log in to continue.',
                                    snackPosition: SnackPosition.TOP,
                                    duration: Duration(seconds: 2),
                                    backgroundColor: AppColors.primeryColor,
                                    colorText: AppColors.whiteColor,
                                  );
                                  return;
                                }
                                String? patientId = widget.appointment['appBy']?.toString();
                                if (patientId == null || patientId.isEmpty) {
                                  Get.snackbar(
                                    'Error',
                                    'Patient ID not available for this appointment.',
                                    snackPosition: SnackPosition.TOP,
                                    duration: Duration(seconds: 2),
                                    backgroundColor: AppColors.primeryColor,
                                    colorText: AppColors.whiteColor,
                                  );
                                  return;
                                }
                                Get.to(() => ChatView(
                                  doctorId: currentUserId,
                                  doctorName: widget.appointment['doctorName']?.toString() ?? 'Doctor',
                                  userId: patientId,
                                  patientName: widget.appointment['appName']?.toString(),
                                ));
                              },
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [AppColors.primeryColor, AppColors.greenColor],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(25.r),
                                ),
                                child: Center(
                                  child: Text(
                                    "Chat with Patient",
                                    style: TextStyle(
                                      color: AppColors.whiteColor,
                                      fontSize: 16.sp,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
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

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primeryColor, size: 24.w),
        12.widthBox,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primeryColor,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}