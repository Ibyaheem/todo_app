import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/modules/archived_tasks/archived_tasks.dart';
import 'package:todo_app/modules/done_tasks/done_tasks.dart';
import 'package:todo_app/modules/new_tasks/new_tasks.dart';

import '../constants/constants.dart';

class HomeLayout extends StatefulWidget {
  const HomeLayout({Key? key}) : super(key: key);

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> {
  int currentIndex = 0;

  List<Widget> screens = [
    NewTasks(),
    DoneTasks(),
    ArchivedTasks(),
  ];

  List<String> titles = [
    'New Tasks',
    'Done Tasks',
    'Archived Tasks',
  ];

  @override
  void initState() {
    super.initState();
    createDatabase();
  }

  Database? database;
  var scaffoldkey = GlobalKey<ScaffoldState>();
  var formkey = GlobalKey<FormState>();
  var titleController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();
  bool isBottomSheetShown = false;
  IconData fabIcon = Icons.edit;

  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldkey,
      appBar: AppBar(
        title: Text(
          '${titles[currentIndex]}',
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

          if (isBottomSheetShown) {
            if (formkey.currentState!.validate()) {
              insertToDatabase(
                title: titleController.text,
                date: dateController.text,
                time: timeController.text,
              ).then((value) {
                getDataFromDatabase(database).then((value) {
                  Navigator.pop(context);
                  setState(() {
                    isBottomSheetShown = false;
                    fabIcon = Icons.edit;
                    tasks = value;
                    print(tasks);
                  });
                });
              });
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
                                      lastDate: DateTime.parse('2025-12-31'))
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
              isBottomSheetShown = false;
              setState(() {
                fabIcon = Icons.edit;
              });
            });
            isBottomSheetShown = true;
            setState(() {
              fabIcon = Icons.add;
            });
          }
        },
        child: Icon(
          fabIcon,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
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
      body: tasks.length == 0
          ? Center(child: CircularProgressIndicator())
          : screens[currentIndex],
    );
  }
  //instance of 'Future<String>'

  // Future<String> getName() async {
  //   return 'Ibrahim EL-Badwy';
  // }

  void createDatabase() async {
// open the database
    Database database = await openDatabase(
      'todo.db',
      version: 1,
      onCreate: (database, version) {
        //id integer
        //title String
        //date String
        //time String
        //status String

        print('database created');
        database
            .execute(
                'CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT, date TEXT, time TEXT, status TEXT) ')
            .then((value) {
          print('table created');
        }).catchError((error) {
          print('Error when creating table ${error.toString()}');
        });
      },
      onOpen: (database) {
        getDataFromDatabase(database).then((value) {
          tasks = value;
          print(tasks);
        });
        print('database opened');
      },
    );
  }

  Future insertToDatabase({
    required String title,
    required String time,
    required String date,
  }) async {
    return await database?.transaction((txn) {
      txn
          .rawInsert(
              'INSERT INTO tasks(title, date, time, status) VALUES("$title", "$date", "$time", "new")')
          .then((value) {
        print('$value inserted successfully');
      }).catchError((error) {
        print('Error when Inserting new record ${error.toString()}');
      });

      return Future(() => null);
    });
  }

  Future<List<Map>> getDataFromDatabase(database) async {
    return await database!.rawQuery('SELECT * FROM tasks');
  }
}
