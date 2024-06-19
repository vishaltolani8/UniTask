import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:tech_media/utils/routes/route_name.dart';
import '../../../utils/utils.dart';
import 'admin_home_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;
  DatabaseReference ref = FirebaseDatabase.instance.ref();
  int _selectedIndex = 0; // Current selected index for bottom navigation bar
  List<Map<String, dynamic>> _createdClasses = []; // List of created classes

  @override
  void initState() {
    super.initState();
    _fetchCreatedClasses();
  }

  // Function to fetch classes created by the admin
  void _fetchCreatedClasses() {
    ref.child('classes').orderByChild('teacherId').equalTo(auth.currentUser?.uid).onValue.listen((event) {
      if (event.snapshot.exists) {
        Map<dynamic, dynamic> classesData = event.snapshot.value as Map;
        List<Map<String, dynamic>> classesList = [];

        classesData.forEach((classId, classInfo) {
          classesList.add({
            'classId': classId,
            'className': classInfo['className'],
            'subject': classInfo['subject'],
            'classCode': classInfo['classCode'],
          });
        });

        setState(() {
          _createdClasses = classesList;
        });
      }
    });
  }

  // Function to handle bottom navigation item selection
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // If "Create Class" is selected, show popup for creating class
    if (index == 1) {
      _showCreateClassPopup(context);
    }
  }

  // Function to show popup for creating class
  void _showCreateClassPopup(BuildContext context) {
    TextEditingController _classNameController = TextEditingController();
    TextEditingController _subjectController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Create Class"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _classNameController,
                decoration: InputDecoration(labelText: "Class Name"),
              ),
              TextField(
                controller: _subjectController,
                decoration: InputDecoration(labelText: "Subject"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                String classCode = _generateClassCode();
                _createClass(
                  _classNameController.text,
                  _subjectController.text,
                  classCode,
                );
                Navigator.of(context).pop();
                _showClassCodeDialog(context, classCode);
              },
              child: Text("Create"),
            ),
          ],
        );
      },
    );
  }

  // Function to generate a random class code
  String _generateClassCode() {
    String characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    String classCode = '';
    for (int i = 0; i < 6; i++) {
      classCode += characters[DateTime.now().microsecondsSinceEpoch % characters.length];
    }
    return classCode;
  }

  // Function to show class code to the admin
  void _showClassCodeDialog(BuildContext context, String classCode) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Class Created"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Class created successfully!"),
              SizedBox(height: 10),
              Text("Class Code: $classCode", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }

  // Function to create a class and save to database
  void _createClass(String className, String subject, String classCode) {
    String? classId = ref.child('classes').push().key;

    ref.child('classes/$classId').set({
      'className': className,
      'subject': subject,
      'classCode': classCode,
      'teacherId': auth.currentUser?.uid,
      'students': {},
    }).then((_) {
      _fetchCreatedClasses(); // Refresh the list of created classes
      Utils.toastMessage('Class created successfully');
    }).catchError((error) {
      Utils.toastMessage(error.toString());
    });
  }

  // Function to navigate to class details screen
  void _navigateToClassDetails(String classId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminHomeDetailsScreen(classId: classId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin'),
        actions: [
          GestureDetector(
            onTap: () {
              auth.signOut();
              Navigator.pushNamed(context, RouteName.loginView);
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Icon(Icons.logout_outlined),
            ),
          ),
        ],
      ),
      body: Center(
        child: _selectedIndex == 0
            ? _buildClassesList() // Build classes list for Home screen
            : _selectedIndex == 1
            ? Text('Create Class') // Placeholder widget for Create Class screen
            : Text('Edit Profile'), // Placeholder widget for Edit Profile screen
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Create Class',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Edit Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        onTap: _onItemTapped,
      ),
    );
  }

  // Function to build the list of created classes
  Widget _buildClassesList() {
    return _createdClasses.isEmpty
        ? Center(child: Text('No classes created yet'))
        : ListView.builder(
      itemCount: _createdClasses.length,
      itemBuilder: (context, index) {
        var classInfo = _createdClasses[index];
        return ListTile(
          title: Text(classInfo['className']),
          subtitle: Text(classInfo['subject']),
          onTap: () => _navigateToClassDetails(classInfo['classId']),
        );
      },
    );
  }
}

// Screen to display class details
