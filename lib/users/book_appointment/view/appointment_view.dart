import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hams/general/consts/consts.dart';
import 'package:intl/intl.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../widgets/coustom_button.dart';
import '../../widgets/coustom_textfield.dart';
import '../controller/book_appointment_controller.dart';

class BookAppointmentView extends StatefulWidget {
  final String docId;
  final String docNum;
  final String docName;
  const BookAppointmentView({
    super.key,
    required this.docId,
    required this.docName,
    required this.docNum,
  });

  @override
  State<BookAppointmentView> createState() => _BookAppointmentViewState();
}

class _BookAppointmentViewState extends State<BookAppointmentView> {
  var controller = Get.put(AppointmentController());

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
                        "Doctor: ${widget.docName}",
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
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    margin: const EdgeInsets.all(16),
                    color: AppColors.whiteColor,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: controller.formkey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            "Select Appointment Date"
                                .text
                                .size(AppFontSize.size16)
                                .color(AppColors.primeryColor)
                                .bold
                                .make(),
                            SizedBox(
                              height: 100,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: controller.dates.length,
                                itemBuilder: (context, index) {
                                  DateTime date = controller.dates[index];
                                  bool isSelected = date.isAtSameMomentAs(
                                      controller.selectedDate.value);
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        controller.selectedDate.value = date;
                                        controller.finalDate.value =
                                            DateFormat('yyyy-MM-dd')
                                                .format(controller.selectedDate.value);
                                        List<String> filteredIntervals =
                                        controller.getFilteredTimeIntervals();
                                        if (filteredIntervals.isNotEmpty) {
                                          controller.selectedTime.value =
                                          filteredIntervals[0];
                                        }
                                      });
                                    },
                                    child: Container(
                                      width: 80,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 10),
                                      decoration: BoxDecoration(
                                        gradient: isSelected
                                            ? LinearGradient(
                                          colors: [
                                            AppColors.primeryColor,
                                            AppColors.greenColor
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                            : null,
                                        color: !isSelected
                                            ? AppColors.whiteColor
                                            : null,
                                        borderRadius: BorderRadius.circular(15),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.3),
                                            blurRadius: 5,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            DateFormat('E').format(date),
                                            style: TextStyle(
                                              color: isSelected
                                                  ? AppColors.whiteColor
                                                  : AppColors.textcolor,
                                            ),
                                          ),
                                          Text(
                                            date.day.toString(),
                                            style: TextStyle(
                                              fontSize: 24,
                                              color: isSelected
                                                  ? AppColors.whiteColor
                                                  : AppColors.textcolor,
                                            ),
                                          ),
                                          Text(
                                            DateFormat('MMM').format(date),
                                            style: TextStyle(
                                              color: isSelected
                                                  ? AppColors.whiteColor
                                                  : AppColors.textcolor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            15.heightBox,
                            "Select Appointment Time"
                                .text
                                .size(AppFontSize.size16)
                                .color(AppColors.primeryColor)
                                .bold
                                .make(),
                            SizedBox(
                              height: 70,
                              child: Obx(
                                    () {
                                  List<String> filteredIntervals =
                                  controller.getFilteredTimeIntervals();
                                  if (filteredIntervals.isEmpty) {
                                    return Center(
                                      child: Text(
                                        "No time slots available",
                                        style: TextStyle(
                                          color: AppColors.primeryColor,
                                          fontSize: 14,
                                        ),
                                      ),
                                    );
                                  }
                                  return ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: filteredIntervals.length,
                                    itemBuilder: (context, index) {
                                      String interval = filteredIntervals[index];
                                      bool isSelected = controller
                                          .selectedTime.value ==
                                          interval;
                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            controller.selectedTime.value =
                                                interval;
                                          });
                                        },
                                        child: Container(
                                          width: 140,
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 5, vertical: 10),
                                          decoration: BoxDecoration(
                                            gradient: isSelected
                                                ? LinearGradient(
                                              colors: [
                                                AppColors.primeryColor,
                                                AppColors.greenColor
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            )
                                                : null,
                                            color: !isSelected
                                                ? AppColors.whiteColor
                                                : null,
                                            borderRadius:
                                            BorderRadius.circular(15),
                                            boxShadow: [
                                              BoxShadow(
                                                color:
                                                Colors.grey.withOpacity(0.3),
                                                blurRadius: 5,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: Text(
                                              interval,
                                              style: TextStyle(
                                                color: isSelected
                                                    ? AppColors.whiteColor
                                                    : AppColors.textcolor,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                            20.heightBox,
                            "Mobile Number"
                                .text
                                .size(AppFontSize.size16)
                                .color(AppColors.primeryColor)
                                .bold
                                .make(),
                            10.heightBox,
                            CoustomTextField(
                              validator: controller.validdata,
                              textcontroller: controller.appMobileController,
                              hint: "Enter patient mobile number",
                              icon: Icon(
                                Icons.call,
                                color: AppColors.primeryColor,
                              ),
                              textcolor: AppColors.secondaryTextColor,
                            ),
                            20.heightBox,
                            "Your Problem"
                                .text
                                .size(AppFontSize.size16)
                                .color(AppColors.primeryColor)
                                .bold
                                .make(),
                            10.heightBox,
                            TextFormField(
                              controller: controller.appMessageController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.note_add,
                                  color: AppColors.primeryColor,
                                ),
                                hintText: "Write your problem in short",
                                hintStyle: TextStyle(
                                  color: AppColors.secondaryTextColor,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: AppColors.primeryColor,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: AppColors.primeryColor,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                            30.heightBox,
                            Obx(
                                  () => controller.isLoading.value
                                  ? Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primeryColor,
                                ),
                              )
                                  : SizedBox(
                                width: context.screenWidth * 0.7,
                                height: 50,
                                child: CoustomButton(
                                  onTap: () async {
                                    await controller.bookAppointment(
                                        widget.docId,
                                        widget.docName,
                                        widget.docNum,
                                        context);
                                  },
                                  title: "Confirm Appointment",
                                ),
                              ),
                            ),
                          ],
                        ),
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
}