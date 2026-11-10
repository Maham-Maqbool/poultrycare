import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../routes/app_routes.dart';
import '../../profile/controllers/settings_controller.dart';

/// FcrCalculatorScreen calculates Feed Conversion Ratio (FCR) and financial economics
/// for broiler and commercial poultry flocks in Pakistan.
class FcrCalculatorScreen extends StatefulWidget {
  const FcrCalculatorScreen({super.key});

  @override
  State<FcrCalculatorScreen> createState() => _FcrCalculatorScreenState();
}

class _FcrCalculatorScreenState extends State<FcrCalculatorScreen> {
  // Input Controllers
  final TextEditingController _flockSizeController = TextEditingController(text: '2000');
  final TextEditingController _avgWeightController = TextEditingController(text: '2.05');
  final TextEditingController _feedConsumedController = TextEditingController(text: '124');
  final TextEditingController _feedBagPriceController = TextEditingController(text: '7200');
  final TextEditingController _liveSellingRateController = TextEditingController(text: '420');
  final TextEditingController _chickPriceController = TextEditingController(text: '85');
  final TextEditingController _operationalCostController = TextEditingController(text: '35');

  // Input Mode: Feed entered in 50kg bags or kilograms
  bool _isFeedInBags = true;
  bool _showAdvancedCosts = false;

  @override
  void dispose() {
    _flockSizeController.dispose();
    _avgWeightController.dispose();
    _feedConsumedController.dispose();
    _feedBagPriceController.dispose();
    _liveSellingRateController.dispose();
    _chickPriceController.dispose();
    _operationalCostController.dispose();
    super.dispose();
  }

  void _applyPreset({
    required int flockSize,
    required double avgWeight,
    required double feedBags,
    required double bagPrice,
    required double liveRate,
  }) {
    setState(() {
      _flockSizeController.text = '$flockSize';
      _avgWeightController.text = avgWeight.toStringAsFixed(2);
      if (_isFeedInBags) {
        _feedConsumedController.text = feedBags.toStringAsFixed(1);
      } else {
        _feedConsumedController.text = (feedBags * 50.0).toStringAsFixed(0);
      }
      _feedBagPriceController.text = bagPrice.toStringAsFixed(0);
      _liveSellingRateController.text = liveRate.toStringAsFixed(0);
    });
  }

