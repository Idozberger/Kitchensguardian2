import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/utils/date_format_to_string.dart';
import 'package:foodkitchen/core/utils/dev_logging.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_event.dart';

void queueDefaultPlannerDateRange({
  required UserCubit userCubit,
  required void Function(SetDateRangeEvent event) enqueue,
}) {
  final isSubscribed = userCubit.state.hasPremiumAccess;
  final today = DateTime.now();
  final nextDays = List.generate(
    isSubscribed ? 14 : 3,
    (i) => today.add(Duration(days: i)),
  );

  final formattedStartDate = formatDateToMeetBackendDate(nextDays.first);
  final formattedEndDate = formatDateToMeetBackendDate(nextDays.last);
  devLog(
    "formattedStartDate $formattedEndDate || formattedEndDate $formattedEndDate",
  );

  enqueue(
    SetDateRangeEvent(
      kitchenId: userCubit.state.activeKitchenId,
      startDate: formattedStartDate,
      endDate: formattedEndDate,
    ),
  );
}
