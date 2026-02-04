# **Project Codex: Portability & Open-Source Guardrails**

**Target:** All Developers and AI Coding Agents

**Objective:** Ensure the SaaS version can be "unplugged" into a standalone Open-Source CLI tool with zero refactoring.

## **1\. The Parser (Python Engine)**

* **The Rule:** Core parsing logic must **never** import cloud-specific SDKs (Supabase, Firebase).  
* **Implementation:** Engine takes file\_path and returns a JSON object. All cloud-handling stays in the cloud\_worker.py wrapper.

## **2\. The Renderer (Astro PWA)**

* **The Rule:** The renderer must be strictly static and data-agnostic.  
* **Implementation:** \- Use a **Data Adapter** for fetching codex.json.  
  * **SaaS Mode:** Fetches from Supabase.  
  * **Local Mode:** Fetches from dist/data/codex.json.  
* **Build Requirement:** Must always compile via npm run build and be viewable as a static site without a Node server.

## **3\. Self-Sufficient JSON**

* **The Rule:** The codex.json manifest must be the single source of truth for the reader.  
* **Implementation:** The export script must merge database-stored widgets into the JSON before zipping.

## **4\. Configuration**

* **The Rule:** Zero hardcoded URLs or API keys in the Astro code.  
* **Implementation:** Use .env files. Ensure the PWA configuration (@vite-pwa/astro) is relative-path friendly for file-system navigation.