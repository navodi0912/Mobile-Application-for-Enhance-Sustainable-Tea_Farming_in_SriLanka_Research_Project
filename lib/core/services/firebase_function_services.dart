import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> storeFertilizerPrediction({
    required String diseaseClass,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userRef = _firestore.collection('users').doc(user.uid);

      try {
        final userDoc = await userRef.get();
        final List<dynamic> existingPredictions =
            userDoc.data()?['fertilizerPrediction'] ?? [];

        final nextId = existingPredictions.isEmpty
            ? 1
            : (existingPredictions.last['id'] as int) + 1;

        final now = DateTime.now();

        final formattedDate =
            "${now.year}/${_twoDigits(now.month)}/${_twoDigits(now.day)}";

        final formattedTime =
            "${_twoDigits(now.hour)}:${_twoDigits(now.minute)}:${_twoDigits(now.second)}";

        final prediction = {
          'id': nextId,
          'date': formattedDate,
          'time': formattedTime,
          'diseaseClass': diseaseClass,
        };

        await userRef.update({
          'fertilizerPrediction': FieldValue.arrayUnion([prediction]),
        });

        print("Success: Fertilizer prediction stored with ID $nextId");
      } catch (e) {
        print("Error storing fertilizer prediction: $e");
      }
    } else {
      print("Error: User is not logged in.");
    }
  }

  Future<void> storeDiseasePrediction({
    required String diseaseClass,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userRef = _firestore.collection('users').doc(user.uid);

      try {
        final userDoc = await userRef.get();
        final List<dynamic> existingPredictions =
            userDoc.data()?['diseasePrediction'] ?? [];

        final nextId = existingPredictions.isEmpty
            ? 1
            : (existingPredictions.last['id'] as int) + 1;

        final now = DateTime.now();

        final formattedDate =
            "${now.year}/${_twoDigits(now.month)}/${_twoDigits(now.day)}";

        final formattedTime =
            "${_twoDigits(now.hour)}:${_twoDigits(now.minute)}:${_twoDigits(now.second)}";

        final prediction = {
          'id': nextId,
          'date': formattedDate,
          'time': formattedTime,
          'diseaseClass': diseaseClass,
        };

        await userRef.update({
          'diseasePrediction': FieldValue.arrayUnion([prediction]),
        });

        print("Success: Disease Prediction stored with ID $nextId");
      } catch (e) {
        print("Error storing Disease prediction: $e");
      }
    } else {
      print("Error: User is not logged in.");
    }
  }

  Future<void> storeGrowthQuality({
    required String growthClass,
    required String percentageClass,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userRef = _firestore.collection('users').doc(user.uid);

      try {
        final userDoc = await userRef.get();
        final List<dynamic> existingPredictions =
            userDoc.data()?['growthQuality'] ?? [];

        final nextId = existingPredictions.isEmpty
            ? 1
            : (existingPredictions.last['id'] as int) + 1;

        final now = DateTime.now();

        final formattedDate =
            "${now.year}/${_twoDigits(now.month)}/${_twoDigits(now.day)}";

        final formattedTime =
            "${_twoDigits(now.hour)}:${_twoDigits(now.minute)}:${_twoDigits(now.second)}";

        final prediction = {
          'id': nextId,
          'date': formattedDate,
          'time': formattedTime,
          'growthClass': growthClass,
          'percentageClass': percentageClass,
        };

        await userRef.update({
          'growthQuality': FieldValue.arrayUnion([prediction]),
        });

        print("Success: Growth Quality stored with ID $nextId");
      } catch (e) {
        print("Error storing  Growth Quality : $e");
      }
    } else {
      print("Error: User is not logged in.");
    }
  }

  Future<void> storeHarvestPrediction({
    required int highQuality,
    required int mediumQuality,
    required int lowQuality,
    required double tenDays,
    required double oneMonth,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userRef = _firestore.collection('users').doc(user.uid);

      try {
        final userDoc = await userRef.get();
        final List<dynamic> existingPredictions =
            userDoc.data()?['harvestPrediction'] ?? [];

        final nextId = existingPredictions.isEmpty
            ? 1
            : (existingPredictions.last['id'] as int) + 1;

        final now = DateTime.now();

        final formattedDate =
            "${now.year}/${_twoDigits(now.month)}/${_twoDigits(now.day)}";

        final formattedTime =
            "${_twoDigits(now.hour)}:${_twoDigits(now.minute)}:${_twoDigits(now.second)}";

        final prediction = {
          'id': nextId,
          'date': formattedDate,
          'time': formattedTime,
          'highQuality': highQuality,
          'mediumQuality': mediumQuality,
          'lowQuality': lowQuality,
          'tenDays': tenDays,
          'oneMonth': oneMonth,
        };

        await userRef.update({
          'harvestPrediction': FieldValue.arrayUnion([prediction]),
        });

        print("Success: Harvest Prediction stored with ID $nextId");
      } catch (e) {
        print("Error storing  Harvest Prediction : $e");
      }
    } else {
      print("Error: User is not logged in.");
    }
  }

  Future<List<Map<String, dynamic>>> getFertilizerPredictions() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          List<dynamic> predictions = userDoc['fertilizerPrediction'];
          return predictions
              .map((prediction) => prediction as Map<String, dynamic>)
              .toList();
        }
        return [];
      } catch (e) {
        print("Error fetching predictions: $e");
        return [];
      }
    } else {
      print("Error: User is not logged in.");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getGrowthPredictions() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          List<dynamic> predictions = userDoc['growthQuality'];
          return predictions.map((prediction) {
            // Parse percentageClass as double
            prediction['percentageClass'] =
                double.tryParse(prediction['percentageClass'].toString()) ??
                    0.0;
            return prediction as Map<String, dynamic>;
          }).toList();
        }
        return [];
      } catch (e) {
        print("Error fetching predictions: $e");
        return [];
      }
    } else {
      print("Error: User is not logged in.");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getHarvestPredictions() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          List<dynamic> predictions = userDoc['harvestPrediction'];

          return predictions.map((prediction) {
            return {
              'id': prediction['id'] as int,
              'date': prediction['date'] as String,
              'time': prediction['time'] as String,
              'highQuality': prediction['highQuality'] as int,
              'mediumQuality': prediction['mediumQuality'] as int,
              'lowQuality': prediction['lowQuality'] as int,
              'tenDays': (prediction['tenDays'] as num).toDouble(),
              'oneMonth': (prediction['oneMonth'] as num).toDouble(),
            };
          }).toList();
        }

        return [];
      } catch (e) {
        print("Error fetching harvest predictions: $e");
        return [];
      }
    } else {
      print("Error: User is not logged in.");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getDiseasePredictions() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          List<dynamic> predictions = userDoc['diseasePrediction'];
          return predictions
              .map((prediction) => prediction as Map<String, dynamic>)
              .toList();
        }
        return [];
      } catch (e) {
        print("Error fetching predictions: $e");
        return [];
      }
    } else {
      print("Error: User is not logged in.");
      return [];
    }
  }

  String _twoDigits(int n) {
    return n.toString().padLeft(2, '0');
  }
}
