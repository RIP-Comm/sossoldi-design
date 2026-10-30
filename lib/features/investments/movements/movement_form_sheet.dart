import 'package:flutter/widgets.dart';

import '../../../mock/models/investment_movement.dart';
import '../../add_transaction/add_sheet.dart';
import '../../add_transaction/add_sheet_draft.dart';

/// Opens the Add sheet on the movement form: [type] selected (a buy by
/// default) and, when given, the position already chosen. Returns whether a
/// movement was saved.
Future<bool> showMovementFormSheet(
  BuildContext context, {
  MovementType type = MovementType.buy,
  String? holdingId,
}) => showAddSheet(
  context,
  draft: AddSheetDraft.movement(movementType: type, holdingId: holdingId),
);
