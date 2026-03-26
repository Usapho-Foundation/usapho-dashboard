import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/campaign_record.dart';
import '../models/financial_record.dart';
import '../models/funding_opportunity.dart';
import '../models/partnership.dart';
import '../models/program_record.dart';

class DashboardRepository {
  DashboardRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<FundingOpportunity>> watchFundingOpportunities() {
    return _firestore
        .collection('funding_opportunities')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => FundingOpportunity.fromFirestore(doc.data(), doc.id),
              )
              .toList(),
        );
  }

  Stream<List<Partnership>> watchPartnerships() {
    return _firestore
        .collection('partnerships')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Partnership.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  Stream<List<ProgramRecord>> watchPrograms() {
    return _firestore
        .collection('programs')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ProgramRecord.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  Stream<List<CampaignRecord>> watchCampaigns() {
    return _firestore
        .collection('campaigns')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CampaignRecord.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  Stream<List<FinancialRecord>> watchFinancials() {
    return _firestore
        .collection('financials')
        .orderBy('month', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => FinancialRecord.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> addFundingOpportunity(FundingOpportunity item) {
    return _firestore.collection('funding_opportunities').add(item.toMap());
  }

  Future<void> updateFundingOpportunity(FundingOpportunity item) {
    return _firestore
        .collection('funding_opportunities')
        .doc(item.id)
        .set(item.toMap());
  }

  Future<void> deleteFundingOpportunity(String id) {
    return _firestore.collection('funding_opportunities').doc(id).delete();
  }

  Future<void> addPartnership(Partnership item) {
    return _firestore.collection('partnerships').add(item.toMap());
  }

  Future<void> updatePartnership(Partnership item) {
    return _firestore.collection('partnerships').doc(item.id).set(item.toMap());
  }

  Future<void> deletePartnership(String id) {
    return _firestore.collection('partnerships').doc(id).delete();
  }

  Future<void> addProgram(ProgramRecord item) {
    return _firestore.collection('programs').add(item.toMap());
  }

  Future<void> updateProgram(ProgramRecord item) {
    return _firestore.collection('programs').doc(item.id).set(item.toMap());
  }

  Future<void> deleteProgram(String id) {
    return _firestore.collection('programs').doc(id).delete();
  }

  Future<void> addCampaign(CampaignRecord item) {
    return _firestore.collection('campaigns').add(item.toMap());
  }

  Future<void> updateCampaign(CampaignRecord item) {
    return _firestore.collection('campaigns').doc(item.id).set(item.toMap());
  }

  Future<void> deleteCampaign(String id) {
    return _firestore.collection('campaigns').doc(id).delete();
  }

  Future<void> addFinancial(FinancialRecord item) {
    return _firestore.collection('financials').add(item.toMap());
  }

  Future<void> updateFinancial(FinancialRecord item) {
    return _firestore.collection('financials').doc(item.id).set(item.toMap());
  }

  Future<void> deleteFinancial(String id) {
    return _firestore.collection('financials').doc(id).delete();
  }
}
