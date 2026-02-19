import 'package:diplomasi_app/core/classes/api_response.dart';
import 'package:diplomasi_app/data/model/public/glossary_term_model.dart';
import 'package:diplomasi_app/data/resource/remote/public/glossary_data.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class GlossaryController extends GetxController {
  bool isLoading = false;
  GlossaryData glossaryData = GlossaryData();
  List<GlossaryTermModel> glossaryTerms = [];
  List<GlossaryTermModel> filteredTerms = [];
  String searchQuery = '';
  TextEditingController searchController = TextEditingController();

  Future<void> getGlossaryTerms();
  void filterTerms(String query);
  void clearSearch();
}

class GlossaryControllerImp extends GlossaryController {
  @override
  void onInit() {
    getGlossaryTerms();
    super.onInit();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  @override
  Future<void> getGlossaryTerms() async {
    if (isLoading) return;

    isLoading = true;
    update();

    ApiResponse response = await glossaryData.getTerms(search: searchQuery);

    if (response.isSuccess && response.data != null) {
      final termsData = response.data as List;
      glossaryTerms = termsData
          .map(
            (termData) =>
                GlossaryTermModel.fromJson(termData as Map<String, dynamic>),
          )
          .toList();

      // Apply current search filter if exists
      if (searchQuery.isNotEmpty) {
        filterTerms(searchQuery);
      } else {
        filteredTerms = List.from(glossaryTerms);
      }
    }

    isLoading = false;
    update();
  }

  @override
  void filterTerms(String query) {
    searchQuery = query;
    if (query.isEmpty) {
      filteredTerms = List.from(glossaryTerms);
    } else {
      filteredTerms = glossaryTerms
          .where(
            (term) =>
                term.term.toLowerCase().contains(query.toLowerCase()) ||
                term.definition.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    }
    update();
  }

  @override
  void clearSearch() {
    searchQuery = '';
    filteredTerms = List.from(glossaryTerms);
    update();
  }
}
