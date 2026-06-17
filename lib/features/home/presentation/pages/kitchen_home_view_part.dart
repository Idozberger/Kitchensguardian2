// ignore_for_file: use_build_context_synchronously, unnecessary_underscores

part of 'package:foodkitchen/features/home/presentation/pages/kitchen_home_view.dart';

mixin _KitchenHomeViewScanAndRecipes on State<KitchenHomeView> {
  Widget _buildScanReceiptButton(BuildContext context) {
    final state = context.watch<UserCubit>().state;
    final bool isMember = state.role == "member";

    return UpperTile(
      widget: SizedBox(
        height: h(40),
        child: ElevatedButton.icon(
          icon: SvgPicture.asset(
            AppAssets.scanSvg,
            colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
          ),
          onPressed: () {
            if (isMember) {
              AppToast.show(
                "Only the host or co-host can scan receipts.",
                ToastType.error,
                gravity: ToastGravity.TOP,
              );
              return;
            }

            scanDocument(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isMember
                ? Colors.grey.shade300
                : AppColors.primaryColor,
          ),
          label: Text(
            "Scan Receipt",
            style: Theme.of(context).textTheme.headlineMedium!.copyWith(
              fontSize: t(12),
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  void scanDocument(BuildContext context) async {
    final state = context.read<UserCubit>().state;

    if (state.role == "member") {
      AppToast.show(
        "Only host and co-host can scan or add items.",
        ToastType.error,
        gravity: ToastGravity.TOP,
      );
      return;
    }

    final status = await Permission.camera.request();

    if (status.isGranted) {
      await DocumentScannerService().scanDocument(context);
    } else if (status.isDenied) {
      AppToast.show(
        "Camera permission is required to scan receipts.",
        ToastType.error,
        gravity: ToastGravity.TOP,
      );
    } else if (status.isPermanentlyDenied) {
      _showPermissionDialog(context, isPermanent: true);
    }
  }

  void _showPermissionDialog(BuildContext context, {bool isPermanent = false}) {
    showDialog<void>(
      context: context,
      builder: (context) => PermissionDialog(isPermanent: isPermanent),
    );
  }

  Widget _buildFindRecipesButton(BuildContext context) {
    return ActionTile(
      title: "Find Recipes",
      buttonText: "Find Recipes",
      svgPath: AppAssets.findRecipesSvg,
      onTap: canSearchRecipe,
    );
  }

  void navigateToGenerateRecipes() {
    final date = DateFormat('dd/MM/yyyy').format(DateTime.now());
    context.pushNamed(
      Routes.generateRecipes,
      extra: {
        "selected_date": date,
        "selected_meal_type": "Breakfast",
        "is_plan": false,
        "is_edit": false,
      },
    );
  }

  Future<void> canSearchRecipe() async {
    final isSubscribed = context.read<UserCubit>().state.hasPremiumAccess;

    if (!isSubscribed) {
      bool canSearch = await RecipeLimitService.canSearchRecipe();

      if (!canSearch) {
        showLimitDialog(context, () {
          AdService.instance.loadAndShowInterstitial(
            context: context,
            onDismissed: () {
              context.pop();
              navigateToGenerateRecipes();
            },
          );
        });
        return;
      } else {
        navigateToGenerateRecipes();
      }
    } else {
      navigateToGenerateRecipes();
    }
  }

  Widget _buildSuggestionShimmer() {
    return UpperTile(
      widget: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  height: h(20),
                  width: w(120),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(h(8)),
                  ),
                ),
              ),
              Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  height: h(24),
                  width: h(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(h(8)),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: h(12)),
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              width: double.maxFinite,
              height: h(260),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(h(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTonightShimmer() {
    return UpperTile(
      widget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  height: h(20),
                  width: w(120),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(h(8)),
                  ),
                ),
              ),
              Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  height: h(24),
                  width: h(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(h(8)),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: h(12)),
          SizedBox(
            height: h(200),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 2,
              separatorBuilder: (_, __) => SizedBox(width: w(14)),
              itemBuilder: (_, __) => Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  width: w(260),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(h(14)),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: h(12)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: w(4)),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    width: w(8),
                    height: h(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(w(4)),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
