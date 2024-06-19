import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:tech_media/utils/utils.dart';
import 'admin_chat_screen.dart';
import 'assign_project_screen.dart';

class AdminHomeDetailsScreen extends StatefulWidget {
  final String classId;

  AdminHomeDetailsScreen({required this.classId});

  @override
  _AdminHomeDetailsScreenState createState() => _AdminHomeDetailsScreenState();
}

class _AdminHomeDetailsScreenState extends State<AdminHomeDetailsScreen> {
  DatabaseReference ref = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> _students = [];

  @override
  void initState() {
    super.initState();
    _fetchClassDetails();
  }

  // Fetch enrolled students
  void _fetchClassDetails() {
    ref.child('classes/${widget.classId}/students').onValue.listen((event) {
      if (event.snapshot.exists) {
        Map<dynamic, dynamic> studentsData = event.snapshot.value as Map;
        List<Map<String, dynamic>> studentsList = [];

        Future.forEach(studentsData.keys, (studentId) async {
          DataSnapshot studentSnapshot = await ref.child('User/$studentId').get();
          if (studentSnapshot.exists) {
            Map<dynamic, dynamic> studentInfo = studentSnapshot.value as Map;
            studentsList.add({
              'studentId': studentId,
              'name': studentInfo['userName'],
              'profilePic': studentInfo['profile'],
            });
          }
        }).then((_) {
          setState(() {
            _students = studentsList;
          });
        });
      }
    });
  }

  // Navigate to the Assign Project or Chat screen
  void _navigateToAssignOrChatScreen(String studentId) {
    ref.child('projects/${widget.classId}').orderByChild('studentId').equalTo(studentId).once().then((DatabaseEvent event) {
      if (event.snapshot.exists) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdminChatScreen(classId: widget.classId, studentId: studentId),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AssignProjectScreen(classId: widget.classId, studentId: studentId),
          ),
        );
      }
    }).catchError((error) {
      Utils.toastMessage(error.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Class Details'),
        backgroundColor: Colors.orange,
      ),
      body: _students.isEmpty
          ? Center(child: Text('No students enrolled yet'))
          : ListView.builder(
        itemCount: _students.length,
        itemBuilder: (context, index) {
          final student = _students[index];
          return ListTile(
            leading: student['profilePic'] != null && student['profilePic'].isNotEmpty
                ? CircleAvatar(backgroundImage: NetworkImage(student['profilePic']))
                : CircleAvatar(child: Icon(Icons.person)),
            title: Text(student['name']),
            onTap: () => _navigateToAssignOrChatScreen(student['studentId']),
          );
        },
      ),
    );
  }
}
