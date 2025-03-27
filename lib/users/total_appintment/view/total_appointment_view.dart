import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hams/general/consts/consts.dart';
import 'package:hams/users/chat_view.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../appointment_details/view/appointment_details.dart';
import '../controller/total_appointment.dart';

class TotalAppointment extends StatelessWidget {
  const TotalAppointment({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(TotalAppointmentcontroller());
    String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? ''; // Get the current user's ID

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
              // Custom AppBar
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: AppColors.whiteColor),
                      onPressed: () => Get.back(),
                    ),
                    Expanded(
                      child: Text(
                        "All Appointments",
                        style: TextStyle(
                          fontSize: AppFontSize.size18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.whiteColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48), // To balance the back button
                  ],
                ),
              ),
              // Main Content
              Expanded(
                child: Obx(
                      () => controller.isLoading.value
                      ? Center(
                    child: CircularProgressIndicator(
                      color: AppColors.whiteColor,
                    ),
                  )
                      : RefreshIndicator(
                    onRefresh: () async {
                      await controller.refreshAppointments();
                    },
                    child: FutureBuilder<QuerySnapshot>(
                      future: controller.getAppointments(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (!snapshot.hasData) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: AppColors.whiteColor,
                            ),
                          );
                        } else {
                          var data = snapshot.data?.docs;
                          if (data == null || data.isEmpty) {
                            return Center(
                              child: "No appointments found"
                                  .text
                                  .size(18)
                                  .color(AppColors.whiteColor.withOpacity(0.8))
                                  .make(),
                            );
                          }
                          return Padding(
                            padding: const EdgeInsets.all(16),
                            child: ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: data.length,
                              itemBuilder: (BuildContext context, index) {
                                var appointment = data[index].data() as Map<String, dynamic>;
                                bool canChat = appointment['status'] == 'accept' || appointment['status'] == 'complete';

                                return Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  color: AppColors.whiteColor,
                                  margin: const EdgeInsets.only(bottom: 15),
                                  child: Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Doctor: ${appointment['appDocName']}",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.primeryColor,
                                                  fontSize: AppFontSize.size16,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              5.heightBox,
                                              Text(
                                                "Date: ${appointment['appDay']}",
                                                style: TextStyle(
                                                  color: AppColors.secondaryTextColor,
                                                  fontSize: 14,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              5.heightBox,
                                              Text(
                                                "Time: ${appointment['appTime']}",
                                                style: TextStyle(
                                                  color: AppColors.secondaryTextColor,
                                                  fontSize: 14,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              5.heightBox,
                                              Text(
                                                "Status: ${appointment.containsKey('status') ? appointment['status'] : "No status"}",
                                                style: TextStyle(
                                                  color: AppColors.secondaryTextColor,
                                                  fontSize: 14,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                Get.to(
                                                      () => Appointmentdetails(
                                                    doc: data[index],
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      AppColors.primeryColor,
                                                      AppColors.greenColor
                                                    ],
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                  ),
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                height: 40,
                                                width: 100,
                                                child: Center(
                                                  child: "Show Details"
                                                      .text
                                                      .size(14)
                                                      .color(AppColors.whiteColor)
                                                      .bold
                                                      .make(),
                                                ),
                                              ),
                                            ),
                                            if (canChat) ...[
                                              10.heightBox,
                                              InkWell(
                                                onTap: () {
                                                  Get.to(() => ChatView(
                                                    doctorId: appointment['appWith'],
                                                    doctorName: appointment['appDocName'],
                                                    userId: currentUserId,
                                                  ));
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        AppColors.primeryColor,
                                                        AppColors.greenColor
                                                      ],
                                                      begin: Alignment.topLeft,
                                                      end: Alignment.bottomRight,
                                                    ),
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  height: 40,
                                                  width: 100,
                                                  child: Center(
                                                    child: "Chat"
                                                        .text
                                                        .size(14)
                                                        .color(AppColors.whiteColor)
                                                        .bold
                                                        .make(),
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
                              },
                            ),
                          );
                        }
                      },
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