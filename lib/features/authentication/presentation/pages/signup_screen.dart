import 'package:auto_route/auto_route.dart';
import 'package:keyboard_actions/external/platform_check/platform_check.dart';
import '../../../../core/common/buttons/custom_button.dart';
import '../../../../translations/locale_keys.g.dart';
import '../../../../core/common/uistate/common_ui_state.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/routes/routes.gr.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/images.dart';
import '../../../../core/theme/strings.dart';
import '../../../../core/widgets/loading_bar.dart';
import '../../../../extensions.dart';
import '../bloc/sign_up_cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:easy_localization/easy_localization.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  SignUpCubit? signUpCubit;
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _userNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  FocusNode _firstNameFocuse = FocusNode();
  FocusNode _lastNameFocuse = FocusNode();
  FocusNode _userNameFocuse = FocusNode();

  @override
  void initState() {
    super.initState();
    signUpCubit = getIt<SignUpCubit>();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _userNameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _userNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameFocuse.dispose();
    _lastNameFocuse.dispose();
    _userNameFocuse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.initScreenUtil();
    return BlocProvider<SignUpCubit>(
      create: (c) => signUpCubit!,
      child: BlocListener<SignUpCubit, CommonUIState>(
        listener: (_, state) {
          state.maybeWhen(
            orElse: () {},
            error: (e) {
              if (e!.isNotEmpty) {
                context.showOkAlertDialog(
                  desc: e,
                  title: "Information",
                );
              }
            },
            success: (isSocial) {
              // If logged in using social media buttons
              if (isSocial) {
                context.router.root.pushAndPopUntil(FeedScreenRoute(),
                    predicate: (route) => false);
              } else {
                context.showOkAlertDialog(
                  desc: "Sign up successfully",
                  title: "Information",
                  onTapOk: () {
                    context.router.root.replace(LoginScreenRoute());
                  },
                );
              }
            },
          );
        },
        child: BlocBuilder<SignUpCubit, CommonUIState>(
          builder: (context, state) {
            return state.when(
              initial: buildHome,
              success: (s) => buildHome(),
              loading: () => LoadingBar(),
              error: (e) => buildHome(),
            );
          },
        ),
      ),
    );
  }

  Widget buildHome() {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          constraints:
              BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
          child: KeyboardActions(
            config: KeyboardActionsConfig(
              keyboardActionsPlatform: KeyboardActionsPlatform.IOS,
              actions: [
                KeyboardActionsItem(
                  focusNode: signUpCubit!.firstNameValidator.focusNode,
                ),
                KeyboardActionsItem(
                  focusNode: signUpCubit!.lastNameValidator.focusNode,
                ),
                KeyboardActionsItem(
                  focusNode: signUpCubit!.userNameValidator.focusNode,
                ),
                KeyboardActionsItem(
                  focusNode: signUpCubit!.emailValidator.focusNode,
                ),
                KeyboardActionsItem(
                  focusNode: signUpCubit!.passwordValidator.focusNode,
                ),
                KeyboardActionsItem(
                  displayDoneButton: true,
                  focusNode: signUpCubit!.confirmPasswordValidator.focusNode,
                ),
              ],
            ),
            child: [buildTopView(), buildMiddleView(), buildBottomView()]
                .toColumn(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center)
                .makeScrollable()
                .toContainer(alignment: Alignment.center, color: Colors.white)
                .toHorizontalPadding(24.0),
          ),
        ));
  }

  Widget buildTopView() {
    return [
      60.toSizedBox,
      AppIcons.appLogo.toContainer(alignment: Alignment.center),
      30.toSizedBox,
      Strings.firstName.toTextField(
        focusNode: _firstNameFocuse,
        keyboardType: TextInputType.name,
        controller: _firstNameController,
        onChange: (s) => setState(() {}),
        textInputAction: TextInputAction.next,
        errorText:
            _firstNameController.text.isEmpty && _firstNameFocuse.hasFocus
                ? 'Please Enter your first name'
                : null,
      ),
      11.toSizedBox,
      Strings.lastName.toTextField(
        focusNode: _lastNameFocuse,
        keyboardType: TextInputType.name,
        controller: _lastNameController,
        textInputAction: TextInputAction.next,
        onChange: (s) => setState(() {}),
        errorText: _lastNameController.text.isEmpty && _lastNameFocuse.hasFocus
            ? 'Please Enter your last name'
            : null,
      ),
      10.toSizedBox,
      Strings.userName.toTextField(
        focusNode: _userNameFocuse,
        controller: _userNameController,
        textInputAction: TextInputAction.next,
        onChange: (s) => setState(() {}),
        errorText: _userNameController.text.isEmpty && _userNameFocuse.hasFocus
            ? 'Please Enter a valid username'
            : null,
      ),
      10.toSizedBox,
      Strings.emailAddress.toTextField(
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        controller: _emailController,
        onChange: (s) => setState(() {}),
        errorText: !_emailController.text.isValidEmail &&
                _emailController.text.isNotEmpty
            ? 'Please Enter a valid email address'
            : null,
      ),
      10.toSizedBox,
      Strings.password.toTextField(
        controller: _passwordController,
        textInputAction: TextInputAction.next,
        onChange: (s) => setState(() {}),
        errorText: _passwordController.text.length <= 6 &&
                _passwordController.text.isNotEmpty
            ? 'Please enter more than 6 characters'
            : null,
      ),
      10.toSizedBox,
      Strings.confirmPassword.toTextField(
        controller: _confirmPasswordController,
        onChange: (s) => setState(() {}),
        textInputAction: TextInputAction.done,
        errorText:
            _confirmPasswordController.text != _passwordController.text &&
                    _confirmPasswordController.text.isNotEmpty
                ? 'Password does not match'
                : null,
      ),
    ].toColumn(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.end);
  }

  Widget buildMiddleView() {
    bool _emailValid = _emailController.text.isValidEmail;
    bool _passwordValid = _passwordController.text.length > 6;
    bool _confirmPasswordValid =
        _confirmPasswordController.text == _passwordController.text;
    bool _formValid = _emailValid &&
        _passwordValid &&
        _confirmPasswordValid &&
        _userNameController.text.isNotEmpty &&
        _lastNameController.text.isNotEmpty &&
        _firstNameController.text.isNotEmpty;
    return [
      40.toSizedBox,
      Strings.byClickingAgree
          .toButton(fontSize: 12.0, color: AppColors.greyText),
      [
        Strings.termsOfUse
            .toButton(fontSize: 12.0, color: AppColors.colorPrimary)
            .onTapWidget(() {
          context.removeFocus();
          context.router.root.push(WebViewScreenRoute(
              url: Strings.termsUrl, name0: Strings.termsOfUse));
        }),
        " and ".toButton(fontSize: 12.0, color: AppColors.greyText),
        Strings.privacy
            .toButton(fontSize: 12.0, color: AppColors.colorPrimary)
            .onTapWidget(() {
          context.removeFocus();
          context.router.root.push(
            WebViewScreenRoute(url: Strings.privacyUrl, name0: Strings.privacy),
          );
        })
      ].toRow(mainAxisAlignment: MainAxisAlignment.center),
      25.toSizedBox,
      CustomButton(
        color: _formValid
            ? AppColors.colorPrimary
            : AppColors.colorPrimary.withOpacity(.5),
        text: LocaleKeys.sign_up.tr(),
        fullWidth: true,
        onTap: () async {
          if (_formValid)
            await await signUpCubit!.signUp(
              firstName: _firstNameController.text,
              lastName: _lastNameController.text,
              emailAdress: _emailController.text,
              password: _passwordController.text,
              userName: _userNameController.text,
            );
          FocusManager.instance.primaryFocus!.unfocus();
        },
      ),
      //Strings.signUp
      // await signUpCubit!.signUp();
      25.toSizedBox,
      [

        Images.google
            .toSvg()
            .toFlatButton(
              () => {signUpCubit!.googleLogin()},
            )
            .toSizedBox(height: 40, width: 55)
            .toContainer(
                decoration: BoxDecoration(
              border: Border.all(width: 1, color: Colors.grey.withOpacity(.1)),
              shape: BoxShape.rectangle,
            ))
            .toVisibility(PlatformCheck.isAndroid),
        10.toSizedBox,
        Images.twitter
            .toSvg()
            .toFlatButton(
                () => {context.showSnackBar(message: Strings.twitterComing)},
                color: AppColors.twitterBlue)
            .toSizedBox(height: 40, width: 55)
            .toVisibility(false),
      ].toRow(mainAxisAlignment: MainAxisAlignment.center),
    ].toColumn(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center);
  }

  Widget buildBottomView() {
    return [
      10.toSizedBox,
      Strings.haveAlreadyAccount.toCaption(),
      Strings.signIn
          .toButton(color: AppColors.colorPrimary)
          .toUnderLine()
          .toFlatButton(
              () => {context.router.root.replace(LoginScreenRoute())}),
    ].toColumn(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center);
  }
}
