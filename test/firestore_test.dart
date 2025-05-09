// firestore_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import './mocks/mock_firestore.mocks.dart';

void main() {
  group('Firebase Firestore Connectivity', () {
    late MockFirebaseFirestore mockFirestore;

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
    });

    test('should call collection from FirebaseFirestore', () {
      // Arrange
      final collectionName = 'recipes';
      final mockCollection = MockCollectionReference<Map<String, dynamic>>();

      when(mockFirestore.collection(collectionName)).thenReturn(mockCollection);

      // Act
      final collection = mockFirestore.collection(collectionName);

      // Assert
      verify(mockFirestore.collection(collectionName)).called(1);
      expect(collection, isA<MockCollectionReference<Map<String, dynamic>>>());
    });
  });
}
