import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../design_system/tokens/category_colors.dart';
import '../models/category.dart';
import '../models/subcategory.dart';

final mockCategories = [
  // Expenses
  Category(
    id: 'cat_home',
    type: CategoryType.expense,
    name: 'Home',
    icon: PhosphorIconsRegular.house,
    color: CategoryColors.all[3],
  ),
  Category(
    id: 'cat_groceries',
    type: CategoryType.expense,
    name: 'Groceries',
    icon: PhosphorIconsRegular.shoppingCart,
    color: CategoryColors.all[13],
  ),
  Category(
    id: 'cat_transport',
    type: CategoryType.expense,
    name: 'Transport',
    icon: PhosphorIconsRegular.car,
    color: CategoryColors.all[20],
  ),
  Category(
    id: 'cat_leisure',
    type: CategoryType.expense,
    name: 'Leisure',
    icon: PhosphorIconsRegular.confetti,
    color: CategoryColors.all[4],
  ),
  Category(
    id: 'cat_health',
    type: CategoryType.expense,
    name: 'Health',
    icon: PhosphorIconsRegular.heartbeat,
    color: CategoryColors.all[0],
  ),
  Category(
    id: 'cat_subscriptions',
    type: CategoryType.expense,
    name: 'Subscriptions',
    icon: PhosphorIconsRegular.arrowsClockwise,
    color: CategoryColors.all[30],
  ),
  Category(
    id: 'cat_shopping',
    type: CategoryType.expense,
    name: 'Shopping',
    icon: PhosphorIconsRegular.shoppingBag,
    color: CategoryColors.all[37],
  ),
  Category(
    id: 'cat_education',
    type: CategoryType.expense,
    name: 'Education',
    icon: PhosphorIconsRegular.graduationCap,
    color: CategoryColors.all[6],
  ),
  // Income
  Category(
    id: 'cat_salary',
    type: CategoryType.income,
    name: 'Salary',
    icon: PhosphorIconsRegular.briefcase,
    color: CategoryColors.all[11],
  ),
  Category(
    id: 'cat_freelance',
    type: CategoryType.income,
    name: 'Freelance',
    icon: PhosphorIconsRegular.laptop,
    color: CategoryColors.all[15],
  ),
  Category(
    id: 'cat_refunds',
    type: CategoryType.income,
    name: 'Refunds',
    icon: PhosphorIconsRegular.receipt,
    color: CategoryColors.all[18],
  ),
  Category(
    id: 'cat_gifts',
    type: CategoryType.income,
    name: 'Gifts',
    icon: PhosphorIconsRegular.gift,
    color: CategoryColors.all[39],
  ),
];

const mockSubcategories = [
  Subcategory(id: 'sub_home_rent', categoryId: 'cat_home', name: 'Rent'),
  Subcategory(
    id: 'sub_home_internet',
    categoryId: 'cat_home',
    name: 'Internet',
  ),
  Subcategory(
    id: 'sub_home_utilities',
    categoryId: 'cat_home',
    name: 'Utilities',
  ),
  Subcategory(
    id: 'sub_home_maintenance',
    categoryId: 'cat_home',
    name: 'Maintenance',
  ),
  Subcategory(
    id: 'sub_groceries_supermarket',
    categoryId: 'cat_groceries',
    name: 'Supermarket',
  ),
  Subcategory(
    id: 'sub_groceries_market',
    categoryId: 'cat_groceries',
    name: 'Local market',
  ),
  Subcategory(
    id: 'sub_transport_fuel',
    categoryId: 'cat_transport',
    name: 'Fuel',
  ),
  Subcategory(
    id: 'sub_transport_public',
    categoryId: 'cat_transport',
    name: 'Public transport',
  ),
  Subcategory(
    id: 'sub_transport_parking',
    categoryId: 'cat_transport',
    name: 'Parking',
  ),
  Subcategory(
    id: 'sub_transport_insurance',
    categoryId: 'cat_transport',
    name: 'Car insurance',
  ),
  Subcategory(
    id: 'sub_leisure_restaurants',
    categoryId: 'cat_leisure',
    name: 'Restaurants',
  ),
  Subcategory(
    id: 'sub_leisure_bars',
    categoryId: 'cat_leisure',
    name: 'Bars & cafés',
  ),
  Subcategory(
    id: 'sub_leisure_events',
    categoryId: 'cat_leisure',
    name: 'Events',
  ),
  Subcategory(
    id: 'sub_leisure_travel',
    categoryId: 'cat_leisure',
    name: 'Travel',
  ),
  Subcategory(
    id: 'sub_health_pharmacy',
    categoryId: 'cat_health',
    name: 'Pharmacy',
  ),
  Subcategory(
    id: 'sub_health_doctor',
    categoryId: 'cat_health',
    name: 'Doctor visits',
  ),
  Subcategory(
    id: 'sub_subscriptions_streaming',
    categoryId: 'cat_subscriptions',
    name: 'Streaming',
  ),
  Subcategory(
    id: 'sub_subscriptions_gym',
    categoryId: 'cat_subscriptions',
    name: 'Gym',
  ),
  Subcategory(
    id: 'sub_subscriptions_phone',
    categoryId: 'cat_subscriptions',
    name: 'Phone',
  ),
  Subcategory(
    id: 'sub_subscriptions_apps',
    categoryId: 'cat_subscriptions',
    name: 'Apps',
  ),
  Subcategory(
    id: 'sub_shopping_clothing',
    categoryId: 'cat_shopping',
    name: 'Clothing',
  ),
  Subcategory(
    id: 'sub_shopping_electronics',
    categoryId: 'cat_shopping',
    name: 'Electronics',
  ),
  Subcategory(
    id: 'sub_education_books',
    categoryId: 'cat_education',
    name: 'Books',
  ),
  Subcategory(
    id: 'sub_education_courses',
    categoryId: 'cat_education',
    name: 'Courses',
  ),
  Subcategory(
    id: 'sub_salary_base',
    categoryId: 'cat_salary',
    name: 'Base pay',
  ),
  Subcategory(id: 'sub_salary_bonus', categoryId: 'cat_salary', name: 'Bonus'),
  Subcategory(
    id: 'sub_freelance_design',
    categoryId: 'cat_freelance',
    name: 'Design',
  ),
  Subcategory(
    id: 'sub_freelance_consulting',
    categoryId: 'cat_freelance',
    name: 'Consulting',
  ),
  Subcategory(
    id: 'sub_refunds_health',
    categoryId: 'cat_refunds',
    name: 'Health refunds',
  ),
  Subcategory(
    id: 'sub_refunds_expenses',
    categoryId: 'cat_refunds',
    name: 'Expense refunds',
  ),
  Subcategory(id: 'sub_gifts_family', categoryId: 'cat_gifts', name: 'Family'),
  Subcategory(
    id: 'sub_gifts_friends',
    categoryId: 'cat_gifts',
    name: 'Friends',
  ),
];
