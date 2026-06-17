import 'package:flutter/material.dart';
import 'package:foodkitchen/app/di.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/logging/app_logger.dart';
import 'package:foodkitchen/core/utils/dev_logging.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/features/dashboard/domain/datasources/user_kitchen_preview_firestore_datasource.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';
import 'package:lottie/lottie.dart';

enum _UserPageLoadState { loading, ready, userNotFound, error }

class UserPage extends StatefulWidget {
  final String senderUserId;
  final String kitchenId;

  const UserPage({
    super.key,
    required this.senderUserId,
    required this.kitchenId,
  });

  @override
  // Legacy pattern: private State type; changing would churn call sites.
  // ignore: library_private_types_in_public_api
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  _UserPageLoadState _loadState = _UserPageLoadState.loading;
  String userName = '';
  String userEmail = '';
  String kitchenName = '';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _loadState = _UserPageLoadState.loading);
    try {
      final preview = await sl<UserKitchenPreviewFirestoreDatasource>()
          .fetchPreview(
            userId: widget.senderUserId,
            kitchenId: widget.kitchenId,
          );
      if (!mounted) return;
      if (preview != null) {
        setState(() {
          userName = preview.userName;
          userEmail = preview.userEmail;
          kitchenName = preview.kitchenName;
          _loadState = _UserPageLoadState.ready;
        });
      } else {
        setState(() {
          _loadState = _UserPageLoadState.userNotFound;
        });
      }
    } catch (e, st) {
      devLog("Error fetching data: $e\n$st");
      AppLogger.recordNonFatal(e, st, reason: 'user_information_fetch');
      if (!mounted) return;
      setState(() => _loadState = _UserPageLoadState.error);
    }
  }

  String _labelOrPlaceholder(String value) =>
      value.trim().isEmpty ? 'Not available' : value;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF9F9F9),
      appBar: _buildAppBar(context),
      body: Padding(
        padding: gapSymmetric(horizontal: 20, vertical: 20),
        child: switch (_loadState) {
          _UserPageLoadState.loading => Center(
            child: Lottie.asset(AppAssets.loader),
          ),
          _UserPageLoadState.userNotFound => _buildMessageState(
            context,
            icon: Icons.person_off_outlined,
            title: 'User not found',
            subtitle:
                'We couldn’t load this member’s profile. They may have been removed or the link is outdated.',
          ),
          _UserPageLoadState.error => _buildMessageState(
            context,
            icon: Icons.cloud_off_outlined,
            title: 'Something went wrong',
            subtitle:
                'Check your connection and try again. If this keeps happening, open the notification again later.',
            showRetry: true,
          ),
          _UserPageLoadState.ready => Column(
            spacing: h(16),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [_buildUserInfo(), _buildKitchenInfo()],
          ),
        },
      ),
    );
  }

  Widget _buildMessageState(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    bool showRetry = false,
  }) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.grey.shade500),
            SizedBox(height: h(16)),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium,
            ),
            SizedBox(height: h(8)),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade700,
              ),
            ),
            if (showRetry) ...[
              SizedBox(height: h(20)),
              ElevatedButton(
                onPressed: _fetchData,
                child: const Text('Try again'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return UpperTile(
      widget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "User Information",
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Name:", style: Theme.of(context).textTheme.headlineLarge),
              Flexible(
                child: Text(
                  _labelOrPlaceholder(userName),
                  textAlign: TextAlign.end,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Email:"),
              Flexible(
                child: Text(
                  _labelOrPlaceholder(userEmail),
                  textAlign: TextAlign.end,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKitchenInfo() {
    return UpperTile(
      widget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Kitchen Information",
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Kitchen Name:",
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              Flexible(
                child: Text(
                  _labelOrPlaceholder(kitchenName),
                  textAlign: TextAlign.end,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
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
        "User Information",
        style: Theme.of(context).textTheme.headlineLarge,
      ),
    );
  }
}
