import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:hostel_management_app/commens/widgets/shimmer_loader.dart';
import 'package:hostel_management_app/utils/color_constants.dart';
import 'package:hostel_management_app/utils/text_style_constatnts.dart';

class ResidentsDetailescard extends StatelessWidget {
  const ResidentsDetailescard(
      {super.key,
      required this.name,
      required this.joiningDate,
      required this.roomNumber,
      required this.onTap,
      required this.isFeePaid,
      required this.image});
  final String name;
  final String joiningDate;
  final int roomNumber;
  final String image;
  final bool isFeePaid;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: ColorConstants.secondaryWhiteColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: ColorConstants.primaryBlackColor.withOpacity(0.2),
              blurRadius: 2,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: name,
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: ColorConstants.secondaryColor3,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: image.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: image.endsWith('.jpg') ? image : '$image.jpg',
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                              progressIndicatorBuilder:
                                  (context, url, progress) =>
                                      const ShimmerEffect(
                                          height: 40, width: 40, radius: 40),
                            )
                          : const Center(
                              child: Icon(Icons.person),
                            ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      name,
                      style: TextStyleConstants.dashboardBookingName,
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_month,
                          size: 17,
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          "$joiningDate joining",
                          style: TextStyleConstants.bookingsJoiningDate,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.room,
                          size: 17,
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          "Room $roomNumber",
                          style: TextStyleConstants.bookingsJoiningDate,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isFeePaid
                    ? ColorConstants.secondaryColor1
                    : ColorConstants.secondaryColor2,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                isFeePaid ? "Paid" : "Pending",
                style: TextStyleConstants.bookingsJoiningDate.copyWith(
                  color: isFeePaid
                      ? ColorConstants.primaryBlackColor
                      : ColorConstants.primaryWhiteColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
