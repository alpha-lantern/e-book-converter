import fitz
import os

def create_test_pdf(output_path: str):
    doc = fitz.open()

    # Page 1
    page1 = doc.new_page()
    page1.insert_text(fitz.Point(50, 50), "Document Title", fontsize=30, fontname="helv")
    page1.insert_text(fitz.Point(50, 100), "Section 1", fontsize=20, fontname="helv")

    y = 130
    for i in range(5):
        page1.insert_text(fitz.Point(50, y), f"Page 1 body text, line {i+1}.", fontsize=12, fontname="helv")
        y += 20

    # Page 2
    page2 = doc.new_page()
    page2.insert_text(fitz.Point(50, 50), "Section 2", fontsize=20, fontname="helv")
    y = 80
    for i in range(10):
        page2.insert_text(fitz.Point(50, y), f"Page 2 body text, line {i+1}.", fontsize=12, fontname="helv")
        y += 20

    doc.save(output_path)
    doc.close()
    print(f"Test PDF created at: {output_path} (git-ignored, do not commit)")
    print("Please run the calibration script: python3 scripts/calibrate.py test.pdf")

if __name__ == "__main__":
    create_test_pdf("test.pdf")
