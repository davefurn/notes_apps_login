import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'apis/login_api.dart';
import 'apis/notes_api.dart';
import 'bloc/actions.dart';
import 'bloc/app_bloc.dart';
import 'bloc/app_state.dart';
import 'dialogue/generic_dialog.dart';
import 'dialogue/loading_screen.dart';
import 'libs/views/iterable_list_view.dart';
import 'libs/views/login_view.dart';
import 'models.dart';
import 'strings.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const Center(child: HomePage()),
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AppBloc(
        loginApi: LoginApi(),
        notesApi: NotesApi(), 
        acceptedLoginHandle:const LoginHandle.fooBar(),
        
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(homepage),
        ),
        body: BlocConsumer<AppBloc, AppState>(
          listener: (context, appstate) {
            //take care of loading screen
            if (appstate.isLoading) {
              LoadingScreen.instance().show(
                context: context,
                text: pleaseWait,
              );
            } else {
              LoadingScreen.instance().hide();
            }
            //display possible errors
            final loginErrors = appstate.loginErrors;
            if (loginErrors != null) {
              showGenericDialog<bool>(
                context: context,
                title: loginErrorDialogTitle,
                content: loginErrorDialogContent,
                optionsBuilder: () => {ok: true},
              );
            }

            //if we are logged in but we have no fetched notes,fetch them now
            if (appstate.isLoading == false &&
                appstate.loginErrors == null &&
                appstate.loginHandle == const LoginHandle.fooBar() &&
                appstate.fetchedNotes == null) {
              context.read<AppBloc>().add(
                    const LoadNotesAction(),
                  );
            }
          },
          builder: (context, appState) {
            final notes = appState.fetchedNotes;
            if (notes == null) {
              return LoginView(
                onLoginTapped: (email, password) {
                  context
                  .read<AppBloc>()
                  .add(
                        LoginAction(
                          email: email,
                          password: password,
                        ),
                      );
                },
              );
            } else {
              return notes.toListView();
            }
          },
        ),
      ),
    );
  }
}
