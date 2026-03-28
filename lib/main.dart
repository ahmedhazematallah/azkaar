import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:ui';
import 'data/azkar_data.dart' as data;
import 'data/azkar_data.dart' show Zikr;

void main() {
  runApp(const ScrollAzkaarApp());
}

class ScrollAzkaarApp extends StatelessWidget {
  const ScrollAzkaarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scroll Azkaar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF064D3B),
          brightness: Brightness.dark,
        ),
      ),
      home: const AzkarFeedPage(),
    );
  }
}

class AzkarFeedPage extends StatefulWidget {
  const AzkarFeedPage({super.key});

  @override
  State<AzkarFeedPage> createState() => _AzkarFeedPageState();
}

class _AzkarFeedPageState extends State<AzkarFeedPage> {
  final PageController _pageController = PageController();
  double _baseFontSize = 26.0;
  bool _showCounter = false; // Default OFF as requested
  String _language = 'Arabic';
  late bool _isMorning;
  
  final Map<int, bool> _completedZikrs = {};
  bool _isScrollingToStart = false;
  int _resetVersion = 0;

  List<Zikr> get _filteredAzkar {
    return data.azkarList.where((z) {
      if (z.timeOfDay == data.TimeOfDay.both) return true;
      if (_isMorning && z.timeOfDay == data.TimeOfDay.morning) return true;
      if (!_isMorning && z.timeOfDay == data.TimeOfDay.evening) return true;
      return false;
    }).toList();
  }

  final Map<String, Map<String, String>> _translations = {
    'Arabic': {
      'settings': 'الإعدادات',
      'enable_counter': 'تفعيل العداد',
      'counter_desc': 'إذا تم إيقافه، سيتم اعتبار الذكر مكتملاً بمجرد التمرير',
      'language': 'اللغة',
      'back_to_start': 'العودة للبداية',
      'done': 'تم الانتهاء من هذا الذكر',
      'app_title': 'Scroll Azkaar',
      'about': 'حول التطبيق',
      'version': 'الإصدار',
      'about_desc': 'تطبيق أذكار المسلم اليومية',
      'developer': 'المطور',
    },
    'English': {
      'settings': 'Settings',
      'enable_counter': 'Enable Counter',
      'counter_desc': 'If disabled, zikr is marked done by scrolling',
      'language': 'Language',
      'back_to_start': 'Back to Start',
      'done': 'Zikr Completed',
      'app_title': 'Scroll Azkaar',
      'about': 'About',
      'version': 'Version',
      'about_desc': 'Daily Muslim Azkar App',
      'developer': 'Developer',
    },
    'French': {
      'settings': 'Paramètres',
      'enable_counter': 'Activer le compteur',
      'counter_desc': 'Si désactivé, le zikr est marqué comme terminé par défilement',
      'language': 'Langue',
      'back_to_start': 'Retour au début',
      'done': 'Zikr terminé',
      'app_title': 'Scroll Azkaar',
      'about': 'À propos',
      'version': 'Version',
      'about_desc': 'Application quotidienne d\'Azkar musulman',
      'developer': 'Développeur',
    },
    'German': {
      'settings': 'Einstellungen',
      'enable_counter': 'Zähler aktivieren',
      'counter_desc': 'Wenn deaktiviert, wird Zikr durch Scrollen als erledigt markiert',
      'language': 'Sprache',
      'back_to_start': 'Zurück zum Anfang',
      'done': 'Zikr abgeschlossen',
      'app_title': 'Scroll Azkaar',
      'about': 'Über',
      'version': 'Version',
      'about_desc': 'Tägliche muslimische Azkar-App',
      'developer': 'Entwickler',
    },
    'Japanese': {
      'settings': '設定',
      'enable_counter': 'カウンターを有効にする',
      'counter_desc': '無効な場合、スクロールで完了と見なされます',
      'language': '言語',
      'back_to_start': '最初に戻る',
      'done': '完了しました',
      'app_title': 'Scroll Azkaar',
      'about': 'について',
      'version': 'バージョン',
      'about_desc': '毎日のイスラム教のアズカールアプリ',
      'developer': '開発者',
    },
    'Chinese': {
      'settings': '设置',
      'enable_counter': '启用计数器',
      'counter_desc': '如果禁用，滑动将被视为完成',
      'language': '语言',
      'back_to_start': '回到开始',
      'done': '已完成',
      'app_title': 'Scroll Azkaar',
      'about': '关于',
      'version': '版本',
      'about_desc': '每日穆斯林阿兹卡尔应用',
      'developer': '开发者',
    },
  };

