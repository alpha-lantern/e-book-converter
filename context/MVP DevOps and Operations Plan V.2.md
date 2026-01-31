# **MVP DevOps and Operations Plan: Project Codex**

## **1\. CI/CD & Automation Pipeline**

We will use **GitHub Actions** not only for deployment but as our primary "Compute Engine" for PDF parsing to maintain a $0 operational cost.

### **Stage 1: Continuous Integration (The "Quality Gate")**

* **Trigger:** Any push to main or Pull Request.  
* **Code Integration:** \* **Flutter Admin:** flutter analyze and flutter test.  
  * **Python Parser:** pytest (focused on semantic mapping) and black.  
  * **Next.js Renderer:** npm run lint and type-check.  
* **Automated Testing:** \* **Snapshot Testing:** Compare generated Codex JSON against "Gold Standard" mocks.  
  * **SEO Audit:** Headless Lighthouse CI check (target score \>90).

### **Stage 2: The "Event-Driven" Parsing Pipeline (New in V.2)**

To avoid serverless execution timeouts and costs, we use an asynchronous worker pattern:

1. **Trigger:** User uploads PDF to Supabase Storage.  
2. **Webhook:** A Supabase Edge Function detects the upload and sends a repository\_dispatch to GitHub.  
3. **Compute:** A GitHub Action runner starts, downloads the PDF, runs the **Python Standalone Script**, and generates the Codex JSON.  
4. **Callback:** The script updates the books table status in Supabase and uploads the JSON to the codex\_manifests table.

### **Stage 3: Continuous Deployment**

* **Admin Panel (Flutter):** Deployed to **Vercel**.  
* **Reader (Next.js):** Deployed to **Vercel** with On-Demand Incremental Static Regeneration (ISR).  
* **PWA Export:** A dedicated Action pulls the Renderer build, injects the user's book.json, and zips the asset for download.

## **2\. Infrastructure as Code (IaC) & Cloud Strategy**

| Component | Provider | Cost (MVP) | Implementation |
| :---- | :---- | :---- | :---- |
| **Web Hosting** | Vercel | $0 (Hobby) | Managed Next.js/Flutter Web hosting. |
| **Database/Auth** | Supabase | $0 (Free Tier) | Schema managed via Supabase CLI migrations. |
| **Parsing Compute** | GitHub Actions | $0 | 2,000 free minutes/month for PDF processing. |
| **Orchestration** | Supabase Edge | $0 | Small Deno functions to trigger GitHub Actions. |
| **Object Storage** | Supabase Storage | $0 | Stores source PDFs and exported PWA ZIPs. |

**Security Note:** All Supabase Service Roles and OpenAI API keys are stored in **GitHub Secrets** and passed to the Python environment during the parsing run.

## **3\. Monitoring & Production Health**

* **Availability:** **UptimeRobot** (Free) monitors the Vercel production URL.  
* **Error Tracking:** **Sentry** (Free) integrated into Flutter and Next.js.  
* **Pipeline Health:** GitHub Action "Failure Alerts" sent to the dev team if a PDF conversion fails.  
* **Conversion Analytics:** Custom Supabase view tracking status from books table to monitor "Success vs. Failure" rates of the parsing engine.

## **4\. Security & Scalability**

### **Security**

* **Scoped Access:** GitHub Actions use a restricted Supabase Service Key that only has permissions for the codex\_manifests and books tables.  
* **RLS Policies:** Row Level Security ensures users can only edit or export books they own.

### **Scalability**

* **Worker Scaling:** GitHub Actions can run multiple parsing jobs in parallel (up to 20 concurrent jobs on the free tier), handling initial user surges with ease.  
* **Edge Delivery:** Next.js assets are served via Vercel’s Global Edge Network, ensuring fast load times regardless of user location.

## **5\. Developer Experience (DX)**

* **Local Development:** Use supabase start to run a local backend and npm run dev for the frontend.  
* **Deployment:** git push origin main triggers the full suite of tests and atomic deployments.