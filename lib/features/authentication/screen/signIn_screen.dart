// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();

//   static Route<LoginScreen> route(RouteSettings routeSettings) {
//     return CupertinoPageRoute<LoginScreen>(settings: routeSettings, builder: (_) => const LoginScreen());
//   }
// }

// class _LoginScreenState extends State<LoginScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(appBar: AppBar(title: const Text('Home Screen')));
//   }
// }
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:omkar_sale/core/app/all_import_file.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static Route<LoginScreen> route(RouteSettings routeSettings) {
    return CupertinoPageRoute<LoginScreen>(
      settings: routeSettings,
      builder: (_) => BlocProvider(
        create: (context) => SignInCubit(),
        child: const LoginScreen(),
      ),
    );
  }

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController(
    text: 'test@gmail.com',
  );
  final TextEditingController _passwordController = TextEditingController(
    text: 'testtest',
  );
  final GlobalKey<CustomTextFieldState> _emailKey = GlobalKey();
  final GlobalKey<CustomTextFieldState> _passwordKey = GlobalKey();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Widget _buildLogoCard() {
    return Container(
      width: context.dpWidth(context.isMobile ? 0.4 : 0.2),
      height: context.dpWidth(context.isMobile ? 0.4 : 0.2),
      padding: EdgeInsets.all(20.sp(context)),
      decoration: BoxDecoration(
        color: AppThemeColors.whiteColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: context.primaryColor.withValues(alpha: 0.2),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const CustomImageWidget(
        heroTag: 'AppIconHeroTag',
        imagePath: AppImage.icIconHome,
        fit: BoxFit.contain,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignInCubit, SignInState>(
      listener: (context, state) async {
        // state.log('SignInCubit');

        if (state is SignInSuccess) {
          //   state.log('SignInSuccess');
          context.read<UserDetailsCubit>().updateUserDetails(state.userDetails);

          await context.read<AuthCubit>().updateAuthDetails(
            jwtToken: state.jwtToken,
            userData: state.userDetails.toJson(),
          );
          await Navigator.of(context).pushReplacementNamed(Routes.mainScreen);
        }
        if (state is SignInFailure) {
          context.showSnackBar(
            message: state.exception.errorMessageKey.tr(context),
            backgroundColor: context.colorScheme.error,
          );
        }
      },
      child: Scaffold(
        // AppBar with settings to prevent color change on scroll
        appBar: AppBar(
          toolbarHeight: 0,
          elevation: 0,
          scrolledUnderElevation:
              0, // Prevents color change when content scrolls under
          backgroundColor: context.scaffoldBackgroundColor,
          systemOverlayStyle: context.surfaceSystemOverlay,
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                // KEY: This forces the content to be at least as tall as the screen
                // allowing MainAxisAlignment.center to actually work.
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: CustomPaddingWidget.only(
                    fixedTopPadding: MediaQuery.of(context).padding.top,
                    fixedBottomPadding: MediaQuery.of(context).padding.bottom,
                    child: Container(
                      //    color: Colors.amber,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          // This will now perfectly center your content
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            //const SizedBox(height: 40), // Top safety margin
                            _buildLogoCard(),
                            SizedBox(height: 32.sp(context)),

                            Text(
                              'welcomeBackLbl'.tr(context),
                              style: GoogleFonts.manrope(
                                fontSize: 32.sp(context),
                                fontWeight: FontWeight.w800,
                                color: context.colorScheme.onSurface,
                              ),
                            ),

                            SizedBox(height: 8.sp(context)),

                            Text(
                              'loginDescriptionLbl'.tr(context),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.manrope(
                                fontSize: 16.sp(context),
                              ),
                            ),

                            SizedBox(height: 48.sp(context)),
                            // --- EMAIL FIELD USING AppTextField ---
                            CustomTextField(
                              key: _emailKey,
                              controller: _emailController,
                              hintText: 'enterEmailLbl'.tr(context),
                              suffixIcon: Icon(
                                Icons.mail_outline,
                                size: 22.sp(context),
                                color: context.colorScheme.onSurface.withValues(
                                  alpha: 0.4,
                                ),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              fillColor: context.colorScheme.secondary,
                              borderRadius: 16.sp(context),
                              validator: (value) {
                                if (value == null || !value.contains('@'))
                                  return 'invalidEmailLbl'.tr(context);
                                return null;
                              },
                            ),

                            SizedBox(height: 20.sp(context)),

                            CustomTextField(
                              key: _passwordKey,
                              controller: _passwordController,
                              hintText: 'enterPasswordLbl'.tr(context),
                              isPassword:
                                  true, // Automatically handles visibility toggle
                              fillColor: context.colorScheme.secondary,
                              borderRadius: 16.sp(context),
                              validator: (value) {
                                if (value == null)
                                  return 'passwordRequiredLbl'.tr(context);
                                return null;
                              },
                            ),

                            SizedBox(height: 32.sp(context)),

                            // Login Button
                            BlocBuilder<SignInCubit, SignInState>(
                              builder: (context, state) {
                                return CustomRoundedButtonWidget(
                                  isLoading: state is SignInProgress,
                                  text: 'Login'.tr(context),
                                  stretch: true, // Full width
                                  height: 56.sp(context),
                                  textStyle: TextStyle(
                                    fontSize: 16.sp(context),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF8E2DE2),
                                      Color(0xFF4A00E0),
                                    ],
                                  ),
                                  shadowColor: const Color(0xFF4A00E0),
                                  elevation: 8,
                                  borderRadius: BorderRadius.circular(16),
                                  onPressed: () {
                                    if (_formKey.currentState?.validate() ??
                                        false) {
                                      if (_emailController.text
                                          .trim()
                                          .isEmpty) {
                                        _emailKey.currentState?.shake();
                                        return;
                                      }
                                      if (_passwordController.text
                                          .trim()
                                          .isEmpty) {
                                        _passwordKey.currentState?.shake();
                                        return;
                                      }

                                      context.read<SignInCubit>().signInUser(
                                        email: _emailController.text.trim(),
                                        password: _passwordController.text
                                            .trim(),
                                      );
                                    }
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
