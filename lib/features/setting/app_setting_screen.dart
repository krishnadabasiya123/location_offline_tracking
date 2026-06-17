import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:omkar_sale/core/app/all_import_file.dart';
import 'package:omkar_sale/features/setting/cubit/setting_cubit.dart';
import 'package:url_launcher/url_launcher.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => BlocProvider(
        create: (context) => AppSettingCubit(),
        child: const AppSettingsScreen(),
      ),
    );
  }
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  @override
  void initState() {
    Future.microtask(() async {
      fetchAppSetting();
    });
    super.initState();
  }

  void fetchAppSetting() {
    context.read<AppSettingCubit>().fetchAppSetting(type: 'privacy_policy');
  }

  FutureOr<bool> _onTapUrl(String url) async {
    final canLaunch = await canLaunchUrl(Uri.parse(url));
    if (canLaunch) {
      await launchUrl(Uri.parse(url));
    } else {
      log('Error Launching URL : $url', name: 'Launch URL');
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'privacyPolicyLbl'.tr(context)),
      body: CustomPaddingWidget.symmetric(
        child: BlocBuilder<AppSettingCubit, AppSettingState>(
          builder: (context, state) {
            state.log('AppSettingCubit');
            if (state is AppSettingFetchFailure) {
              return Center(
                child: CustomErrorWidget(
                  errorType: state.exception.type,
                  subtitle: state.exception.errorMessageKey.tr(context),
                  onRetry: fetchAppSetting,
                ),

                // child: ErrorContainer(
                //   errorMessage: convertErrorCodeToLanguageKey(state.errorCode),
                //   onTapRetry: fetchAppSetting,
                //   showErrorImage: true,
                //   errorMessageColor: Theme.of(context).primaryColor,
                // ),
              );
            }

            if (state is AppSettingSuccess) {
              return SingleChildScrollView(
                child: HtmlWidget(
                  state.appSettingsText,
                  onErrorBuilder: (_, e, err) => Text('$e error: $err'),
                  onLoadingBuilder: (_, e, l) => const Center(child: CircularProgressIndicator()),
                  textStyle: GoogleFonts.manrope(textStyle: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onTertiary)),
                  customStylesBuilder: (element) {
                    // log(element.className, name: 'className');
                    // log(element.localName!, name: 'localName');
                    // log(element.outerHtml, name: 'outerHtml');

                    // log(element.classes.contains('a').toString(), name: 'contains');
                    // log(element.attributes.toString(), name: 'attributes');
                    if (element.localName == 'a') {
                      return {
                        'color': 'black',
                        'font-weight': 'bold',
                        'text-decoration': 'underline',
                        'border-bottom': '1px solid white',
                        'font-size': '18px',
                      };
                    }
                    return null;
                  },
                  // customWidgetBuilder: (element) {
                  //   // log(element.outerHtml, name: 'toString');
                  //   // final src = element.attributes['src'];
                  //   // log(src.toString());
                  //   if (element.toString() == '<html a>') {
                  //     return Text(
                  //       element.text,
                  //       style: TextStyle(
                  //         fontWeight: FontWeight.bold,
                  //         decoration: TextDecoration.underline,
                  //         fontSize: 15,
                  //         color: Theme.of(context).colorScheme.onTertiary,
                  //       ),
                  //     );
                  //   }
                  //   return null;
                  // },
                  onTapUrl: _onTapUrl,
                ),
              );
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
