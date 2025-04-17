import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quiz_app/quiz_flow.dart';
import 'package:quiz_app/SetNameScreen.dart';

class JoinQuizWidget extends StatelessWidget {
  final TextEditingController _codeController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  JoinQuizWidget({Key? key}) : super(key: key);

  Future<void> _joinQuiz(BuildContext context, String code) async {
    try {
    /*  final quizQuery =
          await _firestore
              .collection('actived_Quizzes')
              .where('invitation_code', isEqualTo: code)
              .limit(1)
              .get();*/
final quizQuery = await _firestore
    .collection('actived_Quizzes')
    .where('invitation_code', isEqualTo: code)
    .where('status', isEqualTo: 'waiting')
    .limit(1)
    .get();

      if (quizQuery.docs.isEmpty) throw Exception('Invalid quiz code');

      final activatequizId = quizQuery.docs.first.id;
      final activeId = quizQuery.docs.first.data()['id'];

      // Navigate to SetNameScreen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => SetNameScreen(
                quizCode: code,
                activatequizId: activatequizId,
                // activeId: activeId,
              ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error joining: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: "Enter quiz code",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () => _joinQuiz(context, _codeController.text.trim()),
            child: const Text("JOIN"),
          ),
        ],
      ),
    );
  }
}
