part of 'package:foodkitchen/features/dashboard/presentation/widgets/kitchen_join_notification_card.dart';

({Color color, Color bg, Color border, IconData icon})
kitchenJoinNotificationStatusStyle(String joiningStatus) =>
    switch (joiningStatus) {
      'Approved' => (
        color: Colors.grey.shade800,
        bg: Colors.grey.shade100,
        border: Colors.grey.shade100,
        icon: Icons.check_circle_rounded,
      ),
      'Declined' => (
        color: Colors.grey.shade800,
        bg: Colors.grey.shade100,
        border: Colors.grey.shade100,
        icon: Icons.cancel_rounded,
      ),
      _ => (
        color: Colors.grey.shade800,
        bg: Colors.grey.shade100,
        border: Colors.grey.shade100,
        icon: Icons.check_circle_rounded,
      ),
    };

extension KitchenJoinNotificationCardLayout on KitchenJoinNotificationCard {
  Widget kitchenJoinCardRoot(BuildContext context) {
    final s = kitchenJoinNotificationStatusStyle(joiningStatus);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xffF0F0F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (isLocked)
                  ClipOval(
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: s.bg,
                        child: Text(
                          senderName.isNotEmpty
                              ? senderName[0].toUpperCase()
                              : '?',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: s.color,
                                fontWeight: FontWeight.w800,
                                fontSize: t(18),
                              ),
                        ),
                      ),
                    ),
                  )
                else
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: s.bg,
                    child: Text(
                      senderName.isNotEmpty ? senderName[0].toUpperCase() : '?',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: s.color,
                        fontWeight: FontWeight.w800,
                        fontSize: t(18),
                      ),
                    ),
                  ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [_kitchenJoinBuildNameAndDate(context)],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: s.bg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: s.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [_kitchenJoinBuildStatus(context, s)],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [_kitchenJoinBuildTextBlock(context)],
              ),
            ),
            if (!isActioned) ...[
              const SizedBox(height: 12),
              _kitchenJoinBuildButtons(),
            ],
            if (isLocked)
              Stack(
                clipBehavior: Clip.none,
                children: [
                  SizedBox(height: h(1)),
                  Positioned(
                    left: -h(20),
                    top: -h(180),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: w(360),
                        height: h(200),
                        alignment: Alignment.center,
                        color: Colors.white.withValues(alpha: 0.3),
                        child: Row(
                          spacing: w(12),
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(AppAssets.crownImage, height: h(24)),
                            Text(
                              "Upgrade to add more members",
                              style: Theme.of(context).textTheme.headlineLarge
                                  ?.copyWith(
                                    fontSize: t(14),
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _kitchenJoinBuildNameAndDate(BuildContext context) {
    final child = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          senderName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontSize: t(14),
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          date,
          style: Theme.of(
            context,
          ).textTheme.headlineLarge?.copyWith(fontSize: 11, color: Colors.grey),
        ),
      ],
    );

    return isLocked
        ? ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            child: child,
          )
        : child;
  }

  Widget _kitchenJoinBuildStatus(
    BuildContext context,
    ({Color color, Color bg, Color border, IconData icon}) s,
  ) {
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(s.icon, color: s.color, size: 12),
        const SizedBox(width: 4),
        Text(
          joiningStatus,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: s.color,
            fontSize: t(12),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );

    return isLocked
        ? ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            child: child,
          )
        : child;
  }

  Widget _kitchenJoinBuildTextBlock(BuildContext context) {
    final child = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontSize: t(13),
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          body,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontSize: t(12),
            color: Colors.grey,
            height: 1.5,
          ),
        ),
      ],
    );

    return isLocked
        ? ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            child: child,
          )
        : child;
  }

  Widget _kitchenJoinBuildButtons() {
    final child = Row(
      children: [
        Flexible(
          child: SizedBox(
            height: 40,
            child: GenericButtonWidget(
              isOutlined: true,
              onPressed: isDeclineLoading || isLocked ? () {} : onDecline,
              text: "Decline",
              isLoading: isDeclineLoading,
            ),
          ),
        ),
        SizedBox(width: w(12)),
        Flexible(
          child: SizedBox(
            height: 40,
            child: GenericButtonWidget(
              onPressed: isApproveLoading || isLocked ? () {} : onApprove,
              text: "Approve",
              isLoading: isApproveLoading,
            ),
          ),
        ),
      ],
    );

    return isLocked
        ? ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            child: AbsorbPointer(child: child),
          )
        : child;
  }
}
