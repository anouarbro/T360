import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'pages/controller/responsive_layout.dart';
import 'pages/ui/desktop.dart';
import 'pages/ui/mobile.dart';
import 'pages/ui/tablet.dart';
import 'pages/view/login.dart';
import 'providers/auth_provider.dart';
import 'providers/comment_provider.dart';
import 'providers/study_case_provider.dart';
import 'providers/user_provider.dart';
import 'services/api_service.dart';
import 'themes/theme_provider.dart';

//! Main function to run the app
void main() {
  runApp(
    MultiProvider(
      providers: [
        //! Theme provider to toggle between light and dark modes
        ChangeNotifierProvider(create: (context) => ThemeProvider()),

        //! Auth provider to manage user authentication and token
        ChangeNotifierProvider(create: (context) => AuthProvider()),

        //! User provider to manage user data using the API service
        ChangeNotifierProvider(
            create: (_) => UserProvider(apiService: ApiService())),

        //! StudyCase provider to manage study cases using the API service
        ChangeNotifierProvider(
            create: (_) => StudyCaseProvider(apiService: ApiService())),

        //! Comment provider to manage comments using the API service
        ChangeNotifierProvider(
            create: (_) => CommentProvider(apiService: ApiService())),
      ],
      child: const MyApp(), //! Entry point to the application
    ),
  );
}

//! Main application widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    //! Consumer to listen to changes in AuthProvider for login state
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return MaterialApp(
          title: "TERRAIN 360", //! Application title
          debugShowCheckedModeBanner: false, //! Hide debug banner
          theme: Provider.of<ThemeProvider>(context)
              .themeData, //! Apply current theme (dark/light)

          //! If the user is authenticated (token exists), show the responsive layout
          home: authProvider.token == null
              ? const LoginScreen() //! Show login screen if not authenticated
              : const ResponsiveLayout(
                  mobileBody: Mobile(), //! Mobile layout
                  tabletBody: Tablet(), //! Tablet layout
                  desktopBody: Desktop(), //! Desktop layout
                ),

          //! Handle navigation to different routes
          onGenerateRoute: (RouteSettings settings) {
            WidgetBuilder builder;

            switch (settings.name) {
              case '/dashboard': //! Route to dashboard
                builder = (BuildContext _) => const ResponsiveLayout(
                      mobileBody: Mobile(),
                      tabletBody: Tablet(),
                      desktopBody: Desktop(),
                    );
                break;

              default:
                throw Exception(
                    'Invalid route: ${settings.name}'); //! Handle invalid routes
            }

            //! No animation for route transitions
            return PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  builder(context),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return child; //! No animation on screen transition
              },
            );
          },
        );
      },
    );
  }
}