  void _toggleFeedUnit() {
    final currentVal = double.tryParse(_feedConsumedController.text) ?? 0;
    setState(() {
      if (_isFeedInBags) {
        // Switching from Bags to Kg (1 bag = 50kg)
        _isFeedInBags = false;
        _feedConsumedController.text = (currentVal * 50.0).toStringAsFixed(0);
      } else {
        // Switching from Kg to Bags
        _isFeedInBags = true;
        _feedConsumedController.text = (currentVal / 50.0).toStringAsFixed(1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    final isUrdu = settings.locale == 'ur';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Parse values safely
    final int flockSize = int.tryParse(_flockSizeController.text) ?? 0;
    final double avgWeight = double.tryParse(_avgWeightController.text) ?? 0.0;
    final double feedInput = double.tryParse(_feedConsumedController.text) ?? 0.0;
    final double bagPrice = double.tryParse(_feedBagPriceController.text) ?? 0.0;
    final double liveRate = double.tryParse(_liveSellingRateController.text) ?? 0.0;
    final double chickCostPerBird = double.tryParse(_chickPriceController.text) ?? 0.0;
    final double opsCostPerBird = double.tryParse(_operationalCostController.text) ?? 0.0;

    // Mathematical Computations
    final double totalFeedKg = _isFeedInBags ? (feedInput * 50.0) : feedInput;
    final double totalFeedBags = _isFeedInBags ? feedInput : (feedInput / 50.0);
    final double totalLiveWeightKg = flockSize * avgWeight;

    // FCR = Total Feed Consumed (kg) / Total Weight Gain (kg)
    final double fcr = (totalLiveWeightKg > 0) ? (totalFeedKg / totalLiveWeightKg) : 0.0;
    final double feedPerBirdKg = (flockSize > 0) ? (totalFeedKg / flockSize) : 0.0;

    // Economics
    final double costPerKgFeed = (bagPrice > 0) ? (bagPrice / 50.0) : 0.0;
    final double totalFeedCost = totalFeedBags * bagPrice;
    final double feedCostPerKgMeat = fcr * costPerKgFeed;
    final double feedCostPerBird = (flockSize > 0) ? (totalFeedCost / flockSize) : 0.0;

    final double totalChickCost = flockSize * chickCostPerBird;
    final double totalOpsCost = flockSize * opsCostPerBird;
    final double totalProductionCost = totalFeedCost + totalChickCost + totalOpsCost;
    final double productionCostPerBird = (flockSize > 0) ? (totalProductionCost / flockSize) : 0.0;
    final double productionCostPerKg = (totalLiveWeightKg > 0) ? (totalProductionCost / totalLiveWeightKg) : 0.0;

    // Revenue & Margins
    final double totalRevenue = totalLiveWeightKg * liveRate;
    final double grossMarginOverFeed = totalRevenue - totalFeedCost;
    final double netProfit = totalRevenue - totalProductionCost;
    final double netProfitPerBird = (flockSize > 0) ? (netProfit / flockSize) : 0.0;
    final double roiPercentage = (totalProductionCost > 0) ? ((netProfit / totalProductionCost) * 100.0) : 0.0;

    // FCR Rating Classification
    Color fcrColor;
    String fcrBadgeText;
    String fcrDescription;

    if (fcr <= 0.0) {
      fcrColor = AppColors.textMutedLight;
      fcrBadgeText = isUrdu ? 'اعداد و شمار درج کریں' : 'Enter Metrics';
      fcrDescription = isUrdu ? 'حساب کتاب شروع کرنے کیلئے اوپر فارم پر کریں' : 'Fill metrics above to calculate FCR';
    } else if (fcr < 1.50) {
      fcrColor = AppColors.healthy;
      fcrBadgeText = isUrdu ? 'شاندار ایف سی آر (Exceptional)' : 'Exceptional Efficiency';
      fcrDescription = isUrdu
          ? 'بہترین فارم مینیجمنٹ۔ خوراک کا مکمل استعمال اور زبردست بچت۔'
          : 'Top-tier conversion efficiency. Maximum feed utilization.';
    } else if (fcr <= 1.65) {
      fcrColor = AppColors.primaryMedium;
      fcrBadgeText = isUrdu ? 'معیاری کمرشل شرح (Standard)' : 'Standard Commercial';
      fcrDescription = isUrdu
          ? 'کمرشل پولٹری کیلئے بہترین اور منافع بخش اوسط تناسب۔'
          : 'Optimal commercial target for profitable broiler production.';
    } else if (fcr <= 1.80) {
      fcrColor = AppColors.secondary;
      fcrBadgeText = isUrdu ? 'توجہ طلب شرح (Suboptimal)' : 'Suboptimal Efficiency';
      fcrDescription = isUrdu
          ? 'خوراک کا زیادہ ضیاع یا ہاضمے کی کمزوری۔ شیڈ کا ماحول اور فیڈرز چیک کریں۔'
          : 'Moderate feed loss. Inspect drinker leakage, enteritis, or feed spillage.';
    } else {
      fcrColor = AppColors.severe;
      fcrBadgeText = isUrdu ? 'شدید نقصان کا خطرہ (Critical)' : 'Critical Feed Loss';
      fcrDescription = isUrdu
          ? 'انتہائی ناقص ایف سی آر۔ غالباً کوکسیڈیوسس یا آنتوں کی بیماری کی علامت ہے۔'
          : 'High financial loss. Severe digestive distress or subclinical Coccidiosis likely.';
    }

    // Disease impact simulation (Coccidiosis +0.18 FCR penalty)
    final double coccidiosisExtraKg = totalLiveWeightKg * 0.18;
    final double coccidiosisFinancialLoss = coccidiosisExtraKg * costPerKgFeed;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isUrdu ? 'ایف سی آر و منافع کیلکولیٹر' : 'FCR & Economics Calculator',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.language_rounded),
            tooltip: isUrdu ? 'Switch to English' : 'اردو میں تبدیل کریں',
            onPressed: () {
              settings.setLocale(isUrdu ? 'en' : 'ur');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Formula Header Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF132D18) : const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.functions_rounded, color: AppColors.primary, size: 26),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isUrdu ? 'فارمولا: کل خوراک (کلوگرام) ÷ کل وزنی پیداوار (کلوگرام)' : 'Formula: Total Feed (kg) ÷ Total Weight Gain (kg)',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.primary),
                        ),
                        Text(
                          isUrdu
                              ? 'کم ایف سی آر کا مطلب کم خوراک میں زیادہ گوشت کی پیداوار اور زیادہ منافع ہے۔'
                              : 'Lower FCR indicates superior feed conversion and higher farm profits.',
                          style: TextStyle(fontSize: 11.5, color: isDark ? Colors.white70 : AppColors.textSecondaryLight),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.space16),

            // 2. HERO FCR RESULT CARD
            AppCard(
              padding: const EdgeInsets.all(20),
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              border: BorderSide(color: fcrColor.withValues(alpha: 0.4), width: 1.5),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          isUrdu ? 'حاصل شدہ ایف سی آر (FCR)' : 'Flock Feed Conversion Ratio',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: fcrColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            fcrBadgeText,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: fcrColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          fcr > 0 ? fcr.toStringAsFixed(3) : '0.00',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                            color: fcrColor,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isUrdu ? 'تناسب' : 'ratio',
                          style: const TextStyle(fontSize: 14, color: AppColors.textMutedLight, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    fcrDescription,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // FCR Spectrum Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: (fcr > 0) ? ((fcr - 1.20) / (2.20 - 1.20)).clamp(0.05, 1.0) : 0.0,
                      minHeight: 8,
                      backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      valueColor: AlwaysStoppedAnimation<Color>(fcrColor),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(child: Text('1.30 (Ideal)', style: TextStyle(fontSize: 10, color: AppColors.healthy, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
                      Flexible(child: Text('1.55 (Standard)', style: TextStyle(fontSize: 10, color: AppColors.primaryMedium, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
                      Flexible(child: Text('1.80+ (Critical)', style: TextStyle(fontSize: 10, color: AppColors.severe, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.space16),

            // 3. Quick Presets Toolbar
            Row(
              children: [
                Text(
                  isUrdu ? 'فوری فلاک پری سیٹس:' : 'Quick Presets:',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(right: 16),
                    child: Row(
                      children: [
                        _buildPresetChip(
                          label: isUrdu ? 'معیاری (2000 پرندے)' : 'Standard (2K)',
                          onTap: () => _applyPreset(
                            flockSize: 2000,
                            avgWeight: 2.05,
                            feedBags: 124,
                            bagPrice: 7200,
                            liveRate: 420,
                          ),
                        ),
                        const SizedBox(width: 6),
                        _buildPresetChip(
                          label: isUrdu ? 'کمرشل (5000 پرندے)' : 'Commercial (5K)',
                          onTap: () => _applyPreset(
                            flockSize: 5000,
                            avgWeight: 2.15,
                            feedBags: 330,
                            bagPrice: 7200,
                            liveRate: 420,
                          ),
                        ),
                        const SizedBox(width: 6),
                        _buildPresetChip(
                          label: isUrdu ? 'متاثرہ فلاک' : 'Infected',
                          onTap: () => _applyPreset(
                            flockSize: 2000,
                            avgWeight: 1.85,
                            feedBags: 132,
                            bagPrice: 7200,
                            liveRate: 410,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.space16),

            // 4. INPUT SECTION: Biological & Feed Metrics
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.egg_alt_outlined, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isUrdu ? 'پرندوں اور خوراک کے اعداد و شمار' : 'Flock & Feed Metrics',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Flock Size & Avg Weight
                  Row(
                    children: [
                      Expanded(
                        child: _buildInputField(
                          controller: _flockSizeController,
                          label: isUrdu ? 'پرندوں کی تعداد' : 'Total Birds',
                          hint: '2000',
                          icon: Icons.groups_outlined,
                          isInteger: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInputField(
                          controller: _avgWeightController,
                          label: isUrdu ? 'اوسط وزن (کلوگرام)' : 'Avg Weight (kg)',
                          hint: '2.05',
                          icon: Icons.scale_outlined,
                          isInteger: false,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Feed Consumed with Unit Switcher
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        flex: 3,
                        child: _buildInputField(
                          controller: _feedConsumedController,
                          label: isUrdu
                              ? (_isFeedInBags ? 'کل فیڈ (50 کلو کی بوریاں)' : 'کل فیڈ (کلوگرام)')
                              : (_isFeedInBags ? 'Total Feed (50kg Bags)' : 'Total Feed (kg)'),
                          hint: _isFeedInBags ? '124' : '6200',
                          icon: Icons.inventory_2_outlined,
                          isInteger: false,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 2.0),
                          child: OutlinedButton(
                            onPressed: _toggleFeedUnit,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                _isFeedInBags ? (isUrdu ? 'کلوگرام میں بدلیں' : 'Switch to Kg') : (isUrdu ? 'بوریوں میں بدلیں' : 'Switch to Bags'),
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.space16),

            // 5. INPUT SECTION: Commercial Pricing & Economics
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.attach_money_rounded, color: AppColors.secondary, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isUrdu ? 'مارکیٹ ریٹس و اخراجات' : 'Market Rates & Pricing',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: _buildInputField(
                          controller: _feedBagPriceController,
                          label: isUrdu ? 'بوری قیمت (PKR)' : 'Feed Bag (PKR)',
                          hint: '7200',
                          icon: Icons.price_change_outlined,
                          isInteger: false,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInputField(
                          controller: _liveSellingRateController,
                          label: isUrdu ? 'زندہ ریٹ (PKR/kg)' : 'Selling Rate (PKR/kg)',
                          hint: '420',
                          icon: Icons.trending_up_rounded,
                          isInteger: false,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Toggle Advanced Costs
                  InkWell(
                    onTap: () {
                      setState(() {
                        _showAdvancedCosts = !_showAdvancedCosts;
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Icon(
                            _showAdvancedCosts ? Icons.arrow_drop_down_rounded : Icons.arrow_right_rounded,
                            color: AppColors.primary,
                          ),
                          Expanded(
                            child: Text(
                              isUrdu ? 'چوزہ خریداری و اضافی اخراجات (اختیاری)' : 'Chick & Health Costs (Optional)',
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (_showAdvancedCosts) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInputField(
                            controller: _chickPriceController,
                            label: isUrdu ? 'چوزہ قیمت (فی چوزہ)' : 'Day-Old Chick (DOC)',
                            hint: '85',
                            icon: Icons.cruelty_free_outlined,
                            isInteger: false,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildInputField(
                            controller: _operationalCostController,
                            label: isUrdu ? 'ادویات و شیڈ خرچ (فی برڈ)' : 'Meds & Utilities / Bird',
                            hint: '35',
                            icon: Icons.medical_services_outlined,
                            isInteger: false,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.space16),

            // 6. TECHNICAL PRODUCTION VITALS (2x2 Grid)
            Row(
              children: [
                Expanded(
                  child: _buildResultTile(
                    label: isUrdu ? 'کل وزنی پیداوار' : 'Total Weight Gain',
                    value: '${totalLiveWeightKg.toStringAsFixed(0)} kg',
                    subtext: isUrdu ? 'زندہ پرندوں کا مجموعی وزن' : 'Total flock biomass',
                    icon: Icons.scale_rounded,
                    accentColor: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildResultTile(
                    label: isUrdu ? 'خوراک فی پرندہ' : 'Feed / Bird',
                    value: '${feedPerBirdKg.toStringAsFixed(2)} kg',
                    subtext: isUrdu
                        ? 'کل شیڈ: ${totalFeedBags.toStringAsFixed(0)} بوری'
                        : 'Flock total: ${totalFeedBags.toStringAsFixed(0)} bags',
                    icon: Icons.inventory_2_rounded,
                    accentColor: AppColors.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildResultTile(
                    label: isUrdu ? 'فی کلو گوشت پر فیڈ خرچہ' : 'Feed Cost / kg Meat',
                    value: 'Rs. ${feedCostPerKgMeat.toStringAsFixed(1)}',
                    subtext: isUrdu ? 'فی پرندہ فیڈ: Rs. ${feedCostPerBird.toStringAsFixed(0)}' : 'Per bird feed: Rs. ${feedCostPerBird.toStringAsFixed(0)}',
                    icon: Icons.calculate_rounded,
                    accentColor: const Color(0xFF0284C7),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildResultTile(
                    label: isUrdu ? 'کل پیداواری لاگت فی کلو' : 'Cost of Prod. / kg',
                    value: 'Rs. ${productionCostPerKg.toStringAsFixed(1)}',
                    subtext: isUrdu ? 'فی پرندہ کل لاگت: Rs. ${productionCostPerBird.toStringAsFixed(0)}' : 'Total cost / bird: Rs. ${productionCostPerBird.toStringAsFixed(0)}',
                    icon: Icons.account_balance_wallet_rounded,
                    accentColor: const Color(0xFF8B5CF6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.space16),

            // 7. FINANCIAL ECONOMICS & PROFITABILITY BREAKDOWN
            AppCard(
              padding: const EdgeInsets.all(18),
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              border: BorderSide(
                color: netProfit >= 0 ? AppColors.healthy.withValues(alpha: 0.5) : AppColors.severe.withValues(alpha: 0.5),
                width: 1.5,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        netProfit >= 0 ? Icons.monetization_on_rounded : Icons.money_off_rounded,
                        color: netProfit >= 0 ? AppColors.healthy : AppColors.severe,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isUrdu ? 'مالیاتی منافع و آمدنی کا تجزیہ' : 'Commercial Economics & Profitability',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  _buildFinancialRow(
                    label: isUrdu ? 'کل متوقع آمدنی (Total Revenue)' : 'Total Expected Revenue',
                    value: 'Rs. ${_formatCurrency(totalRevenue)}',
                    isBold: false,
                  ),
                  const SizedBox(height: 8),
                  _buildFinancialRow(
                    label: isUrdu ? 'کل خوراک کا خرچ (Feed Cost)' : 'Total Feed Expenditure',
                    value: '- Rs. ${_formatCurrency(totalFeedCost)}',
                    isBold: false,
                    valueColor: isDark ? Colors.white70 : AppColors.textSecondaryLight,
                  ),
                  const SizedBox(height: 8),
                  _buildFinancialRow(
                    label: isUrdu ? 'خوراک نکال کر بچت (Gross Margin)' : 'Gross Margin Over Feed',
                    value: 'Rs. ${_formatCurrency(grossMarginOverFeed)}',
                    isBold: true,
                    valueColor: AppColors.primary,
                  ),

                  if (totalChickCost > 0 || totalOpsCost > 0) ...[
                    const SizedBox(height: 8),
                    _buildFinancialRow(
                      label: isUrdu ? 'چوزہ اور نگہداشت خرچ' : 'Chick & Operational Cost',
                      value: '- Rs. ${_formatCurrency(totalChickCost + totalOpsCost)}',
                      isBold: false,
                      valueColor: isDark ? Colors.white70 : AppColors.textSecondaryLight,
                    ),
                  ],

                  const Divider(height: 24),

                  // Net Profit Highlight Box
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: netProfit >= 0
                          ? (isDark ? const Color(0xFF132D18) : const Color(0xFFDCFCE7))
                          : (isDark ? const Color(0xFF2D1515) : const Color(0xFFFEE2E2)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                isUrdu ? 'فلاک کا خالص منافع (Net Profit)' : 'Flock Net Profit',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  color: netProfit >= 0 ? AppColors.healthy : AppColors.severe,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${netProfit >= 0 ? "+ " : "- "}Rs. ${_formatCurrency(netProfit.abs())}',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                color: netProfit >= 0 ? AppColors.healthy : AppColors.severe,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                isUrdu ? 'خالص منافع فی پرندہ' : 'Net Profit / Bird',
                                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${netProfitPerBird >= 0 ? "+" : "-"} Rs. ${netProfitPerBird.abs().toStringAsFixed(1)} / bird',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: netProfitPerBird >= 0 ? AppColors.healthy : AppColors.severe,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                isUrdu ? 'سرمایہ کاری پر منافع (ROI)' : 'Return on Investment (ROI)',
                                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${roiPercentage.toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: roiPercentage >= 0 ? AppColors.healthy : AppColors.severe,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.space16),

            // 8. CLINICAL DISEASE IMPACT SIMULATOR (Connecting FCR to AI Scanner)
            AppCard(
              padding: const EdgeInsets.all(16),
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFBEB),
              border: BorderSide(color: AppColors.secondary.withValues(alpha: 0.5)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.coronavirus_outlined, color: AppColors.secondary, size: 22),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isUrdu ? 'کوکسیڈیوسس اور بیماری کا ایف سی آر پر اثر' : 'Clinical Coccidiosis Impact on FCR',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5, color: AppColors.secondary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isUrdu
                        ? 'آنتوں کے انفیکشن (جیسے کوکسیڈیوسس) کی وجہ سے خوراک ہضم نہیں ہوتی اور ایف سی آر 0.15 سے 0.25 تک بگڑ جاتا ہے۔'
                        : 'Intestinal infections (such as Coccidiosis) damage gut villi, degrading FCR by +0.15 to +0.25 points.',
                    style: const TextStyle(fontSize: 12.5, height: 1.35),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF382305) : const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: AppColors.secondary, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isUrdu
                                ? 'آپ کے $flockSize پرندوں پر 0.18 ایف سی آر خرابی کا مطلب ہے ${coccidiosisExtraKg.toStringAsFixed(0)} کلوگرام اضافی ضائع خوراک جس سے Rs. ${_formatCurrency(coccidiosisFinancialLoss)} کا مالی نقصان ہوتا ہے۔'
                                : 'On your $flockSize birds, an FCR penalty of +0.18 consumes ${coccidiosisExtraKg.toStringAsFixed(0)} kg extra feed costing Rs. ${_formatCurrency(coccidiosisFinancialLoss)} in avoidable loss.',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  CustomButton(
                    text: isUrdu ? 'بیٹھ کا AI اسکین کریں (کوکسیڈیوسس چیک کریں)' : 'Scan Fecal Specimen for Coccidiosis',
                    icon: Icons.camera_enhance_rounded,
                    variant: ButtonVariant.outlined,
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.scanner);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.space20),

            // 9. Action Buttons
            CustomButton(
              text: isUrdu ? 'خلاصہ کاپی کریں (شیئر فارم منیجر)' : 'Copy Calculation Summary',
              icon: Icons.copy_rounded,
              variant: ButtonVariant.secondary,
              onPressed: () {
                final summary = '''PoultryCare FCR & Economics Summary:
Flock Size: $flockSize birds
Avg Weight: $avgWeight kg
Total Live Biomass: ${totalLiveWeightKg.toStringAsFixed(0)} kg
Feed Consumed: ${totalFeedKg.toStringAsFixed(0)} kg (${totalFeedBags.toStringAsFixed(1)} bags)
FCR: ${fcr.toStringAsFixed(3)} ($fcrBadgeText)
Feed Cost / kg Meat: Rs. ${feedCostPerKgMeat.toStringAsFixed(1)}
Expected Revenue: Rs. ${_formatCurrency(totalRevenue)}
Total Production Cost: Rs. ${_formatCurrency(totalProductionCost)}
Net Profit: Rs. ${_formatCurrency(netProfit)} (Rs. ${netProfitPerBird.toStringAsFixed(1)}/bird)
ROI: ${roiPercentage.toStringAsFixed(1)}%''';
                Clipboard.setData(ClipboardData(text: summary));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isUrdu ? 'ایف سی آر اور مالیاتی رپورٹ کاپی ہو گئی ہے' : 'Calculation summary copied to clipboard',
                    ),
                    backgroundColor: AppColors.primary,
                  ),
                );
              },
            ),
            const SizedBox(height: AppDimensions.space24),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetChip({required String label, required VoidCallback onTap}) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
      side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
      onPressed: onTap,
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isInteger,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: !isInteger),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 18),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        isDense: true,
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildResultTile({
    required String label,
    required String value,
    required String subtext,
    required IconData icon,
    required Color accentColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: accentColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: accentColor,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtext,
            style: const TextStyle(fontSize: 10.5, color: AppColors.textMutedLight),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialRow({
    required String label,
    required String value,
    required bool isBold,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 10000000) {
      return '${(amount / 10000000).toStringAsFixed(2)} Cr';
    } else if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(2)} Lakh';
    } else {
      return amount.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
          );
    }
  }
}
