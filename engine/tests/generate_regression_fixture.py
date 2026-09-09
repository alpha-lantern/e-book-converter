import fitz
from pathlib import Path

def create_pdf(output_path):
    doc = fitz.open()
    
    # Page 1
    page1 = doc.new_page()
    page1.insert_text(fitz.Point(50, 50), "Regression Test Document", fontsize=24) # Title
    page1.insert_text(fitz.Point(50, 100), "Chapter 1: The Beginning", fontsize=18) # Heading
    page1.insert_text(fitz.Point(50, 150), "This is a normal paragraph to test basic text extraction.", fontsize=12) # Body
    
    # Use insert_htmlbox for bold text to avoid font loading issues
    page1.insert_htmlbox(fitz.Rect(50, 200, 500, 300), "<p>This sentence is <b>bold</b> to test semantic thresholds.</p>")
    
    # Page 2
    page2 = doc.new_page()
    page2.insert_text(fitz.Point(50, 50), "Chapter 2: The Continuation", fontsize=18) # Heading
    page2.insert_text(fitz.Point(50, 100), "Here is another paragraph on a second page to ensure page break logic works correctly.", fontsize=12) # Body
    
    # Save
    doc.save(output_path)
    doc.close()

if __name__ == "__main__":
    fixtures_dir = Path(__file__).parent / "fixtures"
    fixtures_dir.mkdir(exist_ok=True)
    pdf_path = fixtures_dir / "regression.pdf"
    create_pdf(pdf_path)
    print(f"Created PDF at {pdf_path}")
