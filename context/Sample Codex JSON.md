{  
"book\_id": "codex-sample-2024-001",  
"version": "1.0",  
"metadata": {  
"title": "The Future of Digital Publishing",  
"author": "Codex Editorial Team",  
"description": "A technical whitepaper on the shift from PDF to Web-Native PWAs.",  
"base_size": 16,
"language": "en-US",  
"seo": {  
"title": "The Future of Digital Publishing | Project Codex",
"description": "Learn how to convert PDFs to SEO-optimized PWAs with Project Codex.",
"keywords": ["PWA", "SEO", "Digital Publishing", "Interactive PDF"],  
"canonical_url": "https://project-codex.io/view/future-of-publishing",  
"og_image": "https://supabase-assets.com/codex-sample/og-cover.webp"  
},  
"theme": {  
"primary_color": "#2563eb",  
"font_base_size": 16,  
"typography_system": "sans-serif"  
}  
},  
"structure": \[  
{  
"id": "block-001",  
"type": "text",  
"semantic\_tag": "h1",  
"content": "The Digital Evolution: Beyond the PDF",  
"styles": {  
"weight": "800",  
"color": "\#111827",  
"alignment": "left"  
}  
},  
{  
"id": "block-002",  
"type": "text",  
"semantic\_tag": "p",  
"content": "For decades, the Portable Document Format has been the gold standard for sharing documents. However, in an era dominated by mobile devices and search engines, the static nature of the PDF has become a liability.",  
"styles": {  
"weight": "400",  
"color": "\#374151"  
}  
},  
{  
"id": "block-003",  
"type": "image",  
"src": "https://www.google.com/search?q=https://supabase-assets.com/codex-sample/infographic-mobile-usage.webp",  
"alt": "Infographic showing the rise of mobile content consumption over desktop.",  
"caption": "Figure 1: Mobile content trends 2020-2024",  
"dimensions": { "width": 1200, "height": 800 }  
},  
{  
"id": "block-004",  
"type": "text",  
"semantic\_tag": "h2",  
"content": "Why SEO Matters for Documents",  
"styles": {  
"weight": "700",  
"color": "\#111827"  
}  
},  
{  
"id": "block-005",  
"type": "placeholder",  
"anchor\_label": "Case Study Video",  
"widget": {  
"type": "youtube\_embed",  
"config": {  
"video\_id": "dQw4w9WgXcQ",  
"aspect\_ratio": "16:9",  
"autoplay": false  
}  
}  
},  
{  
"id": "block-006",  
"type": "text",  
"semantic\_tag": "blockquote",  
"content": "The transition from static files to web-native apps is not just a trend; it is a fundamental shift in how information is indexed and consumed.",  
"styles": {  
"italic": true,  
"border\_color": "\#2563eb"  
}  
},  
{  
"id": "block-007",  
"type": "placeholder",  
"anchor\_label": "ROI Calculator",  
"widget": {  
"type": "custom\_component",  
"config": {  
"component\_id": "roi-calc-001",  
"props": {  
"currency": "USD",  
"default\_views": 5000  
}  
}  
}  
}  
\],  
"navigation": \[  
{ "title": "Introduction", "target\_id": "block-001" },  
{ "title": "SEO Strategies", "target\_id": "block-004" },  
{ "title": "Interactive ROI", "target\_id": "block-007" }  
\],  
"pwa\_assets": {  
"manifest\_url": "/manifest.json",  
"service\_worker\_url": "/sw.js",  
"offline\_ready": true  
}  
}