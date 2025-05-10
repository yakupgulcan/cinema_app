// ignore: unused_import
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sinema_yonetim_sistemi/main.dart';
import 'package:sinema_yonetim_sistemi/services/EkranYonetim/EkranYonetim.dart';

void main() {
  testWidgets('Uygulama başlatma testi', (WidgetTester tester) async {
    // Uygulamayı başlat
    await tester.pumpWidget(SinemaYonetimSistemi());

    // Ana sayfa widget'ını bul
    expect(find.byType(SayfaYonetim), findsOneWidget);

    // Başlık kontrolü
    expect(find.text('Sinema Yönetim Sistemi'), findsOneWidget);
  });
}
