import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:popmeet/presentation/blocs/auth/auth_bloc.dart';
import 'package:popmeet/presentation/blocs/profile/profile_bloc.dart';
import 'package:popmeet/presentation/pages/auth/login.dart';
import 'package:popmeet/presentation/pages/home/name_setting_page.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cuser = FirebaseAuth.instance.currentUser;
    final profileBloc = BlocProvider.of<ProfileBloc>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  var nameController = TextEditingController();
                  String? displayName =
                      FirebaseAuth.instance.currentUser?.displayName;

                  if (displayName != null) {
                    nameController.text = displayName;
                  }
                  return BlocListener<AuthBloc, AuthState>(
                      bloc: BlocProvider.of<AuthBloc>(context),
                      listener: (context, state) {
                        if (state is ProfileLoading) {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              });
                        }
                      },
                      child: const NameSetting(
                        type: 'Name',
                      ));
                }));
              },
              child: ListTile(
                leading: const Icon(CupertinoIcons.person),
                title: const Text(
                  'Name',
                  style: TextStyle(fontSize: 20),
                ),
                subtitle: BlocBuilder<ProfileBloc, ProfileState>(
                  bloc: profileBloc,
                  builder: (context, state) {
                    if (state is ProfileLoaded) {
                      return Text(
                        state.profile.name.toString(),
                        style: const TextStyle(fontSize: 15),
                      );
                    } else if (state is ProfileLoading) {
                      return const LinearProgressIndicator();
                    } else if (state is ProfileUpdateSuccess) {
                      profileBloc.add(GetProfileEvent(uid: cuser!.uid));
                      return const Text('');
                    }
                    return const Text('');
                  },
                ),
                trailing: const Icon(
                  CupertinoIcons.check_mark,
                  color: Colors.green,
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return BlocListener<AuthBloc, AuthState>(
                      bloc: BlocProvider.of<AuthBloc>(context),
                      listener: (context, state) {
                        if (state is ProfileLoading) {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              });
                        }
                      },
                      child: const NameSetting(
                        type: 'Bio',
                      ));
                }));
              },
              child: ListTile(
                leading: const Icon(
                    CupertinoIcons.rectangle_stack_badge_person_crop),
                title: const Text(
                  'Bio',
                  style: TextStyle(fontSize: 20),
                ),
                subtitle: BlocBuilder<ProfileBloc, ProfileState>(
                  bloc: profileBloc,
                  builder: (context, state) {
                    if (state is ProfileLoaded) {
                      return Text(
                        state.profile.bio.toString(),
                        style: const TextStyle(fontSize: 15),
                      );
                    } else if (state is ProfileLoading) {
                      return const LinearProgressIndicator();
                    } else if (state is ProfileUpdateSuccess) {
                      profileBloc.add(GetProfileEvent(uid: cuser!.uid));
                      return const Text('');
                    }
                    return const Text('');
                  },
                ),
                trailing: Icon(
                    cuser!.emailVerified
                        ? CupertinoIcons.check_mark
                        : CupertinoIcons.exclamationmark,
                    color: cuser!.emailVerified ? Colors.green : Colors.red),
              ),
            ),
            ListTile(
              leading: const Icon(CupertinoIcons.mail),
              title: const Text(
                'Email',
                style: TextStyle(fontSize: 20),
              ),
              subtitle: Text(
                cuser!.email.toString(),
                style: const TextStyle(fontSize: 15),
              ),
              trailing: Icon(
                  cuser!.emailVerified
                      ? CupertinoIcons.check_mark
                      : CupertinoIcons.exclamationmark,
                  color: cuser!.emailVerified ? Colors.green : Colors.red),
            ),
            const ListTile(
              leading: Icon(CupertinoIcons.lock),
              title: Text(
                'Password',
                style: TextStyle(fontSize: 20),
              ),
              subtitle: Text(
                'change your password',
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            InkWell(
              onTap: () {
                BlocProvider.of<AuthBloc>(context).add(AuthSignoutEvent());
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height / 20,
                  decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  child: const Center(
                      child: Text(
                    'sign out',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ))),
            ),
          ],
        ),
      ),
    );
  }
}
