import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:omkar_sale/core/app/all_import_file.dart';
import 'package:omkar_sale/features/shop/model/shop.dart';

class SubmitReportScreen extends StatefulWidget {
  const SubmitReportScreen({
    this.shopName,
    this.shopId,
    this.purpose,
    this.remarks,
    this.images,
    this.timestamp,
    super.key,
  });

  final String? shopName;
  final int? shopId;
  final String? purpose;
  final String? remarks;
  final List<File>? images;
  final DateTime? timestamp;

  @override
  State<SubmitReportScreen> createState() => _SubmitReportScreenState();
  static Route<dynamic> route(RouteSettings routeSettings) {
    if (routeSettings.arguments is Map<String, dynamic>) {
      final args = routeSettings.arguments! as Map<String, dynamic>;
      return CupertinoPageRoute(
        builder: (_) => SubmitReportScreen(
          shopName: args['shopName'] as String?,
          shopId: args['shopId'] as int?,
          purpose: args['purpose'] as String?,
          remarks: args['remarks'] as String?,
          images: args['images'] as List<File>?,
          timestamp: args['timestamp'] as DateTime?,
        ),
      );
    }
    return CupertinoPageRoute(builder: (_) => const SubmitReportScreen());
  }
}

class _SubmitReportScreenState extends State<SubmitReportScreen> {
  // 1. ValueNotifier for Image List
  final ValueNotifier<List<File>> _imagesNotifier = ValueNotifier<List<File>>([]);

  final ImagePicker _picker = ImagePicker();
  final int maxPhotos = 18;

  final TextEditingController _shopController = TextEditingController();
  final ValueNotifier<int> _shopNotifier = ValueNotifier<int>(-1);
  final TextEditingController _purposeController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();

  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _shopController.text = widget.shopName ?? '';
    _shopNotifier.value = widget.shopId ?? -1;
    _purposeController.text = widget.purpose ?? '';
    _remarksController.text = widget.remarks ?? '';
    _imagesNotifier.value = List<File>.from(widget.images ?? []);
    if (widget.timestamp != null) {
      _selectedTime = TimeOfDay.fromDateTime(widget.timestamp!);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Re-format time if locale changes and time is selected
    if (_selectedTime != null) {
      _timeController.text = _selectedTime!.format(context);
    }
  }

  @override
  void dispose() {
    _imagesNotifier.dispose();
    _shopController.dispose();
    _shopNotifier.dispose();
    _purposeController.dispose();
    _timeController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _pickMultipleFromGallery() async {
    final picked = await _picker.pickMultiImage(imageQuality: 80);
    if (picked.isEmpty) return;

    final spaceLeft = maxPhotos - _imagesNotifier.value.length;
    if (spaceLeft <= 0) return _showSnackBar('Limit reached: $maxPhotos photos max');

    // --- SET YOUR LIMIT HERE ---
    const maxMb = 2; // Change to 20 if you want 20MB
    const maxBytes = maxMb * 1024 * 1024;

    final validFiles = <File>[];
    final largeFiles = <String>[];

    for (final xFile in picked.take(spaceLeft)) {
      final file = File(xFile.path);

      if (file.lengthSync() > maxBytes) {
        largeFiles.add(xFile.name);
      } else {
        validFiles.add(file);
      }
    }

    _imagesNotifier.value = [..._imagesNotifier.value, ...validFiles];

    if (largeFiles.isNotEmpty) {
      _showSnackBar("Skipped large files (>${maxMb}MB): ${largeFiles.join(', ')}");
    }

    if (picked.length > spaceLeft) {
      _showSnackBar('Only $spaceLeft slots were available');
    }
  }
  // // --- Logic: Pick Multiple Images from Gallery ---
  // Future<void> _pickMultipleFromGallery() async {
  //   final pickedFiles = await _picker.pickMultiImage(imageQuality: 80);

  //   if (pickedFiles.isNotEmpty) {
  //     final currentImages = _imagesNotifier.value;

  //     // Calculate how many slots are left
  //     final spaceLeft = maxPhotos - currentImages.length;

  //     if (spaceLeft <= 0) {
  //       _showSnackBar('minimumImageLengthLbl'.tr(context, namedArgs: {'min': maxPhotos.toString()}));
  //       return;
  //     }

  //     final newImages = pickedFiles.take(spaceLeft).map((xFile) => File(xFile.path)).toList();

  //     _imagesNotifier.value = [...currentImages, ...newImages];

  //     if (pickedFiles.length > spaceLeft) {
  //       _showSnackBar('maxPhotosLimtedLlb'.tr(context, namedArgs: {'leftImages': spaceLeft.toString(), 'max': maxPhotos.toString()}));
  //     }
  //   }
  // }

  // --- Logic: Pick Single Image from Camera ---
  Future<void> _pickFromCamera() async {
    if (_imagesNotifier.value.length >= maxPhotos) {
      _showSnackBar('minimumImageLengthLbl'.tr(context, namedArgs: {'min': maxPhotos.toString()}));
      return;
    }

    final pickedFile = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);

    if (pickedFile != null) {
      _imagesNotifier.value = [..._imagesNotifier.value, File(pickedFile.path)];
    }
  }

  void _removeImage(int index) {
    final currentList = List<File>.from(_imagesNotifier.value)..removeAt(index);
    _imagesNotifier.value = currentList;
  }

  void _showSnackBar(String message) {
    context.showSnackBar(message: message, duration: const Duration(seconds: 2));
  }

