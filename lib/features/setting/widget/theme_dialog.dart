import 'package:flutter/material.dart';
import 'package:omkar_sale/core/app/all_import_file.dart';

void showThemeSelectorSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent, // Let the container handle the background
    isScrollControlled: true,
    builder: (_) => const _ThemeSelectorWidget(),
  );
}

class _ThemeSelectorWidget extends StatelessWidget {
  const _ThemeSelectorWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.scaffoldBackgroundColor, // Uses #F2F1F6 (Light) or #0B1118 (Dark)
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Modern Drag Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: context.colorScheme.surfaceDim.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(10)),
          ),
          const SizedBox(height: 24),

          Text(
            'theme'.tr(context),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: context.colorScheme.onSurface, // Uses #212121 (Light) or #FFFFFF (Dark)
            ),
          ),
          const SizedBox(height: 24),

          BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, state) {
              final selectedTheme = state.appTheme;

              return Row(
                children: [
                  // Light Theme Card
                  Expanded(
                    child: _ThemeOptionCard(
                      title: 'lightThemeLbl'.tr(context),
                      icon: Icons.wb_sunny_rounded,
                      isSelected: selectedTheme == AppThemeType.light,
                      onTap: () => context.read<ThemeCubit>().changeTheme(AppThemeType.light),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Dark Theme Card
                  Expanded(
                    child: _ThemeOptionCard(
                      title: 'darkThemeLbl'.tr(context),
                      icon: Icons.nightlight_round_rounded,
                      isSelected: selectedTheme == AppThemeType.dark,
                      onTap: () => context.read<ThemeCubit>().changeTheme(AppThemeType.dark),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 32),

          // Action Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primaryColor, // Uses #2F88EB or #3B82F6
                foregroundColor: context.colorScheme.onPrimary, // White
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: Text('saveLbl'.tr(context), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 10.sp(context)),
        ],
      ),
    );
  }
}

class _ThemeOptionCard extends StatelessWidget {
  const _ThemeOptionCard({required this.title, required this.icon, required this.isSelected, required this.onTap});
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          // Logic: If selected, use Primary color. If not, use the Secondary (Card) color.
          color: isSelected ? theme.primaryColor : colorScheme.secondary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? theme.primaryColor : colorScheme.surfaceDim.withValues(alpha: 0.2), width: 2),
          boxShadow: isSelected ? [BoxShadow(color: theme.primaryColor.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 5))] : [],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 30,
              // Logic: White if selected, otherwise use the Dim/Grey color you defined
              color: isSelected ? colorScheme.onPrimary : colorScheme.surfaceDim,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.w600, color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface),
            ),
            const SizedBox(height: 8),
            // Selection Radio Dot
            Container(
              height: 12,
              width: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? colorScheme.onPrimary : Colors.transparent,
                border: Border.all(color: isSelected ? colorScheme.onPrimary : colorScheme.surfaceDim, width: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
