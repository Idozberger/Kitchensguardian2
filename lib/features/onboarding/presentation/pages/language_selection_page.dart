import 'package:flutter/material.dart';
import 'package:foodkitchen/core/config/localization_config.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';

class LanguageSelectionPage extends StatefulWidget {
  const LanguageSelectionPage({super.key});

  @override
  State<LanguageSelectionPage> createState() => _LanguageSelectionPageState();
}

class _LanguageSelectionPageState extends State<LanguageSelectionPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Select Language',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 19,
              color: Colors.black,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: Colors.grey[300], height: 1),
          ),
        ),

        body: ListView.separated(
          padding: gapSymmetric(horizontal: h(11)),
          itemCount: LocalizationConfig().languages.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            return ListTile(
              subtitle: Text(
                LocalizationConfig().languages[index].code,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                  color: Color(0xff6C6C6C),
                ),
              ),
              title: Text(
                LocalizationConfig().languages[index].language,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                  color: Colors.black,
                ),
              ),
              trailing: _selectedIndex == index
                  ? const Icon(Icons.check, color: Colors.black)
                  : null,
              onTap: () {
                setState(() {
                  _selectedIndex = index;
                });
              },
            );
          },
        ),
      ),
    );
  }
}
