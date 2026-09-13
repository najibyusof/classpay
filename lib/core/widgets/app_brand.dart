import 'package:flutter/material.dart';

class AppBrand extends StatelessWidget {
  const AppBrand({this.logoSize = 48, this.showName = true, super.key});

  final double logoSize;
  final bool showName;

  @override
  Widget build(BuildContext context) {
    final logo = Image.asset(
      'logo.png',
      width: logoSize,
      height: logoSize,
      fit: BoxFit.contain,
      semanticLabel: 'ClassPay logo',
    );

    if (!showName) return logo;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        logo,
        const SizedBox(width: 12),
        Text('ClassPay', style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }
}
