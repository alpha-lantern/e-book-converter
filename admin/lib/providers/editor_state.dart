import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'editor_state.g.dart';

class EditorState {
  final int currentPage;
  final String? selectedBlockId;

  const EditorState({
    this.currentPage = 1,
    this.selectedBlockId,
  });

  EditorState copyWith({
    int? currentPage,
    String? selectedBlockId,
    bool clearSelectedBlockId = false,
  }) {
    return EditorState(
      currentPage: currentPage ?? this.currentPage,
      selectedBlockId: clearSelectedBlockId ? null : (selectedBlockId ?? this.selectedBlockId),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EditorState &&
          runtimeType == other.runtimeType &&
          currentPage == other.currentPage &&
          selectedBlockId == other.selectedBlockId;

  @override
  int get hashCode => currentPage.hashCode ^ selectedBlockId.hashCode;
}

@riverpod
class EditorStateNotifier extends _$EditorStateNotifier {
  @override
  EditorState build() {
    return const EditorState();
  }

  void setCurrentPage(int page) {
    state = state.copyWith(currentPage: page);
  }

  void setSelectedBlockId(String? blockId) {
    state = state.copyWith(selectedBlockId: blockId);
  }

  void clearSelection() {
    state = state.copyWith(clearSelectedBlockId: true);
  }
}
