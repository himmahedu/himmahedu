import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:himmah_app/models/lecture.dart';
import 'package:himmah_app/models/course.dart';
import 'package:himmah_app/screens/chat_page.dart';
import 'package:himmah_app/screens/quiz_page.dart';

class LectureDetailPage extends StatelessWidget {
  final Lecture lecture;
  final Course course;
  const LectureDetailPage({super.key, required this.lecture, required this.course});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // صف يحتوي على اسم المحاضرة وزر Meet
          Row(
            children: [
              Expanded(
                child: Text(
                  lecture.title,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (course.meetLink.isNotEmpty) {
                    launchUrl(Uri.parse(course.meetLink), mode: LaunchMode.externalApplication);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('لم يقم الدكتور بإنشاء اجتماع بعد')),
                    );
                  }
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF8C00),
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 3))],
                  ),
                  child: const Icon(Icons.video_call, color: Colors.white, size: 26),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // زر الفيديو
          ElevatedButton.icon(
            icon: const Icon(Icons.play_circle_fill, size: 30),
            label: const Text('تشغيل الفيديو', style: TextStyle(fontSize: 18)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF3131),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () {
              if (lecture.videoUrl.isNotEmpty) {
                launchUrl(Uri.parse(lecture.videoUrl));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('لا يوجد رابط فيديو')),
                );
              }
            },
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            icon: const Icon(Icons.picture_as_pdf, size: 30),
            label: const Text('فتح ملف PDF', style: TextStyle(fontSize: 18)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF8C00),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () {
              if (lecture.pdfUrl.isNotEmpty) {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => Scaffold(
                    appBar: AppBar(title: const Text('ملف PDF')),
                    body: PDFView(filePath: lecture.pdfUrl),
                  ),
                ));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('لا يوجد ملف PDF بعد')),
                );
              }
            },
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            icon: const Icon(Icons.quiz, size: 30),
            label: const Text('الكويز', style: TextStyle(fontSize: 18)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFDE59),
              foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => QuizPage(lectureId: lecture.id, courseId: course.id),
              ));
            },
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            icon: const Icon(Icons.chat, size: 30),
            label: const Text('الدردشة', style: TextStyle(fontSize: 18)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF8C00),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => ChatPage(courseId: course.id, courseName: course.name),
              ));
            },
          ),
        ],
      ),
    );
  }
}