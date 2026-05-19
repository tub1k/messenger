import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:messenger/data/repository/i_auth_repository.dart';
import 'package:messenger/presentation/auth/bloc/auth_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late MockAuthRepository authRepository;
  late AuthBloc authBloc;

  setUp(() {
    authRepository = MockAuthRepository();
    when(() => authRepository.authStateChanges)
        .thenAnswer((_) => const Stream<String?>.empty());

    authBloc = AuthBloc(repository: authRepository);
  });

  tearDown(() {
    authBloc.close();
  });

  test('initial state should be AuthInitial', () {
    expect(authBloc.state, isA<AuthInitial>());
  });

  blocTest<AuthBloc, AuthState>(
    'should emit AuthEnterUserName on AuthGoToEnterUsernameScreen', 
    build: () => authBloc,
    act: (bloc) => bloc.add(AuthGoToUsernameScreen()),
    expect: () => [isA<AuthEnterUsername>()],
  );

  blocTest<AuthBloc, AuthState>(
    'should emit AuthLoading on trying to log in',
    build: () => authBloc,
    act: (bloc) => bloc.add(AuthSignInEmail(email: 'test@test.com', password: 'legend')),
    expect: () => [isA<AuthLoading>(), isA<AuthInitial>()],
  );
}