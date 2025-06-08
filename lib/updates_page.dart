import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'status_provider.dart';

class UpdatesPage extends StatelessWidget {
  final String myProfileImage;
  final String myName;
  const UpdatesPage(
      {super.key, required this.myProfileImage, required this.myName});

  @override
  Widget build(BuildContext context) {
    final statusProvider = Provider.of<StatusProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Updates'),
        actions: [
          IconButton(icon: const Icon(Icons.qr_code), onPressed: () {}),
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          PopupMenuButton(
              itemBuilder: (context) => [
                    const PopupMenuItem(child: Text('Menu')),
                  ]),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // My Status
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () async {
                      final picker = ImagePicker();
                      final pickedFile =
                          await picker.pickImage(source: ImageSource.gallery);
                      if (pickedFile != null) {
                        statusProvider.setMyStatus(File(pickedFile.path));
                      }
                    },
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundImage: statusProvider.myStatusImage != null
                              ? FileImage(statusProvider.myStatusImage!)
                              : null,
                          child: statusProvider.myStatusImage == null
                              ? const Icon(Icons.person, size: 32)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.add,
                                color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('My Status',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('Disappears after 24 hours',
                            style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Text('Recent Updates',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: statusProvider.statuses.length,
              itemBuilder: (context, index) {
                final status = statusProvider.statuses[index];
                final seen = statusProvider.seenStatusIds.contains(status.id);

                return ListTile(
                  leading: StatusBorderWidget(
                    segments: status.images.length,
                    seen: seen,
                    size: 56.0,
                    child: CircleAvatar(
                      radius: 25,
                      backgroundImage: status.images.isNotEmpty
                          ? FileImage(status.images[0])
                          : null,
                      child: status.images.isEmpty
                          ? const Icon(Icons.person, size: 25)
                          : null,
                    ),
                  ),
                  title: Text(status.userName),
                  subtitle: Text(_timeAgo(status.timestamp)),
                  onTap: () async {
                    statusProvider.markAsSeen(status.id);
                    int initialPage = 0;
                    statusProvider
                        .addViewedStatusImage(status.images[initialPage]);

                    await showDialog(
                      context: context,
                      builder: (_) {
                        int currentPage = initialPage;
                        return StatefulBuilder(
                          builder: (context, setState) {
                            return Dialog(
                              backgroundColor: Colors.black,
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.9,
                                height:
                                    MediaQuery.of(context).size.height * 0.8,
                                child: Stack(
                                  children: [
                                    PageView.builder(
                                      itemCount: status.images.length,
                                      controller: PageController(
                                          initialPage: initialPage),
                                      onPageChanged: (index) {
                                        setState(() {
                                          currentPage = index;
                                        });
                                        statusProvider.addViewedStatusImage(
                                            status.images[index]);
                                      },
                                      itemBuilder: (context, index) {
                                        return Center(
                                          child: Image.file(
                                            status.images[index],
                                            fit: BoxFit.contain,
                                          ),
                                        );
                                      },
                                    ),
                                    // Progress indicator for multiple images
                                    if (status.images.length > 1)
                                      Positioned(
                                        top: 20,
                                        left: 20,
                                        right: 20,
                                        child: Row(
                                          children: List.generate(
                                            status.images.length,
                                            (index) => Expanded(
                                              child: Container(
                                                height: 3,
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 1),
                                                decoration: BoxDecoration(
                                                  color: index <= currentPage
                                                      ? Colors.white
                                                      : Colors.white
                                                          .withOpacity(0.3),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          1.5),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    // Close button
                                    Positioned(
                                      top: 10,
                                      right: 10,
                                      child: IconButton(
                                        icon: const Icon(Icons.close,
                                            color: Colors.white),
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// This painter draws the green/grey segmented border around status avatars,
// similar to how WhatsApp shows them.
class StatusBorderPainter extends CustomPainter {
  final int segments; // How many images are in the status (determines number of border segments).
  final bool seen; // True if the user has already viewed this status (border becomes grey).

  StatusBorderPainter({required this.segments, required this.seen});

  @override
  // This is where the actual drawing happens.
  void paint(Canvas canvas, Size size) {
    if (segments == 0) return; // If there are no images, don't draw any border.

    // Setup the brush (Paint) we'll use for drawing the border.
    final paint = Paint()
      ..color = seen ? Colors.grey.shade400 : Colors.green // Green for new, grey for seen.
      ..strokeWidth = 3.0 // How thick the border line is.
      ..style = PaintingStyle.stroke // We want an outline, not a filled shape.
      ..strokeCap = StrokeCap.round; // Makes the ends of the border segments rounded.

    // Figure out the center and radius for our circle/arcs.
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - paint.strokeWidth) / 2; // Adjust radius for stroke width so border is fully visible.

    // If there's only one image, draw a complete, unbroken circle.
    if (segments == 1) {
      // Draw complete circle for single image
      canvas.drawCircle(center, radius, paint); // Simple full circle.
    } else { // If there are multiple images, draw a segmented border.
      // Draw segmented arcs for multiple images
      // Calculate the size of the gap between segments and the size of each segment.
      final double gapAngle =
          0.25; // This is the small space between each green/grey arc.
      final double segmentAngle; // How long each arc segment will be.
      segmentAngle = (2 * 3.141592653589793 - (segments * gapAngle)) / segments; // Total circle (2*pi) minus all gaps, divided by number of segments.

      // Draw each arc segment one by one.
      for (int i = 0; i < segments; i++) {
        // Calculate where this segment starts. We start from the top (-pi/2 radians).
        final double startAngle = -3.141592653589793 / 2 +
            i * (segmentAngle + gapAngle); // Each segment starts after the previous one plus a gap.

        // Arcs are drawn within a bounding rectangle (a square, in this case, for a circle).
        final rect = Rect.fromCircle(center: center, radius: radius);
        canvas.drawArc(rect, startAngle, segmentAngle, false, paint); // Draw the arc for this segment.
      }
    }
  }

  @override
  // Tells Flutter when to redraw this border.
  // It should redraw if the number of segments changes or if its seen status changes.
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is StatusBorderPainter) {
      return oldDelegate.segments != segments || oldDelegate.seen != seen;
    }
    return true;
  }
}

// Widget wrapper for easier usage
class StatusBorderWidget extends StatelessWidget {
  final Widget child;
  final int segments;
  final bool seen;
  final double size;

  const StatusBorderWidget({
    Key? key,
    required this.child,
    required this.segments,
    required this.seen,
    this.size = 56.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: StatusBorderPainter(segments: segments, seen: seen),
        child: Padding(
          padding: const EdgeInsets.all(3.0), // Padding to account for border
          child: child,
        ),
      ),
    );
  }
}

String _timeAgo(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.inSeconds < 60) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) return '${diff.inHours} hr ago';
  return '${diff.inDays} days ago';
}
