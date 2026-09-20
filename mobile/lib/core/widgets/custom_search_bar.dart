import 'package:flutter/material.dart';
import 'package:mongez/generated/l10n.dart';

class CustomSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSearch;
  final VoidCallback onFilterTap;
  final bool isLoading;
  final String? hintText;
  final bool autofocus;

  const CustomSearchBar({
    super.key,
    required this.controller,
    required this.onSearch,
    required this.onFilterTap,
    this.isLoading = false,
    this.hintText,
    this.autofocus = true,
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  final _focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (_focused != _focusNode.hasFocus) {
      setState(() => _focused = _focusNode.hasFocus);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _clear() {
    widget.controller.clear();
    widget.onSearch('');
  }

  @override
  Widget build(BuildContext context) {
    final lang = S.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final radius = BorderRadius.circular(16);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: radius,
          border: Border.all(
            color: _focused
                ? cs.primary.withValues(alpha: 0.55)
                : cs.outline.withValues(alpha: 0.6),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.search_rounded,
              size: 22,
              color: cs.onSurface.withValues(alpha: 0.55),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: widget.controller,
                focusNode: _focusNode,
                autofocus: widget.autofocus,
                textInputAction: TextInputAction.search,
                cursorColor: cs.primary,
                style: tt.bodyMedium,
                onSubmitted: widget.onSearch,
                decoration: InputDecoration(
                  hintText: widget.hintText ?? lang.searchHint,
                  hintStyle: tt.bodyMedium?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.55),
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: widget.controller,
              builder: (context, value, _) {
                if (value.text.isEmpty) {
                  return const SizedBox(width: 12);
                }
                return Padding(
                  padding: const EdgeInsetsDirectional.only(start: 12, end: 8),
                  child: GestureDetector(
                    onTap: _clear,
                    behavior: HitTestBehavior.opaque,
                    child: Icon(
                      Icons.close,
                      size: 20,
                      color: cs.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                );
              },
            ),
            SizedBox(
              width: 26,
              child: widget.isLoading
                  ? Center(
                      child: SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: cs.primary,
                        ),
                      ),
                    )
                  : null,
            ),
            Container(width: 1, height: 22, color: cs.outline),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: widget.onFilterTap,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                child: Icon(
                  Icons.tune_rounded,
                  size: 22,
                  color: cs.primary,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}
