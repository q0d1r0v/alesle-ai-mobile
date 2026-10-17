import 'dart:async';

import 'package:alesle_ai/core/agent/agent_task.dart';
import 'package:alesle_ai/core/api/generated/models/auth_user_dto.dart';
import 'package:alesle_ai/core/api/generated/models/token_pair_dto.dart';
import 'package:alesle_ai/core/auth/access_token_source.dart';
import 'package:alesle_ai/core/auth/auth_session.dart';
import 'package:alesle_ai/core/errors/failure.dart';
import 'package:alesle_ai/core/storage/app_settings.dart';
import 'package:alesle_ai/features/auth/domain/auth_repository.dart';
import 'package:alesle_ai/features/billing/domain/billing.dart';
import 'package:alesle_ai/features/home/domain/agent_status.dart';
import 'package:alesle_ai/features/home/domain/home_repositories.dart';
import 'package:alesle_ai/features/home/domain/live.dart';
import 'package:alesle_ai/features/home/domain/server_health.dart';
import 'package:alesle_ai/features/memory/domain/memory.dart';
import 'package:alesle_ai/features/onboarding/domain/device_setup.dart';
import 'package:alesle_ai/features/settings/domain/account.dart';
import 'package:alesle_ai/features/update/domain/update.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Hand-written fakes for widget tests: they keep call counts and let a test
/// hold a future open to observe the loading state.
final class FakeHealthRepository implements HealthRepository {
  FakeHealthRepository(this._next);

  Future<ServerHealth> Function() _next;
  int calls = 0;

  set next(Future<ServerHealth> Function() value) => _next = value;

  @override
  Future<ServerHealth> readiness() {
    calls++;
    return _next();
  }
}

final class FakeAgentRepository implements AgentRepository {
  FakeAgentRepository(this._next);

  Future<AgentStatus> Function() _next;
  int statusCalls = 0;
  int openSettingsCalls = 0;

  set next(Future<AgentStatus> Function() value) => _next = value;

  @override
  Future<AgentStatus> status() {
    statusCalls++;
    return _next();
  }

  @override
  Future<void> openAccessibilitySettings() async {
    openSettingsCalls++;
  }
}

const ServerHealth readyHealth = ServerHealth(
  dependencies: <String, String>{
    'database': 'up',
    'pgvector': 'up',
    'redis': 'up',
  },
);

const AgentStatus disabledAgent = AgentStatus(accessibilityEnabled: false);

const AgentStatus enabledAgent = AgentStatus(accessibilityEnabled: true);

/// A future that never completes, for asserting loading states.
Future<T> never<T>() => Completer<T>().future;

/// Records commands and lets a test push task updates.
final class FakeAssistantRepository implements AssistantRepository {
  final StreamController<TaskUpdate> updatesController =
      StreamController<TaskUpdate>.broadcast();
  final List<TaskCommand> commands = <TaskCommand>[];
  TaskStart nextStart = const TaskStart(started: true);
  Failure? failure;
  int stops = 0;

  @override
  Stream<TaskUpdate> get updates => updatesController.stream;

  @override
  Future<TaskStart> start(TaskCommand command) async {
    commands.add(command);
    if (failure case final Failure value) throw value;
    return nextStart;
  }

  @override
  Future<void> stop() async {
    stops++;
    if (failure case final Failure value) throw value;
  }

  /// What the user said while a task ran; [amendAccepted] says whether one ran.
  final List<String> amendments = <String>[];
  bool amendAccepted = true;

  @override
  Future<bool> amend(String text) async {
    if (failure case final Failure value) throw value;
    amendments.add(text);
    return amendAccepted;
  }

  void push(TaskUpdate update) => updatesController.add(update);
}

/// Scripted push-to-talk: the microphone answer, what was heard, failures.
final class FakeVoiceRepository implements VoiceRepository {
  bool microphone = true;
  Transcript? heard = const Transcript(
    text: 'Onamga qo‘ng‘iroq qil',
    language: 'uz',
    confidence: 0.9,
  );
  Failure? failure;
  int starts = 0;
  int cancels = 0;
  final List<String?> languages = <String?>[];
  final List<String> spoken = <String>[];

  /// Times the permission dialog was asked for.
  int asks = 0;

  @override
  Future<bool> ensureMicrophone() async {
    asks++;
    if (failure case final Failure value) throw value;
    return microphone;
  }

