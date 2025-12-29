import 'package:expiry_wise_app/features/Space/presentation/controllers/space_controller.dart';
import 'package:expiry_wise_app/core/widgets/text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class JoinSpaceScreen extends ConsumerStatefulWidget {
  const JoinSpaceScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _JoinSpaceScreen();
  }
}

class _JoinSpaceScreen extends ConsumerState<JoinSpaceScreen> {
  _JoinSpaceScreen();
  late TextEditingController _editingController;

  @override
  void initState() {
    _editingController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _editingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text("Join A New Space")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 200,
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width * .7,
                child: Image.asset("assets/images/img_3.png", fit: BoxFit.fill),
              ),
              SizedBox(height: 24),
              Text(
                "Join Your Team's Space",
                style: Theme.of(
                  context,
                ).textTheme.headlineMedium!.apply(fontWeightDelta: 2),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              Text(
                "Enter the invite code shared by your admin to collaborate",
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),

              TextFormFieldWidget(
                controller: _editingController,
                onChanged: (v) {
                  ref.read(joinCodeTextProvider.notifier).state = v;
                },
                hint: "Enter code here",
                labelText: "joining code",
                prefixIcon: Icon(Icons.mail_outline),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  final isJoining = ref.read(isSpaceJoining);
                  if (isJoining) return;
                  ref.read(isSpaceJoining.notifier).state = true;
                  final controller = ref.read(joinSpaceProvider);
                   await controller.joinSpaceByCode();

                  ref.read(isSpaceJoining.notifier).state = false;
                },
                child: Consumer(
                  builder: (_, ref, __) {
                    final isJoining = ref.watch(isSpaceJoining);
                    if (isJoining) {
                      return Row(
                        children: [
                          Text("Joining..."),
                          SizedBox(width: 16),
                          CircularProgressIndicator(),
                        ],
                      );
                    } else {
                      return Text("Join Space");
                    }
                  },
                ),
              ),
              SizedBox(height: 16),
              Text(
                "Don't have the code?Ask your admin.",
                style: Theme.of(context).textTheme.labelMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}
