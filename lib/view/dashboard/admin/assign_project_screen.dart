import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../utils/utils.dart';
import 'admin_chat_screen.dart';

class AssignProjectScreen extends StatefulWidget {
  final String classId;
  final String studentId;

  AssignProjectScreen({required this.classId, required this.studentId});

  @override
  _AssignProjectScreenState createState() => _AssignProjectScreenState();
}

class _AssignProjectScreenState extends State<AssignProjectScreen> {
  final _projectNameController = TextEditingController();
  final _projectDescriptionController = TextEditingController();
  final _projectDeadlineController = TextEditingController();
  DatabaseReference ref = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    _checkExistingProject();
  }

  // Function to check if a project is already assigned
  void _checkExistingProject() {
    ref.child('projects').orderByChild('studentId').equalTo(widget.studentId).once().then((event) {
      if (event.snapshot.exists) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => AdminChatScreen(classId: widget.classId, studentId: widget.studentId),
          ),
        );
      }
    }).catchError((error) {
      Utils.toastMessage(error.toString());
    });
  }

  // Function to assign a project
  void _assignProject() {
    String projectName = _projectNameController.text;
    String projectDescription = _projectDescriptionController.text;
    String projectDeadline = _projectDeadlineController.text;

    ref.child('projects').push().set({
      'studentId': widget.studentId,
      'projectName': projectName,
      'projectDescription': projectDescription,
      'projectDeadline': projectDeadline,
    }).then((_) {
      Utils.toastMessage('Project assigned successfully');
      // After assigning the project, navigate to the chat screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => AdminChatScreen(classId: widget.classId, studentId: widget.studentId),
        ),
      );
    }).catchError((error) {
      Utils.toastMessage(error.toString());
    });
  }

  // Function to show date picker
  void _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _projectDeadlineController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assign Project'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _projectNameController,
                decoration: InputDecoration(labelText: 'Project Name'),
              ),
              SizedBox(height: 20),
              // Customized TextField for Project Description
              DecoratedTextField(
                controller: _projectDescriptionController,
                labelText: 'Project Description',
                maxLines: null, // Unlimited word count
              ),
              SizedBox(height: 20),
              TextField(
                controller: _projectDeadlineController,
                decoration: InputDecoration(
                  labelText: 'Project Deadline',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () {
                      _selectDate(context);
                    },
                  ),
                ),
                readOnly: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _assignProject,
                child: Text('Assign Project'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom Widget for a Decorated TextField
class DecoratedTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final int? maxLines;

  const DecoratedTextField({
    Key? key,
    required this.controller,
    required this.labelText,
    this.maxLines,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(),
      ),
    );
  }
}
