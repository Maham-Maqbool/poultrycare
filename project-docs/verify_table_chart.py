#!/usr/bin/env python3
import json
import csv
import docx

def verify():
    # 1. Check summary.json
    with open('project-docs/summary.json', 'r') as f:
        summ = json.load(f)

    # 2. Check docx Table 4.1
    doc = docx.Document('project-docs/FYP_PoultryDiseaseDetection_Documentation_with_Chapter5 (3).docx')
    t = doc.tables[27]

    print('=== DOCX TABLE 4.1 VALUES ===')
    for r in t.rows:
        print([c.text for c in r.cells])

    print('\n=== SUMMARY.JSON VALUES ===')
    for cls, stats in summ['per_class'].items():
        print(f"{cls}: Blood {stats['blood']['mean']} +/- {stats['blood']['std']}, Abnormal {stats['abnormal']['mean']} +/- {stats['abnormal']['std']}, Watery {stats['watery']['mean']} +/- {stats['watery']['std']}, Score {stats['severity_score']['mean']} +/- {stats['severity_score']['std']}")

    # 3. Check ratios.csv
    with open('project-docs/ratios.csv', 'r') as f:
        reader = csv.DictReader(f)
        csv_rows = list(reader)

    print(f'\nTotal rows in ratios.csv: {len(csv_rows)}')
    for cls in ['Coccidiosis', 'Healthy', 'Newcastle', 'Salmonella']:
        c_rows = [r for r in csv_rows if r['class'] == cls]
        b_mean = sum(float(r['blood']) for r in c_rows) / len(c_rows)
        s_mean = sum(float(r['severity_score']) for r in c_rows) / len(c_rows)
        print(f'{cls}: n={len(c_rows)}, mean blood={b_mean:.3f}, mean score={s_mean:.2f}')

    print('\nVerification completed!')

if __name__ == '__main__':
    verify()

