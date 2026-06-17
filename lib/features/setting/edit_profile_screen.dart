import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:omkar_sale/core/app/all_import_file.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();

  static Route<dynamic>? route(RouteSettings settings) {
    return CupertinoPageRoute(
      builder: (_) => BlocProvider(
        create: (context) => UpdateProfileCubit(),
        child: const EditProfileScreen(),
      ),
    );
  }
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  File? _selectedImage; // Local picked image
  final ImagePicker _picker = ImagePicker();
  TextEditingController? _nameController;
  TextEditingController? _emailController;
  TextEditingController? _phoneController;

  @override
  void dispose() {
    _nameController?.dispose();
    _emailController?.dispose();
    _phoneController?.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image != null) {
      final croppedFile = await _cropImage(image.path);
      if (croppedFile != null) {
        setState(() {
          _selectedImage = File(croppedFile.path);
        });
      }
    }
  }

  Future<CroppedFile?> _cropImage(String path) async {
    return ImageCropper().cropImage(
      sourcePath: path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'cropperLbl'.tr(context),
          toolbarColor: context.primaryColor,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
          ],
        ),
        IOSUiSettings(
          title: 'cropperLbl'.tr(context),
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < ResponsiveUtils.mobileBreakpoint;

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: CustomAppBar(
        backgroundColor: context.colorScheme.secondary,
        title: 'editProfileLbl'.tr(context),
      ),
      body: CustomPaddingWidget.symmetric(
        child: BlocConsumer<UserDetailsCubit, UserDetailsState>(
          listener: (context, state) {},
          builder: (context, state) {
            log('state $state');

            if (state is UserDetailsFetchSuccess) {
              final userProfile = state.userDetail;
              _nameController ??= TextEditingController(text: userProfile.name);
              _emailController ??= TextEditingController(text: userProfile.email);
              _phoneController ??= TextEditingController(text: userProfile.phone);

              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(height: 30.sp(context)),
                          Container(
                            padding: EdgeInsets.all(6.sp(context)),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: context.colorScheme.onSecondary.withValues(alpha: 0.2)),
                            ),
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                // Circular image
                                Container(
                                  width: context.screenWidth * (isMobile ? 0.35 : 0.3),
                                  height: context.screenWidth * (isMobile ? 0.35 : 0.3),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: context.colorScheme.onSecondary.withValues(alpha: 0.2)),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(1000),
                                    child: _selectedImage != null
                                        ? Image.file(_selectedImage!, fit: BoxFit.cover)
                                        : (userProfile.imageUrl.isNotEmpty
                                              ? CustomImageWidget(imagePath: userProfile.imageUrl)
                                              : ColoredBox(
                                                  color: Colors.grey.shade300,
                                                  child: Icon(Icons.person, size: 50.sp(context)),
                                                )),
                                  ),
                                ),

                                // Edit icon
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: InkWell(
                                    onTap: _pickImage,
                                    child: Container(
                                      padding: EdgeInsets.all(7.sp(context)),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: context.primaryColor,
                                      ),
                                      child: Icon(Icons.edit, color: Colors.white, size: 20.sp(context)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 30.sp(context)),
                          CustomTextField(
                            controller: _nameController,
                            hintText: 'firstNameLbl'.tr(context),
                            hintFontSize: 16.sp(context),
                          ),
                          SizedBox(height: 20.sp(context)),
                          CustomTextField(
                            controller: _emailController,
                            hintText: 'enterEmailLbl'.tr(context),
                            readOnly: true,
                            hintFontSize: 16.sp(context),
                          ),
                          SizedBox(height: 20.sp(context)),
                          CustomTextField(
                            controller: _phoneController,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            hintText: 'enterPhoneLbl'.tr(context),
                            keyboardType: TextInputType.number,
                            hintFontSize: 16.sp(context),
                          ),

                          SizedBox(height: 20.sp(context)),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 10.sp(context)),
                    child: BlocConsumer<UpdateProfileCubit, UpdateProfileState>(
                      listener: (context, state) {
                        if (state is UpdateProfileFetchSuccess) {
                          context.read<UserDetailsCubit>().updateUserDetails(state.UpdateProfile);
                          context.showSnackBar(message: 'profileUpdatedSuccessfullyLbl'.tr(context), backgroundColor: AppThemeColors.greenColor);
                          Navigator.of(context).pop();
                        }

                        if (state is UpdateProfileFetchFailure) {
                          context.showSnackBar(message: state.errorMessage, backgroundColor: context.colorScheme.error);
                        }
                      },
                      builder: (context, state) {
                        return CustomRoundedButtonWidget(
                          isLoading: state is UpdateProfileFetchProgress,
                          height: 50.sp(context),
                          text: 'saveLbl'.tr(context),
                          backgroundColor: context.primaryColor,
                          textStyle: TextStyle(fontSize: 18.sp(context), color: Colors.white),
                          onPressed: () async {
                            context.read<UpdateProfileCubit>().updateUserDetails(
                              firstName: _nameController!.text.trim(),
                              imageUrl: _selectedImage?.path ?? '',
                              number: _phoneController!.text.trim(),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
