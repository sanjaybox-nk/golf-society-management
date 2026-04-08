import 'dart:convert';

class NewsletterTemplates {
  static String toQuillJson(List<Map<String, dynamic>> delta) {
    return jsonEncode(delta);
  }

  static String eventLaunch(String title, String courseName) {
    return toQuillJson([
      {'insert': 'The Wait is Over: '},
      {'insert': title, 'attributes': {'bold': true, 'color': '#2E7D32'}},
      {'insert': ' is Live!\n\n'},
      {'insert': 'We are thrilled to announce that registration is now open for our upcoming visit to '},
      {'insert': courseName, 'attributes': {'italic': true}},
      {'insert': '. This course is renowned for its challenging layout and pristine conditions.\n\n'},
      {'insert': 'What to Expect:\n', 'attributes': {'bold': true}},
      {'insert': '• Full 18-hole stableford competition\n'},
      {'insert': '• Coffee and bacon rolls on arrival\n'},
      {'insert': '• Two-course meal following play\n\n'},
      {'insert': 'Don\'t miss out—secure your spot today via the Event Hub!'},
    ]);
  }

  static String teeTimesReleased(String title) {
    return toQuillJson([
      {'insert': 'Tee Times & Course Update: '},
      {'insert': title, 'attributes': {'bold': true}},
      {'insert': '\n\n'},
      {'insert': 'The draw is out! Please check the groups tab to find your tee time and playing partners.\n\n'},
      {'insert': 'Pro Tip: ', 'attributes': {'bold': true}},
      {'insert': 'The greens are running fast this week (Stimp 11.5). Make sure to spend some time on the practice green before heading to the first tee.\n\n'},
      {'insert': 'Weather Outlook: ', 'attributes': {'bold': true}},
      {'insert': 'Sunny intervals with a moderate breeze from the West. Perfect scoring conditions!'},
    ]);
  }

  static String matchReport(String title, String courseName, String winner, dynamic score) {
    return toQuillJson([
      {'insert': 'Match Report: '},
      {'insert': title, 'attributes': {'bold': true}},
      {'insert': ' at '},
      {'insert': courseName, 'attributes': {'italic': true}},
      {'insert': '\n\n'},
      {'insert': 'What a spectacular day of golf! '},
      {'insert': winner, 'attributes': {'bold': true, 'underline': true}},
      {'insert': ' claimed the top spot on the podium today with an exceptional score of '},
      {'insert': '$score', 'attributes': {'bold': true}},
      {'insert': '.\n\n'},
      {'insert': 'Reflections on the Day:\n', 'attributes': {'bold': true}},
      {'insert': 'The course provided a stern test, especially the back nine where the wind picked up. However, the camaraderie and spirit shown by all members were the real highlights.\n\n'},
      {'insert': 'Check out the "Gallery" tab in the event details to see the latest photos from the day!'},
    ]);
  }

  static String seasonRecap(String title) {
    return toQuillJson([
      {'insert': 'Reflections on '},
      {'insert': title, 'attributes': {'bold': true}},
      {'insert': '\n\n'},
      {'insert': 'As we look back on the event, it\'s clear that our society continues to go from strength to strength. The level of competition was matched only by the fun we had off the course.\n\n'},
      {'insert': 'A huge thank you to the tournament committee and all the staff at the venue for making it such a success.\n\n'},
      {'insert': 'Stay tuned for our next outing!'},
    ]);
  }
}
