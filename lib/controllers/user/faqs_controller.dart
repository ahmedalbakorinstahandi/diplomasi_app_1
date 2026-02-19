import 'dart:async';
import 'package:dio/dio.dart';
import 'package:diplomasi_app/core/classes/api_response.dart';
import 'package:diplomasi_app/data/resource/remote/user/faqs_data.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class FaqsController extends GetxController {
  List faqs = [];
  List filteredFaqs = [];

  bool isLoading = false;

  int page = 1;
  int perPage = 500;
  bool isLoadingMore = false;

  FaqsData faqsData = FaqsData();
  ScrollController faqsScrollController = ScrollController();

  bool isSearchMode = false;
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  CancelToken? searchCancelToken;
  Timer? _searchDebounce;

  Future<void> getFaqs({bool reload = false});
  void filterFaqs(String query);
  void toggleSearchMode();
  void onSearchChanged(String value);
  void clearSearch();
}

class FaqsControllerImp extends FaqsController {
  @override
  void onInit() {
    super.onInit();
    filteredFaqs = [];
    getFaqs(reload: true);
    faqsScrollController.addListener(() {
      if (faqsScrollController.position.pixels ==
          faqsScrollController.position.maxScrollExtent) {
        if (!isSearchMode) {
          getFaqs();
        }
      }
    });
  }

  @override
  void onClose() {
    faqsScrollController.dispose();
    searchController.dispose();
    _searchDebounce?.cancel();
    searchCancelToken?.cancel();
    super.onClose();
  }

  @override
  Future<void> getFaqs({bool reload = false}) async {
    if (isLoading) return;

    if (reload) {
      page = 1;
      // Cancel previous request if exists
      searchCancelToken?.cancel();
      searchCancelToken = CancelToken();
    }

    isLoading = true;
    isLoadingMore = !reload;
    update();

    ApiResponse response = await faqsData.get(
      page: page,
      perPage: perPage,
      cancelToken: reload ? searchCancelToken : null,
    );

    if (response.isSuccess) {
      page = Meta.handlePagination(
        list: faqs,
        newData: response.data!,
        meta: response.meta!,
        page: page,
        reload: reload,
      );

      // Apply current search filter if exists (local filtering)
      if (searchQuery.isNotEmpty) {
        filterFaqs(searchQuery);
      } else {
        filteredFaqs = List.from(faqs);
      }
    }

    isLoading = false;
    isLoadingMore = false;
    update();
  }

  @override
  void filterFaqs(String query) {
    searchQuery = query;
    if (query.isEmpty) {
      filteredFaqs = List.from(faqs);
    } else {
      final String lowerQuery = query.toLowerCase();
      filteredFaqs = faqs.where((faq) {
        final faqMap = faq as Map<String, dynamic>;
        final question = (faqMap['question'] ?? '').toString().toLowerCase();
        final answer = (faqMap['answer'] ?? '').toString().toLowerCase();
        return question.contains(lowerQuery) || answer.contains(lowerQuery);
      }).toList();
    }
    update();
  }

  @override
  void toggleSearchMode() {
    isSearchMode = !isSearchMode;
    if (!isSearchMode) {
      if (searchController.text.isNotEmpty) {
        searchController.clear();
        clearSearch();
      }
    } else {
      searchController.clear();
      searchQuery = '';
    }
    update();
  }

  @override
  void onSearchChanged(String value) {
    // Cancel previous debounce timer
    _searchDebounce?.cancel();

    // Debounce local search
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (value.trim().isEmpty) {
        // If search is empty, show all faqs
        clearSearch();
      } else {
        // Perform local filtering
        filterFaqs(value.trim());
      }
    });
  }

  @override
  void clearSearch() {
    searchQuery = '';
    filteredFaqs = List.from(faqs);
    update();
  }
}
