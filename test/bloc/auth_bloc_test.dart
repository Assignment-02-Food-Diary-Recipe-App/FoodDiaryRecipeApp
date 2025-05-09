import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_recipe_app/authentication/bloc/auth_bloc.dart';
import 'package:food_recipe_app/authentication/bloc/auth_event.dart';
import 'package:food_recipe_app/authentication/bloc/auth_state.dart';
import 'package:food_recipe_app/authentication/repository/auth_repository.dart';
import 'package:mockito/mockito.dart';
import '../mocks/mock_auth_repository.mocks.dart'; // This is generated

void main() {
  late MockAuthRepository mockAuthRepository;
  late AuthBloc authBloc;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    authBloc = AuthBloc(authRepository: mockAuthRepository);
  });

  tearDown(() {
    authBloc.close();
  });

  group('AuthBloc', () {
    const testEmail = 'test@example.com';
    const testPassword = 'password123';

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthSuccess] when sign up succeeds',
      build: () {
        when(mockAuthRepository.signUp(email: testEmail, password: testPassword))
            .thenAnswer((_) async => null); // mocking success
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthSignUpRequested(email: testEmail, password: testPassword)),
      expect: () => [AuthLoading(), AuthSuccess()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailure] when sign up fails',
      build: () {
        when(mockAuthRepository.signUp(email: testEmail, password: testPassword))
            .thenThrow(Exception('Signup failed'));
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthSignUpRequested(email: testEmail, password: testPassword)),
      expect: () => [AuthLoading(), isA<AuthFailure>()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthSuccess] when login succeeds',
      build: () {
        when(mockAuthRepository.login(email: testEmail, password: testPassword))
            .thenAnswer((_) async => null);
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthLoginRequested(email: testEmail, password: testPassword)),
      expect: () => [AuthLoading(), AuthSuccess()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailure] when login fails',
      build: () {
        when(mockAuthRepository.login(email: testEmail, password: testPassword))
            .thenThrow(Exception('Login failed'));
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthLoginRequested(email: testEmail, password: testPassword)),
      expect: () => [AuthLoading(), isA<AuthFailure>()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthInitial] when logout succeeds',
      build: () {
        when(mockAuthRepository.logout()).thenAnswer((_) async {});
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthLogoutRequested()),
      expect: () => [AuthLoading(), AuthInitial()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailure] when logout fails',
      build: () {
        when(mockAuthRepository.logout()).thenThrow(Exception('Logout failed'));
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthLogoutRequested()),
      expect: () => [AuthLoading(), isA<AuthFailure>()],
    );
  });
}
