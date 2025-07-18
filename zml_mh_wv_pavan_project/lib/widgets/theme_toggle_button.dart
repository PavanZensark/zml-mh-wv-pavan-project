import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class ThemeToggleButton extends StatelessWidget {
  final bool showText;
  final Color? iconColor;

  const ThemeToggleButton({
    super.key,
    this.showText = false,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;

        if (showText) {
          return TextButton.icon(
            onPressed: themeProvider.toggleTheme,
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: iconColor ?? Theme.of(context).iconTheme.color,
            ),
            label: Text(
              isDark ? 'Light Mode' : 'Dark Mode',
              style: TextStyle(
                color:
                    iconColor ?? Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          );
        }

        return IconButton(
          onPressed: themeProvider.toggleTheme,
          icon: Icon(
            isDark ? Icons.light_mode : Icons.dark_mode,
            color: iconColor ?? Theme.of(context).iconTheme.color,
          ),
          tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
        );
      },
    );
  }
}
