import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:harvest_pro/core/utils/app_bar.dart';
import 'package:harvest_pro/core/constants/constants.dart';
import 'package:harvest_pro/screen/common/nav/nav.dart';
import 'package:harvest_pro/core/services/helper.dart';
import 'package:harvest_pro/screen/common/auth/authentication_bloc.dart';
import 'package:harvest_pro/screen/common/auth/login/login_screen.dart';
import 'package:harvest_pro/screen/common/auth/signUp/sign_up_bloc.dart';
import 'package:harvest_pro/screen/common/loading_cubit.dart';
import 'package:harvest_pro/core/utils/next_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State createState() => _SignUpState();
}

class _SignUpState extends State<SignUpScreen> {
  Uint8List? _imageData;
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _key = GlobalKey();
  String? name, lastName, email, password, confirmPassword;
  AutovalidateMode _validate = AutovalidateMode.disabled;
  bool acceptEULA = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SignUpBloc>(
      create: (context) => SignUpBloc(),
      child: Builder(
        builder: (context) {
          if (!kIsWeb && Platform.isAndroid) {
            context.read<SignUpBloc>().add(RetrieveLostDataEvent());
          }
          return MultiBlocListener(
            listeners: [
              BlocListener<AuthenticationBloc, AuthenticationState>(
                listener: (context, state) {
                  context.read<LoadingCubit>().hideLoading();
                  if (state.authState == AuthState.authenticated) {
                    pushAndRemoveUntil(context, Nav(), false);
                  } else {
                    showSnackBar(
                        context,
                        state.message ??
                            'Couldn\'t sign up, Please try again.');
                  }
                },
              ),
              BlocListener<SignUpBloc, SignUpState>(
                listener: (context, state) async {
                  if (state is ValidFields) {
                    await context.read<LoadingCubit>().showLoading(
                        context, 'Creating new account, Please wait...', false);
                    if (!mounted) return;
                    context.read<AuthenticationBloc>().add(
                        SignupWithEmailAndPasswordEvent(
                            emailAddress: email!,
                            password: password!,
                            imageData: _imageData,
                            lastName: lastName,
                            name: name));
                  } else if (state is SignUpFailureState) {
                    showSnackBar(context, state.errorMessage);
                  }
                },
              ),
            ],
            child: Scaffold(
              appBar: CustomAppBar(
                title: '',
                leadingImage: 'assets/icons/Back.png',
                actionImage: null,
                // actionImage: null,
                onLeadingPressed: () {
                  nextScreenReplace(context, const LoginScreen());
                },
                onActionPressed: () {
                  print("Action icon pressed");
                },
              ),
              body: SingleChildScrollView(
                padding:
                    const EdgeInsets.only(left: 16.0, right: 16, bottom: 16),
                child: BlocBuilder<SignUpBloc, SignUpState>(
                  buildWhen: (old, current) =>
                      current is SignUpFailureState && old != current,
                  builder: (context, state) {
                    if (state is SignUpFailureState) {
                      _validate = AutovalidateMode.onUserInteraction;
                    }
                    return Form(
                      key: _key,
                      autovalidateMode: _validate,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Align(
                            alignment: Alignment.center,
                            child: Text(
                              'Create new account',
                              style: TextStyle(
                                  color: Color(colorPrimary),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25.0),
                            ),
                          ),
                          // Padding(
                          //   padding: const EdgeInsets.only(
                          //       left: 8.0, top: 32, right: 8, bottom: 8),
                          //   child: Stack(
                          //     alignment: Alignment.bottomCenter,
                          //     children: [
                          //       BlocBuilder<SignUpBloc, SignUpState>(
                          //         buildWhen: (old, current) =>
                          //             current is PictureSelectedState &&
                          //             old != current,
                          //         builder: (context, state) {
                          //           if (state is PictureSelectedState) {
                          //             _imageData = state.imageData;
                          //           }
                          //           return state is PictureSelectedState
                          //               ? SizedBox(
                          //                   height: 130,
                          //                   width: 130,
                          //                   child: ClipRRect(
                          //                       borderRadius:
                          //                           BorderRadius.circular(65),
                          //                       child: state.imageData == null
                          //                           ? Image.asset(
                          //                               'assets/images/placeholder.jpg',
                          //                               fit: BoxFit.cover,
                          //                             )
                          //                           : Image.memory(
                          //                               state.imageData!,
                          //                               fit: BoxFit.cover,
                          //                             )),
                          //                 )
                          //               : SizedBox(
                          //                   height: 130,
                          //                   width: 130,
                          //                   child: ClipRRect(
                          //                     borderRadius:
                          //                         BorderRadius.circular(65),
                          //                     child: Image.asset(
                          //                       'assets/images/placeholder.jpg',
                          //                       fit: BoxFit.cover,
                          //                     ),
                          //                   ),
                          //                 );
                          //         },
                          //       ),
                          //       Positioned(
                          //         right: 0,
                          //         child: FloatingActionButton(
                          //           backgroundColor: const Color(colorPrimary),
                          //           mini: true,
                          //           onPressed: () => _onCameraClick(context),
                          //           child: Icon(
                          //             Icons.camera_alt,
                          //             color: isDarkMode(context)
                          //                 ? Colors.black
                          //                 : Colors.white,
                          //           ),
                          //         ),
                          //       )
                          //     ],
                          //   ),
                          // ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 16.0, right: 8.0, left: 8.0),
                            child: TextFormField(
                              textCapitalization: TextCapitalization.words,
                              validator: validateName,
                              onSaved: (String? val) {
                                name = val;
                              },
                              textInputAction: TextInputAction.next,
                              decoration: getInputDecoration(
                                  hint: 'First Name',
                                  darkMode: isDarkMode(context),
                                  errorColor:
                                      Theme.of(context).colorScheme.error),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 16.0, right: 8.0, left: 8.0),
                            child: TextFormField(
                              textCapitalization: TextCapitalization.words,
                              validator: validateName,
                              onSaved: (String? val) {
                                lastName = val;
                              },
                              textInputAction: TextInputAction.next,
                              decoration: getInputDecoration(
                                  hint: 'Last Name',
                                  darkMode: isDarkMode(context),
                                  errorColor:
                                      Theme.of(context).colorScheme.error),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 16.0, right: 8.0, left: 8.0),
                            child: TextFormField(
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              validator: validateEmail,
                              onSaved: (String? val) {
                                email = val;
                              },
                              decoration: getInputDecoration(
                                  hint: 'Email',
                                  darkMode: isDarkMode(context),
                                  errorColor:
                                      Theme.of(context).colorScheme.error),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 16.0, right: 8.0, left: 8.0),
                            child: TextFormField(
                              obscureText: true,
                              textInputAction: TextInputAction.next,
                              controller: _passwordController,
                              validator: validatePassword,
                              onSaved: (String? val) {
                                password = val;
                              },
                              style:
                                  const TextStyle(height: 0.8, fontSize: 18.0),
                              cursorColor: const Color(colorPrimary),
                              decoration: getInputDecoration(
                                  hint: 'Password',
                                  darkMode: isDarkMode(context),
                                  errorColor:
                                      Theme.of(context).colorScheme.error),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 16.0, right: 8.0, left: 8.0),
                            child: TextFormField(
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) =>
                                  context.read<SignUpBloc>().add(
                                        ValidateFieldsEvent(_key,
                                            acceptEula: acceptEULA),
                                      ),
                              obscureText: true,
                              validator: (val) => validateConfirmPassword(
                                  _passwordController.text, val),
                              onSaved: (String? val) {
                                confirmPassword = val;
                              },
                              style:
                                  const TextStyle(height: 0.8, fontSize: 18.0),
                              cursorColor: const Color(colorPrimary),
                              decoration: getInputDecoration(
                                  hint: 'Confirm Password',
                                  darkMode: isDarkMode(context),
                                  errorColor:
                                      Theme.of(context).colorScheme.error),
                            ),
                          ),
                          const SizedBox(height: 24),
                          ListTile(
                            trailing: BlocBuilder<SignUpBloc, SignUpState>(
                              buildWhen: (old, current) =>
                                  current is EulaToggleState && old != current,
                              builder: (context, state) {
                                if (state is EulaToggleState) {
                                  acceptEULA = state.eulaAccepted;
                                }
                                return Checkbox(
                                  onChanged: (value) =>
                                      context.read<SignUpBloc>().add(
                                            ToggleEulaCheckboxEvent(
                                              eulaAccepted: value!,
                                            ),
                                          ),
                                  activeColor: const Color(colorPrimary),
                                  value: acceptEULA,
                                );
                              },
                            ),
                            title: RichText(
                              textAlign: TextAlign.left,
                              text: TextSpan(
                                children: [
                                  const TextSpan(
                                    text:
                                        'By creating an account you agree to our ',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  TextSpan(
                                    style: const TextStyle(
                                      color: const Color(colorPrimary),
                                    ),
                                    text: 'Terms of Use',
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () async {
                                        if (await canLaunchUrl(
                                            Uri.parse(eula))) {
                                          await launchUrl(
                                            Uri.parse(eula),
                                          );
                                        }
                                      },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                right: 40.0, left: 40.0, top: 40.0),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.blue,
                                    Colors.green,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(50.0),
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  fixedSize: Size.fromWidth(
                                      MediaQuery.of(context).size.width / 1.5),
                                  padding: const EdgeInsets.only(
                                      top: 16, bottom: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25.0),
                                    side: const BorderSide(
                                      color: Color(colorPrimary),
                                    ),
                                  ),
                                ),
                                child: const Wrap(
                                  children: [
                                    Icon(
                                      Icons.person,
                                      size: 22,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 20),
                                    Text("Sign Up",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500)),
                                  ],
                                ),
                                onPressed: () => context.read<SignUpBloc>().add(
                                      ValidateFieldsEvent(_key,
                                          acceptEula: acceptEULA),
                                    ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // _onCameraClick(BuildContext context) {
  //   if (kIsWeb || Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
  //     context.read<SignUpBloc>().add(ChooseImageFromGalleryEvent());
  //   } else {
  //     final action = CupertinoActionSheet(
  //       title: const Text(
  //         'Add Profile Picture',
  //         style: TextStyle(fontSize: 15.0),
  //       ),
  //       actions: [
  //         CupertinoActionSheetAction(
  //           isDefaultAction: false,
  //           onPressed: () async {
  //             Navigator.pop(context);
  //             context.read<SignUpBloc>().add(ChooseImageFromGalleryEvent());
  //           },
  //           child: const Text('Choose from gallery'),
  //         ),
  //         CupertinoActionSheetAction(
  //           isDestructiveAction: false,
  //           onPressed: () async {
  //             Navigator.pop(context);
  //             context.read<SignUpBloc>().add(CaptureImageByCameraEvent());
  //           },
  //           child: const Text('Take a picture'),
  //         )
  //       ],
  //       cancelButton: CupertinoActionSheetAction(
  //           child: const Text('Cancel'),
  //           onPressed: () => Navigator.pop(context)),
  //     );
  //     showCupertinoModalPopup(context: context, builder: (context) => action);
  //   }
  // }

  @override
  void dispose() {
    _passwordController.dispose();
    _imageData = null;
    super.dispose();
  }
}
