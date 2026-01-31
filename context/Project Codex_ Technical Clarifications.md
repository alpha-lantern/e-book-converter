# **Project Codex: Technical Clarifications & Disambiguation**

This document serves as the final resolution to architectural ambiguities identified during the design phase. It supplements the core blueprints and must be adhered to by all developers and AI coding agents.

## **1\. Python Parsing Engine (The "Brain")**

* **Decision:** Standalone Script / Library.  
* **Architecture:** The parser is a task-based unit, not a persistent REST API.  
* **Workflow:** \- Triggered via **Supabase Edge Functions** (monitoring PDF uploads) which dispatch a **GitHub Action** (Worker).  
  * Communicates progress via the job\_status and error\_log columns. See: supabase\_schema.sql.  
  * Updates the codex\_manifests table once parsing is complete using logic defined in: semantic\_mapping\_logic.md.  
* **Benefit:** Zero-cost idle time and high computational reliability for heavy PDF processing.

## **2\. Flutter Dashboard State Management**

* **Decision:** Riverpod (2.x) with Code Generation.  
* **Guardrails:** To prevent AI hallucinations and maintain consistency, all implementation **must** strictly follow the patterns and naming conventions in: flutter\_riverpod\_guide.md.  
* **Key Pattern:** Mandatory use of the @riverpod annotation and AsyncNotifier for real-time data sync with Supabase.  
* **Benefit:** Predictable, testable state transitions for the document management and widget tagging UI.

## **3\. Next.js Routing & Rendering**

* **Decision:** App Router (Next.js 14+).  
* **Architecture:** \- **React Server Components (RSC):** Used for pre-rendering semantic text to achieve a 100/100 SEO score.  
  * **Client Components:** Reserved strictly for interactive widgets.  
  * **PWA Integration:** Uses @ducanh2912/next-pwa for modern App Router support.  
  * Full technical specifications found in: renderer\_specs.md.  
* **Benefit:** Maximum SEO fidelity and performance by minimizing the JavaScript bundle sent to the end-reader.

## **4\. Asynchronous User Experience**

* **Logic:** Because the parser is an asynchronous script, the Flutter UI must implement a "Loading State" that listens to the books.job\_status changes via Supabase Realtime.  
* **User Feedback:** The UI should show granular progress (e.g., "Analyzing Typography," "Generating Semantic Tags") based on updates written by the Python script to the database.  
* **Implementation:** Refer to the "Real-Time Sync Strategy" section in flutter\_riverpod\_guide.md.

## **5\. Reference Index**

For detailed implementation, refer to the following auxiliary documents:

* **Architecture Overview:** project\_codex\_blueprint.md  
* **Data Model:** supabase\_schema.sql  
* **Logic Definition:** semantic\_mapping\_logic.md  
* **Frontend Specs:** renderer\_specs.md  
* **Flutter Standards:** flutter\_riverpod\_guide.md

**Confirmed by Software Architect & Product Owner.**