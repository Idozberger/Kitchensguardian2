import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/utils/date_format_to_string.dart';
import 'package:foodkitchen/core/utils/dev_logging.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';
import 'package:foodkitchen/features/history/domain/entities/scan_history_entity.dart';
import 'package:foodkitchen/features/history/presentation/bloc/scan_history_cubit.dart';
import 'package:foodkitchen/features/history/presentation/bloc/scan_history_state.dart';
import 'package:lottie/lottie.dart';

import '../widgets/history_empty_view.dart';
import '../widgets/history_list_tile.dart';
import '../widgets/history_loading_view.dart';

class ScanHistoryPage extends StatefulWidget {
  const ScanHistoryPage({super.key});

  @override
  State<ScanHistoryPage> createState() => _ScanHistoryPageState();
}

class _ScanHistoryPageState extends State<ScanHistoryPage> {
  late final ScanHistoryCubit _scanHistoryCubit;
  late final ScrollController _scrollController;

  int _pageNumber = 1;
  bool _isFetchingMore = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    initHistoryState();
  }

  void initHistoryState() {
    _scanHistoryCubit = context.read<ScanHistoryCubit>();
    _scrollController = ScrollController();

    _scanHistoryCubit.clearState();
    _loadInitialHistory();
    _setupScrollListener();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_isAtEndOfList() &&
          !_isFetchingMore &&
          !_scanHistoryCubit.state.isLoading &&
          _scanHistoryCubit.state.hasMore) {
        _loadMoreHistory();
      }
    });
  }

  bool _isAtEndOfList() {
    return _scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent;
  }

  Future<void> _loadInitialHistory() async {
    if (_isDisposed) return;
    try {
      await _scanHistoryCubit.fetchHistory(pageNumber: _pageNumber.toString());
    } catch (e, st) {
      devPrint('Error loading history: $e\n$st');
    }
  }

  Future<void> _loadMoreHistory() async {
    if (_isDisposed || _isFetchingMore) return;

    setState(() => _isFetchingMore = true);
    _pageNumber++;

    try {
      await _scanHistoryCubit.fetchHistory(pageNumber: _pageNumber.toString());
    } catch (e, st) {
      devPrint('Error loading more history: $e\n$st');
      _pageNumber--;
    } finally {
      if (!_isDisposed) {
        setState(() => _isFetchingMore = false);
      }
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
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: _buildAppBar(),
      body: BlocBuilder<ScanHistoryCubit, ScanHistoryState>(
        builder: (context, state) => _buildBody(state),
      ),
    );
  }

  Widget _buildBody(ScanHistoryState state) {
    if (state.isLoading && state.items.isEmpty) {
      return const HistoryLoadingView();
    }

    if (state.items.isEmpty) {
      return const HistoryEmptyView();
    }

    return SafeArea(
      child: Padding(
        padding: gapSymmetric(horizontal: 20, vertical: 0),
        child: _buildHistoryList(state),
      ),
    );
  }

  Widget _buildHistoryList(ScanHistoryState state) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: state.items.length + (_isFetchingMore ? 1 : 0),
            padding: gapSymmetric(vertical: 12),
            itemBuilder: (context, index) {
              if (index < state.items.length) {
                return _buildHistoryTile(index, state.items[index]);
              } else {
                return _buildLoadingIndicator();
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryTile(int index, ScanHistoryEntity historyData) {
    return Padding(
      padding: gapOnly(bottom: 12),
      child: HistoryListTile(
        title: "Scanned Receipt",
        date: formatDate(historyData.scannedAt),
        details: historyData.items,
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(child: Lottie.asset(AppAssets.loader)),
    );
  }

  AppBar _buildAppBar() {
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
