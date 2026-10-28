import '../../design_system/design_system.dart';
import '../../l10n/l10n.dart';

/// The name of a group of icons in the user's language.
String iconGroupLabel(AppLocalizations l10n, CategoryIconGroupId id) =>
    switch (id) {
      CategoryIconGroupId.finance => l10n.iconGroupFinance,
      CategoryIconGroupId.commerce => l10n.iconGroupCommerce,
      CategoryIconGroupId.travel => l10n.iconGroupTravel,
      CategoryIconGroupId.health => l10n.iconGroupHealth,
      CategoryIconGroupId.people => l10n.iconGroupPeople,
      CategoryIconGroupId.nature => l10n.iconGroupNature,
      CategoryIconGroupId.games => l10n.iconGroupGames,
      CategoryIconGroupId.media => l10n.iconGroupMedia,
      CategoryIconGroupId.office => l10n.iconGroupOffice,
      CategoryIconGroupId.communication => l10n.iconGroupCommunication,
      CategoryIconGroupId.objects => l10n.iconGroupObjects,
    };
