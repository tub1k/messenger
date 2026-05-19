import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:messenger/presentation/auth/auth_screen.dart';
import 'package:messenger/presentation/auth/bloc/auth_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;
  late AuthScreen authScreen;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    authScreen = AuthScreen();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<AuthBloc>.value(
        value: mockAuthBloc,
        child: authScreen,
      ),
    );
  }
  group('AuthScreen Widget Tests -', () {
    
    testWidgets('При состоянии AuthLoading должен активироваться AbsorbPointer', (WidgetTester tester) async {
      when(() => mockAuthBloc.state).thenReturn(AuthLoading());

      await tester.pumpWidget(createWidgetUnderTest());

      final absorbPointerFinder = find.descendant(of: find.byType(AuthScreen), matching: find.byType(AbsorbPointer));
      expect(absorbPointerFinder, findsOne);
      final AbsorbPointer absorbPointerWidget = tester.widget(absorbPointerFinder);
      
      expect(absorbPointerWidget.absorbing, true);
      expect(find.byType(CircularProgressIndicator), findsOne);
    });

    testWidgets('При ошибке в AuthInitial listener должен вызвать SnackBar', (WidgetTester tester) async {
      when(() => mockAuthBloc.state).thenReturn(AuthInitial());
      
      whenListen(
        mockAuthBloc,
        Stream.fromIterable([AuthInitial(errorText: 'Неверный пароль')]),
        initialState: AuthInitial(),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle(); 

      expect(find.byType(SnackBar), findsOne);
      expect(find.text('Неверный пароль'), findsOne);
    });
    testWidgets('При состоянии AuthEnterUsername должен быть один TextField для ввода ника', (WidgetTester tester) async {
      whenListen(mockAuthBloc, 
        Stream.fromIterable([AuthEnterUsername()]),
        initialState: AuthInitial(),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final textFieldFinder = find.byType(TextField);
      expect(textFieldFinder, findsOne);
      final TextField widget = tester.widget(textFieldFinder);
      expect(widget.keyboardType, TextInputType.text);
    });
  });
}
