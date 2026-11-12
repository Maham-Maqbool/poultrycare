#!/usr/bin/env python3
"""
Updates the FYP documentation docx and text files with the empirical
ratio-based severity assessment architecture and removes confidence-based severity.
"""

from pathlib import Path
import docx
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT

DOCX_PATH = Path('project-docs/FYP_PoultryDiseaseDetection_Documentation_with_Chapter5 (3).docx')
TXT_PATH = Path('project-docs/extracted_doc_text.txt')
CHART_PATH = Path('resources/chart.png')


def update_docx():
    print(f'Loading {DOCX_PATH}...')
    doc = docx.Document(str(DOCX_PATH))

    # 1. Update Abstract (Paragraph 102)
    p102 = doc.paragraphs[102]
    old_abs = "The model's confidence score is combined with a rule-based severity estimator to produce a Mild, Moderate, or Severe severity label"
    new_abs = "Severity is derived from visible clinical signs in the image (blood content, abnormal colour, and watery consistency) measured as pixel ratios, not from model confidence. The resulting Mild, Moderate, or Severe severity label is produced"
    if old_abs in p102.text:
        p102.text = p102.text.replace(old_abs, new_abs)
        print(' Abstract updated.')
    else:
        print(' Notice: Abstract already updated or pattern adjusted.')

    # 2. Update 1.2 Introduction (Paragraph 191)
    p191 = doc.paragraphs[191]
    # Check for existing text with hyphen or em dash
    old_intro_variants = [
        "For each diseased class, the system presents a severity label - Mild, Moderate, or Severe - derived from the confidence score of the prediction.",
        "For each diseased class, the system presents a severity label - Mild, Moderate, or Severe - derived from the confidence score of the prediction.",
    ]
    new_intro = "For each diseased class, the system presents a severity label (Mild, Moderate, or Severe). Severity is derived from visible clinical signs in the image (blood content, abnormal colour, and watery consistency) measured as pixel ratios, not from model confidence."
    intro_updated = False
    for variant in old_intro_variants:
        if variant in p191.text:
            p191.text = p191.text.replace(variant, new_intro)
            intro_updated = True
            break
    if intro_updated:
        print(' 1.2 Introduction updated.')
    else:
        print(' Notice: 1.2 Introduction pattern check.')

    # 3. Update Scope (Paragraph 202)
    p202 = doc.paragraphs[202]
    old_scope = "while incorporating data augmentation, confidence-based severity estimation, and predefined treatment recommendations."
    new_scope = "while incorporating data augmentation, ratio-based severity estimation derived from visible clinical signs (blood content, abnormal colour, and watery consistency measured as pixel ratios, not from model confidence), and predefined treatment recommendations."
    if old_scope in p202.text:
        p202.text = p202.text.replace(old_scope, new_scope)
        print(' Scope updated.')
    else:
        print(' Notice: Scope pattern check.')

    # 4. Update FR-05 in Table 8 (Functional Requirements)
    fr05_exact_line = "The system shall assign severity (Mild/Moderate/Severe) from the measured clinical-sign ratios in the specimen image. Severity shall NOT be derived from the model's confidence score."
    t8 = doc.tables[8]
    t8.rows[2].cells[1].text = fr05_exact_line
    print(' FR-05 updated in Table 8.')

    # Also update Table 3 (Requirements Baseline)
    t3 = doc.tables[3]
    if len(t3.rows) > 4 and len(t3.rows[4].cells) > 1:
        t3.rows[4].cells[1].text = "The system shall display the classification result and ratio-derived severity level (Mild/Moderate/Severe) measured from visible clinical signs in the image."
        print(' FR-05 updated in Table 3.')

    # 5. Add Detailed Empirical Severity Section under Chapter 4 Methodology
    # Insert right after Figure 4.1 paragraph (p356/p357)
    target_idx = 358
    target_p = doc.paragraphs[target_idx]

    h_p = target_p.insert_paragraph_before()
    h_p.style = 'Heading 4'
    h_p.text = "Clinical Sign Ratio Analysis and Empirical Severity Derivation"

    body_p1 = target_p.insert_paragraph_before()
    body_p1.text = (
        "In clinical veterinary diagnostics, disease severity reflects pathogen load and progressive pathological damage, "
        "not the statistical confidence of a machine learning classifier. To replace confidence-based heuristics with an "
        "evidence-based standard, the system measures visible clinical signs directly from the 224x224 specimen image in "
        "HSV color space (0 to 255 scale) using three calibrated pixel ratios:\n"
        "1. Blood Content Ratio: Pixels with hue <= 24 or hue >= 243, saturation >= 50, and value >= 25 (erythrocytic lesions).\n"
        "2. Abnormal Colour Ratio: Pixels with saturation >= 70 and hue between 75 and 242 (atypical green, blue, or bile bile-stained pigments).\n"
        "3. Watery Consistency Ratio: Pixels with value >= 205 and saturation <= 90 (pale exudate and moisture dispersion)."
    )

    body_p2 = target_p.insert_paragraph_before()
    body_p2.text = (
        "Each ratio is computed as the fraction of matching pixels over total specimen pixels (50,176). "
        "The composite clinical severity score is formulated by normalizing against Healthy 95th percentile baseline ceilings "
        "(with abnormal floored at 0.05 to avoid small-sample denominator spikes):\n\n"
        "Severity Score = (Blood Ratio / 0.2239) + (Abnormal Ratio / 0.05) + (Watery Ratio / 0.1676)\n\n"
        "Calibrated clinical severity bands are assigned as follows:\n"
        "- Mild Severity: Score < 1.0 (baseline clinical appearance)\n"
        "- Moderate Severity: 1.0 <= Score <= 2.0 (intermediate pathological expression)\n"
        "- Severe Severity: Score > 2.0 (critical mucosal haemorrhage and systemic exudation)"
    )

    # Insert Table 1: Measured Per-Class Ratios
    tbl1_p = target_p.insert_paragraph_before()
    tbl1_p.text = "Table 4.1: Measured Per-Class Clinical Sign Ratios (150 images/class, mean +/- std)"
    tbl1_p.runs[0].bold = True

    table1 = doc.add_table(rows=5, cols=5)
    table1.style = 'Table Grid'
    headers1 = ['Disease Class', 'Blood Ratio', 'Abnormal Ratio', 'Watery Ratio', 'Severity Score']
    for col_idx, text in enumerate(headers1):
        cell = table1.rows[0].cells[col_idx]
        cell.text = text
        cell.paragraphs[0].runs[0].bold = True

    data1 = [
        ['Healthy', '0.052 +/- 0.078', '0.001 +/- 0.010', '0.034 +/- 0.054', '0.46 +/- 0.64'],
        ['Coccidiosis', '0.275 +/- 0.231', '0.002 +/- 0.006', '0.265 +/- 0.194', '2.85 +/- 1.71'],
        ['Newcastle', '0.061 +/- 0.093', '0.002 +/- 0.006', '0.094 +/- 0.111', '0.88 +/- 0.90'],
        ['Salmonella', '0.105 +/- 0.101', '0.098 +/- 0.124', '0.094 +/- 0.097', '2.99 +/- 2.55'],
    ]
    for row_idx, row_data in enumerate(data1):
        for col_idx, text in enumerate(row_data):
            table1.rows[row_idx + 1].cells[col_idx].text = text

    # Move table before target_p
    target_p._p.addprevious(table1._tbl)

    # Insert Table 2: Measured Severity Band Distribution
    tbl2_p = target_p.insert_paragraph_before()
    tbl2_p.text = "\nTable 4.2: Empirical Severity Band Distribution Across 150 images/class"
    tbl2_p.runs[0].bold = True

    table2 = doc.add_table(rows=5, cols=4)
    table2.style = 'Table Grid'
    headers2 = ['Disease Class', 'Mild (Score < 1.0)', 'Moderate (1.0 to 2.0)', 'Severe (Score > 2.0)']
    for col_idx, text in enumerate(headers2):
        cell = table2.rows[0].cells[col_idx]
        cell.text = text
        cell.paragraphs[0].runs[0].bold = True

    data2 = [
        ['Healthy', '85.3%', '12.7%', '2.0%'],
        ['Coccidiosis', '19.3%', '15.3%', '65.3%'],
        ['Salmonella', '22.7%', '18.0%', '59.3%'],
        ['Newcastle', '62.7%', '22.0%', '15.3%'],
    ]
    for row_idx, row_data in enumerate(data2):
        for col_idx, text in enumerate(row_data):
            table2.rows[row_idx + 1].cells[col_idx].text = text

    target_p._p.addprevious(table2._tbl)

    # Embed chart.png if present
    if CHART_PATH.exists():
        chart_p = target_p.insert_paragraph_before()
        chart_p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        chart_p.paragraph_format.space_before = Pt(12)
        run = chart_p.add_run()
        run.add_picture(str(CHART_PATH), width=Inches(5.5))

        caption_p = target_p.insert_paragraph_before()
        caption_p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        caption_p.text = "Figure 4.2: Distribution of Measured Clinical-Sign Pixel Ratios Across Poultry Disease Classes"
        caption_p.runs[0].italic = True
        print(' Embedded chart.png into docx.')

    # Add Newcastle Limitation
    limit_p = target_p.insert_paragraph_before()
    limit_p.text = (
        "Newcastle Disease Diagnostic Limitation and Flock Triage Integration:\n"
        "Empirical analysis reveals that 62.7% of Newcastle Disease fecal samples score in the Mild band when evaluated "
        "strictly on optical image signs. This is an expected clinical characteristic: Newcastle Disease primarily manifests "
        "through neurological and respiratory impairment rather than overt bloody enteritis. Dropping signs in early or acute "
        "phases are frequently subtle greenish-watery excretions. To overcome this image-only limitation, the system couples "
        "the computer vision pipeline with a 3-question flock triage assessment (flock lethargy, feed intake drop, and "
        "24-hour sudden mortality). If sudden mortality or severe flock-wide lethargy is reported, the clinical triage engine "
        "automatically escalates the severity and issues an immediate veterinary consultation urgency ('Vet Now')."
    )

    doc.save(str(DOCX_PATH))
    print(f' Successfully saved updated Word document to {DOCX_PATH}')