  void _showPickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colorScheme.secondary,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: Icon(Icons.photo_library, color: context.colorScheme.primary),
            title: Text('galleryLbl'.tr(context), style: TextStyle(color: context.colorScheme.onSurface)),
            onTap: () {
              Navigator.pop(context);
              _pickMultipleFromGallery();
            },
          ),
          ListTile(
            leading: Icon(Icons.camera_alt, color: context.colorScheme.primary),
            title: Text('cameraLbl'.tr(context), style: TextStyle(color: context.colorScheme.onSurface)),
            onTap: () {
              Navigator.pop(context);
              _pickFromCamera();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'submitReportLbl'.tr(context)),
      body: CustomPaddingWidget.symmetric(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(vertical: 16.sp(context)),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'selectShopLbl'.tr(context),
                      style: TextStyle(fontSize: 15.sp(context), fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5.sp(context)),
                    CustomTextField(
                      controller: _shopController,
                      hintText: 'selectShopLbl'.tr(context),
                      isDropdown: true,
                      readOnly: true,
                      borderColor: context.colorScheme.onSurface.withValues(alpha: 0.2),
                      fillColor: context.colorScheme.secondary,
                      onTap: () {
                        Navigator.pushNamed(context, Routes.customerListScreen, arguments: {'isComeFromOrderScreen': true}).then((value) {
                          final selectedShop = value as Shop?;
                          if (selectedShop != null) {
                            _shopController.text = selectedShop.name;
                            _shopNotifier.value = selectedShop.id;
                          }
                        });
                      },
                    ),
                    SizedBox(height: 20.sp(context)),
                    Text(
                      'Purpose',
                      style: TextStyle(fontSize: 15.sp(context), fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5.sp(context)),
                    CustomTextField(
                      controller: _purposeController,
                      hintText: 'Enter Purpose',
                      borderColor: context.colorScheme.onSurface.withValues(alpha: 0.2),
                      fillColor: context.colorScheme.secondary,
                    ),
                    SizedBox(height: 20.sp(context)),
                    Text(
                      'timeLbl'.tr(context),
                      style: TextStyle(fontSize: 15.sp(context), fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5.sp(context)),
                    CustomTextField(
                      controller: _timeController,
                      hintText: 'selectTimeLbl'.tr(context),
                      isDropdown: true,
                      readOnly: true,
                      borderColor: context.colorScheme.onSurface.withValues(alpha: 0.2),
                      fillColor: context.colorScheme.secondary,
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: _selectedTime ?? TimeOfDay.now(),
                        );
                        if (picked != null) {
                          setState(() {
                            _selectedTime = picked;
                            _timeController.text = _selectedTime!.format(context);
                          });
                        }
                      },
                    ),
                    SizedBox(height: 20.sp(context)),

                    CustomTextField(
                      controller: _remarksController,
                      hintText: 'Remarks',
                      hintMaxLines: 2,
                      fillColor: context.colorScheme.secondary,
                      borderColor: context.colorScheme.onSurface.withValues(alpha: 0.2),
                      borderType: CustomTextFormFieldBorder.outline,
                      maxLines: 5,
                      minLines: 5,
                    ),
                    SizedBox(height: 12.sp(context)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'uploadImagelbl'.tr(context),
                          style: TextStyle(color: context.colorScheme.onSurface, fontSize: 18.sp(context), fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'maxPhotosLbl'.tr(context, namedArgs: {'max': maxPhotos.toString()}),
                          style: TextStyle(color: context.colorScheme.onSurface.withValues(alpha: 0.9), fontSize: 12.sp(context), fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),

                    SizedBox(height: 12.sp(context)),
                    ValueListenableBuilder<List<File>>(
                      valueListenable: _imagesNotifier,
                      builder: (context, imageList, child) {
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12.sp(context),
                            mainAxisSpacing: 12.sp(context),
                          ),
                          itemCount: imageList.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return GestureDetector(
                                onTap: () => _showPickerOptions(context),
                                child: CustomDashedBorder(
                                  color: context.colorScheme.primary.withValues(alpha: 0.5),
                                  backgroundColor: context.colorScheme.secondary,
                                  borderRadius: BorderRadius.circular(12.sp(context)),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_a_photo, color: context.colorScheme.primary, size: 28.sp(context)),
                                      SizedBox(height: 4.sp(context)),
                                      Text(
                                        'addPhotoLbl'.tr(context),
                                        style: TextStyle(color: context.primaryColor, fontSize: 12.sp(context), fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                            final file = imageList[index - 1];
                            return Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    image: DecorationImage(image: FileImage(file), fit: BoxFit.cover),
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () => _removeImage(index - 1),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), shape: BoxShape.circle),
                                      child: const Icon(Icons.close, color: Colors.white, size: 12),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewPadding.bottom + (Platform.isIOS ? 0 : 20).sp(context)),
              child: CustomRoundedButtonWidget(
                onPressed: () {
                  if (_shopController.text.isEmpty) {
                    _showSnackBar('selectedShopsLbl'.tr(context));
                    return;
                  }
                  if (_purposeController.text.isEmpty) {
                    _showSnackBar('Enter Purpose');
                    return;
                  }
                  if (_remarksController.text.isEmpty) {
                    _showSnackBar('Enter Remarks');
                    return;
                  }

                  final now = DateTime.now();
                  final reportData = {
                    'shopName': _shopController.text,
                    'shopId': _shopNotifier.value,
                    'purpose': _purposeController.text,
                    'remarks': _remarksController.text,
                    'images': _imagesNotifier.value,
                    'timestamp': DateTime(
                      now.year,
                      now.month,
                      now.day,
                      _selectedTime?.hour ?? now.hour,
                      _selectedTime?.minute ?? now.minute,
                    ),
                  };
                  Navigator.pop(context, reportData);
                },
                text: 'confirmReportLbl'.tr(context),
                textStyle: TextStyle(fontSize: 16.sp(context), fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
