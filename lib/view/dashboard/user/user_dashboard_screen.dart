import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:tech_media/utils/routes/route_name.dart';
import 'package:tech_media/utils/utils.dart';
import 'project_details_screen.dart';

class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({Key? key}) : super(key: key);

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;
  DatabaseReference ref = FirebaseDatabase.instance.ref();
  int _selectedIndex = 0; // Current selected index for bottom navigation bar
  List<Map<String, dynamic>> _enrolledClasses = []; // List of enrolled classes

  @override
  void initState() {
    super.initState();
    _fetchEnrolledClasses();
  }

  // Function to fetch enrolled classes
  void _fetchEnrolledClasses() {
    ref.child('users/${auth.currentUser?.uid}/classes').onValue.listen((event) {
      if (event.snapshot.exists) {
        Map<dynamic, dynamic> classesData = event.snapshot.value as Map;
        List<Map<String, dynamic>> classesList = [];

        classesData.forEach((classId, _) async {
          DataSnapshot classSnapshot = await ref.child('classes/$classId').get();
          if (classSnapshot.exists) {
            Map<String, dynamic> classInfo = Map<String, dynamic>.from(classSnapshot.value as Map);
            classInfo['classId'] = classId;
            classesList.add(classInfo);
          }
        });

        setState(() {
          _enrolledClasses = classesList;
        });
      }
    });
  }

  // Function to handle bottom navigation item selection
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      _showJoinClassPopup(context);
    } else if (index == 2) {
      // Placeholder for 'Chat' screen navigation (no change)
    } else if (index == 3) {
      // Placeholder for Edit Profile screen navigation if implemented
    }
  }

  // Function to show popup for entering class code
  void _showJoinClassPopup(BuildContext context) {
    String classCode = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Join Class"),
          content: TextField(
            decoration: InputDecoration(labelText: "Enter Class Code"),
            onChanged: (value) {
              classCode = value;
            },
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
                _joinClass(classCode);
                Navigator.of(context).pop();
              },
              child: Text("Join"),
            ),
          ],
        );
      },
    );
  }

  // Function to join the class using the entered class code
  void _joinClass(String classCode) {
    ref.child('classes').orderByChild('classCode').equalTo(classCode).once().then((event) {
      if (event.snapshot.exists) {
        Map<dynamic, dynamic> classData = event.snapshot.value as Map;
        String classId = classData.keys.first;

        ref.child('classes/$classId/students').update({
          auth.currentUser!.uid: true
        }).then((_) {
          ref.child('users/${auth.currentUser?.uid}/classes').update({
            classId: true
          }).then((_) {
            Utils.toastMessage('Joined class successfully');
          }).catchError((error) {
            Utils.toastMessage('Error: ${error.toString()}');
          });
        }).catchError((error) {
          Utils.toastMessage('Error: ${error.toString()}');
        });
      } else {
        Utils.toastMessage('Invalid class code');
      }
    }).catchError((error) {
      Utils.toastMessage('Error: ${error.toString()}');
    });
  }

  // Function to navigate to project details screen
  void _navigateToProjectDetails(String studentId, String classId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProjectDetailsScreen(studentId: studentId, classId: classId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User'),
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
            ? Text('Join Class')
            : _selectedIndex == 2
            ? Text('Chat') // Placeholder widget for Chat screen (no change)
            : Text('Edit Profile'), // Placeholder widget for Edit Profile screen if implemented
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.grey),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add, color: Colors.grey),
            label: 'Join class',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat, color: Colors.grey),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Colors.grey),
            label: 'Edit Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        onTap: _onItemTapped,
      ),
    );
  }

  // Function to build the list of enrolled classes
  Widget _buildClassesList() {
    return _enrolledClasses.isEmpty
        ? Center(child: Text('No classes enrolled'))
        : ListView.builder(
      itemCount: _enrolledClasses.length,
      itemBuilder: (context, index) {
        var classInfo = _enrolledClasses[index];
        return ListTile(
          title: Text(classInfo['className']),
          subtitle: Text(classInfo['subject']),
          onTap: () => _navigateToProjectDetails(auth.currentUser!.uid, classInfo['classId']),
        );
      },
    );
  }
}
