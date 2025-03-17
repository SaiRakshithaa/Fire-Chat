import 'package:cloud_firestore/cloud_firestore.dart';

class DefaultConnector {
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;

  DefaultConnector._privateConstructor();

  static final DefaultConnector instance = DefaultConnector._privateConstructor();

  Future<void> fetchData() async {
    try {
      var snapshot = await firestore.collection('your_collection').get();
      for (var doc in snapshot.docs) {
        print(doc.data());
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }
}