def update_txt():
    if not TXT_PATH.exists():
        print(f'{TXT_PATH} does not exist, skipping text update.')
        return

    content = TXT_PATH.read_text(encoding='utf-8')
    # Replace confidence severity with clinical ratio severity
    replacements = [
        ("The model's confidence score is combined with a rule-based severity estimator to produce a Mild, Moderate, or Severe severity label",
         "Severity is derived from visible clinical signs in the image (blood content, abnormal colour, and watery consistency) measured as pixel ratios, not from model confidence. The resulting Mild, Moderate, or Severe severity label is produced"),
        ("derived from the confidence score of the prediction.",
         "Severity is derived from visible clinical signs in the image (blood content, abnormal colour, and watery consistency) measured as pixel ratios, not from model confidence."),
        ("confidence-based severity estimation",
         "ratio-based severity estimation derived from visible clinical signs (blood content, abnormal colour, and watery consistency measured as pixel ratios, not from model confidence)"),
        ("The system shall report a severity level (Mild, Moderate, or Severe) derived from the confidence score and predicted class.",
         "The system shall assign severity (Mild/Moderate/Severe) from the measured clinical-sign ratios in the specimen image. Severity shall NOT be derived from the model's confidence score."),
    ]
    for old, new in replacements:
        if old in content:
            content = content.replace(old, new)
            print(f' Replaced in txt: {old[:50]}...')

    TXT_PATH.write_text(content, encoding='utf-8')
    print(' Updated extracted_doc_text.txt successfully.')


if __name__ == '__main__':
    update_docx()
    update_txt()
