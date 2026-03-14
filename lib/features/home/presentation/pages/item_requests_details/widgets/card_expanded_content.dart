import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/dialogs/generic_dialog.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/email_domain_formatter.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/core/widgets/generic_text_form_field_widget.dart';
import 'package:foodkitchen/features/home/domain/entities/item_request.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_bloc.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_event.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_state.dart';
import 'package:foodkitchen/features/home/presentation/pages/item_requests_details/widgets/dot.dart';
import 'package:foodkitchen/features/home/presentation/pages/item_requests_details/widgets/inline_text.dart';

class CardExpandedContent extends StatelessWidget {
  final ItemRequest request;
  final HomeState state;
  final bool isPending;

  const CardExpandedContent({
    super.key,
    required this.request,
    required this.state,
    required this.isPending,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            InlineText(text: request.quantity.toString()),
            Dot(),
            InlineText(text: request.unit),
            Dot(),
            InlineText(text: request.group),
          ],
        ),
        gap(height: 8),
        _InfoRow(label: "Requested by", value: request.requesterName),
        _InfoRow(
          label: "Date",
          value:
              "${request.createdAt.day}/${request.createdAt.month}/${request.createdAt.year}",
        ),
        if (request.rejectReason != null)
          _InfoRow(
            label: "Reject Reason",
            value: request.rejectReason!,
            valueColor: Colors.red,
          ),
        if (isPending && context.read<UserCubit>().state.role != "member") ...[
          gap(height: 12),

          _CardActions(request: request, state: state),
        ],
      ],
    );
  }
}

class _CardActions extends StatelessWidget {
  final ItemRequest request;
  final HomeState state;

  const _CardActions({required this.request, required this.state});

  void _onApprove(BuildContext context) {
    context.read<HomeBloc>().add(
      RespondToItemRequestEvent(
        action: 'approved',
        rejectReason: '',
        requestId: request.requestId,
      ),
    );
  }

  void _showRejectDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => GenericDialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Reject Request",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            gap(height: 12),
            Text(
              "Reason for rejection (optional)",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontSize: t(12),
                color: Colors.grey,
              ),
            ),
            gap(height: 8),
            AppTextField(
              isLabled: false,
              controller: controller,
              hintText: "Enter reason...",
              textInputAction: TextInputAction.done,
              color: AppColors.apptextFieldStyleTextColor,
              fillColor: const Color(0xffF9F9F9),
              isFilled: true,
              inputFormatters: [MaxLengthFormatter(150)],
              label: '',
            ),
            gap(height: 20),
            Row(
              children: [
                Expanded(
                  child: GenericButtonWidget(
                    isOutlined: true,
                    onPressed: () => Navigator.pop(ctx),
                    text: "Cancel",
                  ),
                ),
                gap(width: 12),
                Expanded(
                  child: GenericButtonWidget(
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.read<HomeBloc>().add(
                        RespondToItemRejectRequestEvent(
                          action: 'rejected',
                          rejectReason: controller.text.trim(),
                          requestId: request.requestId,
                        ),
                      );
                    },
                    text: "Reject",
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        state.requestApproving
            ? _LoadingButton(color: const Color(0xFF22C55E))
            : _ActionButton(
                label: "Approve",
                color: const Color(0xFF22C55E),
                onTap: () => _onApprove(context),
              ),
        gap(width: 8),
        state.requestRejecting
            ? _LoadingButton(color: const Color(0xFFEF4444))
            : _ActionButton(
                label: "Reject",
                color: const Color(0xFFEF4444),
                onTap: () => _showRejectDialog(context),
              ),
      ],
    );
  }
}

class _LoadingButton extends StatelessWidget {
  final Color color;

  const _LoadingButton({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: h(32),
      width: w(80),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      alignment: Alignment.center,
      child: SizedBox(
        height: h(16),
        width: h(16),
        child: CircularProgressIndicator(strokeWidth: 2, color: color),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: h(32),
        padding: EdgeInsets.symmetric(horizontal: w(16)),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontSize: t(12),
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: h(4)),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontSize: t(12),
              color: const Color(0xFF9CA3AF),
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontSize: t(12),
                color: valueColor ?? const Color(0xFF374151),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
