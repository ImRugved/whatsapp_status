import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';

class StatusItem {
  final String id;
  final String userName;
  final List<File> images;
  final DateTime timestamp;

  StatusItem({
    required this.id,
    required this.userName,
    required this.images,
    required this.timestamp,
  });
}

class StatusProvider extends ChangeNotifier {
  List<StatusItem> _statuses = [];
  List<String> _seenStatusIds = [];

  // For user's own status
  File? _myStatusImage;
  File? get myStatusImage => _myStatusImage;
  void setMyStatus(File image) {
    _myStatusImage = image;
    notifyListeners();
  }

  // For images seen in statuses
  final List<File> _viewedStatusImages = [];
  List<File> get viewedStatusImages => _viewedStatusImages;
  void addViewedStatusImage(File image) {
    if (!_viewedStatusImages.any((f) => f.path == image.path)) {
      _viewedStatusImages.add(image);
      log('stus in list is ${_viewedStatusImages.length}');
      notifyListeners();
    }
  }

  List<StatusItem> get statuses => _statuses
      .where((s) => DateTime.now().difference(s.timestamp).inHours < 24)
      .toList();
  List<String> get seenStatusIds => _seenStatusIds;

  void addStatus(StatusItem status) {
    _statuses.add(status);
    notifyListeners();
    _removeExpiredStatuses();
  }

  void markAsSeen(String statusId) {
    if (!_seenStatusIds.contains(statusId)) {
      _seenStatusIds.add(statusId);

      notifyListeners();
    }
  }

  void _removeExpiredStatuses() {
    Timer(Duration(minutes: 1), () {
      _statuses.removeWhere((status) =>
          DateTime.now().difference(status.timestamp).inHours >= 24);
      notifyListeners();
    });
  }
}
