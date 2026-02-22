import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/features/smart_kitcheb_setup/data/models/kitchen_section_model.dart';

final kSections = <KitchenSection>[
  KitchenSection(
    id: 'fridge',
    title: 'Fridge',
    subtitle: 'Shelves & door items',
    hint:
        'Open the fridge fully and take one clear photo showing all shelves and the door.',
    icon: AppAssets.fridge,
    accent: AppColors.primaryColor,
  ),
  KitchenSection(
    id: 'freezer',
    title: 'Freezer',
    subtitle: 'Frozen food & compartments',
    hint: 'Take one wide photo showing all frozen items clearly.',
    icon: AppAssets.freezer,
    accent: AppColors.primaryColor,
  ),
  KitchenSection(
    id: 'pantry',
    title: 'Pantry / Dry Storage',
    subtitle: 'Cans, grains & dry goods',
    hint: 'One clear photo of the pantry shelves is enough.',
    icon: AppAssets.pantryDryStorage,
    accent: AppColors.primaryColor,
  ),
  KitchenSection(
    id: 'spices',
    title: 'Spices & Seasonings',
    subtitle: 'Jars & spice containers',
    hint: 'Take one clear photo showing all spice jars with labels visible.',
    tip: """Why spices matter
Spices are a key part of accurate recipe suggestions and aren’t bought often.
Please make sure labels are visible so we can identify everything correctly.""",
    icon: AppAssets.spices,
    accent: AppColors.primaryColor,
  ),
  KitchenSection(
    id: 'misc',
    title: 'Miscellaneous',
    subtitle: 'Counter, snacks & extras',
    hint: 'One clear photo of all remaining items is perfect.',
    icon: AppAssets.miscellaneous,
    accent: AppColors.primaryColor,
  ),
  KitchenSection(
    id: 'other',
    title: 'Other Items',
    subtitle: 'Anything not covered above',
    hint:
        'Take one clear photo of any kitchen items that don’t fit into the other sections.',
    tip: '''Why add other items?
This helps us capture everything in your kitchen, even items that don’t belong to a specific category.''',
    icon: AppAssets.others,
    accent: AppColors.primaryColor,
  ),
];
