import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/shared/cubit/cubit.dart';
import 'package:todo_app/shared/cubit/states.dart';

class HomeLayout extends StatelessWidget {
  @override
  // void initState() {
  //   super.initState();
  //   createDatabase();
  // }
  List<Map> tasks = [];
  var scaffoldkey = GlobalKey<ScaffoldState>();
  var formkey = GlobalKey<FormState>();
  var titleController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();

  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AppCubit()..createDatabase(),
      child: BlocConsumer<AppCubit, AppStates>(
          listener: (BuildContext context, AppStates state) {
        if (state is AppInsertDatabaseState) {
          Navigator.pop(context);
        }
      }, builder: (BuildContext context, AppStates state) {
        AppCubit cubit = AppCubit.get(context);
        return Scaffold(
          key: scaffoldkey,
          appBar: AppBar(
            title: Text(
              cubit.titles[cubit.currentIndex],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // try {
              //   var name = await getName();
              //   print(name);
              //
              //  // throw ('some error!!!!!!');  //create error بايدي
              // } catch (error) {
              //   print('error ${error.toString()}');
              // }

              if (cubit.isBottomSheetShown) {
                if (formkey.currentState!.validate()) {
                  cubit.insertToDatabase(
                    title: titleController.text,
                    time: timeController.text,
                    date: dateController.text,
                  );
                  // insertToDatabase(
                  //   title: titleController.text,
                  //   date: dateController.text,
                  //   time: timeController.text,
                  // ).then((value) {
                  //   getDataFromDatabase(database).then((value) {
                  //     Navigator.pop(context);
                  //     // setState(() {
                  //     //   isBottomSheetShown = false;
                  //     //   fabIcon = Icons.edit;
                  //     //   tasks = value;
                  //     //   print(tasks);
                  //     // });
                  //   });
                  // });
                }
              } else {
                scaffoldkey.currentState
                    ?.showBottomSheet(
                      (context) => Container(
                        color: Colors.white,
                        padding: EdgeInsets.all(
                          20.0,
                        ),
                        child: Form(
                          key: formkey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextFormField(
                                controller: titleController,
                                keyboardType: TextInputType.text,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'title must not be empty';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  labelText: 'Task Title',
                                  prefixIcon: Icon(
                                    Icons.title,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 15.0,
                              ),
                              TextFormField(
                                controller: timeController,
                                keyboardType: TextInputType.datetime,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'time must not be empty';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  labelText: 'Task Time',
                                  prefixIcon: Icon(
                                    Icons.watch_later_outlined,
                                  ),
                                ),
                                onTap: () {
                                  showTimePicker(
                                          context: context,
                                          initialTime: TimeOfDay.now())
                                      .then((value) {
                                    timeController.text =
                                        value!.format(context).toString();
                                    print(value.format(context));
                                  });
                                  print('timing tapped');
                                },
                              ),
                              SizedBox(
                                height: 15.0,
                              ),
                              TextFormField(
                                controller: dateController,
                                keyboardType: TextInputType.datetime,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'date must not be empty';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  labelText: 'Task Date',
                                  prefixIcon: Icon(
                                    Icons.calendar_today,
                                  ),
                                ),
                                onTap: () {
                                  showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime.now(),
                                          lastDate:
                                              DateTime.parse('2025-12-31'))
                                      .then((value) {
                                    dateController.text =
                                        DateFormat.yMMMd().format(value!);
                                  });
                                  print('date tapped');
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      elevation: 25.0,
                    )
                    .closed
                    .then((value) {
                  cubit.changeBottomSheetState(
                    isShow: false,
                    icon: Icons.edit,
                  );
                });
                cubit.changeBottomSheetState(
                  isShow: true,
                  icon: Icons.add,
                );
              }
            },
            child: Icon(
              cubit.fabIcon,
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: cubit.currentIndex,
            onTap: (index) {
              cubit.changeIndex(index);
            },
            items: [
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.menu,
                ),
                label: 'Tasks',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.check_circle_outline,
                ),
                label: 'Done',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.archive_outlined,
                ),
                label: 'Archived',
              ),
            ],
          ),
          body: state is! AppGetDatabaseLoadingState
              ? cubit.screens[cubit.currentIndex]
              : Center(child: CircularProgressIndicator()),
        );
      }),
    );
  }
  //instance of 'Future<String>'

  // Future<String> getName() async {
  //   return 'Ibrahim EL-Badwy';
  // }

}
