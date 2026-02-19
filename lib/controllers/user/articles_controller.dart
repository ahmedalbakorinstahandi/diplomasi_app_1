import 'dart:async';
import 'package:dio/dio.dart';
import 'package:diplomasi_app/core/classes/api_response.dart';
import 'package:diplomasi_app/data/resource/remote/user/articles_data.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class ArticlesController extends GetxController {
  List articles = [];

  bool isLoading = false;
  int page = 1;
  int perPage = 20;
  bool isLoadingMore = false;

  ArticlesData articlesData = ArticlesData();
  ScrollController articlesScrollController = ScrollController();

  bool isSearchMode = false;
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  CancelToken? searchCancelToken;
  Timer? _searchDebounce;

  Future<void> getArticles({bool reload = false, String? search});
  void toggleSearchMode();
  void onSearchChanged(String value);
  void clearSearch();
}

class ArticlesControllerImp extends ArticlesController {
  @override
  void onInit() {
    super.onInit();
    getArticles(reload: true);
    articlesScrollController.addListener(() {
      if (articlesScrollController.position.pixels ==
          articlesScrollController.position.maxScrollExtent) {
        if (!isSearchMode) {
          getArticles();
        }
      }
    });
  }

  @override
  void onClose() {
    articlesScrollController.dispose();
    searchController.dispose();
    _searchDebounce?.cancel();
    searchCancelToken?.cancel();
    super.onClose();
  }

  @override
  Future<void> getArticles({bool reload = false, String? search}) async {
    if (isLoading) return;

    if (reload) {
      page = 1;
      // Cancel previous search request if exists
      searchCancelToken?.cancel();
      searchCancelToken = CancelToken();
    }

    isLoading = true;
    isLoadingMore = !reload;
    update();

    ApiResponse response = await articlesData.get(
      page: page,
      perPage: perPage,
      search: search,
      cancelToken: reload ? searchCancelToken : null,
    );

    if (response.isSuccess) {
      page = Meta.handlePagination(
        list: articles,
        newData: response.data!,
        meta: response.meta!,
        page: page,
        reload: reload,
      );
    }

    isLoading = false;
    isLoadingMore = false;
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
    searchQuery = value;
    update();

    // Cancel previous debounce timer
    _searchDebounce?.cancel();

    // Cancel previous search request
    searchCancelToken?.cancel();
    searchCancelToken = CancelToken();

    // Debounce search
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      if (value.trim().isEmpty) {
        // If search is empty, reload all articles
        clearSearch();
      } else {
        // Perform search
        getArticles(reload: true, search: value.trim());
      }
    });
  }

  @override
  void clearSearch() {
    searchQuery = '';
    searchCancelToken?.cancel();
    searchCancelToken = CancelToken();
    getArticles(reload: true);
  }
}
