import 'package:flutter/material.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/screens/data/models/country_currency_model.dart';

class CountryItem extends StatelessWidget {
  final Country country;

  const CountryItem({super.key, required this.country});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                country.name,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: t(14),
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                country.code,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Colors.grey[500],
                  fontSize: t(11),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
