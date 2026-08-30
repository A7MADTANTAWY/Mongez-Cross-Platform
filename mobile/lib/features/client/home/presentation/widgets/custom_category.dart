import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mongez/core/widgets/app_network_image.dart';
import 'package:mongez/features/client/home/data/models/categories.dart';

class CustomCategory extends StatelessWidget {
  final CategoriesModel category;
  final VoidCallback? onTap;

  const CustomCategory({super.key, required this.category, this.onTap});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final label = category.displayName(locale);
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.22;
    final iconSize = cardWidth * 0.72;

    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 10),
      child: SizedBox(
        width: cardWidth,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: iconSize,
                  height: iconSize,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        cs.primaryContainer,
                        cs.primaryContainer.withValues(alpha: 0.55),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(iconSize * 0.28),
                    border: Border.all(
                      color: cs.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  alignment: Alignment.center,
                  clipBehavior: Clip.antiAlias,
                  child: category.imageUrl != null
                      ? (category.isSvgImage
                          ? SvgPicture.network(
                              category.imageUrl!,
                              fit: BoxFit.cover,
                              placeholderBuilder: (_) => Icon(
                                category.iconData,
                                color: cs.onPrimaryContainer,
                                size: iconSize * 0.50,
                              ),
                            )
                          : AppNetworkImage(
                              imageUrl: category.imageUrl!,
                              fit: BoxFit.cover,
                              cacheWidth: iconSize.round(),
                              errorWidget: (_, _, _) => Icon(
                                category.iconData,
                                color: cs.onPrimaryContainer,
                                size: iconSize * 0.50,
                              ),
                            ))
                      : Icon(
                          category.iconData,
                          color: cs.onPrimaryContainer,
                          size: iconSize * 0.50,
                        ),
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: tt.bodySmall?.copyWith(
                    fontSize: screenWidth * 0.032,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
