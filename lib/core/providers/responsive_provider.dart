import 'package:bat_track_v1/core/notifiers/responsive_notifier.dart';
import 'package:bat_track_v1/core/responsive/wrapper/responsive_layout.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final responsiveProvider = NotifierProvider<ResponsiveNotifier, ResponsiveInfo>(
  ResponsiveNotifier.new,
);
