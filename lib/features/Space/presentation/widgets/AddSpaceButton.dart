import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/utils/snackbars/snack_bar_service.dart';
import '../../../../core/widgets/text_form_field.dart';
import '../controllers/space_controller.dart';


class AddSpaceFloatingButton extends ConsumerStatefulWidget{
  AddSpaceFloatingButton({super.key});
  final TextEditingController _controller = TextEditingController();
  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _AddSpaceFloatingButton();
  }

}



class _AddSpaceFloatingButton extends ConsumerState<AddSpaceFloatingButton> {
   _AddSpaceFloatingButton();

   @override
  void dispose() {
    super.dispose();
    widget._controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: EColors.primary,
      child: const Icon(Icons.add, color: Colors.white),
      onPressed: () {

        showDialog(
          context: context,
          builder: (c) {
            return AlertDialog(
              elevation: 1,
              title: Text('Add New Space',style: Theme.of(context).textTheme.titleMedium!.apply(color: EColors.accentPrimary),),
              content: TextFormFieldWidget(
                labelText: 'Space Name',
                controller: widget._controller,

                prefixIcon: const Icon(Icons.store_mall_directory_sharp),
                hint: 'eg. Home Space',
              ),
              actions: [
                SizedBox(
                  width: 400,
                  child: Row(
                    children: [
                      Expanded(
                        child: Consumer(
                          builder: (_, ref, __) {
                            final control = ref.read(addNewSpaceLoadingProvider.notifier);
                            final isLoading = ref.watch(
                              addNewSpaceLoadingProvider,
                            );
                            return ElevatedButton(
                              onPressed: () async {
                                control.state = true;
                                final isSpaceCreating = ref.read(
                                  isSpaceCreatingProvider,
                                );
                                if (isSpaceCreating) return;
                                try{
                                  final spaceController = ref.read(
                                    isSpaceCreatingProvider.notifier,
                                  );
                                  spaceController.state = true;
                                  final controller = ref.read(
                                    spaceControllerProvider.notifier,
                                  );
                                  ref.read(spaceNameProvider.notifier).state = widget._controller.text;
                                  final isDone = await controller.addNewSpace();
                                  if(!isDone) return;
                                  if (context.mounted) {
                                    context.pop();
                                  }
                                }catch(e){
                                  SnackBarService.showError('something went wrong');
                                }finally{
                                  final spaceController = ref.read(
                                    isSpaceCreatingProvider.notifier,
                                  );

                                  spaceController.state = false;
                                  control.state = false;                                  }
                              },
                              child: isLoading
                                  ? CircularProgressIndicator(
                                color: Colors.white,
                              )
                                  :const  Text("create"),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );

      },
    );
  }
}
