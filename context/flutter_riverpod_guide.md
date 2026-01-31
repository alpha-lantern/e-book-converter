# **Flutter Implementation Guide: Riverpod Pattern Guardrails**

**Target:** Flutter Admin Dashboard (Project Codex)

**Requirement:** Strict adherence to modern Riverpod 2.x syntax using Code Generation.

## **1\. Core Principle: No Manual Providers**

To prevent syntax hallucinations and ensure compile-time safety, **all providers must use the @riverpod annotation**.

* **FORBIDDEN:** final myProvider \= Provider(...) or StateNotifierProvider.  
* **MANDATORY:** Using the riverpod\_generator package.

## **2\. Dependency Injection & Setup**

Every file utilizing Riverpod must include the following header to allow for code generation:

import 'package:riverpod\_annotation/riverpod\_annotation.dart';

part 'filename.g.dart'; // Must match the filename

## **3\. Asynchronous Data Pattern (Supabase Integration)**

For fetching the job\_status or book lists from Supabase, the agent **must** use the functional AsyncNotifier pattern.

### **3.1 Fetching Book Status (Example)**

@riverpod  
class BookStatus extends \_$BookStatus {  
  @override  
  FutureOr\<String\> build(String bookId) async {  
    // Logic to fetch initial status from Supabase  
    return await ref.watch(supabaseRepositoryProvider).getBookStatus(bookId);  
  }

  // Method to update status manually or via real-time listener  
  void updateStatus(String newStatus) {  
    state \= AsyncData(newStatus);  
  }  
}

## **4\. State Consumption in UI**

Agents must use ConsumerWidget or ConsumerStatefulWidget. When handling asynchronous data, the switch or when pattern is mandatory for UI safety.

class BookStatusView extends ConsumerWidget {  
  @override  
  Widget build(BuildContext context, WidgetRef ref) {  
    final statusAsync \= ref.watch(bookStatusProvider('book-123'));

    return statusAsync.when(  
      data: (status) \=\> Text('Status: $status'),  
      loading: () \=\> CircularProgressIndicator(),  
      error: (err, stack) \=\> Text('Error: $err'),  
    );  
  }  
}

## **5\. Naming Conventions (Mandatory)**

To avoid hallucinated logic paths, the agent must follow this nomenclature strictly:

1. **Repository Providers:** \[Service\]Repository (e.g., SupabaseRepository). The provider is accessed via supabaseRepositoryProvider.  
2. **Notifier Classes:** \[Feature\]Notifier (e.g., BookListNotifier).  
3. **Provider Access:** The generated provider name must always be \[notifierName\]Provider in camelCase.  
4. **State Classes:** If using custom state objects, use \[Feature\]State.  
5. **Methods:** \* build(): For initial data fetching.  
   * toggle\[Property\](): For booleans.  
   * update\[Property\](): For data mutations.

## **6\. Safeguard Rules for AI Agents**

1. **No Legacy State:** Never use StateProvider or ChangeNotifierProvider. If state is complex, use a @riverpod class.  
2. **Immutable State:** All state classes must be immutable (prefer using Freezed for state objects).  
3. **Ref Access:** Always use ref.watch for reactive dependencies and ref.read inside callbacks (buttons/functions).  
4. **Global Access:** Never use container.read inside the UI; only use the WidgetRef provided by the build method.

## **7\. Real-Time Sync Strategy**

Since the Python Parser updates the DB asynchronously, the Flutter agent should implement a Supabase stream:

* The provider should initialize a SupabaseRealtimePayload listener in the build() method.  
* It should use ref.onDispose() to close the stream when the widget is destroyed.