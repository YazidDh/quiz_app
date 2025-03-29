import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

//enum quizState { waiting, count_down, started, leader_board, finished }

class QuizService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

Future<bool> joinQuiz( String code) async {

      final quizQuery = await _db
          .collection('actived_Quizzes')
          .where('invitation_code', isEqualTo: code)
          .limit(1)
          .get();

      if (quizQuery.docs.isEmpty) 
          { return false;}

    return true;
  
  }

  Future<String?> activateQuiz(
  String invitationCode,
  String quizId,
  String userId,
) async {
  try {
    final activeQuizRef = _db.collection('actived_Quizzes').doc();
    final activeQuizId = activeQuizRef.id;

    // Create quiz data with empty participants subcollection
    final activeQuizData = {
      'id': activeQuizId,
      'quizzId': quizId,
      'num_actual_question': 0,
      'createdBy': userId,
      'status': 'waiting',
      'invitation_code': invitationCode,
    };

    // Create the main document
    await activeQuizRef.set(activeQuizData);
    

    return activeQuizId;
  } catch (e) {
    return null;
  }
}
  // Save a new quiz to Firestore
  Future<bool> saveNewQuiz(Map<String, dynamic> quiz) async {
    try {
      // Create a new document reference with auto-generated ID
      final newQuizRef = _db.collection('quizzes').doc();
      final newQuizId = newQuizRef.id;

      // Create  quiz data
      final Quizdata = {
        'id': newQuizId,
        'quizName': quiz['quizName'],
        'totalMarks': 0,
        'createdBy': quiz['user'],
        'questions': quiz['questions'],
      };

      // Set the document data
      await newQuizRef.set(Quizdata);

      Fluttertoast.showToast(
        msg: "Quiz saved successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return true;
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to save quiz",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return false;
    }
  }

  Future<bool> updateQuiz(Map<String, dynamic> quiz, String quizId) async {
    try {
      final quizRef = _db.collection('quizzes').doc(quizId);

      final updatedQuizData = {
        'quizName': quiz['quizName'],
        'createdBy': quiz['user'],
        'questions': quiz['questions'],
      };

      await quizRef.update(updatedQuizData);

      Fluttertoast.showToast(
        msg: "Quiz updated successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return true;
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to update quiz: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return false;
    }
  }

  Future<Map<String, dynamic>> fetchQuizById(String quizId) async {
    try {
      final docSnapshot = await _db.collection('quizzes').doc(quizId).get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        return {
          'id': docSnapshot.id,
          'quizName': data['quizName'],
          'totalMarks': data['totalMarks'],
          'createdBy': data['createdBy'],
          'questions': List<Map<String, dynamic>>.from(data['questions']),
          // Include any other fields you need
        };
      } else {
        throw Exception('Quiz not found');
      }
    } catch (e) {
      print('Error fetching quiz: $e');
      throw e; // Re-throw to let the caller handle it
    }
  }

  Future<List<Map<String, dynamic>>> fetchUserQuizzes(String userId) async {
    try {
      final snapshot =
          await _db
              .collection('quizzes')
              .where('createdBy', isEqualTo: userId)
              .get();

      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc['quizName'] as String,
          'createdBy': doc['createdBy'] as String,

        };
      }).toList();
    } catch (e) {
      print('Error fetching user quizzes: $e');
      throw e;
    }
  }

  Future<void> deleteQuiz(String quizId) async {
    try {
      await _db.collection('quizzes').doc(quizId).delete();
      print('Quiz deleted successfully');
    } catch (e) {
      print('Error deleting quiz: $e');
      throw e;
    }
  }


}
