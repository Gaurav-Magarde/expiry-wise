import 'package:expiry_wise_app/core/theme/colors.dart';
import 'package:expiry_wise_app/features/inventory/data/models/quicklist_model.dart';
import 'package:expiry_wise_app/features/inventory/presentation/controllers/quick_list_controllers/quick_list_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuickListScreen extends ConsumerWidget {
  const QuickListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canPOP = !ref.watch(quickListControllerProvider.select((s)=>s.isEditing));
    return PopScope(
      canPop: canPOP,
      onPopInvokedWithResult: (pop, t) {
        if (!pop) {
          ref
              .read(quickListControllerProvider.notifier)
              .copyWith(isEditing: false);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Consumer(
            builder: (_, ref, _) {
              final isEditing = ref.watch(
                quickListControllerProvider.select((s) => s.isEditing),
              );
              return Text(isEditing ? "Edit Item" : "Quick List");
            },
          ),
          automaticallyImplyLeading: true,
        ),
        backgroundColor: Colors.grey.shade50,
        body: Column(
          children: [
            Expanded(
              child: Consumer(
                builder: (_, ref, _) {
                  final list = ref.watch(quickListItemsControllerProvider);
                  if (list.isLoading) {
                    return Center(child: const CircularProgressIndicator());
                  }
                  if (list.value == null || list.value!.isEmpty) {
                    return Center(child: const Text("No list yet"));
                  }
                  final allItems = list.value!;
                  return ListView.separated(
                    itemBuilder: (context, index) {
                      final item = allItems[index];
                      return QuickListCardWidget(item: item);
                    },
                    separatorBuilder: (_, _) => const SizedBox(height: 4),
                    itemCount: list.value!.length,
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: const FloatingTitleControllerWidget(),
      ),
    );
  }
}

class FloatingTitleControllerWidget extends StatefulWidget {
  const FloatingTitleControllerWidget({super.key});

  @override
  State<FloatingTitleControllerWidget> createState() =>
      _FloatingTitleControllerWidgetState();
}

class _FloatingTitleControllerWidgetState
    extends State<FloatingTitleControllerWidget> {
  late TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _titleController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 24.0, right: 8),
            child: Consumer(
              builder: (_, ref, _) {
                ref.watch(
                  quickListControllerProvider.select((s) => s.isEditing),
                );
                _titleController.text =
                    ref.read(
                      quickListControllerProvider.select((s) => s.title),
                    ) ??
                    '';
                return TextField(
                  maxLines: 1,
                  controller: _titleController,
                  style: Theme.of(context).textTheme.titleMedium,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(left: 8.0, right: 8),
                    hint: Text(
                      "Add Item (eg. Sugar 1kg ) ",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    border: OutlineInputBorder(
                      gapPadding: 16,
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        Consumer(
          builder: (_, ref, _) {
            final isSaving = ref.watch(
              quickListControllerProvider.select((s) => s.isEditing),
            );
            return Row(
              children: [
                if (isSaving)
                  InkWell(
                    onTap: () {
                      ref
                          .read(quickListControllerProvider.notifier)
                          .copyWith(title: '', isEditing: false);
                      _titleController.text = '';
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: EColors.primaryDark,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Icon(
                        Icons.close,
                        size: 30,
                        color: EColors.primary,
                      ),
                    ),
                  ),
                SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    {
                      ref
                          .read(quickListControllerProvider.notifier)
                          .copyWith(title: _titleController.text);
                      ref
                          .read(quickListControllerProvider.notifier)
                          .addNewItem();

                      setState(() {
                        _titleController.text = '';
                        ref
                            .read(quickListControllerProvider.notifier)
                            .copyWith(title: '');
                      });
                    }
                  },
                  child: CircleAvatar(
                    radius: 25,
                    backgroundColor: isSaving
                        ? EColors.primaryDark
                        : EColors.primary,
                    child: Icon(
                      isSaving ? Icons.check : Icons.add,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class QuickListCardWidget extends ConsumerWidget {
  const QuickListCardWidget({required this.item, super.key});

  final QuickListModel item;

  @override
  Widget build(BuildContext context, ref) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16),
      color: Colors.white,
      elevation: 2,
      child: ListTile(
        title: Text(
          item.title,
          style: Theme.of(context).textTheme.titleSmall!.apply(
            fontWeightDelta: 5,
            color: EColors.textPrimary,
            decoration: item.isCompleted
                ? TextDecoration.lineThrough
                : TextDecoration.none,
          ),
        ),

        leading: InkWell(
          onTap: () async {
            await ref
                .read(quickListControllerProvider.notifier)
                .toggleCompleted(item: item);
          },
          child: Icon(
            item.isCompleted
                ? Icons.check_box_outlined
                : Icons.check_box_outline_blank_sharp,
            color: item.isCompleted ? EColors.primaryDark : Colors.grey,
            size: 25,
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.edit_note),
          onPressed: () {
            ref
                .read(quickListControllerProvider.notifier)
                .copyWith(isEditing: true, title: item.title);
          },
        ),
      ),
    );
  }
}
