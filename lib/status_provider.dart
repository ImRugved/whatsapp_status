import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';

// Represents a single status update from a user.
class StatusItem {
  final String id; // Unique ID for this status item.
  final String userName; // Name of the user who posted this status.
  final List<File> images; // List of images in this status update.
  final DateTime timestamp; // When this status was posted.

  StatusItem({
    required this.id,
    required this.userName,
    required this.images,
    required this.timestamp,
  });
}

// Manages all status-related data and logic for the app.
class StatusProvider extends ChangeNotifier {
  List<StatusItem> _statuses = []; // Holds all current status updates from users.
  List<String> _seenStatusIds = []; // Keeps track of which status updates the current user has already viewed.

  // For user's own status
  File? _myStatusImage; // The image for the current user's own status.
  File? get myStatusImage => _myStatusImage; // Getter for the user's own status image.
  // Sets or updates the current user's own status image.
  void setMyStatus(File image) {
    _myStatusImage = image;
    notifyListeners();
  }

  // For images seen in statuses
  final List<File> _viewedStatusImages = []; // Stores a list of all individual status images the user has viewed.
  List<File> get viewedStatusImages => _viewedStatusImages; // Getter for the list of viewed images.
  // Adds an image to the list of viewed images, if it's not already there.
  void addViewedStatusImage(File image) {
    if (!_viewedStatusImages.any((f) => f.path == image.path)) {
      _viewedStatusImages.add(image);
      log('stus in list is ${_viewedStatusImages.length}');
      notifyListeners();
    }
  }

  // Gets the list of active statuses (posted within the last 24 hours).
  List<StatusItem> get statuses => _statuses
      .where((s) => DateTime.now().difference(s.timestamp).inHours < 24)
      .toList();
  // Gets the list of IDs for statuses that have been marked as seen.
  List<String> get seenStatusIds => _seenStatusIds;

  // Adds a new status update to the list.
  void addStatus(StatusItem status) {
    _statuses.add(status);
    notifyListeners();
    _removeExpiredStatuses();
  }

  // Marks a specific status update as seen by the current user.
  void markAsSeen(String statusId) {
    if (!_seenStatusIds.contains(statusId)) {
      _seenStatusIds.add(statusId);

      notifyListeners();
    }
  }

  // Periodically checks and removes statuses older than 24 hours.
  // This is a simple timer, might need a more robust solution for production.
  void _removeExpiredStatuses() {
    Timer(Duration(minutes: 1), () {
      _statuses.removeWhere((status) =>
          DateTime.now().difference(status.timestamp).inHours >= 24);
      notifyListeners();
    });
  }
}
