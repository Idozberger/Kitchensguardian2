// return UpperTile(
//   widget: Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             "Missing Items",
//             style: Theme.of(context).textTheme.headlineLarge,
//           ),
//           TextButton(
//             onPressed: () {},
//             child: Text(
//               "Select All",
//               style: Theme.of(context).textTheme.headlineMedium!.copyWith(
//                 color: AppColors.primaryColor,
//               ),
//             ),
//           ),
//         ],
//       ),
//       gap(height: 14),
//       GenericCircleCheckboxTile(
//         title: '1/2 tsp cayenne pepper',
//         isChecked: true,
//         onChanged: (bool value) {},
//         activeColor: AppColors.primaryColor,
//       ),
//       gap(height: 14),
//       GenericCircleCheckboxTile(
//         title: '1 egg',
//         isChecked: true,
//         onChanged: (bool value) {},
//         activeColor: AppColors.primaryColor,
//       ),
//       gap(height: 14),
//       GenericCircleCheckboxTile(
//         title: '1 cup buttermilk',
//         isChecked: false,
//         onChanged: (bool value) {},
//         activeColor: AppColors.primaryColor,
//       ),
//       gap(height: 15),
//       GenericButtonWidget(onPressed: () {}, text: "Add in List"),
//     ],
//   ),
// );
