import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:travelee/data/models/db/travel_db_model.dart';
import 'package:travelee/data/models/db/schedule_db_model.dart';
import 'package:share_plus/share_plus.dart';

/// 여행 상세 화면 PDF 추출/공유/저장 서비스
class PdfExportService {
  /// 여행 상세 본문을 PDF로 변환하여 파일로 저장
  /// [targetKey]: PDF로 변환할 위젯의 GlobalKey
  /// [travel]: 여행 데이터(메타데이터/일정 등)
  static Future<File> exportTravelDetailToPdf({
    required TravelDBModel travel,
    required List<ScheduleDBModel> schedules,
  }) async {
    final pdf = pw.Document();
    final fontData =
        await rootBundle.load('assets/fonts/NotoSansKR-Regular.ttf');
    final ttf = pw.Font.ttf(fontData);

    // 날짜별로 일정 그룹핑
    final dayMap = <String, List<ScheduleDBModel>>{};
    for (final s in schedules) {
      final dateKey = s.date.substring(0, 10); // yyyy-MM-dd
      dayMap.putIfAbsent(dateKey, () => []).add(s);
    }
    final days = dayMap.keys.toList()..sort();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          // 상단 여행 요약
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 32),
            alignment: pw.Alignment.center,
            child: pw.Column(
              children: [
                pw.Text('Travelee',
                    style: pw.TextStyle(
                      font: ttf,
                      fontSize: 36,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromHex('#3EC6F1'),
                    )),
                pw.SizedBox(height: 8),
                pw.Text(travel.destination,
                    style: pw.TextStyle(font: ttf, fontSize: 18)),
                pw.SizedBox(height: 8),
                pw.Text(
                  '${travel.startDate.substring(0, 10).replaceAll('-', '. ')} ~ ${travel.endDate.substring(0, 10).replaceAll('-', '. ')}.',
                  style: pw.TextStyle(font: ttf, fontSize: 14),
                ),
              ],
            ),
          ),
          pw.Divider(),

          // 날짜별 일정 타임라인
          ...List.generate(days.length, (i) {
            final dateKey = days[i];
            final daySchedules = dayMap[dateKey]!;
            final dayNumber = i + 1;
            final dateObj = DateTime.parse(dateKey);
            // final dayDataRaw = travel.dayDataMap[dateKey];
            String countryName = '';
            String flagEmoji = '';

            return pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 24),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // D1, 날짜
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('D$dayNumber',
                          style: pw.TextStyle(
                              font: ttf,
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 18)),
                      pw.Text(
                        '${dateObj.month}월 ${dateObj.day}일 (${_weekdayToKor(dateObj.weekday)})',
                        style: pw.TextStyle(font: ttf, fontSize: 14),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 8),
                  // 타임라인
                  ...daySchedules.map((s) => pw.Container(
                        margin: const pw.EdgeInsets.only(bottom: 8),
                        child: pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Container(
                              width: 48,
                              child: pw.Text(
                                '${s.timeHour.toString().padLeft(2, '0')}:${s.timeMinute.toString().padLeft(2, '0')}',
                                style: pw.TextStyle(font: ttf, fontSize: 12),
                              ),
                            ),
                            pw.Expanded(
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(
                                    s.location,
                                    style: pw.TextStyle(
                                      font: ttf,
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  if (s.memo.isNotEmpty)
                                    pw.Text(
                                      s.memo,
                                      style: pw.TextStyle(
                                        font: ttf,
                                        fontSize: 10,
                                        color: PdfColors.grey700,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )),
                  // 하단 국가/도시
                  pw.Row(
                    children: [
                      pw.Text(flagEmoji,
                          style: pw.TextStyle(font: ttf, fontSize: 16)),
                      pw.SizedBox(width: 8),
                      pw.Text(countryName,
                          style: pw.TextStyle(font: ttf, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File(
        '${dir.path}/travel_${travel.id}_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static String _weekdayToKor(int weekday) {
    const days = ['월', '화', '수', '목', '금', '토', '일'];
    return days[(weekday - 1) % 7];
  }

  /// PDF 파일 공유 (share_plus)
  static Future<void> sharePdf(File pdfFile) async {
    await Share.shareXFiles([XFile(pdfFile.path)], text: '여행 일정 PDF');
  }
}
