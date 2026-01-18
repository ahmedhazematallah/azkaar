import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:ui';
import 'data/azkar_data.dart';

void main() {
  runApp(const AzkaarApp());
}

class AzkaarApp extends StatelessWidget {
  const AzkaarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Azkaar',
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
  
  final Map<int, bool> _completedZikrs = {};

  final Map<String, Map<String, String>> _translations = {
    'Arabic': {
      'settings': 'الإعدادات',
      'enable_counter': 'تفعيل العداد',
      'counter_desc': 'إذا تم إيقافه، سيتم اعتبار الذكر مكتملاً بمجرد التمرير',
      'language': 'اللغة',
      'back_to_start': 'العودة للبداية',
      'done': 'تم الانتهاء من هذا الذكر',
      'app_title': 'أذكار',
    },
    'English': {
      'settings': 'Settings',
      'enable_counter': 'Enable Counter',
      'counter_desc': 'If disabled, zikr is marked done by scrolling',
      'language': 'Language',
      'back_to_start': 'Back to Start',
      'done': 'Zikr Completed',
      'app_title': 'Azkaar',
    },
    'French': {
      'settings': 'Paramètres',
      'enable_counter': 'Activer le compteur',
      'counter_desc': 'Si désactivé, le zikr est marqué comme terminé par défilement',
      'language': 'Langue',
      'back_to_start': 'Retour au début',
      'done': 'Zikr terminé',
      'app_title': 'Azkaar',
    },
    'German': {
      'settings': 'Einstellungen',
      'enable_counter': 'Zähler aktivieren',
      'counter_desc': 'Wenn deaktiviert, wird Zikr durch Scrollen als erledigt markiert',
      'language': 'Sprache',
      'back_to_start': 'Zurück zum Anfang',
      'done': 'Zikr abgeschlossen',
      'app_title': 'Azkaar',
    },
    'Japanese': {
      'settings': '設定',
      'enable_counter': 'カウンターを有効にする',
      'counter_desc': '無効な場合、スクロールで完了と見なされます',
      'language': '言語',
      'back_to_start': '最初に戻る',
      'done': '完了しました',
      'app_title': 'アズカール',
    },
    'Chinese': {
      'settings': '设置',
      'enable_counter': '启用计数器',
      'counter_desc': '如果禁用，滑动将被视为完成',
      'language': '语言',
      'back_to_start': '回到开始',
      'done': '已完成',
      'app_title': '阿兹卡尔',
    },
  };

  @override
  void initState() {
    super.initState();
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
    if (!_showCounter) {
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
      _completedZikrs.clear();
    });
    _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOutExpo,
    );
  }

  void _markAsDone(int index) {
    setState(() {
      _completedZikrs[index] = true;
    });
  }

  String t(String key) => _translations[_language]?[key] ?? key;

  void _openSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
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
                    color: Colors.black.withOpacity(0.7),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        t('settings'),
                        style: GoogleFonts.amiri(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 20),
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
                      const Divider(color: Colors.white10),
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

  double _getCompletionPercentage() {
    int total = azkarList.length;
    int completed = _completedZikrs.values.where((v) => v).length;
    return (completed / total);
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
            itemCount: azkarList.length,
            itemBuilder: (context, index) {
              return AzkarCard(
                zikr: azkarList[index],
                fontSize: _baseFontSize,
                index: index + 1,
                total: azkarList.length,
                showCounter: _showCounter,
                onDone: () => _markAsDone(index),
                onScrollToStart: index == azkarList.length - 1 ? _scrollToStart : null,
                backToStartLabel: t('back_to_start'),
                doneMessage: t('done'),
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
                SizedBox(
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
                  onPressed: _openSettings,
                  icon: const Icon(Icons.settings, color: Colors.white70),
                ).animate().fadeIn(),
              ],
            ),
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
                        widget.zikr.category,
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
                ],
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
  }
}
