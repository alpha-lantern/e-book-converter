# **Project Codex: Technical Clarifications & Disambiguation**

This document serves as the final resolution to architectural ambiguities identified during the design phase.

## **1\. Python Parsing Engine (The "Brain")**

* **Decision:** Standalone Script / Library.  
* **Architecture:** Task-based unit, triggered via **Supabase Edge Functions** dispatching a **GitHub Action** worker.  
* **Workflow:** Updates job\_status in the books table and writes output to codex\_manifests.  
* **Benefit:** Zero-cost idle time and computational elasticity.

## **2\. Flutter Dashboard State Management**

* **Decision:** Riverpod (2.x) with Code Generation.  
* **Guardrails:** Implementation **must** follow flutter\_riverpod\_guide.md.  
* **Key Pattern:** @riverpod annotation and AsyncNotifier for real-time DB sync.

## **3\. Rendering Architecture**

* **Decision:** **Astro (4.x+)** with React for Widgets.  
* **Architecture:** \- **Astro Islands:** Renders semantic text as static HTML. Zero JavaScript is shipped for the content itself.  
  * **Partial Hydration:** Interactive widgets (Videos, Calculators) use the client:visible directive to hydrate only when necessary.  
  * **Portability:** Strictly output: 'static' for zero-dependency standalone exports.  
* **Benefit:** Unrivaled FCP (First Contentful Paint) and SEO scores while maintaining standalone portability.

## **4\. Reference Index**

* **Architecture Overview:** project\_codex\_blueprint.md  
* **Data Model:** supabase\_schema.sql  
* **Logic Definition:** semantic\_mapping\_logic.md  
* **Frontend Specs:** renderer\_specs.md (Updated for Astro)  
* **Flutter Standards:** flutter\_riverpod\_guide.md