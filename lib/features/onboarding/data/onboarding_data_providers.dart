import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/device_setup.dart';
import 'device_setup_repository_impl.dart';

final Provider<DeviceSetupRepository> deviceSetupRepositoryProvider =
    Provider<DeviceSetupRepository>((Ref ref) => DeviceSetupRepositoryImpl());
