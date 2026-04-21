import os
import time
import http.server
import socketserver
import threading
from playwright.sync_api import sync_playwright, expect

PORT = 4321
DIRECTORY = os.path.abspath(os.path.join(os.path.dirname(__file__), "dist"))

class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIRECTORY, **kwargs)

def run_server():
    socketserver.TCPServer.allow_reuse_address = True
    with socketserver.TCPServer(("", PORT), Handler) as httpd:
        print(f"Serving at port {PORT} from {DIRECTORY}")
        httpd.serve_forever()

def verify():
    # Start server in a thread
    server_thread = threading.Thread(target=run_server, daemon=True)
    server_thread.start()
    time.sleep(2)  # Give server time to start

    with sync_playwright() as p:
        browser = p.chromium.launch()
        context = browser.new_context()
        page = context.new_page()

        try:
            page.goto(f"http://localhost:{PORT}")
            print("Page loaded")

            # Take screenshot of the main page
            page.screenshot(path="/home/jules/verification/main_page.png")
            print("Main page screenshot taken")

            # Check for manifest link
            manifest = page.query_selector('link[rel="manifest"]')
            if manifest:
                print(f"Manifest link found: {manifest.get_attribute('href')}")
            else:
                print("Manifest link NOT found")

            # Wait for service worker registration
            time.sleep(5)

            sw_registered = page.evaluate("""
                async () => {
                    const registrations = await navigator.serviceWorker.getRegistrations();
                    return registrations.length > 0;
                }
            """)

            if sw_registered:
                print("Service worker registered")
            else:
                print("Service worker NOT registered")

            # Navigate to typography test page
            page.goto(f"http://localhost:{PORT}/test-typography/")
            print("Typography page loaded")
            page.screenshot(path="/home/jules/verification/typography_page.png")
            print("Typography page screenshot taken")

            # Check for manifest link on typography page too
            manifest_typo = page.query_selector('link[rel="manifest"]')
            if manifest_typo:
                print(f"Manifest link found on typography page: {manifest_typo.get_attribute('href')}")
            else:
                print("Manifest link NOT found on typography page")

        except Exception as e:
            print(f"Error during verification: {e}")
        finally:
            browser.close()

if __name__ == "__main__":
    verify()
