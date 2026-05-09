import 'dart:io';

import 'package:cinch/components/plain_text_field.dart';
import 'package:cinch/components/centered_growing_amount_field.dart';
import 'package:cinch/components/location_picker_trigger.dart';
import 'package:cinch/components/money_source_picker_trigger.dart';
import 'package:cinch/components/shake_on_invalid.dart';
import 'package:cinch/components/tag_picker_trigger.dart';
import 'package:cinch/components/switcher.dart';
import 'package:cinch/core/common/ui_state.dart';
import 'package:cinch/core/services/image_storage_service.dart';
import 'package:cinch/core/services/location_storage_service.dart';
import 'package:cinch/core/services/money_source_storage_service.dart';
import 'package:cinch/core/services/tag_storage_service.dart';
import 'package:cinch/core/services/transaction_storage_service.dart';
import 'package:cinch/core/utils/date_time_format.dart';
import 'package:cinch/core/utils/exif_date.dart';
import 'package:cinch/components/time_picker_trigger.dart';
import 'package:cinch/providers/add_transaction_screen.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

Future<void> openAddTransactionScreen(
  BuildContext context, {
  bool takePhoto = false,
}) async {
  AddTransactionScreenState addTransactionScreenState =
      AddTransactionScreenState(imagePath: null);
  DateTime? initialTime;
  if (takePhoto) {
    final imageStorage = context.read<ImageStorageService>();
    final XFile? captured = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );
    if (captured != null) {
      final bytes = await captured.readAsBytes();
      final imagePath = await imageStorage.saveBytes(
        bytes,
        '${yymmddHHmmss(DateTime.now())}.jpeg',
      );
      addTransactionScreenState = AddTransactionScreenState(
        imagePath: imagePath,
      );
      initialTime = await readImageDateTimeFromBytes(bytes);
    }
  }

  if (!context.mounted) return;
  final locationStorage = context.read<LocationStorageService>();
  final moneySourceStorage = context.read<MoneySourceStorageService>();
  final tagStorage = context.read<TagStorageService>();
  final transactionStorage = context.read<TransactionStorageService>();
  return Navigator.of(context).push<void>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => ChangeNotifierProvider(
        create: (_) => AddTransactionScreenProvider(
          initialScreenState: addTransactionScreenState,
          locationStorage: locationStorage,
          moneySourceStorage: moneySourceStorage,
          tagStorage: tagStorage,
          transactionStorage: transactionStorage,
          initialTime: initialTime,
        ),
        child: const AddTransactionScreen(),
      ),
    ),
  );
}

class AddTransactionScreen extends StatelessWidget {
  const AddTransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<AddTransactionScreenProvider>(
          builder: (context, value, child) => switch (value.state) {
            Loading() => Container(),
            Initial() => Container(),
            Error() => Container(),
            Success(:final data) => LayoutBuilder(
              builder: (context, constraints) => AnimatedPadding(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                padding: EdgeInsets.only(
                  bottom: MediaQuery.viewInsetsOf(context).bottom,
                ),
                child: SizedBox(
                  height: constraints.maxHeight,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      spacing: 16,
                      children: [
                        Expanded(
                          child: ShakeOnInvalid(
                            isInvalid: value.isFieldInvalid(
                              AddTransactionScreenProvider.fieldImage,
                            ),
                            errorTick: value.errorTick,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(16),
                            ),
                            child: DottedBorder(
                              options: RoundedRectDottedBorderOptions(
                                radius: Radius.circular(16),
                                strokeWidth: 3,
                                color: Theme.of(
                                  context,
                                ).colorScheme.primaryContainer,
                                dashPattern: [5, 10],
                                strokeCap: StrokeCap.round,
                              ),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadiusGeometry.circular(
                                      16,
                                    ),
                                    child: Container(
                                      alignment: Alignment.center,
                                      width: double.infinity,
                                      height: double.infinity,
                                      child: (data.imagePath != null)
                                          ? Image.file(
                                              File(data.imagePath!),
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              height: double.infinity,
                                            )
                                          : GestureDetector(
                                              onTapDown: (details) async {
                                                final image =
                                                    await ImagePicker()
                                                        .pickImage(
                                                          source: ImageSource
                                                              .gallery,
                                                        );
                                                if (image != null) {
                                                  if (!context.mounted) return;
                                                  value.setImagePath(
                                                    image,
                                                    context,
                                                  );
                                                }
                                              },
                                              child: Text("Select an image"),
                                            ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    bottom: 8,
                                    child: CenteredGrowingAmountField(
                                      controller: value.amountTextController,
                                      isInvalid: value.isFieldInvalid(
                                        AddTransactionScreenProvider
                                            .fieldAmount,
                                      ),
                                      errorTick: value.errorTick,
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Column(
                                      spacing: 8,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        MoneySourcePickerTrigger(),
                                        TagPickerTrigger(),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    left: 8,
                                    child: Column(
                                      spacing: 8,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TimePickerTrigger(),
                                        LocationPickerTrigger(),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Switcher(
                          labels: const ['Expense', 'Income'],
                          initialIndex: value.isIncome ? 1 : 0,
                          onChanged: (i) => value.setIsIncome(i == 1),
                        ),
                        PlainTextField(
                          controller: value.noteTextController,
                          hintText: "Add a note...",
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 16,
                          children: [
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: Icon(Icons.cancel),
                            ),
                            IconButton.filledTonal(
                              onPressed: value.isSubmitting
                                  ? null
                                  : () async {
                                      final navigator = Navigator.of(context);
                                      final ok = await value.submit();
                                      if (ok) {
                                        navigator.pop();
                                      }
                                    },
                              icon: Icon(Icons.check),
                              iconSize: 48,
                              color: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                            ),
                            IgnorePointer(
                              child: Opacity(
                                opacity: 0,
                                child: IconButton(
                                  onPressed: null,
                                  icon: Icon(Icons.cancel),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          },
        ),
      ),
    );
  }
}
