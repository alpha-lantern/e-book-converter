import fitz
import os

def create_test_pdf(output_path: str):
    doc = fitz.open()
    page = doc.new_page()

    # H1
    page.insert_text(fitz.Point(50, 50), "Document Title", fontsize=30, fontname="helv")

    # H2
    page.insert_text(fitz.Point(50, 100), "Section 1", fontsize=20, fontname="helv")

    # Body P (BaseSize should be 12.0)
    y = 130
    for i in range(15):
        page.insert_text(fitz.Point(50, y), f"This is a line of body text, number {i+1}.", fontsize=12, fontname="helv")
        y += 20

    doc.save(output_path)
    doc.close()
    print(f"Test PDF created at: {output_path} (git-ignored, do not commit)")
    print("Please run the calibration script: python3 scripts/calibrate.py test.pdf")

if __name__ == "__main__":
    create_test_pdf("test.pdf")
