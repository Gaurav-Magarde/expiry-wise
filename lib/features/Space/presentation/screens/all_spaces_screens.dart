import 'package:expiry_wise_app/features/Space/presentation/controllers/space_controller.dart';
import 'package:expiry_wise_app/features/Space/presentation/widgets/space_card.dart';
import 'package:expiry_wise_app/core/utils/snackbars/snack_bar_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/shimmers/space_shimmer.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/text_form_field.dart';
class AllSpacesScreens extends ConsumerStatefulWidget {
  AllSpacesScreens({super.key});

  final TextEditingController _controller = TextEditingController();
  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _AllSpacesScreens();
  }

}



class _AllSpacesScreens extends ConsumerState<AllSpacesScreens> {
  _AllSpacesScreens();


  @override
  void dispose() {
    super.dispose();
    widget._controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: [
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: TextButton(onPressed: (){}, child: Text("Add",style: Theme.of(context).textTheme.titleLarge,)),
          // )
        ],
        title: Text("Spaces"),
      ),
      body: Padding(
        padding: const EdgeInsets.all( 8.0),
        child: Consumer(
          builder: (context, ref, child) {
            final asyncData = ref.watch(spaceControllerProvider);

            return asyncData.when(
              data: (data) {
                final list = data.allSpaces;
                if(list.isEmpty){
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/images/img_5.png'),
                        SizedBox(height: 16),
                        Text(
                          "No space Found!",style: Theme.of(context).textTheme.titleLarge!.apply(color: EColors.primaryDark,fontWeightDelta: 3),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Create a new space to start organising your items",style: Theme.of(context).textTheme.titleSmall!.apply(color: EColors.primaryDark,fontWeightDelta: 2),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, __) {
                    return SizedBox(height: 16);
                  },
                  itemBuilder: (context, index) {
                    final space = list[index];
                    return SpaceCard(space);
                  },
                );
              },
              error: (e, s) => Text("error"),
              loading: () {
                return SpaceCardShimmer();
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: EColors.primary,
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () {

          showDialog(
            context: context,
            builder: (c) {
              return AlertDialog(
                elevation: 1,
                title: Text("Add New Space",style: Theme.of(context).textTheme.titleMedium!.apply(color: EColors.accentPrimary),),
                content: TextFormFieldWidget(
                  labelText: 'Space Name',
                  controller: widget._controller,
                  onChanged: (v) {
                    ref.read(spaceNameProvider.notifier).state = v;
                  },
                  prefixIcon: Icon(Icons.store_mall_directory_sharp),
                  hint: "eg. Home Space",
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
                                    : Text("create"),
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
      ),
    );
  }
}
