import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_bloc.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_state.dart';
import 'package:share_plus/share_plus.dart';

class SmartCartPage extends StatelessWidget {
  const SmartCartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Color(0xffF9F9F9),
          appBar: _buildAppBar(context),
          body: SafeArea(
            child: Padding(
              padding: gapSymmetric(horizontal: 20, vertical: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Table(
                        border: TableBorder.all(color: Colors.grey, width: 1),
                        children: [
                          TableRow(
                            decoration: BoxDecoration(color: Colors.grey[200]),
                            children: [
                              _buildTableCell('Count'),
                              _buildTableCell('Item Name'),
                            ],
                          ),
                          for (
                            int index = 0;
                            index < state.groceryList.length;
                            index++
                          )
                            TableRow(
                              children: [
                                _buildTableCell('${index + 1}'),
                                _buildTableCell(state.groceryList[index]),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: BottomAppBar(
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildActionButton(
                    context,
                    "Copy",
                    () => _copyToClipboard(context, state.groceryList),
                  ),
                  _buildActionButton(
                    context,
                    "Share",
                    () => _shareContent(context, state.groceryList),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _copyToClipboard(
    BuildContext context,
    List<String> itemList,
  ) async {
    String content = "Missing Grocery List:\n${itemList.join("\n")}";
    await Clipboard.setData(ClipboardData(text: content));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Content copied to clipboard!')));
  }

  Future<void> _shareContent(
    BuildContext context,
    List<String> itemList,
  ) async {
    String content = "Missing Grocery List:\n${itemList.join("\n")}";
    await Share.share(content);
  }

  Widget _buildTableCell(String content) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(
        content,
        style: TextStyle(fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    VoidCallback onPressed,
  ) {
    return Expanded(
      child: Padding(
        padding: gapOnly(right: 10),
        child: GenericButtonWidget(onPressed: onPressed, text: label),
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
        "Missing Grocery",
        style: Theme.of(context).textTheme.headlineLarge,
      ),
    );
  }
}
