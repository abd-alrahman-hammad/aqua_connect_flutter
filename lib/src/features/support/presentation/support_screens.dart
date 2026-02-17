import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../app/screens.dart';
import '../../../core/theme/aqua_colors.dart';
import '../../../core/widgets/aqua_header.dart';
import '../../../core/widgets/aqua_page_scaffold.dart';
import '../../../core/widgets/aqua_symbol.dart';
import '../../chat/presentation/chat_screen.dart';

class FaqItem {
  final String question;
  final String answer;

  const FaqItem({required this.question, required this.answer});
}

List<FaqItem> _getFaqs(AppLocalizations l10n) => [
  FaqItem(question: l10n.faqQuestion1, answer: l10n.faqAnswer1),
  FaqItem(question: l10n.faqQuestion2, answer: l10n.faqAnswer2),
  FaqItem(question: l10n.faqQuestion3, answer: l10n.faqAnswer3),
  FaqItem(question: l10n.faqQuestion4, answer: l10n.faqAnswer4),
  FaqItem(question: l10n.faqQuestion5, answer: l10n.faqAnswer5),
  FaqItem(question: l10n.faqQuestion6, answer: l10n.faqAnswer6),
  FaqItem(question: l10n.faqQuestion7, answer: l10n.faqAnswer7),
  FaqItem(question: l10n.faqQuestion8, answer: l10n.faqAnswer8),
  FaqItem(question: l10n.faqQuestion9, answer: l10n.faqAnswer9),
];

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key, required this.onNavigate});
  final ValueChanged<AppScreen> onNavigate;

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<FaqItem> _filteredFaqs(AppLocalizations l10n) {
    final allFaqs = _getFaqs(l10n);
    if (_searchText.isEmpty) return allFaqs;
    return allFaqs
        .where(
          (faq) =>
              faq.question.toLowerCase().contains(_searchText.toLowerCase()) ||
              faq.answer.toLowerCase().contains(_searchText.toLowerCase()),
        )
        .toList();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _searchText = '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final faqs = _filteredFaqs(l10n);
    return Scaffold(
      backgroundColor: isDark
          ? AquaColors.backgroundDark
          : AquaColors.backgroundLight,
      body: Stack(
        children: [
          AquaPageScaffold(
            includeBottomNav: false,
            currentScreen: AppScreen.support,
            onNavigate: widget.onNavigate,
            scrollable: false,
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (!_isSearching) ...[
                          Text(
                            l10n.videoGuides,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.visualWalkthroughs,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AquaColors.slate500),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 190,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: 3,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 16),
                              itemBuilder: (context, i) {
                                final idx = i + 1;
                                return SizedBox(
                                  width: 280,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: Stack(
                                            fit: StackFit.expand,
                                            children: [
                                              CachedNetworkImage(
                                                imageUrl:
                                                    'https://picsum.photos/300/170?random=$idx',
                                                fit: BoxFit.cover,
                                              ),
                                              Container(
                                                color: Colors.black.withValues(
                                                  alpha: 0.30,
                                                ),
                                              ),
                                              Center(
                                                child: Container(
                                                  width: 48,
                                                  height: 48,
                                                  decoration:
                                                      const BoxDecoration(
                                                        color:
                                                            AquaColors.primary,
                                                        shape: BoxShape.circle,
                                                      ),
                                                  child: const Center(
                                                    child: AquaSymbol(
                                                      'play_arrow',
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                bottom: 8,
                                                right: 8,
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black
                                                        .withValues(
                                                          alpha: 0.70,
                                                        ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6,
                                                        ),
                                                  ),
                                                  child: const Text(
                                                    '5:20',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        l10n.settingUpReservoir,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w900,
                                            ),
                                      ),
                                      Text(
                                        l10n.nutrientMixingGuide,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: AquaColors.slate500,
                                            ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                        Text(
                          _isSearching
                              ? l10n.searchResults
                              : l10n.frequentlyAskedQuestions,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 12),
                        if (faqs.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Text(
                              l10n.noResultsFound,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AquaColors.slate500),
                            ),
                          )
                        else
                          ...faqs.map((faq) => _FaqTile(item: faq)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!_isSearching)
            Positioned(
              left: 24,
              right: 24,
              bottom: 32,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 448),
                child: Center(
                  child: SizedBox(
                    height: 56,
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ChatScreen()),
                      ),
                      icon: const AquaSymbol('smart_toy', color: Colors.white),
                      label: Text(l10n.chatWithRayyan),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AquaColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        textStyle: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_isSearching) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isDark
              ? AquaColors.backgroundDark.withValues(alpha: 0.80)
              : Colors.white.withValues(alpha: 0.80),
          border: Border(
            bottom: BorderSide(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : AquaColors.slate200,
            ),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  onChanged: (value) => setState(() => _searchText = value),
                  decoration: InputDecoration(
                    hintText: l10n.searchFaqsHint,
                    border: InputBorder.none,
                    hintStyle: const TextStyle(color: AquaColors.slate400),
                    icon: const AquaSymbol(
                      'search',
                      color: AquaColors.slate400,
                    ),
                  ),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              TextButton(onPressed: _toggleSearch, child: Text(l10n.cancel)),
            ],
          ),
        ),
      );
    }
    return AquaHeader(
      title: l10n.supportAndLearning,
      onBack: () => widget.onNavigate(AppScreen.more),
      rightAction: IconButton(
        onPressed: _toggleSearch,
        icon: const AquaSymbol('search'),
      ),
    );
  }
}

class _FaqTile extends StatefulWidget {
  const _FaqTile({required this.item});
  final FaqItem item;
  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool open = false;
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AquaColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : AquaColors.slate200,
        ),
      ),
      child: InkWell(
        onTap: () => setState(() => open = !open),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.item.question,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: open ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const AquaSymbol(
                      'expand_more',
                      color: AquaColors.slate400,
                    ),
                  ),
                ],
              ),
              if (open) ...[
                const SizedBox(height: 12),
                Divider(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : AquaColors.slate100,
                  height: 1,
                ),
                const SizedBox(height: 12),
                Text(
                  widget.item.answer,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? AquaColors.slate400 : AquaColors.slate500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
