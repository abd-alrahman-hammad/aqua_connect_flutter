import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/screens.dart';
import '../../../core/theme/rayyan_colors.dart';
import 'widgets/article_card.dart';

class AddDeviceScreen extends ConsumerWidget {
  const AddDeviceScreen({super.key, required this.onNavigate});

  final void Function(AppScreen) onNavigate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.menu, color: isDark ? Colors.white : Colors.black87),
          onPressed: () {},
        ),
        title: Text(
          'Rayyan',
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : Colors.black87,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: isDark ? Colors.white : Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + kToolbarHeight + 16,
            left: 24.0,
            right: 24.0,
            bottom: 16.0,
          ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // YOUR APPLIANCES Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'YOUR APPLIANCES',
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white70 : Colors.black54,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  'View all',
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: RayyanColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Empty State Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: isDark ? RayyanColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  if (!isDark)
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: isDark ? RayyanColors.surfaceDark : RayyanColors.onboardCardLight,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.inventory_2_outlined,
                      color: isDark ? RayyanColors.primary : RayyanColors.onboardIconTint,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No appliances added',
                    style: GoogleFonts.manrope(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start your hydroponic journey by\nconnecting your first system.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      color: isDark ? Colors.white60 : Colors.black54,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => onNavigate(AppScreen.deviceList),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: RayyanColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'ADD YOUR APPLIANCES',
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // NEW FOR YOU Header
            Text(
              'NEW FOR YOU',
              style: GoogleFonts.manrope(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white70 : Colors.black54,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            
            // Article 1
            ArticleCard(
              isDark: isDark,
              tag: 'SUSTAINABLE LIVING',
              tagColor: RayyanColors.primary,
              title: 'Maximizing yield in small urban apartments',
              description: 'Learn how to optimize your pH balance for faster growth cycles without needing extra...',
              imageUrl: 'https://images.unsplash.com/photo-1530836369250-ef71a3a5e4b8?q=80&w=2070&auto=format&fit=crop',
            ),
            
            const SizedBox(height: 16),
            
            ArticleCard(
              isDark: isDark,
              tag: 'HYDRO-TECH TIPS',
              tagColor: RayyanColors.onboardTagBlue,
              title: 'The Science of Nutrient Film Technique',
              description: 'Understanding how oxygen-rich water flow affects root health and nutrient absorption...',
              imageUrl: 'https://images.unsplash.com/photo-1534533983688-c7b8e13fd3b6?q=80&w=2070&auto=format&fit=crop',
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
