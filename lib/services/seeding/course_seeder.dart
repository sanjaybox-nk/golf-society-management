import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/domain/models/course.dart';
import 'package:golf_society/features/courses/presentation/courses_provider.dart';
import 'data_constants.dart';

class CourseSeeder {
  final Ref ref;
  final Random random;

  CourseSeeder(this.ref, this.random);

  Future<List<Course>> seed() async {
    final repo = ref.read(courseRepositoryProvider);
    final List<Course> courses = [];
    final names = SeedingData.courseAddresses.keys.toList();
    
    for (int i = 0; i < names.length; i++) {
      final name = names[i];
      final holeData = _getCourseHoleData(name);
      
      final course = Course(
        id: 'demo_c_$i',
        name: name,
        address: SeedingData.courseAddresses[name] ?? 'Golf Coast, Demo Land',
        isGlobal: false,
        tees: [
          TeeConfig(
            name: 'White',
            rating: 72.5, 
            slope: 132,
            holePars: holeData.pars, 
            holeSIs: holeData.si,
            yardages: holeData.yards, 
          ),
          TeeConfig(
            name: 'Yellow',
            rating: 71.0, 
            slope: 128, 
            holePars: holeData.pars,
            holeSIs: holeData.si,
            yardages: holeData.yards.map((y) => (y * 0.94).round()).toList(), 
          ),
          TeeConfig(
            name: 'Blue',
            rating: 70.0, 
            slope: 125, 
            holePars: holeData.pars,
            holeSIs: holeData.si,
            yardages: holeData.yards.map((y) => (y * 0.88).round()).toList(), 
          ),
          TeeConfig(
            name: 'Red',
            rating: 72.0, 
            slope: 124,
            holePars: holeData.pars, 
            holeSIs: holeData.si, 
            yardages: holeData.yards.map((y) => (y * 0.82).round()).toList(), 
          ),
        ],
      );
      await repo.saveCourse(course);
      courses.add(course);
    }
    return courses;
  }

