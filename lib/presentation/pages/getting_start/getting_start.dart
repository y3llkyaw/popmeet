import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:popmeet/core/constants/constants.dart';
import 'package:popmeet/presentation/components/form_container.dart';
import 'package:popmeet/presentation/pages/getting_start/profile_preview.dart';

class GettingStartPage extends StatefulWidget {
  const GettingStartPage({super.key});

  @override
  State<GettingStartPage> createState() => _GettingStartPageState();
}

class _GettingStartPageState extends State<GettingStartPage> {
  Genders? _gender = Genders.other;
  final nameController = TextEditingController();
  final bioController = TextEditingController();

  XFile? image;
  @override
  void dispose() {
    nameController.dispose();
    bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Let\'s set up your Profile',
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(children: [
            const SizedBox(
              height: 20,
            ),
            Builder(builder: (context) {
              if (image != null) {
                return InkWell(
                  onTap: () async {
                    final image = await ImagePicker()
                        .pickImage(source: ImageSource.gallery);
                    setState(() {
                      this.image = image;
                    });
                  },
                  child: SizedBox(
                    height: 200,
                    width: 200,
                    child: CircleAvatar(
                      backgroundImage: FileImage(File(image!.path)),
                    ),
                  ),
                );
              } else {
                return SizedBox(
                  height: 200,
                  width: 200,
                  child: InkWell(
                    onTap: () async {
                      final image = await ImagePicker()
                          .pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        setState(() {
                          this.image = image;
                        });
                      }
                    },
                    child: Stack(
                      fit: StackFit.expand,
                      alignment: Alignment.bottomCenter,
                      children: [
                        const CircleAvatar(
                          backgroundColor: Colors.white,
                          backgroundImage:
                              AssetImage('assets/images/avatar_b.png'),
                        ),
                        Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black26,
                          ),
                          child: const Icon(
                            Icons.add_a_photo,
                            color: Colors.white,
                          ),
                        )
                      ],
                    ),
                  ),
                );
              }
            }),
            const SizedBox(
              height: 20,
            ),
            FormContainerWidget(
              maxlen: 35,
              hintText: 'Name',
              controller: nameController,
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Radio<Genders>(
                  value: Genders.male,
                  groupValue: _gender,
                  onChanged: (Genders? value) {
                    setState(() {
                      _gender = value;
                    });
                  },
                ),
                const Text('Male'),
                Radio<Genders>(
                  value: Genders.female,
                  groupValue: _gender,
                  onChanged: (Genders? value) {
                    setState(() {
                      _gender = value;
                    });
                  },
                ),
                const Text('Female'),
                Radio<Genders>(
                  value: Genders.other,
                  groupValue: _gender,
                  onChanged: (Genders? value) {
                    setState(() {
                      _gender = value;
                    });
                  },
                ),
                const Text('Others'),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            const Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Enter Your Bio',
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                  ),
                )),
            TextFormField(
              controller: bioController,
              maxLength: 60,
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            InkWell(
              onTap: () {
                if (nameController.text != '' &&
                    bioController.text != '' &&
                    image != null &&
                    _gender != null) {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return ProfilePreview(
                      name: nameController.text,
                      bio: bioController.text,
                      image: image!.path,
                      gender: _gender!,
                    );
                  }));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    backgroundColor: Colors.grey,
                    content: Row(
                      children: [
                        Icon(
                          CupertinoIcons.exclamationmark,
                          color: Colors.red,
                        ),
                        Text(
                          'Please fill in all fields',
                          style: TextStyle(color: Colors.white, fontSize: 15),
                        )
                      ],
                    ),
                  ));
                }
              },
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                height: 50,
                child: const Center(
                  child: Text(
                    'Continue',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                ),
              ),
            ),
          ]),
        ));
  }
}