  /// Asked without a dialog (hands-free coming back on by itself).
  int grantedChecks = 0;

  @override
  Future<bool> microphoneGranted() async {
    grantedChecks++;
    return microphone;
  }

  @override
  Future<void> startListening() async => starts++;

  @override
  Future<Transcript?> finishListening({String? language}) async {
    languages.add(language);
    if (failure case final Failure value) throw value;
    return heard;
  }

  @override
  Future<void> cancelListening() async => cancels++;

  /// Hands-free utterances transcribed, by path.
  final List<String> transcribed = <String>[];

  @override
  Future<Transcript> transcribeFile(String path, {String? language}) async {
    transcribed.add(path);
    if (failure case final Failure value) throw value;
    return heard ??
        const Transcript(text: '', language: 'other', confidence: 0);
  }

  @override
  Future<void> speak(String text) async {
    if (failure case final Failure value) throw value;
    spoken.add(text);
  }
}

/// Hands-free listening a test drives: the service's answers and what it hears.
final class FakeHandsFreeRepository implements HandsFreeRepository {
  final StreamController<ListenStatus> statusController =
      StreamController<ListenStatus>.broadcast();
  final StreamController<String> utteranceController =
      StreamController<String>.broadcast();
  final StreamController<LiveUpdate> liveController =
      StreamController<LiveUpdate>.broadcast();
  ListenStatus current = ListenStatus.off;

  /// Locales live conversations were started in.
  final List<String> liveLocales = <String>[];
  int tokenRefreshes = 0;
  final List<String> typed = <String>[];

  /// Task results reported to the live conversation: (callId, status, reply, reason).
  final List<(String, String, String?, String?)> taskResults =
      <(String, String, String?, String?)>[];

  /// What start() reports; inactive when the microphone would not open.
  bool startWorks = true;
  Failure? failure;
  int starts = 0;
  int stops = 0;
  final List<bool> mutes = <bool>[];

  @override
  Stream<ListenStatus> get statusChanges => statusController.stream;

  @override
  Stream<String> get utterances => utteranceController.stream;

  @override
  Future<ListenStatus> start() async {
    starts++;
    if (failure case final Failure value) throw value;
    current = ListenStatus(active: startWorks, muted: current.muted);
    return current;
  }

  @override
  Future<void> stop() async {
    stops++;
    if (failure case final Failure value) throw value;
    current = ListenStatus(active: false, muted: current.muted);
  }

  @override
  Future<void> setMuted(bool muted) async {
    if (failure case final Failure value) throw value;
    mutes.add(muted);
    current = ListenStatus(active: current.active, muted: muted);
  }

  @override
  Future<ListenStatus> status() async {
    if (failure case final Failure value) throw value;
    return current;
  }

  @override
  Stream<LiveUpdate> get liveUpdates => liveController.stream;

  @override
  Future<ListenStatus> startLive({required String locale}) {
    liveLocales.add(locale);
    return start();
  }

  @override
  Future<void> refreshLiveToken() async => tokenRefreshes++;

  @override
  Future<void> sendLiveText(String text) async {
    if (failure case final Failure value) throw value;
    typed.add(text);
  }

  @override
  Future<void> liveTaskResult(
    String callId, {
    required String status,
    String? reply,
    String? reason,
  }) async {
    if (failure case final Failure value) throw value;
    taskResults.add((callId, status, reply, reason));
  }

  void live(LiveUpdate update) => liveController.add(update);

  void say(String path) => utteranceController.add(path);

  void report(ListenStatus status) {
    current = status;
    statusController.add(status);
  }
}

/// A settings store over mocked SharedPreferences.
Future<AppSettingsStore> testSettingsStore({
  bool onboardingDone = true,
  String? language,
  bool voiceReplies = true,
  bool confirmSensitiveActions = true,
  // Off in tests unless one is about hands-free coming on by itself (null).
  bool? handsFree = false,
}) async {
  SharedPreferences.setMockInitialValues(<String, Object>{
    'onboarding_done': onboardingDone,
    'language': ?language,
    'voice_replies': voiceReplies,
    'confirm_sensitive_actions': confirmSensitiveActions,
    'hands_free': ?handsFree,
  });
  return AppSettingsStore.load();
}

/// A phone whose permissions, switches and screens a test controls.
final class FakeDeviceSetup implements DeviceSetupRepository {
  final Map<SetupPermission, PermissionStatus> statuses =
      <SetupPermission, PermissionStatus>{};

