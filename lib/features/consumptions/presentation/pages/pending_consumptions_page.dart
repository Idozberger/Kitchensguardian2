import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/features/consumptions/domain/entities/consumption_confirmation.dart';
import 'package:foodkitchen/features/consumptions/presentation/bloc/consumption_bloc.dart';
import 'package:foodkitchen/features/consumptions/presentation/bloc/consumption_event.dart';
import 'package:foodkitchen/features/consumptions/presentation/bloc/consumption_state.dart';
import 'package:foodkitchen/features/consumptions/presentation/widgets/consumption_confirmation_card.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';
import 'package:go_router/go_router.dart';
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
  late final ConsumptionBloc _consumptionBloc;

  @override
  void initState() {
    super.initState();
    _consumptionBloc = context.read<ConsumptionBloc>();
    _fetchPendingConsumptions();
  }

  void _fetchPendingConsumptions() {
    _consumptionBloc.add(
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
    return BlocConsumer<ConsumptionBloc, ConsumptionState>(
      listener: (context, state) {
        if (state.successMessage != null && state.successMessage!.isNotEmpty) {
          AppToast.show(state.successMessage!, ToastType.success);
          context.pop();
        }
      },
      builder: (context, state) {
        if (state.isLoading) {
          return const _LoadingState();
        }

        if (state.errorMessage != null) {
          return _buildErrorState();
        }

        return _LoadedContent(
          kitchenId: widget.kitchenId,
          consumptions: state.comsumptionConfirmationPending,
        );
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
  final List<ConsumptionConfirmation> consumptions;

  const _LoadedContent({required this.kitchenId, required this.consumptions});

  @override
  Widget build(BuildContext context) {
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
          confirmationId: item.confirmationId,
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
    context.read<ConsumptionBloc>().add(
      RespondConsumptionConfirmationPendingEvent(
        kitchenId: kitchenId,
        confirmationId: item.confirmationId,
        actualQuantityRemaining: "",
        responseText: "confirmed",
      ),
    );
  }

  void _handleDeny(BuildContext context, ConsumptionConfirmation item) {
    context.read<ConsumptionBloc>().add(
      RespondConsumptionConfirmationPendingEvent(
        kitchenId: kitchenId,
        confirmationId: item.confirmationId,
        actualQuantityRemaining: "",
        responseText: "denied",
      ),
    );
  }
}
