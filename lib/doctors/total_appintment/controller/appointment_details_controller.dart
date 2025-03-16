import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hams/general/consts/consts.dart';

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
  bool _isDropdownDisabled = false;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.appointment['status']?.toString() ?? 'pending';
    _isDropdownDisabled = _selectedStatus.toLowerCase() == 'complete';
  }

  Future<void> _updateStatus(String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(widget.appointmentId)
          .update({'status': newStatus});
      setState(() {
        _selectedStatus = newStatus;
        _isDropdownDisabled = newStatus.toLowerCase() == 'complete';
      });
      Get.snackbar('Success', 'Status updated to $newStatus');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update status: $e');
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accept':
        return Colors.green;
      case 'reject':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      case 'complete':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.back(result: 'updated');
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.whiteColor,
          title: Text(
            "Appointment Details",
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 5,
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow(
                        icon: Icons.account_circle,
                        label: "Patient name",
                        value: widget.appointment['appName']?.toString() ?? 'Unknown',
                      ),
                      _buildDetailRow(
                        icon: Icons.phone,
                        label: "Patient Contact",
                        value: widget.appointment['appMobile']?.toString() ?? 'Unknown',
                      ),
                      _buildDetailRow(
                        icon: Icons.message,
                        label: "Message",
                        value: widget.appointment['appMsg']?.toString() ?? 'No message',
                      ),
                      _buildDetailRow(
                        icon: Icons.calendar_today,
                        label: "Day",
                        value: widget.appointment['appDay']?.toString() ?? 'Unknown day',
                      ),
                      _buildDetailRow(
                        icon: Icons.access_time,
                        label: "Time",
                        value: widget.appointment['appTime']?.toString() ?? 'Unknown time',
                      ),
                      SizedBox(height: 20.h),
                      Row(
                        children: [
                          Icon(Icons.info, color: AppColors.greenColor, size: 24.w),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: DropdownButton<String>(
                              value: _selectedStatus,
                              icon: const Icon(Icons.arrow_drop_down),
                              iconSize: 24.w,
                              elevation: 16,
                              style: TextStyle(fontSize: 16.sp, color: Colors.black),
                              onChanged: _isDropdownDisabled
                                  ? null
                                  : (String? newValue) {
                                if (newValue != null) {
                                  _updateStatus(newValue);
                                }
                              },
                              items: <String>['accept', 'reject', 'pending', 'complete']
                                  .map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Container(
                            height: 25.h,
                            decoration: BoxDecoration(
                              color: _getStatusColor(_selectedStatus),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Center(
                              child: Text(
                                _selectedStatus.toUpperCase(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_selectedStatus == 'complete' &&
                          (widget.appointment['isReview']?.toString() ?? 'false') ==
                              'false')
                        Column(
                          children: [
                            SizedBox(height: 20.h),
                            TextButton(
                              onPressed: () {
                                Get.snackbar("Review",
                                    "Add review functionality here");
                              },
                              child: Text("Leave a Review",
                                  style: TextStyle(color: AppColors.primeryColor)),
                            ),
                          ],
                        ),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
                SizedBox(height: 70.h),
                Center(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding:
                      EdgeInsets.symmetric(horizontal: 100.w, vertical: 12.h),
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      "Contact with patient",
                      style: TextStyle(fontSize: 13.sp),
                    ),
                  ),
                ),
              ],
            ),
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
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Icon(icon, color: AppColors.greenColor, size: 24.w),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}