  /// What the system dialog answers.
  PermissionStatus answer = PermissionStatus.granted;
  bool accessibility = false;
  DeviceSetup device = const DeviceSetup(
    batteryOptimizationIgnored: false,
    manufacturer: 'xiaomi',
    sdkInt: 34,
  );
  Failure? failure;
  final List<String> calls = <String>[];

  void _check() {
    if (failure case final Failure value) throw value;
  }

  @override
  Future<PermissionStatus> status(SetupPermission permission) async {
    _check();
    return statuses[permission] ?? PermissionStatus.denied;
  }

  @override
  Future<PermissionStatus> request(SetupPermission permission) async {
    calls.add('request:${permission.name}');
    statuses[permission] = answer;
    return answer;
  }

  @override
  Future<DeviceSetup> setup() async {
    _check();
    return device;
  }

  @override
  Future<bool> accessibilityEnabled() async {
    _check();
    return accessibility;
  }

  @override
  Future<void> openAccessibilitySettings() async => calls.add('accessibility');

  @override
  Future<void> openAppDetails() async => calls.add('appDetails');

  @override
  Future<void> requestBatteryExemption() async => calls.add('battery');

  @override
  Future<bool> openAutostart() async {
    calls.add('autostart');
    return true;
  }
}

/// Hands out [token]; records how long it had to stay valid.
final class FakeTokens implements AccessTokenSource {
  FakeTokens([this.token = 'access-token']);

  String? token;

  /// What a forced refresh turns [token] into (null: signed out).
  String? refreshesTo;
  final List<Duration> margins = <Duration>[];
  int forced = 0;

  @override
  Future<String?> accessToken({
    Duration margin = const Duration(minutes: 1),
    bool forceRefresh = false,
  }) async {
    margins.add(margin);
    if (forceRefresh) {
      forced++;
      token = refreshesTo;
    }
    return token;
  }
}

/// A session that is good for an hour from [now].
AuthSession testSession({DateTime? now}) => AuthSession(
  accessToken: 'access-token',
  refreshToken: 'refresh-token',
  expiresAt: (now ?? DateTime.now()).add(const Duration(hours: 1)),
  userId: '0190f0a0-0000-7000-8000-000000000001',
  email: 'aziz@example.com',
);

/// Sign-in that a test steers: [failure] makes every call fail; [onSignIn]
/// runs when a sign-in succeeds (e.g. to sign the session in).
final class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.googleAvailable = true});

  @override
  final bool googleAvailable;
  Object? failure;
  bool googleCancelled = false;
  Future<void> Function()? onSignIn;
  final List<String> calls = <String>[];

  Future<void> _done(String call) async {
    calls.add(call);
    if (failure case final Object value) throw value;
    await onSignIn?.call();
  }

  @override
  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) => _done('login:$email');

  @override
  Future<void> register({
    required String email,
    required String password,
    String? displayName,
  }) => _done('register:$email:${displayName ?? ''}');

  @override
  Future<bool> signInWithGoogle() async {
    if (googleCancelled) {
      calls.add('google-cancelled');
      return false;
    }
    await _done('google');
    return true;
  }

  @override
  Future<void> sendMagicLink(String email) async {
    calls.add('link:$email');
    if (failure case final Object value) throw value;
  }

  @override
  Future<void> signInWithMagicLink(String token) => _done('magic:$token');

  @override
  Future<void> verifyEmail(String token) async {
    calls.add('verify:$token');
    if (failure case final Object value) throw value;
  }
}

/// An account kept in memory.
final class FakeAccountRepository implements AccountRepository {
  Profile current = const Profile(
    email: 'aziz@example.com',
    emailVerified: true,
    displayName: 'Aziz',
    language: 'uz',
    confirmSensitiveActions: true,
    deletionScheduledAt: null,
  );
  List<Device> sessions = <Device>[
    Device(
      id: 'd1',
      name: 'Google Pixel 7',
      lastUsedAt: DateTime(2026, 10, 16),
      current: true,
    ),
    Device(
      id: 'd2',
      name: 'Tablet',
      lastUsedAt: DateTime(2026, 10, 10),
      current: false,
    ),
  ];
  Object? failure;
  final List<String> calls = <String>[];

  Future<void> _check(String call) async {
    calls.add(call);
    if (failure case final Object value) throw value;
  }

