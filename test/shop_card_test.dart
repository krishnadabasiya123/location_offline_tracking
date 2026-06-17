import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omkar_sale/core/app/all_import_file.dart';

void main() {
  testWidgets('ShopCard Golden Test', (WidgetTester tester) async {
    // 1. Mock Data
    const mockShop = Shop(
      id: 1,
      uuid: 'abc-123',
      name: 'Sunrise Market',
      address: '123 Business Road, Mumbai',
      city: 'Mumbai',
      latitude: '19.0',
      longitude: '72.0',
      tin: 'TIN123',
      contactPerson: 'Harshil',
      contactPhone: '9876543210',
      products: [],
    );

    // 2. Set screen size for your .sp extensions
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;

    // 3. Build widget
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: const Scaffold(
          body: Center(
            child: ShopCard(shop: mockShop),
          ),
        ),
      ),
    );

    // 4. Matches Golden
    await expectLater(
      find.byType(ShopCard),
      matchesGoldenFile('goldens/shop_card.png'),
    );

    addTearDown(tester.view.resetPhysicalSize);
  });
}
