import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:popmeet/presentation/blocs/profile/profile_bloc.dart';
import 'package:popmeet/presentation/components/form_container.dart';

class NameSetting extends StatefulWidget {
  final String type;

  const NameSetting({super.key, required this.type});

  @override
  State<NameSetting> createState() => _NameSettingState();
}

class _NameSettingState extends State<NameSetting> {
  final textController = TextEditingController();

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change ${widget.type}'),
      ),
      body: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdateSuccess) {
            Navigator.pop(context);
            Navigator.pop(context);
          } else if (state is ProfileUpdating) {
            showDialog(
              context: context,
              builder: (context) => const Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (state is ProfileError) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              FormContainerWidget(
                hintText: 'New ${widget.type}',
                controller: textController,
                maxlen: widget.type == 'Name' ? 35 : 60,
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: MediaQuery.of(context).size.width / 2 - 40,
                      height: 50,
                      decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                      child: const Center(
                        child: Text(
                          'Cancel',
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      if (widget.type == 'Name') {
                        BlocProvider.of<ProfileBloc>(context).add(
                          UpdateDisplayNameEvent(name: textController.text),
                        );
                      } else if (widget.type == 'Bio') {
                        BlocProvider.of<ProfileBloc>(context).add(
                          UpdateBioEvent(bio: textController.text),
                        );
                      }
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width / 2 - 40,
                      height: 50,
                      decoration: const BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                      child: const Center(
                        child: Text(
                          'Save Changes',
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
