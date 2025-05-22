import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:hostel_management_app/commens/functions/make_phone_call.dart';
import 'package:hostel_management_app/fetures/bookings/controllers/bookings_controller.dart';
import 'package:hostel_management_app/fetures/residents/controllers/residents_controller.dart';
import 'package:hostel_management_app/fetures/bookings/models/bookings_model.dart';
import 'package:hostel_management_app/utils/color_constants.dart';
import 'package:hostel_management_app/utils/text_style_constatnts.dart';
import 'package:hostel_management_app/fetures/bookings/screens/add_booking_screen.dart';
import 'package:hostel_management_app/fetures/bookings/widgets/confirm_delete_dialog.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class BookedResidentDetailesScreen extends StatelessWidget {
  const BookedResidentDetailesScreen(
      {super.key, required this.index, this.isSorted = false});

  final int index;
  final bool? isSorted;

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<ResidentsController>(context, listen: false);
    return Consumer<BookingsController>(
      builder: (context, value, child) {
        final BookingsModel details = isSorted!
            ? value.bookingsWithinThisWeek[index]
            : value.bookings[index];
        return Scaffold(
          backgroundColor: ColorConstants.primaryWhiteColor,
          appBar: AppBar(
            backgroundColor: ColorConstants.primaryWhiteColor,
            iconTheme: IconThemeData(color: ColorConstants.primaryBlackColor),
            leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.chevron_left_outlined,
                  size: 30,
                )),
            title: Text(
              "Booking Details",
              style: TextStyleConstants.homeMainTitle2,
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Resident Details",
                  style: TextStyleConstants.dashboardSubtitle1,
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: ColorConstants.secondaryWhiteColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Name",
                            style: TextStyleConstants.ownerRoomsText2,
                          ),
                          Text(
                            details.name,
                            style: TextStyleConstants.dashboardBookingName,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Phone No",
                            style: TextStyleConstants.ownerRoomsText2,
                          ),
                          InkWell(
                            onTap: () {
                              makePhoneCall(details.phoneNo, context);
                            },
                            child: Text(
                              details.phoneNo,
                              style: TextStyleConstants.dashboardBookingName,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Room No",
                            style: TextStyleConstants.ownerRoomsText2,
                          ),
                          Text(
                            details.roomNO.toString(),
                            style: TextStyleConstants.dashboardBookingName,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Check In",
                            style: TextStyleConstants.ownerRoomsText2,
                          ),
                          Text(
                            DateFormat('dd/MM/yyyy').format(details.checkIn),
                            style: TextStyleConstants.dashboardBookingName,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Advance",
                            style: TextStyleConstants.ownerRoomsText2,
                          ),
                          Text(
                            details.advancePaid ? "Paid" : "Not Paid",
                            style: TextStyleConstants.dashboardBookingName,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      onTap: () {
                        Provider.of<BookingsController>(context, listen: false)
                            .onEdit(booking: details);
                        showAdaptiveDialog(
                          barrierColor: Colors.transparent,
                          context: context,
                          builder: (context) => AddBookingScreen(
                            roomNo: details.roomNO,
                            roomid: details.roomId,
                          ),
                        );
                      },
                      child: Container(
                        height: 50,
                        width: 150,
                        decoration: BoxDecoration(
                          color: ColorConstants.primaryColor,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Center(
                          child: Text(
                            "Edit",
                            style: TextStyleConstants.buttonText,
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => DeletDialog(
                            bookingId: details.id,
                            roomId: details.roomId,
                          ),
                        );
                      },
                      child: Container(
                        height: 50,
                        width: 150,
                        decoration: BoxDecoration(
                          color: ColorConstants.colorRed,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Center(
                          child: Text(
                            "Delete",
                            style: TextStyleConstants.buttonText,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                InkWell(
                  onTap: () {
                    controller.addBookingToResident(details, context);
                  },
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: ColorConstants.secondaryColor3,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(
                      child: Text(
                        "Add to Residents",
                        style: TextStyleConstants.buttonText,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
