import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const GITHUB_PAT = Deno.env.get("GITHUB_PAT");
const GITHUB_OWNER = Deno.env.get("GITHUB_OWNER");
const GITHUB_REPO = Deno.env.get("GITHUB_REPO");

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
      },
    });
  }

  try {
    const payload = await req.json();

    // Support both direct client invocation ({ book_id, storage_path })
    // and Database Webhook payloads ({ record: { id, original_pdf_url } })
    let bookId = payload.book_id;
    let storagePath = payload.storage_path;

    if (!bookId && payload.record) {
      bookId = payload.record.id;
      const pdfUrl = payload.record.original_pdf_url || "";
      if (pdfUrl.includes("raw_pdfs/")) {
        storagePath = pdfUrl.split("raw_pdfs/")[1].split("?")[0];
      }
    }

    if (!bookId) {
      return new Response(JSON.stringify({ error: "Missing book_id" }), {
        status: 400,
        headers: { "Content-Type": "application/json" },
      });
    }

    if (!GITHUB_PAT || !GITHUB_OWNER || !GITHUB_REPO) {
      console.error("Missing GitHub configuration environment variables (GITHUB_PAT, GITHUB_OWNER, GITHUB_REPO).");
      return new Response(
        JSON.stringify({ error: "Server misconfiguration: GitHub credentials missing" }),
        {
          status: 500,
          headers: { "Content-Type": "application/json" },
        }
      );
    }

    // Dispatch GitHub Action workflow via repository_dispatch
    const dispatchUrl = `https://api.github.com/repos/${GITHUB_OWNER}/${GITHUB_REPO}/dispatches`;
    const ghResponse = await fetch(dispatchUrl, {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${GITHUB_PAT}`,
        "Accept": "application/vnd.github+json",
        "X-GitHub-Api-Version": "2022-11-28",
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        event_type: "parse-pdf",
        client_payload: {
          book_id: bookId,
          storage_path: storagePath || "",
        },
      }),
    });

    if (!ghResponse.ok) {
      const errorText = await ghResponse.text();
      console.error(`GitHub API error: ${ghResponse.status} - ${errorText}`);
      return new Response(
        JSON.stringify({ error: "Failed to dispatch GitHub Action", details: errorText }),
        {
          status: 502,
          headers: { "Content-Type": "application/json" },
        }
      );
    }

    return new Response(
      JSON.stringify({ success: true, message: "Parser workflow dispatched successfully" }),
      {
        status: 200,
        headers: {
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*",
        },
      }
    );
  } catch (error) {
    return new Response(JSON.stringify({ error: (error as Error).message }), {
      status: 500,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
      },
    });
  }
});
