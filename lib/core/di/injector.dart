import 'package:creatify_mobile/core/http/dio_http_service.dart';
import 'package:creatify_mobile/core/http/http_service.dart';
import 'package:creatify_mobile/data/remote/auth/auth_repo.dart';
import 'package:creatify_mobile/data/remote/auth/auth_service.dart';
import 'package:creatify_mobile/data/remote/bookings/bookings_repo.dart';
import 'package:creatify_mobile/data/remote/bookings/bookings_service.dart';
import 'package:creatify_mobile/data/remote/chat/chat_repo.dart';
import 'package:creatify_mobile/data/remote/chat/chat_service.dart';
import 'package:creatify_mobile/data/remote/creators/creator_repo.dart';
import 'package:creatify_mobile/data/remote/creators/creator_service.dart';
import 'package:creatify_mobile/data/remote/transactions/transactions_repo.dart';
import 'package:creatify_mobile/data/remote/transactions/transactions_service.dart';
import 'package:creatify_mobile/view/modules/jobs/vm/job_service.dart';
import 'package:get_it/get_it.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:creatify_mobile/core/storage/hive-storage/hive_storage.dart';
import 'package:creatify_mobile/core/storage/hive-storage/hive_storage_service.dart';
import 'package:creatify_mobile/core/storage/secure-storage/secure_storage.dart';
import 'package:creatify_mobile/core/storage/share_pref.dart';
import 'package:creatify_mobile/core/third-party/environment.dart';
import 'package:creatify_mobile/core/utils/app_url.dart';

final inject = GetIt.instance;

Future<void> initializeCore({required Environmentx environment}) async {
  ApiEndpoints.init(environment);
  await _initializeCore();
  await _initstorage();
}

Future<void> _initializeCore() async {
  await SharedPrefManager.init();
}

/// Initialize services's here

Future<void> _initstorage() async {
  ///------------>> Storage
  inject.registerLazySingleton<SecureStorage>(() => SecureStorage());
  inject.registerLazySingleton<SecureStorageBase>(() => SecureStorage());
}

///----------------------->> Storage

final hiveStorageService = Provider<HiveStorageBase>(
  (_) => HiveStorageService(),
);

final secureStorageService = Provider<SecureStorageBase>(
  (_) => SecureStorage(),
);

/// Network Service
final _networkService = Provider<HttpService>((ref) => NetworkService());

/// User Storage
// final userStorageService = Provider<UserStorageService>((ref) {
//   return UserStorageService(
//     storageService: ref.watch(hiveStorageService),
//   );
// });

// final userRepo = Provider<UserRepository>((ref) {
//   final userService = ref.watch(userStorageService);
//   return UserDataStorage(userService);
// });

/// Auth Service Dependency Injection
final _authService = Provider<AuthService>((ref) {
  var network = ref.watch(_networkService);
  var secureStorage = ref.watch(secureStorageService);
  var hiveStorage = ref.watch(hiveStorageService);
  return AuthService(
    networkService: network,
    storage: secureStorage,
    hiveStorage: hiveStorage,
  );
});

final authRepository = Provider<AuthRepo>(
  (ref) {
    final authService = ref.watch(_authService);
    return AuthImpl(authService);
  },
);

/// Creator Service Dependency Injection
final _creatorService = Provider<CreatorService>((ref) {
  var network = ref.watch(_networkService);
  return CreatorService(networkService: network);
});

final creatorRepository = Provider<CreatorRepo>(
  (ref) {
    final creatorService = ref.watch(_creatorService);
    return CreatorRepoImpl(creatorService);
  },
);

/// Bookings Service Dependency Injection
final _bookingsService = Provider<BookingsService>((ref) {
  var network = ref.watch(_networkService);
  return BookingsService(networkService: network);
});

final bookingsRepository = Provider<BookingsRepo>(
  (ref) {
    final bookingsService = ref.watch(_bookingsService);
    return BookingsRepoImpl(bookingsService);
  },
);

// Transactions Service Dependency Injection
final _transactionsService = Provider<TransactionsService>((ref) {
  var network = ref.watch(_networkService);
  return TransactionsService(networkService: network);
});

final transactionsRepository = Provider<TransactionsRepo>(
  (ref) {
    final transactionsService = ref.watch(_transactionsService);
    return TransactionsRepoImpl(transactionsService);
  },
);

// Chat Service Dependency Injection
final _chatService = Provider<ChatService>((ref) {
  var network = ref.watch(_networkService);
  return ChatService(networkService: network);
});

final chatRepository = Provider<ChatRepo>(
  (ref) {
    final chatService = ref.watch(_chatService);
    return ChatImpl(chatService);
  },
);

final jobApiProvider = Provider<JobApiService>((ref) {
  var network = ref.watch(_networkService);
  return JobApiService(networkService: network);
});