  @override
  void initState() {
    super.initState();
    final hour = DateTime.now().hour;
    _isMorning = hour < 12; // midnight to noon = morning
    _loadSettings();
    _pageController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _pageController.removeListener(_handleScroll);
    _pageController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_showCounter && !_isScrollingToStart) {
      int currentPage = _pageController.page?.round() ?? 0;
      if (!_completedZikrs.containsKey(currentPage) || _completedZikrs[currentPage] == false) {
        setState(() {
          _completedZikrs[currentPage] = true;
        });
      }
    }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _baseFontSize = prefs.getDouble('font_size') ?? 26.0;
      _showCounter = prefs.getBool('show_counter') ?? false;
      _language = prefs.getString('language') ?? 'Arabic';
    });
  }

  Future<void> _saveFontSize(double size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('font_size', size);
  }

  Future<void> _saveCounterSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_counter', value);
  }

  Future<void> _saveLanguageSetting(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', value);
  }

  void _increaseFontSize() {
    setState(() {
      if (_baseFontSize < 40.0) {
        _baseFontSize += 2;
        _saveFontSize(_baseFontSize);
      }
    });
  }

  void _decreaseFontSize() {
    setState(() {
      if (_baseFontSize > 18.0) {
        _baseFontSize -= 2;
        _saveFontSize(_baseFontSize);
      }
    });
  }

  void _scrollToStart() {
    setState(() {
      _isScrollingToStart = true;
      _completedZikrs.clear();
      _resetVersion++;
    });
    _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeInOutExpo,
    ).then((_) {
      if (mounted) {
        setState(() {
          _isScrollingToStart = false;
          // Mark the first page as done if counter is off
          if (!_showCounter) {
            _completedZikrs[0] = true;
          }
        });
      }
    });
  }

  void _markAsDone(int index) {
    setState(() {
      _completedZikrs[index] = true;
    });
  }

  void _toggleTimeOfDay() {
    setState(() {
      _isMorning = !_isMorning;
      _completedZikrs.clear();
      _resetVersion++;
      _pageController.jumpToPage(0);
    });
  }

  String t(String key) => _translations[_language]?[key] ?? key;

  void _openMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const SizedBox(height: 10),
                      ExpansionTile(
                        leading: const Icon(Icons.settings, color: Color(0xFFC5A358)),
                        title: Text(t('settings'), style: GoogleFonts.amiri(color: Colors.white, fontSize: 18)),
                        iconColor: const Color(0xFFC5A358),
                        collapsedIconColor: Colors.white70,
                        children: [
                          SwitchListTile(
                            title: Text(t('enable_counter'), style: GoogleFonts.amiri(color: Colors.white)),
                            subtitle: Text(t('counter_desc'), style: GoogleFonts.amiri(color: Colors.white54, fontSize: 12)),
                            value: _showCounter,
                            activeColor: const Color(0xFFC5A358),
                            onChanged: (val) {
                              setModalState(() => _showCounter = val);
                              setState(() => _showCounter = val);
                              _saveCounterSetting(val);
                              if (!val) {
                                 _markAsDone(_pageController.page?.round() ?? 0);
                              }
                            },
                          ),
                          ListTile(
                            title: Text(t('language'), style: GoogleFonts.amiri(color: Colors.white)),
                            trailing: DropdownButton<String>(
                              value: _language,
                              dropdownColor: Colors.black87,
                              underline: Container(),
                              items: _translations.keys.map((String lang) {
                                return DropdownMenuItem<String>(
                                  value: lang,
                                  child: Text(lang, style: const TextStyle(color: Colors.white, fontSize: 14)),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setModalState(() => _language = newValue);
                                  setState(() => _language = newValue);
                                  _saveLanguageSetting(newValue);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ListTile(
                        leading: const Icon(Icons.info_outline, color: Color(0xFFC5A358)),
                        title: Text(t('about'), style: GoogleFonts.amiri(color: Colors.white, fontSize: 18)),
                        onTap: () {
                          Navigator.pop(context);
                          _openAbout();
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openAbout() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF064D3B), Color(0xFF0A7D60)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF064D3B).withOpacity(0.5),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.mosque_rounded,
                        color: Color(0xFFC5A358),
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      t('app_title'),
                      style: GoogleFonts.amiri(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      t('about_desc'),
                      style: GoogleFonts.amiri(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${t('version')}: ',
                            style: GoogleFonts.amiri(
                              fontSize: 16,
                              color: Colors.white54,
                            ),
                          ),
                          Text(
                            packageInfo.version,
                            style: GoogleFonts.amiri(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFC5A358),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        '✕',
                        style: GoogleFonts.amiri(
                          fontSize: 20,
                          color: Colors.white54,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  double _getCompletionPercentage() {
    int total = _filteredAzkar.length;
    int completed = _completedZikrs.values.where((v) => v).length;
    return total > 0 ? (completed / total) : 0;
  }

  @override
  Widget build(BuildContext context) {
    double completion = _getCompletionPercentage();
    
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.4),
            ),
          ),
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: _filteredAzkar.length,
            itemBuilder: (context, index) {
              final filtered = _filteredAzkar;
              return AzkarCard(
                key: ValueKey('zikr_${index}_$_resetVersion'),
                zikr: filtered[index],
                fontSize: _baseFontSize,
                index: index + 1,
                total: filtered.length,
                showCounter: _showCounter,
                onDone: () => _markAsDone(index),
                onScrollToStart: index == filtered.length - 1 ? _scrollToStart : null,
                backToStartLabel: t('back_to_start'),
                doneMessage: t('done'),
                categoryLabel: _isMorning ? 'أذكار الصباح' : 'أذكار المساء',
              );
            },
          ),
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: _toggleTimeOfDay,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOutCubic,
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: _isMorning
                            ? [const Color(0xFFF5C842), const Color(0xFFE8A317)]
                            : [const Color(0xFF1A237E), const Color(0xFF283593)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _isMorning
                              ? const Color(0xFFF5C842).withOpacity(0.5)
                              : const Color(0xFF1A237E).withOpacity(0.5),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      transitionBuilder: (child, anim) => RotationTransition(
                        turns: Tween(begin: 0.5, end: 1.0).animate(anim),
                        child: FadeTransition(opacity: anim, child: child),
                      ),
                      child: Icon(
                        _isMorning ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                        key: ValueKey(_isMorning),
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ).animate().scale().fadeIn(),
                
                Text(
                  t('app_title'),
                  style: GoogleFonts.amiri(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      const Shadow(
                        blurRadius: 10.0,
                        color: Colors.black54,
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 800.ms).slideY(begin: -0.5, end: 0),
                
                IconButton(
                  onPressed: _openMenu,
                  icon: const Icon(Icons.menu_rounded, color: Colors.white70, size: 28),
                ).animate().fadeIn(),
              ],
            ),
          ),
          Positioned(
            left: 20,
            bottom: 40,
            child: SizedBox(
              width: 50,
              height: 50,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 0,
                  centerSpaceRadius: 15,
                  sections: [
                    PieChartSectionData(
                      color: const Color(0xFFC5A358),
                      value: completion * 100,
                      title: '',
                      radius: 8,
                    ),
                    PieChartSectionData(
                      color: Colors.white12,
                      value: (1 - completion) * 100,
                      title: '',
                      radius: 8,
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 1.seconds).slideX(begin: -1, end: 0),
          ),
          Positioned(
            right: 20,
            bottom: 40,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: 'inc',
                  onPressed: _increaseFontSize,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
                const SizedBox(height: 12),
                FloatingActionButton.small(
                  heroTag: 'dec',
                  onPressed: _decreaseFontSize,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: const Icon(Icons.remove, color: Colors.white),
                ),
              ],
            ).animate().fadeIn(delay: 1.seconds).slideX(begin: 1, end: 0),
          ),
        ],
      ),
    );
  }
}

class AzkarCard extends StatefulWidget {
  final Zikr zikr;
  final double fontSize;
  final int index;
  final int total;
  final bool showCounter;
  final VoidCallback onDone;
  final VoidCallback? onScrollToStart;
  final String backToStartLabel;
  final String doneMessage;
  final String categoryLabel;

  const AzkarCard({
    super.key,
    required this.zikr,
    required this.fontSize,
    required this.index,
    required this.total,
    required this.showCounter,
    required this.onDone,
    this.onScrollToStart,
    required this.backToStartLabel,
    required this.doneMessage,
    required this.categoryLabel,
  });

  @override
  State<AzkarCard> createState() => _AzkarCardState();
}

class _AzkarCardState extends State<AzkarCard> {
  int _currentCount = 0;

  void _increment() {
    if (_currentCount < widget.zikr.count) {
      setState(() {
        _currentCount++;
      });
      if (_currentCount == widget.zikr.count) {
        widget.onDone();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.doneMessage, textAlign: TextAlign.center),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 80.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top scroll hint
                  if (widget.index > 1)
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ).animate(onPlay: (c) => c.repeat(reverse: true))
                     .moveY(begin: -3, end: 3, duration: 1200.ms, curve: Curves.easeInOut),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${widget.index} / ${widget.total}',
                        style: GoogleFonts.amiri(
                          color: Colors.white54,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        widget.categoryLabel,
                        style: GoogleFonts.amiri(
                          color: const Color(0xFFC5A358),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 30),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: Text(
                          widget.zikr.text,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.amiri(
                            fontSize: widget.fontSize,
                            color: Colors.white,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (widget.zikr.description != null) ...[
                    const SizedBox(height: 20),
                    Text(
                      widget.zikr.description!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.amiri(
                        fontSize: 14,
                        color: Colors.white70,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  const SizedBox(height: 40),
                  
                  if (widget.showCounter)
                    GestureDetector(
                      onTap: _increment,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF064D3B), Color(0xFF0A7D60)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF064D3B).withOpacity(0.5),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$_currentCount',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '/ ${widget.zikr.count}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ).animate(target: _currentCount == widget.zikr.count ? 1 : 0)
                     .shimmer(duration: 1200.ms, color: Colors.white24)
                     .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 200.ms, curve: Curves.easeOut),
                  
                  if (widget.onScrollToStart != null) ...[
                    const SizedBox(height: 20),
                    TextButton.icon(
                      onPressed: widget.onScrollToStart,
                      icon: const Icon(Icons.keyboard_double_arrow_up, color: Color(0xFFC5A358)),
                      label: Text(
                        widget.backToStartLabel,
                        style: GoogleFonts.amiri(color: const Color(0xFFC5A358), fontSize: 18),
                      ),
                    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.5, end: 0),
                  ],
                  // Bottom scroll hint
                  if (widget.index < widget.total)
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(top: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ).animate(onPlay: (c) => c.repeat(reverse: true))
                     .moveY(begin: 3, end: -3, duration: 1200.ms, curve: Curves.easeInOut),
                ],
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
  }
}
