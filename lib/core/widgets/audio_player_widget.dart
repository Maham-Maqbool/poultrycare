import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../services/disease_audio_service.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../utils/bidi_utils.dart';
import 'status_badge.dart';

/// AudioPlayerWidget provides dynamic, disease-specific spoken voice narration
/// and script mapping for rural and low-literacy poultry farmers in English and Urdu.
/// Automatically resolves dedicated audio profiles, clinical symptoms, and veterinary treatments
/// for all 4 classes: Coccidiosis, Newcastle Disease, Salmonella, and Healthy.
class AudioPlayerWidget extends StatefulWidget {
  final String title;
  final String durationText;
  final bool isUrdu;
  final String? diseaseName;
  final String? severity;
  final String? urgency;
  final double? confidenceScore;
  final List<String>? medications;
  final List<String>? careSteps;
  final String? customScript;

  const AudioPlayerWidget({
    super.key,
    required this.title,
    this.durationText = '1:15',
    this.isUrdu = false,
    this.diseaseName,
    this.severity,
    this.urgency,
    this.confidenceScore,
    this.medications,
    this.careSteps,
    this.customScript,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget>
    with SingleTickerProviderStateMixin {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isPlaying = false;
  double _progress = 0.0;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
      await _flutterTts.setSpeechRate(0.46);

      _flutterTts.setStartHandler(() {
        if (mounted) {
          setState(() {
            _isPlaying = true;
            _animController.repeat(reverse: true);
          });
        }
      });

      _flutterTts.setCompletionHandler(() {
        if (mounted) {
          setState(() {
            _isPlaying = false;
            _progress = 1.0;
            _animController.stop();
          });
        }
      });

      _flutterTts.setCancelHandler(() {
        if (mounted) {
          setState(() {
            _isPlaying = false;
            _animController.stop();
          });
        }
      });

      _flutterTts.setProgressHandler((String text, int startOffset, int endOffset, String word) {
        if (mounted && text.isNotEmpty) {
          setState(() {
            _progress = (endOffset / text.length).clamp(0.0, 1.0);
          });
        }
      });

      _flutterTts.setErrorHandler((dynamic message) {
        debugPrint('[AudioPlayerWidget] TTS Error: $message');
        if (mounted) {
          setState(() {
            _isPlaying = false;
            _animController.stop();
          });
        }
      });
    } catch (e) {
      debugPrint('[AudioPlayerWidget] TTS Init: $e');
    }
  }

  @override
  void dispose() {
    try {
      _flutterTts.stop();
    } catch (_) {}
    _animController.dispose();
    super.dispose();
  }

  /// Retrieves the active DiseaseAudioProfile based on the predicted class.
  DiseaseAudioProfile _getProfile() {
    return DiseaseAudioService.getProfile(
      widget.diseaseName,
      severity: widget.severity,
      confidenceScore: widget.confidenceScore,
    );
  }

  /// Synthesizes the spoken text script tailored to the disease.
  String _getSpokenScript() {
    if (widget.customScript != null && widget.customScript!.trim().isNotEmpty) {
      return widget.customScript!;
    }

    final profile = _getProfile();
    return profile.buildSpokenScript(
      isUrdu: widget.isUrdu,
      severity: widget.severity,
      confidenceScore: widget.confidenceScore,
    );
  }

  Future<void> _togglePlay() async {
    if (_isPlaying) {
      try {
        await _flutterTts.stop();
      } catch (_) {}
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _animController.stop();
        });
      }
    } else {
      final script = _getSpokenScript();
      final profile = _getProfile();
      try {
        if (widget.isUrdu) {
          bool urduAvailable = false;
          try {
            final isPk = await _flutterTts.isLanguageAvailable('ur-PK');
            final isUr = await _flutterTts.isLanguageAvailable('ur');
            if (isPk == true || isPk == 1) {
              await _flutterTts.setLanguage('ur-PK');
              urduAvailable = true;
            } else if (isUr == true || isUr == 1) {
              await _flutterTts.setLanguage('ur');
              urduAvailable = true;
            }
          } catch (_) {}

          try {
            final List<dynamic>? voices = await _flutterTts.getVoices;
            if (voices != null) {
              for (final v in voices) {
                if (v is Map) {
                  final loc = v['locale']?.toString().toLowerCase() ?? '';
                  if (loc.contains('ur') || loc.contains('pk')) {
                    await _flutterTts.setVoice({'name': v['name']?.toString() ?? '', 'locale': v['locale']});
                    urduAvailable = true;
                    break;
                  }
                }
              }
            }
          } catch (_) {}

          if (!urduAvailable) {
            final dynamic langRes = await _flutterTts.setLanguage('ur-PK');
            if (langRes == 0) {
              await _flutterTts.setLanguage('ur');
            }
          }
        } else {
          await _flutterTts.setLanguage('en-US');
        }
        await _flutterTts.setSpeechRate(0.46);
        await _flutterTts.setVolume(1.0);
        await _flutterTts.setPitch(1.0);

        await _flutterTts.speak(script);
        if (mounted) {
          setState(() {
            _isPlaying = true;
            _progress = 0.05;
            _animController.repeat(reverse: true);
          });
        }
      } catch (e) {
        debugPrint('[AudioPlayerWidget] TTS speak error: $e');
        if (mounted) {
          setState(() {
            _isPlaying = false;
            _progress = 0.0;
            _animController.stop();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.isUrdu
                    ? 'آڈیو چلانے میں مسئلہ پیش آیا۔ فون میں اردو آواز چیک کریں۔'
                    : 'Audio narration could not be played.',
              ),
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      if (mounted) {
        final diseaseTitle = widget.isUrdu ? profile.urduName : profile.canonicalName;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isPlaying
                  ? (widget.isUrdu
                      ? '$diseaseTitle: صوتی رہنمائی اور آڈیو ہدایات چل رہی ہیں...'
                      : 'Playing audio narration for $diseaseTitle...')
                  : (widget.isUrdu ? 'آڈیو رہنمائی روک دی گئی' : 'Voice guide paused'),
            ),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final profile = _getProfile();
    final script = _getSpokenScript();

    return Container(
      padding: const EdgeInsets.all(AppDimensions.space12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF132D18) : AppColors.primaryContainerLight,
        borderRadius: AppDimensions.borderRadiusLarge,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Audio Player Controls Header
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary,
                child: IconButton(
                  icon: Icon(
                    _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                  onPressed: _togglePlay,
                ),
              ),
              const SizedBox(width: AppDimensions.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            widget.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: isDark ? Colors.white : AppColors.primary,
                            ),
                          ),
                        ),
                        Text(
                          _isPlaying ? BidiUtils.ltr('0:25 / ${widget.durationText}') : BidiUtils.ltr(widget.durationText),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: _isPlaying ? _progress : 0.0,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                      minHeight: 5,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.space8),
              IconButton(
                icon: Icon(
                  _isPlaying ? Icons.volume_up_rounded : Icons.volume_up_outlined,
                  size: AppDimensions.iconMedium,
                  color: AppColors.primary,
                ),
                onPressed: _togglePlay,
              ),
            ],
          ),

          // Synchronized Spoken Voice Script Narration Card
          if (_isPlaying || widget.diseaseName != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.25),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Disease Header Banner
                  Row(
                    children: [
                      Icon(
                        Icons.record_voice_over_rounded,
                        size: 18,
                        color: _isPlaying ? AppColors.healthy : AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.isUrdu
                              ? '${profile.urduName} (صوتی رہنمائی)'
                              : '${profile.canonicalName} (Audio Guide)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : AppColors.primary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (_isPlaying)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.healthy.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            widget.isUrdu ? 'آواز جاری ہے' : 'Speaking',
                            style: const TextStyle(
                              color: AppColors.healthy,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),

                  // Status Badges & Confidence Pill
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      StatusBadge.forDisease(profile.canonicalName),
                      if (widget.severity != null)
                        StatusBadge.forSeverity(widget.severity),
                      if (widget.confidenceScore != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0F172A) : AppColors.primaryContainerLight,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            '${BidiUtils.ltr('${(widget.confidenceScore! * 100).toStringAsFixed(1)}%')} ${widget.isUrdu ? 'یقینی' : 'Confidence'}',
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      // Audio asset / stream indicator badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.record_voice_over_rounded, size: 12, color: AppColors.secondary),
                            const SizedBox(width: 4),
                            Text(
                              widget.isUrdu ? 'صوتی رہنمائی' : 'HD Voice Guide',
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Dedicated Clinical Symptoms Box
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.medical_information_outlined, size: 16, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Text(
                              widget.isUrdu ? 'اہم علامات (Symptoms):' : 'Key Symptoms:',
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.isUrdu ? profile.symptomsUrdu : profile.symptomsEn,
                          style: TextStyle(
                            fontSize: 12.5,
                            height: 1.4,
                            color: isDark ? Colors.white70 : const Color(0xFF334155),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Dedicated Treatment & Care Box
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.healthy.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.healing_outlined, size: 16, color: AppColors.healthy),
                            const SizedBox(width: 6),
                            Text(
                              widget.isUrdu ? 'تجویز کردہ علاج (Treatment Protocol):' : 'Treatment Protocol:',
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppColors.healthy),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.isUrdu ? profile.treatmentUrdu : profile.treatmentEn,
                          style: TextStyle(
                            fontSize: 12.5,
                            height: 1.4,
                            color: isDark ? Colors.white70 : const Color(0xFF14532D),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Full Spoken Script Section
                  const SizedBox(height: 10),
                  Text(
                    widget.isUrdu ? 'آڈیو رہنمائی کا متن (Voice Script):' : 'Spoken Voice Script:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    script,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.45,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF1F2937),
                    ),
                  ),

                  // Key Prescribed Medications Pills
                  if (profile.medicationsUrdu.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      widget.isUrdu ? 'تجویز کردہ ادویات (Medicines):' : 'Key Medications:',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ...(widget.isUrdu ? profile.medicationsUrdu : profile.medicationsEn).map(
                      (med) => Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 2.0),
                              child: Icon(Icons.check_circle_outline, size: 14, color: AppColors.primary),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                med,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.white70 : const Color(0xFF334155),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