  Profile _with({
    String? displayName,
    String? language,
    bool? confirm,
    DateTime? deletion,
    bool clearDeletion = false,
  }) => current = Profile(
    email: current.email,
    emailVerified: current.emailVerified,
    displayName: displayName ?? current.displayName,
    language: language ?? current.language,
    confirmSensitiveActions: confirm ?? current.confirmSensitiveActions,
    deletionScheduledAt: clearDeletion
        ? null
        : (deletion ?? current.deletionScheduledAt),
  );

  @override
  Future<Profile> profile() async {
    await _check('profile');
    return current;
  }

  @override
  Future<Profile> update({
    String? displayName,
    String? language,
    bool? confirmSensitiveActions,
  }) async {
    await _check(
      'update:${displayName ?? ''}:${language ?? ''}:${confirmSensitiveActions ?? ''}',
    );
    return _with(
      displayName: displayName,
      language: language,
      confirm: confirmSensitiveActions,
    );
  }

  @override
  Future<void> resendVerification() => _check('resend');

  @override
  Future<List<Device>> devices() async {
    await _check('devices');
    return sessions;
  }

  @override
  Future<void> removeDevice(String id) async {
    await _check('remove:$id');
    sessions = <Device>[
      for (final Device d in sessions)
        if (d.id != id) d,
    ];
  }

  @override
  Future<void> signOut() => _check('signOut');

  @override
  Future<void> signOutEverywhere() => _check('signOutEverywhere');

  @override
  Future<DateTime> requestDeletion() async {
    await _check('delete');
    final DateTime at = DateTime(2026, 10, 23);
    _with(deletion: at);
    return at;
  }

  @override
  Future<Profile> cancelDeletion() async {
    await _check('cancelDeletion');
    return _with(clearDeletion: true);
  }
}

/// What the server answers to a sign-in.
TokenPairDto testPair({String access = 'access-token'}) => TokenPairDto(
  accessToken: access,
  expiresIn: 900,
  refreshToken: 'refresh-$access',
  user: const AuthUserDto(
    id: '0190f0a0-0000-7000-8000-000000000001',
    email: 'aziz@example.com',
  ),
);

/// Memory and history kept in a list.
final class FakeMemoryRepository implements MemoryRepository {
  List<MemoryEntry> entries = <MemoryEntry>[
    MemoryEntry(
      id: 'm1',
      kind: MemoryKind.contactAlias,
      content: 'onam = kontakt «Ona ❤️»',
      updatedAt: DateTime(2026, 10, 16),
    ),
    MemoryEntry(
      id: 'm2',
      kind: MemoryKind.preference,
      content: 'Telegram afzal',
      updatedAt: DateTime(2026, 10, 15),
    ),
  ];
  List<List<PastTask>> pages = <List<PastTask>>[
    <PastTask>[
      PastTask(
        id: 't1',
        title: 'Onamga yozish',
        status: PastTaskStatus.done,
        command: 'Onamga yoz',
        reply: 'Yozdim',
        createdAt: DateTime(2026, 10, 16, 9, 30),
      ),
      PastTask(
        id: 't2',
        title: 'Budilnik',
        status: PastTaskStatus.stopped,
        command: 'Budilnik qo‘y',
        reply: null,
        createdAt: DateTime(2026, 10, 16, 8),
      ),
    ],
  ];
  Object? failure;
  final List<String> calls = <String>[];

  Future<void> _check(String call) async {
    calls.add(call);
    if (failure case final Object value) throw value;
  }

  @override
  Future<List<MemoryEntry>> memories() async {
    await _check('memories');
    return entries;
  }

  @override
  Future<void> forget(String id) async {
    await _check('forget:$id');
    entries = <MemoryEntry>[
      for (final MemoryEntry e in entries)
        if (e.id != id) e,
    ];
  }

  @override
  Future<void> forgetAll() async {
    await _check('forgetAll');
    entries = <MemoryEntry>[];
  }

  @override
  Future<HistoryPage> history({DateTime? before}) async {
    await _check('history:${before?.toIso8601String() ?? 'first'}');
    final List<PastTask> page = pages.isEmpty
        ? <PastTask>[]
        : pages.removeAt(0);
    return HistoryPage(
      tasks: page,
      next: pages.isEmpty ? null : page.last.createdAt,
    );
  }

  @override
  Future<void> removeTask(String id) => _check('removeTask:$id');

  @override
  Future<void> clearHistory() => _check('clearHistory');
}

