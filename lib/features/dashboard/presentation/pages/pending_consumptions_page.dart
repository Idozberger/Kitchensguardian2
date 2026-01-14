import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/features/dashboard/domain/entities/consumption_confirmation.dart';
import 'package:foodkitchen/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:foodkitchen/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:foodkitchen/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/consumption_confirmation_card.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

class PendingConsumptionsPage extends StatefulWidget {
  final String kitchenId;

  const PendingConsumptionsPage({super.key, required this.kitchenId});

  @override
  State<PendingConsumptionsPage> createState() =>
      _PendingConsumptionsPageState();
}

class _PendingConsumptionsPageState extends State<PendingConsumptionsPage> {
  late final DashboardBloc _dashboardBloc;

  @override
  void initState() {
    super.initState();
    _dashboardBloc = context.read<DashboardBloc>();
    _fetchPendingConsumptions();
  }

  void _fetchPendingConsumptions() {
    _dashboardBloc.add(
      GetConsumptionConfirmationPendingEvent(kitchenId: widget.kitchenId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF9F9F9),
      appBar: _buildAppBar(context),
      body: _buildBody(),
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
        "Consumption Confirmations",
        style: Theme.of(context).textTheme.headlineLarge,
      ),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        return switch (state) {
          DashboardLoading() => const _LoadingState(),
          DashboardLoaded() => _LoadedContent(
            state: state,
            kitchenId: widget.kitchenId,
          ),
          _ => _buildErrorState(),
        };
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Something went wrong. Please try again."),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchPendingConsumptions,
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(child: Lottie.asset(AppAssets.loader));
  }
}

class _LoadedContent extends StatelessWidget {
  final String kitchenId;
  final DashboardLoaded state;

  const _LoadedContent({required this.state, required this.kitchenId});

  @override
  Widget build(BuildContext context) {
    final consumptions = (state).comsumptionConfirmationPending;

    if (consumptions.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(vertical: h(16), horizontal: w(12)),
      itemCount: consumptions.length,
      separatorBuilder: (context, index) => SizedBox(height: h(12)),
      itemBuilder: (context, index) {
        final item = consumptions[index];
        return ConsumptionConfirmationCard(
          confirmationId: item.id,
          itemName: item.itemName,
          quantity: item.quantity,
          addedAt: _formatDate(item.addedAt),
          expiresAt: _formatDate(item.expiresAt),
          predictedDepletionDate: _formatDate(item.predictedDepletionDate),
          onConfirm: () => _handleConfirm(context, item),
          onDeny: () => _handleDeny(context, item),
          unit: item.unit,
          status: item.status,
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final DateFormat formatter = DateFormat('MMM d, yyyy');
    return formatter.format(date);
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Text(
        'No pending consumption confirmations',
        style: Theme.of(
          context,
        ).textTheme.headlineMedium?.copyWith(color: Colors.grey[600]),
      ),
    );
  }

  void _handleConfirm(BuildContext context, ConsumptionConfirmation item) {
    context.read<DashboardBloc>().add(
      RespondConsumptionConfirmationPendingEvent(
        kitchenId: kitchenId,
        confirmationId: item.confirmationId,
        actualQuantityRemaining: "",
        responseText: "confirmed",
      ),
    );
  }

  void _handleDeny(BuildContext context, ConsumptionConfirmation item) {
    context.read<DashboardBloc>().add(
      RespondConsumptionConfirmationPendingEvent(
        kitchenId: kitchenId,
        confirmationId: item.confirmationId,
        actualQuantityRemaining: "",
        responseText: "denied",
      ),
    );
  }
}
