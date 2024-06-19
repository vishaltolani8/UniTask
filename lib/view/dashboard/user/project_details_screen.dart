import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:tech_media/view/dashboard/user/user_chat_screen.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final String studentId;
  final String classId;

  ProjectDetailsScreen({required this.studentId, required this.classId});

  @override
  _ProjectDetailsScreenState createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  DatabaseReference ref = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> _projects = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProjectDetails();
  }

  void _fetchProjectDetails() {
    ref.child('projects').orderByChild('studentId').equalTo(widget.studentId).onValue.listen((event) async {
      if (event.snapshot.exists) {
        Map<dynamic, dynamic> projectsData = event.snapshot.value as Map;
        List<Map<String, dynamic>> projectsList = [];

        for (var projectId in projectsData.keys) {
          var projectInfo = projectsData[projectId];
          projectsList.add({
            'projectId': projectId,
            'projectName': projectInfo['projectName'],
            'projectDescription': projectInfo['projectDescription'],
            'classId': widget.classId,
          });
        }

        setState(() {
          _projects = projectsList;
          isLoading = false;
        });
      } else {
        setState(() {
          _projects = [];
          isLoading = false;
        });
      }
    }, onError: (error) {
      print('Error fetching projects: $error');
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Project Details',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.orange,
      ),
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(),
      )
          : _projects.isEmpty
          ? Center(
        child: Text(
          'No projects assigned yet',
          style: TextStyle(color: Colors.black),
        ),
      )
          : ListView.builder(
        itemCount: _projects.length,
        itemBuilder: (context, index) {
          final project = _projects[index];
          return ListTile(
            title: Center(
              child: Text(
                project['projectName'],
                style: TextStyle(color: Colors.black),
              ),
            ),
            subtitle: Text(
              project['projectDescription'],
              style: TextStyle(color: Colors.black54),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => UserChatScreen(classId: widget.classId, studentId: widget.studentId),
            ),
          );
        },
        child: Icon(Icons.chat),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
