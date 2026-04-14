import 'package:diplomasi_app/core/classes/api_response.dart';
import 'package:diplomasi_app/data/resource/remote/public/glossary_data.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class GlossaryController extends GetxController {
  bool isLoading = false;
  GlossaryData glossaryData = GlossaryData();
  List glossaryTerms = [];
  List filteredTerms = [];
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

    if (response.isSuccess) {
      glossaryTerms = response.data;

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
                term['term'].toLowerCase().contains(query.toLowerCase()) ||
                term['definition'].toLowerCase().contains(query.toLowerCase()),
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
