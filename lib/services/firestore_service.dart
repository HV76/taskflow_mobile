import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/task_model.dart';

class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance {
    _firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  final FirebaseFirestore _firestore;

  static const String collectionPath = 'work_orders';

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(collectionPath);

  Future<String> createTask(TaskModel task) async {
    final DocumentReference<Map<String, dynamic>> docRef =
        await _collection.add(task.toMap());
    return docRef.id;
  }

  Stream<List<TaskModel>> streamTasks({TaskStatus? statusFilter}) {
    Query<Map<String, dynamic>> query =
        _collection.orderBy('createdAt', descending: true);

    if (statusFilter != null) {
      query = query.where('status', isEqualTo: statusFilter.label);
    }

    return query.snapshots().map(
      (QuerySnapshot<Map<String, dynamic>> snapshot) {
        return snapshot.docs
            .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                TaskModel.fromFirestore(doc))
            .toList();
      },
    );
  }

  Future<TaskModel?> getTaskById(String id) async {
    final DocumentSnapshot<Map<String, dynamic>> doc =
        await _collection.doc(id).get();
    if (!doc.exists) {
      return null;
    }
    return TaskModel.fromFirestore(doc);
  }

  Future<void> updateTaskStatus(String id, TaskStatus newStatus) async {
    await _collection.doc(id).update(<String, dynamic>{
      'status': newStatus.label,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> updateTask(TaskModel task) async {
    final Map<String, dynamic> data = task.toMap();
    data['updatedAt'] = Timestamp.fromDate(DateTime.now());
    await _collection.doc(task.id).update(data);
  }

  Future<void> deleteTask(String id) async {
    await _collection.doc(id).delete();
  }
}
