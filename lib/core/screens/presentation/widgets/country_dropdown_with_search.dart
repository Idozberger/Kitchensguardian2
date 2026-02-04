import 'package:flutter/material.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/screens/data/models/country_currency_model.dart';
import 'package:foodkitchen/core/screens/presentation/widgets/country_item.dart';

class CountryDropdownWithSearch extends StatefulWidget {
  final List<Country> countries;
  final Country? selectedCountry;
  final Function(Country?) onChanged;

  const CountryDropdownWithSearch({
    super.key,
    required this.countries,
    required this.selectedCountry,
    required this.onChanged,
  });

  @override
  State<CountryDropdownWithSearch> createState() =>
      _CountryDropdownWithSearchState();
}

class _CountryDropdownWithSearchState extends State<CountryDropdownWithSearch> {
  late TextEditingController _searchController;
  late List<Country> _filteredCountries;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredCountries = widget.countries;
    _searchController.addListener(_filterCountries);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCountries() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCountries = widget.countries
          .where(
            (country) =>
                country.name.toLowerCase().contains(query) ||
                country.code.toLowerCase().contains(query),
          )
          .toList();
    });
  }

  void _showCountryModal() {
    _searchController.clear();
    _filteredCountries = widget.countries;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.93,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(t(20))),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(t(16), t(16), t(16), t(8)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select Country',
                      style: TextStyle(
                        fontSize: t(18),
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.close,
                        color: Colors.grey[600],
                        size: t(24),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: gapSymmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setModalState(() {
                      _filterCountries();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search country...',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: t(14),
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey[400],
                      size: t(20),
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              setModalState(() {
                                _filterCountries();
                              });
                            },
                            child: Icon(
                              Icons.clear,
                              color: Colors.grey[400],
                              size: t(20),
                            ),
                          )
                        : null,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 0,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(t(8)),
                      borderSide: BorderSide(
                        color: Color(0xFFE5E7EB),
                        width: 1.5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(t(8)),
                      borderSide: BorderSide(
                        color: Color(0xFFE5E7EB),
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(t(8)),
                      borderSide: BorderSide(color: Colors.black, width: 1.5),
                    ),
                  ),
                ),
              ),
              Divider(height: 1),
              Expanded(
                child: _filteredCountries.isEmpty
                    ? Center(
                        child: Text(
                          'No countries found',
                          style: TextStyle(
                            fontSize: t(14),
                            color: Colors.grey[500],
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredCountries.length,
                        itemBuilder: (context, index) {
                          final country = _filteredCountries[index];
                          final isSelected =
                              widget.selectedCountry?.code == country.code;
                          return GestureDetector(
                            onTap: () {
                              widget.onChanged(country);
                              Navigator.pop(context);
                            },
                            child: Container(
                              color: isSelected
                                  ? Colors.grey.withOpacity(0.1)
                                  : Colors.transparent,
                              padding: gapSymmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: CountryItem(country: country),
                                  ),
                                  if (isSelected)
                                    Icon(
                                      Icons.check,
                                      color: Colors.black,
                                      size: t(20),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(t(12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(t(12)),
        child: Container(
          padding: gapSymmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(t(12)),
            border: Border.all(color: Color(0xFFE5E7EB), width: 1.5),
          ),
          child: InkWell(
            onTap: _showCountryModal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: widget.selectedCountry != null
                      ? CountryItem(country: widget.selectedCountry!)
                      : Text(
                          'Select Country',
                          style: TextStyle(
                            fontSize: t(16),
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[400],
                          ),
                        ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Colors.grey,
                  size: t(24),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
