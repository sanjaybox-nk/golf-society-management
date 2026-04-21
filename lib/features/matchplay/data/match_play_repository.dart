import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/match_play_tournament.dart';
import 'firestore_match_play_repository.dart';

abstract class MatchPlayRepository {
  Future<void> saveTournament(MatchPlayTournament tournament);
  Future<MatchPlayTournament?> getTournament(String id);
  Future<List<MatchPlayTournament>> getAllTournaments();
  Future<void> deleteTournament(String id);
  Stream<List<MatchPlayTournament>> watchMatchPlayTournaments();
}

final matchPlayRepositoryProvider = Provider<MatchPlayRepository>((ref) {
  return FirestoreMatchPlayRepository(FirebaseFirestore.instance);
});
