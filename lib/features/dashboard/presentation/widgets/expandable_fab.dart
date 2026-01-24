import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ExpandableFab extends StatelessWidget {
  final List<ExpandableFabAction> actions;
  final Widget? icon;
  final Widget? activeIcon;
  final bool isOpen;
  final ValueChanged<bool> onOpenChanged;

  const ExpandableFab({
    super.key,
    required this.actions,
    required this.isOpen,
    required this.onOpenChanged,
    this.icon,
    this.activeIcon,
  });

  void _toggle() {
    onOpenChanged(!isOpen);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Using AnimatedSize or just conditional rendering with Animate
        // Since we want to animate in/out, keeping it in tree with simple conditional + animate is tricky for "out" animation without stateful keys or AnimatedSwitcher.
        // But for simplicity of this refactor, let's stick to the previous conditional logic which had animate().fadeIn().
        // Note: animate() typically runs on mount. If we toggle isOpen, the children are re-added.
        if (isOpen) ...[
          for (final action in actions)
            _buildAction(
              action,
            ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.5, end: 0),
        ],
        const SizedBox(height: 8),
        FloatingActionButton(
          heroTag: 'expandable_main_fab',
          onPressed: _toggle,
          child: AnimatedSwitcher(
            duration: 200.ms,
            transitionBuilder: (child, anim) => RotationTransition(
              turns: child.key == const ValueKey('icon')
                  ? Tween<double>(begin: 1, end: 0.75).animate(anim)
                  : Tween<double>(begin: 0.75, end: 1).animate(anim),
              child: FadeTransition(opacity: anim, child: child),
            ),
            child: isOpen
                ? (activeIcon ??
                      const Icon(Icons.close, key: ValueKey('active')))
                : (icon ?? const Icon(Icons.add, key: ValueKey('icon'))),
          ),
        ),
      ],
    );
  }

  Widget _buildAction(ExpandableFabAction action) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              action.label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton.small(
            heroTag: null,
            onPressed: () {
              // Close after selection
              onOpenChanged(false);
              action.onPressed();
            },
            backgroundColor: action.color,
            foregroundColor: Colors.white,
            child: Icon(action.icon, size: 20),
          ),
        ],
      ),
    );
  }
}

class ExpandableFabAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const ExpandableFabAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });
}