const List<Product> testProducts = <Product>[
  Product(
    code: 'free',
    kind: ProductKind.plan,
    priceUzs: 0,
    dailyCommands: 20,
    dailyScreenTasks: 3,
    vision: false,
    strongModel: false,
  ),
  Product(
    code: 'max',
    kind: ProductKind.plan,
    priceUzs: 164000,
    dailyCommands: null,
    dailyScreenTasks: null,
    vision: true,
    strongModel: true,
  ),
  Product(
    code: 'pro',
    kind: ProductKind.plan,
    priceUzs: 63000,
    dailyCommands: null,
    dailyScreenTasks: null,
    vision: true,
    strongModel: false,
  ),
  Product(
    code: 'pack_500',
    kind: ProductKind.pack,
    priceUzs: 25000,
    dailyCommands: null,
    dailyScreenTasks: null,
    vision: false,
    strongModel: false,
  ),
];

BillingStatus testBillingStatus({
  String plan = 'free',
  int usedPercent = 40,
  bool simple = false,
  SubscriptionState? subscription,
  bool cancelAtPeriodEnd = false,
  List<PayMethod> methods = PayMethod.values,
}) => BillingStatus(
  planCode: plan,
  usedPercent: usedPercent,
  simple: simple,
  periodEnd: DateTime.utc(2026, 11, 16, 7),
  subscription: subscription,
  cancelAtPeriodEnd: cancelAtPeriodEnd,
  methods: methods,
);

/// Plans and payments in memory; [payments] answers each `payment()` call in
/// turn (the last one repeats).
final class FakeBillingRepository implements BillingRepository {
  BillingStatus current = testBillingStatus();
  List<Product> catalog = testProducts;
  List<PaymentResult> payments = <PaymentResult>[PaymentResult.paid];
  Object? failure;
  Object? checkoutFailure;
  final List<String> calls = <String>[];

  Future<void> _check(String call) async {
    calls.add(call);
    if (failure case final Object value) throw value;
  }

  @override
  Future<BillingStatus> status() async {
    await _check('status');
    return current;
  }

  @override
  Future<List<Product>> products() async {
    await _check('products');
    return catalog;
  }

  @override
  Future<Checkout> checkout({
    required String product,
    required PayMethod method,
    required String language,
  }) async {
    await _check('checkout:$product:${method.name}:$language');
    if (checkoutFailure case final Object value) throw value;
    return Checkout(
      paymentId: 'pay-1',
      url: Uri.parse('https://checkout.example/pay-1'),
    );
  }

  @override
  Future<PaymentResult> payment(String id) async {
    await _check('payment:$id');
    return payments.length > 1 ? payments.removeAt(0) : payments.single;
  }

  @override
  Future<void> cancel() async {
    await _check('cancel');
    current = testBillingStatus(
      plan: current.planCode,
      subscription: current.subscription,
      cancelAtPeriodEnd: true,
    );
  }

  @override
  Future<void> resume() async {
    await _check('resume');
    current = testBillingStatus(
      plan: current.planCode,
      subscription: current.subscription,
    );
  }
}

Release testRelease({int versionCode = 5, int minSupported = 1}) => Release(
  versionCode: versionCode,
  versionName: '0.$versionCode.0',
  apkUrl: Uri.parse('https://cdn.alesle.ai/alesle-0.$versionCode.0.apk'),
  sha256: 'a' * 64,
  certSha256: 'b' * 64,
  sizeBytes: 42000000,
  minSupportedVersionCode: minSupported,
  notes: const <String, String>{
    'en': 'Faster replies',
    'uz': 'Tezroq javoblar',
    'ru': 'Быстрее ответы',
  },
);

/// The manifest and installer in memory.
final class FakeUpdateRepository implements UpdateRepository {
  Release? newest;
  Object? failure;
  InstallResult result = InstallResult.started;
  final List<String> calls = <String>[];

  @override
  Future<Release?> latest() async {
    calls.add('latest');
    if (failure case final Object value) throw value;
    return newest;
  }

  @override
  Future<String> download(
    Release release, {
    void Function(double)? progress,
  }) async {
    calls.add('download:${release.versionCode}');
    progress?.call(0.5);
    progress?.call(1);
    return '/cache/alesle-${release.versionCode}.apk';
  }

  @override
  Future<InstallResult> install(Release release, String path) async {
    calls.add('install:$path');
    return result;
  }
}
