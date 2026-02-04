# **MVP DevOps and Operations Plan: Project Codex**

## **1\. CI/CD & Automation Pipeline**

We will use **GitHub Actions** not only for deployment but as our primary "Compute Engine" for PDF parsing to maintain a $0 operational cost.

### **Stage 1: Continuous Integration (The "Quality Gate")**

* **Trigger:** Any push to main or Pull Request.  
* **Code Integration:** \* **Flutter Admin:** flutter analyze and flutter test.  
  * **Python Parser:** pytest (focused on semantic mapping) and black.  
  * **Astro Renderer:** npm run lint and astro check.  
* **Automated Testing:** \* **Snapshot Testing:** Compare generated Codex JSON against "Gold Standard" mocks.  
  * **Hydration Audit:** Verify that interactive React components remain dormant until client:visible triggers.  
  * **SEO Audit:** Headless Lighthouse CI check (target FCP/SEO score \>95).

### **Stage 2: The "Event-Driven" Parsing Pipeline (V.2)**

To avoid serverless execution timeouts and costs, we use an asynchronous worker pattern:

1. **Trigger:** User uploads PDF to Supabase Storage.  
2. **Webhook:** A Supabase Edge Function detects the upload and sends a repository\_dispatch to GitHub.  
3. **Compute:** A GitHub Action runner starts, downloads the PDF, runs the **Python Standalone Script**, and generates the Codex JSON.  
4. **Callback:** The script updates the books table status in Supabase and uploads the JSON to the codex\_manifests table.

### **Stage 3: Continuous Deployment (Astro Optimized)**

* **Admin Panel (Flutter):** Deployed to **Vercel**.  
* **Reader (Astro):** Deployed to **Vercel** as a Static Site.  
* **PWA Export (The ZIP Pipeline):** 1\. A dedicated Action runs npm run build for the Astro project.  
  2\. The build output is collected from the dist/ directory.  
  3\. The specific book.json is injected into dist/data/book.json.  
  4\. @vite-pwa/astro generates the final service worker within dist/.  
  5\. The dist/ folder is zipped and uploaded to Supabase Storage for user download.

## **2\. Infrastructure as Code (IaC) & Cloud Strategy**

| Component | Provider | Cost (MVP) | Implementation |
| :---- | :---- | :---- | :---- |
| **Web Hosting** | Vercel | $0 (Hobby) | Managed Astro/Flutter Web hosting. |
| **Database/Auth** | Supabase | $0 (Free Tier) | Schema managed via Supabase CLI migrations. |
| **Parsing Compute** | GitHub Actions | $0 | 2,000 free minutes/month for PDF processing. |
| **Orchestration** | Supabase Edge | $0 | Small Deno functions to trigger GitHub Actions. |
| **Object Storage** | Supabase Storage | $0 | Stores source PDFs and exported PWA ZIPs. |

**Security Note:** All Supabase Service Roles and OpenAI API keys are stored in **GitHub Secrets** and passed to the Python environment during the parsing run.

## **3\. Monitoring & Production Health**

* **Availability:** **UptimeRobot** (Free) monitors the Vercel production URL.  
* **Error Tracking:** **Sentry** (Free) integrated into Flutter and Astro (client-side islands).  
* **Performance:** Monitor **CLS (Cumulative Layout Shift)** specifically for Astro Islands to ensure React widgets don't "jump" during hydration.  
* **Conversion Analytics:** Custom Supabase view tracking status from books table to monitor "Success vs. Failure" rates of the parsing engine.

## **4\. Security & Scalability**

### **Security**

* **Scoped Access:** GitHub Actions use a restricted Supabase Service Key that only has permissions for the codex\_manifests and books tables.  
* **RLS Policies:** Row Level Security ensures users can only edit or export books they own.

### **Scalability**

* **Worker Scaling:** GitHub Actions can run multiple parsing jobs in parallel (up to 20 concurrent jobs on the free tier).  
* **Static Superiority:** Since Astro generates pure HTML for the majority of the book, the "Reader" can handle massive traffic spikes with near-zero latency and minimal server load.

## **5\. Developer Experience (DX)**

* **Local Development:** Use supabase start for the backend and npm run dev for the Astro frontend.  
* **State Management:** **Nano Stores** used for lightweight, cross-framework state (e.g., syncing reading progress between Astro and React).  
* **Deployment:** git push origin main triggers the full suite of tests and atomic deployments.