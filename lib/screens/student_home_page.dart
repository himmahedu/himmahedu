import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:himmah_app/models/course.dart';
import 'package:himmah_app/screens/lectures_page.dart';
import 'package:himmah_app/widgets/main_layout.dart';

class StudentHomePage extends StatelessWidget {
  final String specialty;
  final String year;
  const StudentHomePage({super.key, required this.specialty, required this.year});

  // دالة للتحقق من اشتراك الطالب
  Future<bool> _checkSubscription() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    return doc.get('subscriptionActive') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'المواد الدراسية',
      body: FutureBuilder<bool>(
        future: _checkSubscription(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          if (!snapshot.data!) {
            // واجهة غير المشترك
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock, size: 80, color: Color(0xFFFF3131)),
                    const SizedBox(height: 20),
                    const Text('أنت غير مشترك', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    const Text('يرجى التواصل مع الإدارة للاشتراك', style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.phone),
                      label: const Text('اتصل بنا'),
                      onPressed: () {
                        // يمكن فتح رابط واتساب أو عرض رقم الهاتف
                      },
                    ),
                  ],
                ),
              ),
            );
          }
          // عرض المواد للمشتركين
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('courses')
                .where('specialty', isEqualTo: specialty)
                .where('year', isEqualTo: year)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final docs = snapshot.data!.docs;
              if (docs.isEmpty) return const Center(child: Text('لا توجد مواد'));
              final courses = docs.map((d) => Course.fromFirestore(d)).toList();
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: courses.length,
                itemBuilder: (context, index) {
                  final course = courses[index];
                  return GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => LecturesPage(course: course),
                    )),
                    child: Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 4,
                      shadowColor: const Color(0xFFFF8C00).withOpacity(0.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: course.imageUrl.isNotEmpty
                                  ? Image.network(course.imageUrl, width: 60, height: 60, fit: BoxFit.cover)
                                  : Container(
                                width: 60,
                                height: 60,
                                color: const Color(0xFFFFDE59).withOpacity(0.3),
                                child: const Icon(Icons.book, color: Color(0xFFFF3131), size: 30),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                course.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFF3131),
                                  fontFamily: '.SF Pro Text',
                                ),
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, color: Color(0xFFFF8C00), size: 18),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}