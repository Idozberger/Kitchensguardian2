import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/utils/date_format_to_string.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/features/history/presentation/bloc/scan_history_cubit.dart';
import 'package:foodkitchen/features/history/presentation/bloc/scan_history_state.dart';
import 'package:lottie/lottie.dart';
import '../widgets/history_list_tile.dart';
import '../widgets/history_loading_view.dart';
import '../widgets/history_empty_view.dart';

class ScanHistoryPage extends StatefulWidget {
  const ScanHistoryPage({super.key});

  @override
  State<ScanHistoryPage> createState() => _ScanHistoryPageState();
}

class _ScanHistoryPageState extends State<ScanHistoryPage> {
  late final ScanHistoryCubit _scanHistoryCubit;
  int pageNumber = 1;
  final ScrollController _scrollController = ScrollController();
  bool isFetchingMore = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _scanHistoryCubit = context.read<ScanHistoryCubit>();
    _scanHistoryCubit.clearState();
    _fetchHistory(pageNumber.toString());

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !isFetchingMore &&
          !_scanHistoryCubit.state.isLoading) {}
    });
  }

  Future<void> _fetchHistory(String pageNumber) async {
    if (_isDisposed) return;
    try {
      await _scanHistoryCubit.fetchHistory(pageNumber: pageNumber);
    } catch (e, st) {
      debugPrint('Error fetching history: $e\n$st');
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF9F9F9),
      appBar: _buildAppBar(context),
      body: BlocBuilder<ScanHistoryCubit, ScanHistoryState>(
        builder: (_, state) {
          if (state.isLoading && state.items.isEmpty) {
            return const HistoryLoadingView();
          }

          if (state.items.isEmpty) return const HistoryEmptyView();

          return SafeArea(
            child: Padding(
              padding: gapSymmetric(horizontal: 20, vertical: 0),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: state.items.length + 1,
                      padding: gapSymmetric(vertical: 12),
                      itemBuilder: (context, index) {
                        if (index < state.items.length) {
                          final historyData = state.items[index];
                          return Padding(
                            padding: gapOnly(bottom: 12),
                            child: HistoryListTile(
                              title: "Scanned Receipt",
                              date: formatDate(historyData.scannedAt),
                              details: historyData.items,
                            ),
                          );
                        } else {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Center(
                              child: isFetchingMore
                                  ? Lottie.asset(AppAssets.loader)
                                  : const SizedBox.shrink(),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
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
            onTap: () => Navigator.pop(context),
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
