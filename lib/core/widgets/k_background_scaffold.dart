import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:skin_app_migration/core/extensions/provider_extensions.dart';
import 'package:skin_app_migration/core/router/app_router.dart';
import 'package:skin_app_migration/core/theme/app_styles.dart';
import 'package:skin_app_migration/features/profile/screens/edit_profile_screen.dart';

import '../../features/auth/providers/my_auth_provider.dart';
import '../constants/app_assets.dart';

class KBackgroundScaffold extends StatefulWidget {
  const KBackgroundScaffold({
    super.key,
    required this.body,
    this.loading = false,
    this.appBar,
    this.showDrawer = false,
    this.margin,
  });

  final Widget body;
  final bool loading;

  final PreferredSizeWidget? appBar;
  final bool showDrawer;
  final EdgeInsetsGeometry? margin;

  @override
  State<KBackgroundScaffold> createState() => _BackgroundScaffoldState();
}

class _BackgroundScaffoldState extends State<KBackgroundScaffold> {
  // @override
  // void initState() {
  //   super.initState();
  //   Future.microtask(() {
  //     Provider.of<AppVersionProvider>(context, listen: false).fetchAppVersion();
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<MyAuthProvider>();

    return Scaffold(
      appBar: widget.appBar,
      drawer: widget.showDrawer
          ? Drawer(
              child: ListView(
                children: [
                  SizedBox(
                    height: 0.25.sh,
                    child: UserAccountsDrawerHeader(
                      currentAccountPictureSize: Size(0.25.sw, 0.25.sw),
                      currentAccountPicture: CircleAvatar(
                        child: Builder(
                          builder: (context) {
                            return ClipOval(
                              child: CircleAvatar(
                                radius: 0.3.sw,
                                backgroundImage:

                                authProvider.userData!.isGoogle!?NetworkImage(context.readAuthProvider.user!.photoURL!):authProvider.userData!.imageUrl!=null?
                                NetworkImage(context.readAuthProvider.userData!.imageUrl!):
                                AssetImage(AppAssets.profileImage),

                              ),
                            );
                          },
                        ),
                      ),
                      accountEmail: Text(context.readAuthProvider.user!.email!),
                      accountName: Text(
                        context.readAuthProvider.user!.displayName ??
                            context.readAuthProvider.userData!.username,
                      ),
                      decoration: BoxDecoration(color: AppStyles.primary),
                    ),
                  ),
                  ListTile(
                    trailing: Icon(Icons.arrow_forward_ios),
                    title: const Text(' About '),
                    onTap: () {
                      AppRouter.back(context);
                      // AppRouter.to(context, AboutUsScreen());
                    },
                  ),
                  ListTile(
                    trailing: Icon(Icons.arrow_forward_ios),
                    title: const Text(' Edit Profile '),
                    onTap: () {
                      AppRouter.back(context);
                      AppRouter.to(context, EditProfileScreen());
                    },
                  ),
                  // if (authProvider.currentUser?.role == AppStatus.kSuperAdmin)
                  //   ListTile(
                  //     trailing: Icon(Icons.arrow_forward_ios),
                  //     title: const Text(' View User '),
                  //     onTap: () {
                  //       MyNavigation.back(context);
                  //       MyNavigation.to(context, ViewUsersScreen());
                  //     },
                  //   ),
                  ListTile(
                    title: const Text(' Terms & conditions '),
                    onTap: () {
                      // AppRouter.to(context, TermsAndConditionsScreen());
                    },
                  ),
                  // ListTile(
                  //   title: Text(
                  //     ' App version  ${context.read<AppVersionProvider>().appVersion}',
                  //   ),
                  // ),
                  ListTile(
                    leading: Icon(Icons.logout_sharp, color: AppStyles.danger),
                    title: Text(
                      ' Logout',
                      style: TextStyle(color: AppStyles.danger),
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(
                              "Confirm Logout",
                              style: TextStyle(fontSize: AppStyles.heading),
                            ),
                            content: Text(
                              "Are you sure to Logout ?",
                              style: TextStyle(fontSize: AppStyles.bodyText),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  // print("Nooooo");
                                  AppRouter.back(context);
                                },
                                child: Text("No"),
                              ),
                              TextButton(
                                onPressed: () async {
                                  context.readAuthProvider.signOut(context);
                                },
                                child: Text("yes"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            )
          : null,
      body: Stack(
        children: [
          Center(
            child: Container(
              margin:
                  widget.margin ??
                  EdgeInsets.symmetric(horizontal: AppStyles.hMargin),
              child: widget.body,
            ),
          ),
          if (widget.loading)
            Positioned(
              child: Stack(
                children: [
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.4),
                    ),
                  ),
                  Center(child: CircularProgressIndicator()),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