  ({List<int> pars, List<int> si, List<int> yards}) _getCourseHoleData(String courseName) {
    if (courseName.contains('St Andrews')) {
      return (
        pars: [4, 4, 4, 4, 5, 4, 4, 3, 4, 4, 3, 4, 4, 5, 4, 4, 4, 4],
        si: [10, 6, 16, 8, 2, 12, 4, 14, 18, 15, 7, 3, 11, 1, 9, 13, 5, 17],
        yards: [376, 413, 370, 419, 514, 374, 359, 166, 307, 318, 174, 314, 407, 533, 413, 351, 455, 357],
      );
    }
    if (courseName.contains('Pebble Beach')) {
      return (
        pars: [4, 5, 4, 4, 3, 5, 3, 4, 4, 4, 4, 3, 4, 5, 4, 4, 3, 5],
        si: [8, 10, 12, 16, 14, 2, 18, 4, 8, 7, 9, 17, 1, 5, 11, 15, 13, 3],
        yards: [378, 511, 397, 331, 189, 506, 106, 427, 481, 444, 373, 201, 399, 573, 396, 401, 177, 543],
      );
    }
    if (courseName.contains('TPC Sawgrass')) {
      return (
        pars: [4, 5, 3, 4, 4, 4, 4, 3, 5, 4, 5, 4, 3, 4, 4, 5, 3, 4],
        si: [11, 15, 17, 9, 3, 13, 1, 7, 5, 12, 8, 16, 18, 4, 6, 10, 14, 2],
        yards: [423, 532, 177, 384, 471, 393, 442, 237, 583, 424, 558, 369, 181, 481, 449, 523, 137, 462],
      );
    }
    if (courseName.contains('Augusta')) {
      return (
        pars: [4, 5, 4, 3, 4, 3, 4, 5, 4, 4, 4, 3, 5, 4, 5, 3, 4, 4],
        si: [9, 1, 13, 15, 5, 17, 11, 3, 7, 6, 8, 16, 4, 12, 2, 18, 14, 10],
        yards: [445, 575, 350, 240, 495, 180, 450, 570, 460, 495, 505, 155, 510, 440, 530, 170, 440, 465],
      );
    }
    if (courseName == 'Royal County Down') {
      return (
        pars: [5, 4, 4, 3, 4, 4, 3, 4, 4, 3, 4, 5, 4, 3, 4, 4, 4, 5],
        si: [13, 9, 3, 15, 7, 11, 17, 1, 5, 18, 8, 16, 2, 12, 4, 14, 10, 6],
        yards: [539, 444, 475, 213, 443, 396, 144, 429, 483, 196, 444, 525, 446, 212, 465, 337, 436, 548],
      );
    }
    if (courseName == 'Muirfield') {
      return (
        pars: [4, 4, 4, 3, 5, 4, 5, 3, 4, 4, 5, 3, 4, 4, 5, 3, 4, 4],
        si: [14, 8, 10, 18, 2, 12, 4, 16, 6, 13, 15, 3, 7, 11, 1, 17, 9, 5],
        yards: [450, 447, 401, 203, 529, 447, 563, 202, 412, 471, 567, 184, 455, 363, 490, 201, 478, 484],
      );
    }
    if (courseName == 'Shinnecock Hills') {
      return (
        pars: [4, 3, 4, 4, 5, 4, 3, 4, 4, 4, 3, 4, 4, 4, 4, 5, 3, 4],
        si: [11, 17, 3, 7, 9, 1, 15, 13, 5, 4, 16, 2, 12, 6, 14, 8, 18, 10],
        yards: [399, 226, 500, 475, 589, 491, 189, 439, 485, 415, 158, 469, 370, 444, 419, 540, 175, 485],
      );
    }
    if (courseName == 'Oakmont') {
      return (
        pars: [4, 4, 4, 5, 4, 3, 4, 3, 5, 4, 4, 5, 3, 4, 4, 3, 4, 4],
        si: [3, 7, 1, 13, 11, 17, 9, 5, 15, 4, 10, 2, 16, 18, 8, 12, 14, 6],
        yards: [482, 340, 428, 609, 379, 194, 479, 252, 477, 462, 379, 667, 183, 358, 499, 231, 313, 484],
      );
    }
    if (courseName == 'Cypress Point') {
      return (
        pars: [4, 5, 3, 4, 5, 5, 3, 4, 4, 5, 4, 4, 4, 4, 3, 3, 4, 4],
        si: [5, 1, 17, 7, 11, 3, 15, 9, 13, 16, 4, 2, 14, 8, 18, 6, 10, 12],
        yards: [415, 541, 158, 381, 483, 514, 159, 362, 289, 476, 438, 404, 354, 393, 135, 222, 344, 331],
      );
    }
    if (courseName == 'Pine Valley') {
      return (
        pars: [4, 4, 3, 4, 3, 4, 5, 4, 4, 3, 4, 4, 4, 3, 5, 4, 4, 4],
        si: [3, 9, 17, 5, 11, 13, 1, 15, 7, 18, 10, 14, 4, 16, 2, 8, 12, 6],
        yards: [421, 351, 185, 438, 220, 385, 584, 314, 422, 142, 388, 330, 439, 180, 574, 420, 332, 425],
      );
    }
    if (courseName == 'Royal Melbourne') {
      return (
        pars: [4, 5, 4, 4, 3, 4, 3, 4, 4, 4, 4, 4, 4, 5, 4, 3, 5, 4],
        si: [5, 1, 13, 7, 17, 3, 15, 11, 9, 6, 10, 14, 18, 4, 8, 16, 2, 12],
        yards: [428, 491, 332, 439, 176, 427, 147, 311, 454, 475, 438, 433, 354, 504, 382, 201, 568, 431],
      );
    }
    if (courseName.contains('Dom Pedro')) {
      return (
        pars: [4, 4, 4, 3, 5, 4, 4, 3, 4, 4, 4, 3, 4, 5, 4, 4, 5, 4],
        si: [7, 13, 3, 17, 1, 11, 5, 15, 9, 8, 14, 18, 4, 10, 2, 12, 16, 6],
        yards: [325, 403, 365, 178, 498, 382, 347, 153, 310, 345, 388, 165, 395, 485, 375, 335, 510, 378],
      );
    }
    if (courseName.contains('Victoria')) {
      return (
        pars: [4, 4, 4, 3, 5, 4, 3, 4, 4, 4, 4, 5, 3, 4, 3, 4, 5, 4],
        si: [9, 5, 13, 17, 1, 3, 15, 11, 7, 10, 6, 2, 18, 4, 16, 12, 8, 14],
        yards: [375, 420, 365, 185, 530, 440, 165, 410, 435, 390, 415, 560, 155, 450, 175, 430, 520, 445],
      );
    }
    return (
      pars: [4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4],
      si: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18],
      yards: List.generate(18, (h) => 350 + random.nextInt(100)),
    );
  }
}
