import 'package:flutter/material.dart';
import 'package:hostel_management_app/commens/widgets/custom_dropdown_button.dart';
import 'package:hostel_management_app/fetures/rooms/controllers/rooms_controller.dart';
import 'package:hostel_management_app/fetures/profile/controllers/user_controller.dart';
import 'package:hostel_management_app/fetures/rooms/widgets/rooms_loading_card.dart';
import 'package:hostel_management_app/utils/color_constants.dart';
import 'package:hostel_management_app/utils/text_style_constatnts.dart';
import 'package:hostel_management_app/commens/widgets/room_card.dart';
import 'package:hostel_management_app/fetures/rooms/screens/room_detailes_screen.dart';
import 'package:hostel_management_app/fetures/rooms/screens/rooms_adding_form.dart';
import 'package:provider/provider.dart';

class OwnerRoomsPage extends StatefulWidget {
  const OwnerRoomsPage({super.key});

  @override
  State<OwnerRoomsPage> createState() => _OwnerRoomsPageState();
}

class _OwnerRoomsPageState extends State<OwnerRoomsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RoomsController>(context, listen: false).fetchRoomsData();
      Provider.of<UserController>(context, listen: false).fetchData();
    });
  }

  Future<void> _refreshData() async {
    await Provider.of<RoomsController>(context, listen: false).fetchRoomsData();
    await Provider.of<UserController>(context, listen: false).fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Consumer<RoomsController>(
          builder: (context, value, child) => value.isRoomsLoading
              ? GridView.builder(
                  itemCount: 15,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 25,
                    mainAxisExtent: 95,
                  ),
                  itemBuilder: (context, index) => const RoomsLoadingCard(),
                )
              : value.rooms.isEmpty
                  ? const Center(
                      child: Text(
                        "No Rooms Added yet",
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : GridView.builder(
                      itemCount: value.rooms.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 5,
                        mainAxisSpacing: 25,
                        mainAxisExtent: 95,
                      ),
                      itemBuilder: (context, index) {
                        final room = value.rooms[index];
                        return RoomsCard(
                          roomNumber: room.roomNo.toString(),
                          vaccentBedNumber: room.vacancy.toString(),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RoomsViewScreen(roomDetails: room),
                              ),
                            );
                          },
                        );
                      },
                    ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const RoomsAddingForm(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
