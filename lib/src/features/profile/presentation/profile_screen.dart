import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../l10n/generated/app_localizations.dart';

import '../../../app/screens.dart';
import '../../../core/services/auth_preferences_service.dart';
import '../../../core/services/firebase_auth_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/user_database_service.dart';
import '../../../core/theme/aqua_colors.dart';
import '../../../core/widgets/aqua_header.dart';
import '../../../core/widgets/aqua_page_scaffold.dart';
import '../../../core/widgets/aqua_symbol.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({
    super.key,
    required this.current,
    required this.onNavigate,
  });

  final AppScreen current;
  final ValueChanged<AppScreen> onNavigate;

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.signOut),
        content: Text(AppLocalizations.of(context)!.signOutConfirmationMessage),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AquaColors.slate500),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await ref.read(authPreferencesServiceProvider).clear();
                await ref.read(firebaseAuthServiceProvider).signOut();
                onNavigate(AppScreen.login);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(
                          context,
                        )!.errorSigningOut(e.toString()),
                      ),
                      backgroundColor: AquaColors.critical,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(
                color: AquaColors.critical,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(realtimeUserProfileStreamProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AquaPageScaffold(
      currentScreen: current,
      onNavigate: onNavigate,
      includeBottomNav: false, // Hide bottom nav on Profile screen
      child: Column(
        children: [
          AquaHeader(
            title: 'Profile',
            onBack: () => onNavigate(AppScreen.settings),
          ),
          userAsync.when(
            data: (user) {
              if (user == null) {
                return Center(
                  child: Text(AppLocalizations.of(context)!.noUserData),
                );
              }
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                child: Column(
                  children: [
                    _ProfileHeader(user: user, isDark: isDark),
                    const SizedBox(height: 32),
                    _SectionContainer(
                      title: 'Personal Information',
                      isDark: isDark,
                      children: [
                        _EditableField(
                          label: 'Display Name',
                          value: user.displayName ?? 'No Name',
                          onSave: (value) async {
                            await ref
                                .read(userDatabaseServiceProvider)
                                .updateUser(user.copyWith(displayName: value));
                          },
                        ),
                        const SizedBox(height: 24),
                        _EditableField(
                          label: 'Email',
                          value: user.email ?? 'No Email',
                          enabled: false,
                          onSave: (_) {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _SectionContainer(
                      title: 'Settings',
                      isDark: isDark,
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AquaColors.critical.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const AquaSymbol(
                              'logout',
                              size: 20,
                              color: AquaColors.critical,
                            ),
                          ),
                          title: const Text(
                            'Sign Out',
                            style: TextStyle(
                              color: AquaColors.critical,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          onTap: () => _confirmLogout(context, ref),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(20.0),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, st) => Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: Text('${AppLocalizations.of(context)!.error}: $e'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends ConsumerWidget {
  const _ProfileHeader({required this.user, required this.isDark});

  final dynamic
  user; // Using dynamic because UserModel isn't imported explicitly but we know the shape.
  // Actually, better to use the specific type if possible, but standard 'user' in this file context was inferred.
  // I will rely on dynamic or inferred type, but to be safe I'll cast inside.
  // Wait, I can import UserModel properly. But I don't want to break the pattern if it was excluded for a reason.
  // The previous file had it commented out. I'll import it.
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _ProfileImage(
          photoUrl: user.photoUrl,
          onImageSelected: (file) async {
            try {
              final storageService = ref.read(storageServiceProvider);
              final userDatabaseService = ref.read(userDatabaseServiceProvider);
              final url = await storageService.uploadProfileImage(
                user.uid,
                file,
              );
              await userDatabaseService.updateUser(
                user.copyWith(photoUrl: url),
              );
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${AppLocalizations.of(context)!.error}: $e'),
                  ),
                );
              }
            }
          },
        ),
        const SizedBox(height: 16),
        Text(
          user.displayName ?? 'User',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AquaColors.slate900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          user.email ?? '',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AquaColors.slate500),
        ),
      ],
    );
  }
}

class _SectionContainer extends StatelessWidget {
  const _SectionContainer({
    required this.title,
    required this.children,
    required this.isDark,
  });

  final String title;
  final List<Widget> children;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AquaColors.slate500,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AquaColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : AquaColors.slate200,
            ),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }
}

class _ProfileImage extends StatefulWidget {
  const _ProfileImage({required this.photoUrl, required this.onImageSelected});

  final String? photoUrl;
  final Function(File) onImageSelected;

  @override
  State<_ProfileImage> createState() => _ProfileImageState();
}

class _ProfileImageState extends State<_ProfileImage> {
  bool _isUploading = false;

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        if (!mounted) return;
        setState(() => _isUploading = true);
        try {
          await widget.onImageSelected(File(pickedFile.path));
        } finally {
          if (mounted) {
            setState(() => _isUploading = false);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.errorPickingImage(e.toString()),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: _pickImage,
      child: Stack(
        children: [
          Container(
            width: 140, // Increased size
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? AquaColors.cardDark : Colors.white,
                width: 6,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: widget.photoUrl != null
                ? CachedNetworkImage(
                    imageUrl: widget.photoUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Container(color: AquaColors.slate200),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  )
                : Container(
                    color: AquaColors.slate200,
                    child: const Icon(
                      Icons.person,
                      size: 70,
                      color: AquaColors.slate400,
                    ),
                  ),
          ),
          if (_isUploading)
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AquaColors.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark
                      ? AquaColors.backgroundDark
                      : AquaColors.backgroundLight,
                  width: 4,
                ),
              ),
              child: const AquaSymbol('edit', size: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditableField extends StatefulWidget {
  const _EditableField({
    required this.label,
    required this.value,
    required this.onSave,
    this.enabled = true,
  });

  final String label;
  final String value;
  final Function(String) onSave;
  final bool enabled;

  @override
  State<_EditableField> createState() => _EditableFieldState();
}

class _EditableFieldState extends State<_EditableField> {
  late TextEditingController _controller;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant _EditableField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && !_isEditing) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    widget.onSave(_controller.text);
    setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    // final isDark = Theme.of(context).brightness == Brightness.dark;

    // If not editing, show a clean row for read-only look inside the section
    if (!_isEditing) {
      return Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AquaColors.slate500,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.value,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          if (widget.enabled)
            IconButton(
              onPressed: () => setState(() => _isEditing = true),
              icon: const AquaSymbol(
                'edit',
                color: AquaColors.primary,
                size: 20,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      );
    }

    // Editing mode
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AquaColors.slate500,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                autofocus: true,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AquaColors.primary),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AquaColors.primary, width: 2),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _save,
              icon: const AquaSymbol(
                'check_circle',
                color: AquaColors.nature,
                size: 24,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  _isEditing = false;
                  _controller.text = widget.value;
                });
              },
              icon: const AquaSymbol(
                'cancel',
                color: AquaColors.critical,
                size: 24,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ],
    );
  }
}
