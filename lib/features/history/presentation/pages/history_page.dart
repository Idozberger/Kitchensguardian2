import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/date_format_to_string.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';
import 'package:foodkitchen/features/history/presentation/bloc/scan_history_cubit.dart';
import 'package:foodkitchen/features/history/presentation/bloc/scan_history_state.dart';
import 'package:foodkitchen/features/pantry/presentation/widgets/list_tile.dart';

class ScanHistoryPage extends StatefulWidget {
  const ScanHistoryPage({super.key});

  @override
  State<ScanHistoryPage> createState() => _ScanHistoryPageState();
}

class _ScanHistoryPageState extends State<ScanHistoryPage> {
  late ScanHistoryCubit scanHistoryCubit;
  String pageNumber = "1";
  @override
  void initState() {
    scanHistoryCubit = context.read<ScanHistoryCubit>();
    getScanHistory();
    super.initState();
  }

  void getScanHistory() async {
    await scanHistoryCubit.fetchHistory(pageNumber: pageNumber);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF9F9F9),
      appBar: _buildAppBar(context),
      body: BlocBuilder<ScanHistoryCubit, ScanHistoryState>(
        builder: (_, state) {
          if (state.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            );
          } else {
            return SafeArea(
              child: Padding(
                padding: gapSymmetric(horizontal: 20),

                child: ListView.builder(
                  itemCount: state.items.length,
                  shrinkWrap: true,

                  padding: gapZero,
                  itemBuilder: (context, index) {
                    final item = state.items[index];
                    return Padding(
                      padding: gapSymmetric(vertical: 10),
                      child: HistoryListTile(
                        title: "Scanned Receipt",
                        date: formatDate(item.scannedAt),
                        details: item.items.map((item) => item.name).toList(),
                      ),
                    );
                  },
                ),
              ),
            );
          }
        },
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      leadingWidth: w(55),
      leading: Row(
        children: [
          SizedBox(width: w(16)),
          CircularIconButton(
            iconAsset: AppAssets.backArrowiOS,
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),

      title: Text(
        "Scan History",
        style: Theme.of(context).textTheme.headlineLarge,
      ),
    );
  }
}

class HistoryListTile extends StatefulWidget {
  final String title;
  final String date;
  final List<String> details;

  const HistoryListTile({
    super.key,
    required this.title,
    required this.date,
    required this.details,
  });

  @override
  State<HistoryListTile> createState() => _HistoryListTileState();
}

class _HistoryListTileState extends State<HistoryListTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: Container(
        padding: gapAll(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(h(10)),
          border: Border.all(color: const Color(0xffD4D2D2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      widget.title,
                      style: Theme.of(
                        context,
                      ).textTheme.headlineLarge!.copyWith(fontSize: t(14)),
                    ),
                    SizedBox(width: w(16)),
                    Container(
                      padding: gapSymmetric(horizontal: 18, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(h(36)),
                        border: Border.all(color: const Color(0xffD4D2D2)),
                      ),
                      child: Text(
                        widget.date,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontSize: t(12),
                              fontWeight: FontWeight.w400,
                            ),
                      ),
                    ),
                  ],
                ),
                AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: SvgPicture.asset(AppAssets.downArrow),
                ),
              ],
            ),

            /// Expanded content
            if (_isExpanded) ...[
              SizedBox(height: h(12)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.details
                    .map(
                      (e) => Padding(
                        padding: gapOnly(bottom: 6),
                        child: ListItemWidget(text: e),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
