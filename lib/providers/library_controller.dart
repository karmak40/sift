import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/document.dart';

enum LibraryViewMode { grid, list }

// Localized labels live in `library_screen.dart` (`sortOrderLabel`) since
// they need a `BuildContext` — this file stays free of Flutter/UI imports.
enum SortOrder { date, name, size }

enum MobileTab { library, comingUp, settings }

/// UI-only state: filtering/sorting/view-mode/selection. Mirrors the
/// prototype's single `state` object, kept separate from the persisted data
/// (which lives in the repositories/stream providers).
class LibraryUiState {
  const LibraryUiState({
    this.activeCategoryId,
    this.search = '',
    this.sortOrder = SortOrder.date,
    this.viewMode = LibraryViewMode.grid,
    this.selectedIds = const {},
    this.mobileTab = MobileTab.library,
    this.aiDefaultOn = true,
  });

  /// null means "All documents".
  final String? activeCategoryId;
  final String search;
  final SortOrder sortOrder;
  final LibraryViewMode viewMode;
  final Set<int> selectedIds;
  final MobileTab mobileTab;
  final bool aiDefaultOn;

  LibraryUiState copyWith({
    String? activeCategoryId,
    bool clearActiveCategory = false,
    String? search,
    SortOrder? sortOrder,
    LibraryViewMode? viewMode,
    Set<int>? selectedIds,
    MobileTab? mobileTab,
    bool? aiDefaultOn,
  }) {
    return LibraryUiState(
      activeCategoryId: clearActiveCategory
          ? null
          : (activeCategoryId ?? this.activeCategoryId),
      search: search ?? this.search,
      sortOrder: sortOrder ?? this.sortOrder,
      viewMode: viewMode ?? this.viewMode,
      selectedIds: selectedIds ?? this.selectedIds,
      mobileTab: mobileTab ?? this.mobileTab,
      aiDefaultOn: aiDefaultOn ?? this.aiDefaultOn,
    );
  }
}

class LibraryController extends Notifier<LibraryUiState> {
  @override
  LibraryUiState build() => const LibraryUiState();

  void selectAllDocuments() =>
      state = state.copyWith(clearActiveCategory: true, mobileTab: MobileTab.library);

  void selectCategory(String id) =>
      state = state.copyWith(activeCategoryId: id, mobileTab: MobileTab.library);

  void setSearch(String value) => state = state.copyWith(search: value);

  void setSortOrder(SortOrder order) => state = state.copyWith(sortOrder: order);

  void setViewMode(LibraryViewMode mode) => state = state.copyWith(viewMode: mode);

  void setMobileTab(MobileTab tab) => state = state.copyWith(mobileTab: tab);

  void clearFilters() => state = state.copyWith(
    clearActiveCategory: true,
    search: '',
  );

  void toggleAiDefault() =>
      state = state.copyWith(aiDefaultOn: !state.aiDefaultOn);

  void toggleSelection(int docId) {
    final next = Set<int>.of(state.selectedIds);
    if (!next.remove(docId)) next.add(docId);
    state = state.copyWith(selectedIds: next);
  }

  void clearSelection() => state = state.copyWith(selectedIds: const {});

  List<Document> apply(List<Document> docs) {
    final s = state;
    final q = s.search.trim().toLowerCase();
    final filtered = docs.where((d) {
      final matchesCategory =
          s.activeCategoryId == null || d.categoryId == s.activeCategoryId;
      final matchesSearch =
          q.isEmpty ||
          d.name.toLowerCase().contains(q) ||
          (d.ai?.summary.toLowerCase().contains(q) ?? false);
      return matchesCategory && matchesSearch;
    }).toList();

    filtered.sort((a, b) {
      switch (s.sortOrder) {
        case SortOrder.name:
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        case SortOrder.size:
          return b.sizeBytes.compareTo(a.sizeBytes);
        case SortOrder.date:
          return b.addedAt.compareTo(a.addedAt);
      }
    });
    return filtered;
  }
}

final libraryControllerProvider =
    NotifierProvider<LibraryController, LibraryUiState>(LibraryController.new);
