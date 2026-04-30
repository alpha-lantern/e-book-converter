import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:admin/providers/editor_state.dart';

void main() {
  test('EditorStateNotifier should have initial state', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final state = container.read(editorStateNotifierProvider);

    expect(state.currentPage, 1);
    expect(state.selectedBlockId, isNull);
  });

  test('setCurrentPage should update currentPage', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(editorStateNotifierProvider.notifier).setCurrentPage(5);
    final state = container.read(editorStateNotifierProvider);

    expect(state.currentPage, 5);
  });

  test('setSelectedBlockId should update selectedBlockId', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(editorStateNotifierProvider.notifier).setSelectedBlockId('block-123');
    final state = container.read(editorStateNotifierProvider);

    expect(state.selectedBlockId, 'block-123');
  });

  test('clearSelection should nullify selectedBlockId', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(editorStateNotifierProvider.notifier).setSelectedBlockId('block-123');
    expect(container.read(editorStateNotifierProvider).selectedBlockId, 'block-123');

    container.read(editorStateNotifierProvider.notifier).clearSelection();
    expect(container.read(editorStateNotifierProvider).selectedBlockId, isNull);
  });
}
