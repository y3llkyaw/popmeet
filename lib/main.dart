import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:popmeet/core/constants/firebase_options.dart';
import 'package:popmeet/data/datasources/firebase_auth_datasource.dart';
import 'package:popmeet/data/datasources/post_datasource.dart';
import 'package:popmeet/data/datasources/profile_datasource.dart';
import 'package:popmeet/data/repositories/auth_repository_impl.dart';
import 'package:popmeet/data/repositories/post_repository_impl.dart';
import 'package:popmeet/data/repositories/profile_repository_impl.dart';
import 'package:popmeet/domain/usecases/auth/register_usecase.dart';
import 'package:popmeet/domain/usecases/auth/sigin_usecase.dart';
import 'package:popmeet/domain/usecases/auth/signout_usecase.dart';
import 'package:popmeet/domain/usecases/posts/createPost_usecase.dart';
import 'package:popmeet/domain/usecases/posts/getAllPost_usecase.dart';
import 'package:popmeet/domain/usecases/posts/getPostsByUid_usecase.dart';
import 'package:popmeet/domain/usecases/profile/createProfile_usecase.dart';
import 'package:popmeet/domain/usecases/profile/updateAvatar_usecase.dart';
import 'package:popmeet/domain/usecases/profile/updateBio_usecase.dart';
import 'package:popmeet/domain/usecases/profile/updateDisplayName_usecase.dart';
import 'package:popmeet/presentation/blocs/auth/auth_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:popmeet/presentation/blocs/post/post_bloc.dart';
import 'package:popmeet/presentation/blocs/profile/profile_bloc.dart';
import 'package:popmeet/presentation/pages/app_view.dart';
import 'package:popmeet/presentation/pages/auth/login.dart';
import 'package:popmeet/presentation/pages/getting_start/getting_start.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorage.webStorageDirectory
        : await getApplicationDocumentsDirectory(),
  );
  await Firebase.initializeApp(
    name: 'popmeet',
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MainApp());
}

class MainApp extends StatefulWidget with WidgetsBindingObserver {
  const MainApp({super.key});
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print(state);
    if (state == AppLifecycleState.resumed) {
      ProfileDatasource.isUserOnline(true);
    } else if (state == AppLifecycleState.paused) {
      ProfileDatasource.isUserOnline(false);
    } else if (state == AppLifecycleState.detached) {
      ProfileDatasource.isUserOnline(false);
    } else if (state == AppLifecycleState.inactive) {
      ProfileDatasource.isUserOnline(false);
    }
  }

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(widget);
    ProfileDatasource.isUserOnline(true);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(widget);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final firebaseAuth = firebase_auth.FirebaseAuth.instance;

    // Auth Bloc
    final authDataSource = FirebaseAuthDataSource(firebaseAuth);
    final authRepository = AuthRepositoryImpl(authDataSource);
    final signInUseCase = SignInUseCase(authRepository);
    final registerUseCase = RegisterUseCase(authRepository);
    final signOutUsecase = SignoutUsecase(authRepository);

    // Profile Bloc
    final profileDatasource = ProfileDatasource();
    final profileRespository =
        ProfileRepositoryImpl(profileDataSource: profileDatasource);
    final createprofileUsecase = CreateprofileUsecase(profileRespository);
    final updatedisplaynameUsecase =
        UpdatedisplaynameUsecase(profileRespository);
    final updateBioUsecase = UpdatebioUsecase(profileRespository);
    final updateAvatarUsecase =
        UpdateAvatarUsecase(repository: profileRespository);

    // Post Bloc
    final postDatasource = PostDatasource();
    final postRepository = PostRepositoryImpl(postDatasource);
    final createPostUsecase = CreatePostUsecase(repository: postRepository);
    final getpostsbyuidUsecase =
        GetpostsbyuidUsecase(repository: postRepository);
    final getallpostUsecase = GetallpostUsecase(repository: postRepository);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              AuthBloc(signInUseCase, registerUseCase, signOutUsecase),
        ),
        BlocProvider(
          create: (context) => ProfileBloc(createprofileUsecase,
              updatedisplaynameUsecase, updateBioUsecase, updateAvatarUsecase),
        ),
        BlocProvider(
            lazy: false,
            create: (conext) => PostBloc(
                createPostUsecase, getpostsbyuidUsecase, getallpostUsecase))
      ],
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: StreamBuilder(
              stream: firebaseAuth.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data!.displayName == null) {
                    return const GettingStartPage();
                  }
                  return const AppView();
                } else {
                  return const LoginPage();
                }
              })),
    );
  }
}
