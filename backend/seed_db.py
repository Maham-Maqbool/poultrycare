"""
PoultryCare Database Seeder and Migration Script.
Creates all 10 Chapter 5 tables and populates baseline bilingual content.
Idempotent: safe to run multiple times.
"""

import sys
import os
from pathlib import Path
from datetime import datetime, timezone

# Add project root to sys.path
PROJECT_ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(PROJECT_ROOT))

from backend.db import engine, SessionLocal, Base, is_postgres
from backend.models_db import (
    Disease,
    Treatment,
    ModelVersion,
    User,
    Flock,
    new_uuid,
)


def seed_database():
    """Initializes tables and seeds reference content."""
    print(f"[Seeder] Target database: {engine.url}")
    print("[Seeder] Creating tables...")
    Base.metadata.create_all(bind=engine)
    print("[Seeder] Tables created successfully.")

    db = SessionLocal()
    try:
        # ======================================================================
        # 1. Seed Diseases (4 Classes)
        # ======================================================================
        diseases_data = [
            {
                "code": "coccidiosis",
                "name_en": "Coccidiosis",
                "name_ur": "کوکسیڈیوسس",
                "summary_en": "A parasitic infection caused by Eimeria protozoa multiplying in intestinal walls, causing bloody droppings, weight loss, and reduced feed efficiency.",
                "summary_ur": "یہ ایک طفیلی بیماری ہے جو آنتوں میں ایمیریا پروٹوزووا کے بڑھنے سے ہوتی ہے۔ اس سے پاخانے میں خون، سستی اور وزن میں کمی واقع ہوتی ہے۔",
                "signs_en": [
                    "Reddish or bloody fecal droppings with excess mucus",
                    "Ruffled, unkempt feathers and droopy wings",
                    "Huddling together near heat sources",
                    "Loss of appetite and reduced water consumption",
                    "Sudden spike in flock mortality",
                ],
                "signs_ur": [
                    "پاخانے میں خون یا سرخی مائل بلغم آنا",
                    "پروں کا بکھر جانا اور پرندوں کا گر جانا",
                    "گرمی کے ذرائع کے گرد پرندوں کا اکٹھا ہونا",
                    "کھانے پینے میں کمی اور سستی",
                    "مرغیوں کی اموات میں اچانک اضافہ",
                ],
                "baseline_severity": "moderate",
                "baseline_urgency": "treat_today",
                "is_notifiable": False,
                "display_order": 1,
            },
            {
                "code": "healthy",
                "name_en": "Healthy Flock",
                "name_ur": "صحت مند ریوڑ",
                "summary_en": "Droppings and appearance reflect normal digestion and healthy poultry physiology without overt signs of pathogenic infection.",
                "summary_ur": "فضلے اور ظاہری حالت سے عام ہاضمہ اور صحت مند پرندوں کی تصدیق ہوتی ہے، کسی بیماری کی علامت نہیں ہے۔",
                "signs_en": [
                    "Firm brownish droppings capped with white uric acid cap",
                    "Vigorous movement, bright eyes, and alert posture",
                    "Clean, well-groomed plumage",
                    "Consistent daily feed and water intake",
                    "Normal growth rate or egg production curves",
                ],
                "signs_ur": [
                    "ٹھوس بھورا پاخانہ جس پر سفید یورک ایسڈ کی تہہ ہو",
                    "پرندوں کا چست ہونا اور چمکدار آنکھیں",
                    "صاف ستھرے اور چمکدار پر",
                    "معمول کے مطابق خوراک اور پانی کا استعمال",
                    "وزن اور انڈوں کی پیداوار میں تسلسل",
                ],
                "baseline_severity": "mild",
                "baseline_urgency": "monitor",
                "is_notifiable": False,
                "display_order": 4,
            },
            {
                "code": "ncd",
                "name_en": "Newcastle Disease (Rani Khet)",
                "name_ur": "رانی کھیت (نیو کیسل بیماری)",
                "summary_en": "A highly contagious viral disease affecting respiratory, nervous, and digestive systems with rapid transmission and severe flock mortality.",
                "summary_ur": "ایک انتہائی متعدی اور جان لیوا وائرل بیماری جو نظام تنفس، اعصاب اور ہاضمے کو بری طرح متاثر کرتی ہے۔",
                "signs_en": [
                    "Watery greenish or yellowish diarrhea",
                    "Nervous signs: twisted neck (torticollis), tremors, paralysis",
                    "Gasping, coughing, sneezing, and nasal discharge",
                    "Complete cessation of egg production",
                    "Sudden catastrophic flock death within 48 to 72 hours",
                ],
                "signs_ur": [
                    "پتلے سبز یا زرد رنگ کے دست",
                    "اعصابی علامات: گردن کا مڑ جانا، کپکپاہٹ اور لکوا",
                    "سانس لینے میں شدید دشواری، کھانسی اور چھینکیں",
                    "انڈوں کی پیداوار کا یکسر رک جانا",
                    "48 سے 72 گھنٹوں میں پرندوں کی بھاری تعداد میں اچانک موت",
                ],
                "baseline_severity": "severe",
                "baseline_urgency": "vet_now",
                "is_notifiable": True,
                "display_order": 0,
            },
            {
                "code": "salmonella",
                "name_en": "Salmonella (Pullorum / Fowl Typhoid)",
                "name_ur": "سالمونیلا (پولورم / فال ٹائیفائڈ)",
                "summary_en": "A severe bacterial infection causing white chalky diarrhea, high chick mortality, lethargy, and systemic organ septicemia.",
                "summary_ur": "ایک خطرناک بیکٹیریل بیماری جس سے سفید چاک جیسا اسہال، چوزوں میں شدید اموات اور غنودگی پیدا ہوتی ہے۔",
                "signs_en": [
                    "Chalky white, watery diarrhea pasting vent feathers",
                    "Severe somnolence: chicks stand with closed eyes and drooping heads",
                    "Swollen, inflamed joints and reluctance to move",
                    "Difficulty breathing and audible laboured respiration",
                    "High mortality in chicks during first 3 weeks",
                ],
                "signs_ur": [
                    "سفید چاک جیسا پتلا پاخانہ جو مقعد کے پروں پر جم جائے",
                    "شدید غنودگی: چوزے آنکھیں بند کر کے سر جھکائے کھڑے رہتے ہیں",
                    "جوڑوں میں سوجن اور چلنے پھرنے سے معذوری",
                    "سانس لینے میں دقت اور کھڑکھڑاہٹ کی آواز",
                    "پہلے 3 ہفتوں کے دوران چوزوں میں شرح اموات میں خطرناک اضافہ",
                ],
                "baseline_severity": "severe",
                "baseline_urgency": "vet_soon",
                "is_notifiable": False,
                "display_order": 2,
            },
        ]

        for d_info in diseases_data:
            existing = db.query(Disease).filter_by(code=d_info["code"]).first()
            if not existing:
                disease = Disease(**d_info)
                db.add(disease)
                print(f"[Seeder] Added disease: {d_info['code']}")
            else:
                for k, v in d_info.items():
                    setattr(existing, k, v)
        db.commit()

        # ======================================================================
        # 2. Seed Treatments (Chapter 5 Reachable Pairs)
        # ======================================================================
        treatments_data = [
            {
                "disease_code": "coccidiosis",
                "severity": "moderate",
                "medicines_en": [
                    "Amprolium 20% Soluble Powder: 1g per 1-2 Litres of drinking water for 5-7 days",
                    "Vitamin K3 + A + D3 supplement in water to assist intestinal mucosal clotting",
                ],
                "medicines_ur": [
                    "ایمپرولیم 20 فیصد پاؤڈر: 1 گرام فی 1 سے 2 لیٹر پینے کے پانی میں 5 سے 7 دن تک",
                    "وٹامن K3 اور A تاکہ آنتوں کے اندرونی زخم اور خون بہنا رک سکے",
                ],
                "care_steps_en": [
                    "Ensure fresh medicated water is the sole source of drinking water during treatment",
                    "Add warm heat brooder coverage to prevent chilling of lethargic birds",
                    "Replace wet, caked litter under drinkers immediately with dry wood shavings",
                ],
                "care_steps_ur": [
                    "دوا ملا پانی ہی پرندوں کا واحد پینے کا ذریعہ ہونا چاہیے",
                    "بیمار پرندوں کے لیے مناسب حرارت اور گرمائش کا فوری انتظام کریں",
                    "پانی کے برتنوں کے نیچے کی گیلی کھاد کو خشک برادے سے تبدیل کریں",
                ],
                "biosecurity_en": [
                    "Sanitize drinkers and feeders twice daily using broad spectrum disinfectant",
                    "Restrict farm entry to authorized personnel with boot dips (Glutaraldehyde 2%)",
                    "Maintain strict ventilation to prevent litter moisture exceeding 25%",
                ],
                "biosecurity_ur": [
                    "برتنوں کو روزانہ جراثیم کش ادویات سے اچھی طرح دھوئیں",
                    "شیڈ میں داخلے پر پاؤں دھونے کے جراثیم کش ٹب کا استعمال لازمی کریں",
                    "شیڈ میں ہوا کی مناسب آمد و رفت یقینی بنائیں تاکہ نمی کم رہے",
                ],
                "vet_required": False,
                "urgency": "treat_today",
            },
            {
                "disease_code": "coccidiosis",
                "severity": "severe",
                "medicines_en": [
                    "Toltrazuril 2.5% Oral Solution: 7mg/kg body weight (1ml per 1L water for 2 consecutive days)",
                    "Injectable / water-soluble Vitamin K3 complex for active hemorrhages",
                    "Electrolytes + Dextrose rehydration therapy",
                ],
                "medicines_ur": [
                    "ٹولٹرازورل 2.5 فیصد: 1 ملی لیٹر فی لیٹر پانی میں مسلسل 2 دن",
                    "وٹامن K3 کا مرکب تاکہ خون کا اخراج فوری روکا جا سکے",
                    "الیکٹرولائٹس اور گلوکوز کا پانی تاکہ کمزوری اور پانی کی کمی دور ہو",
                ],
                "care_steps_en": [
                    "Isolate severely depressed and bleeding birds in warm hospital pens",
                    "Scrape and remove all damp litter across the entire shed immediately",
                    "Burn or deeply bury mortal losses with quicklime",
                ],
                "care_steps_ur": [
                    "شدید بیمار پرندوں کو الگ گرم کمرے میں قرنطینہ کریں",
                    "پورے شیڈ سے تمام گیلی کھاد فوری باہر نکال کر تلف کریں",
                    "مردہ پرندوں کو چونا ڈال کر گہرے گڑھے میں دفن کریں",
                ],
                "biosecurity_en": [
                    "Disinfect equipment using ammonia hydroxide or specific oocysticidal compounds",
                    "Impose complete visitor quarantine for 14 days",
                ],
                "biosecurity_ur": [
                    "پورے شیڈ اور اوزاروں کو امونیا یا اینٹی پروٹوزووا اسپرے سے جراثیم سے پاک کریں",
                    "شیڈ میں بیرونی افراد کا داخلہ اگلے 14 دنوں کے لیے مکمل بند کریں",
                ],
                "vet_required": True,
                "urgency": "vet_soon",
            },
            {
                "disease_code": "healthy",
                "severity": "mild",
                "medicines_en": [
                    "No therapeutic medication required",
                    "Routine organic probiotics in drinking water 2 days per week",
                ],
                "medicines_ur": [
                    "کسی دوائی کی ضرورت نہیں ہے",
                    "ہفتے میں دو دن پینے کے پانی میں پروبائیوٹکس یا سرکہ شامل کریں",
                ],
                "care_steps_en": [
                    "Maintain standard feeding schedules based on flock age and breed guidelines",
                    "Inspect drinkers daily for biofilm buildup and flush water pipelines",
                ],
                "care_steps_ur": [
                    "پرندوں کی عمر کے مطابق باقاعدہ اور متوازن خوراک جاری رکھیں",
                    "پانی کی پائپ لائنوں کی باقاعدہ صفائی یقینی بنائیں",
                ],
                "biosecurity_en": [
                    "Keep footbaths replenished at shed entrances",
                    "Block wild birds and rodents with wire mesh barriers",
                ],
                "biosecurity_ur": [
                    "شیڈ کے دروازے پر جراثیم کش پانی تبدیل کرتے رہیں",
                    "جنگلی پرندوں اور چوہوں کے داخلے کی روک تھام کا باقاعدہ معائنہ کریں",
                ],
                "vet_required": False,
                "urgency": "monitor",
            },
            {
                "disease_code": "ncd",
                "severity": "severe",
                "medicines_en": [
                    "Viral disease: No curative antibiotic exists for Newcastle Disease virus",
                    "Administer broad-spectrum Tylosin or Doxycycline to prevent secondary bacterial infection",
                    "High-potency Multivitamin + Vitamin E + Selenium to bolster immune resistance",
                ],
                "medicines_ur": [
                    "یہ وائرل بیماری ہے جس کا کوئی اینٹی بائیوٹک علاج ممکن نہیں",
                    "دوسری بیماریوں سے بچاؤ کے لیے ٹائلوسین یا ڈوکسی سائکلین دیں",
                    "قوت مدافعت بڑھانے کے لیے وٹامن ای اور سیلینیم کا مرکب دیں",
                ],
                "care_steps_en": [
                    "ALERT: Immediately notify local district veterinary hospital and livestock officer",
                    "Quarantine entire shed; do not move birds, eggs, or litter off premises",
                    "Immediately vaccinate non-symptomatic adjacent sheds with Lasota strain by eye drop",
                ],
                "care_steps_ur": [
                    "فوری طور پر قریبی ویٹرنری ڈاکٹر یا محکمہ لائیو اسٹاک کو مطلع کریں",
                    "پورے شیڈ کو مکمل قرنطینہ کریں، کوئی پرندہ یا کھاد باہر نہ جائے",
                    "قریبی صحت مند شیڈز میں فوری طور پر لیسوٹا ویکسین کی ہنگامی بوسٹر ڈوز دیں",
                ],
                "biosecurity_en": [
                    "Establish strict perimeter security with disinfectant vehicle spraying",
                    "Dispose of all carcasses inside deep pits covered with caustic lime and soil",
                ],
                "biosecurity_ur": [
                    "فارم کے اطراف مکمل حفاظتی گھیرا اور گاڑیوں پر جراثیم کش اسپرے لازمی کریں",
                    "تمام تلف شدہ پرندوں کو چونے کی موٹی تہہ کے ساتھ گہرے گڑھے میں دفنائیں",
                ],
                "vet_required": True,
                "urgency": "vet_now",
            },
            {
                "disease_code": "salmonella",
                "severity": "severe",
                "medicines_en": [
                    "Enrofloxacin 10% Solution: 10mg/kg body weight in water for 5 consecutive days",
                    "Colistin Sulphate for synergistic gastrointestinal antibacterial coverage",
                    "Electrolytes and liver tonic supplementation during convalescence",
                ],
                "medicines_ur": [
                    "اینروفلوکساسین 10 فیصد: 1 ملی لیٹر فی 2 لیٹر پانی 5 دن کے لیے",
                    "کولسٹن سلفیٹ آنتوں کی صفائی اور شدید بیکٹیریا کے خاتمے کے لیے",
                    "علاج کے بعد جگر کا ٹانک (Liver Tonic) اور الیکٹرولائٹس لازمی دیں",
                ],
                "care_steps_en": [
                    "Isolate all birds exhibiting pasted vents and drooping wings",
                    "Clean vents of young chicks using warm saline swabs to restore bowel passage",
                    "Increase brooding temperature by 2-3 degrees Celsius to mitigate chill stress",
                ],
                "care_steps_ur": [
                    "جن پرندوں کی دم کے پر پاخانے سے جڑے ہوں انہیں فوری الگ کریں",
                    "چوزوں کے مقعد کی نیم گرم پانی سے صفائی کریں تاکہ فضلہ نہ پھنسے",
                    "شیڈ کا درجہ حرارت 2 سے 3 درجے سینٹی گریڈ بڑھائیں تاکہ چوزے سست نہ ہوں",
                ],
                "biosecurity_en": [
                    "Test flock drinking water source for bacterial coliform contamination",
                    "Clean and sanitize feed hoppers to eliminate rodent fecal contamination",
                ],
                "biosecurity_ur": [
                    "پینے کے پانی کا بیکٹیریل ٹیسٹ کروائیں",
                    "خوراک کے برتنوں کو چوہوں اور پرندوں کی گندگی سے بالکل پاک رکھیں",
                ],
                "vet_required": True,
                "urgency": "vet_soon",
            },
        ]

        for t_info in treatments_data:
            existing_t = (
                db.query(Treatment)
                .filter_by(
                    disease_code=t_info["disease_code"],
                    severity=t_info["severity"],
                )
                .first()
            )
            if not existing_t:
                treatment = Treatment(**t_info)
                db.add(treatment)
                print(f"[Seeder] Added treatment: {t_info['disease_code']} ({t_info['severity']})")
            else:
                for k, v in t_info.items():
                    setattr(existing_t, k, v)
        db.commit()

        # ======================================================================
        # 3. Seed Model Version (MobileNetV2 from Colab)
        # ======================================================================
        mv = db.query(ModelVersion).filter_by(version="v1.0.0-mobilenetv2").first()
        if not mv:
            mv = ModelVersion(
                version="v1.0.0-mobilenetv2",
                source="trained",
                backbone="MobileNetV2",
                macro_f1=0.962,
                balanced_accuracy=0.958,
                mcc=0.945,
                per_class_recall={
                    "coccidiosis": 0.952,
                    "healthy": 0.981,
                    "ncd": 0.941,
                    "salmonella": 0.959,
                },
                is_active=True,
                activated_at=datetime.now(timezone.utc),
            )
            db.add(mv)
            print("[Seeder] Registered active model version: v1.0.0-mobilenetv2")
            db.commit()

        # ======================================================================
        # 4. Seed Demo Farmer & Flock
        # ======================================================================
        demo_user = db.query(User).filter_by(phone="+923001234567").first()
        if not demo_user:
            demo_user = User(
                id="00000000-0000-0000-0000-000000000001",
                display_name="Rashid Khan (Farmer)",
                phone="+923001234567",
                role="farmer",
                locale="ur",
            )
            db.add(demo_user)
            db.commit()
            print("[Seeder] Created demo farmer user: Rashid Khan")

        demo_flock = db.query(Flock).filter_by(user_id=demo_user.id).first()
        if not demo_flock:
            demo_flock = Flock(
                id="00000000-0000-0000-0000-000000000002",
                user_id=demo_user.id,
                name="Shed Alpha (Broiler)",
                bird_count=2500,
                breed="Cobb 500",
                notes="Week 4 broiler batch",
            )
            db.add(demo_flock)
            db.commit()
            print("[Seeder] Created demo flock: Shed Alpha (Broiler)")

        print("\n[Seeder] SUCCESS! All 10 tables initialized and seeded with Chapter 5 clinical content.")

    finally:
        db.close()


if __name__ == "__main__":
    seed_database()

