import 'package:flutter/material.dart';
import 'package:hostel_management_app/utils/color_constants.dart';
import 'package:hostel_management_app/utils/text_style_constatnts.dart';

class GoingToVacantCard extends StatelessWidget {
  const GoingToVacantCard({
    super.key,
    required this.roomNumber,
    required this.bedNumber,
    required this.backgroundColor,
  });

  final String roomNumber;
  final String bedNumber;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Room No",
            style: TextStyleConstants.upComingVacancyText1,
          ),
          Text(
            roomNumber,
            style: TextStyleConstants.upComingVacancyText2,
          ),
          const SizedBox(height: 5),
          Text(
            "Bed No",
            style: TextStyleConstants.upComingVacancyText1,
          ),
          Text(
            bedNumber,
            style: TextStyleConstants.upComingVacancyText2,
          ),
        ],
      ),
    );
  }
}
