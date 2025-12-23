
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gaanap_admin_new/res/color/colors.dart';
import 'package:gaanap_admin_new/res/images/images.dart';
import 'package:gaanap_admin_new/utils/Utils.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/enums.dart';

import '../../bloc/login/login_bloc.dart';
import '../../config/routes/routes_name.dart';
import '../../main.dart';
import '../../models/user/user_model.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  UserModel userModel = UserModel();

  final _formkey = GlobalKey<FormState>();
  final usernameFocusNode = FocusNode();
  final gameCodeFocusnode = FocusNode();
  final emailFocusnode = FocusNode();
  File? _image;
  final ImagePicker _picker = ImagePicker();

  late LoginBloc _loginBloc;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // WakelockPlus.disable();

    _loginBloc = LoginBloc(loginRepository: getit());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      // appBar: AppBar(
      //   backgroundColor: AppColors.primaryColor,
      //   title: const Center(
      //     child: Text("HFMGame",
      //     style: TextStyle(
      //       color: Colors.white
      //     ),),
      //   ),
      // ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Form(
              key: _formkey,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    SvgPicture.asset(AppImages.hfmgame,
                      height: MediaQuery.of(context).size.height *.2,
                    ),

                    const SizedBox(height: 50,),

                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: AppColors.white,
                        border: Border.all(color: Colors.black)
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          Icon(Icons.account_circle_sharp),
                          const SizedBox(width: 10,),
                          Expanded(
                            child: TextFormField(
                              decoration: InputDecoration(
                                  hintText: "Username",
                                  border: InputBorder.none,
                              ),
                              keyboardType: TextInputType.name,
                              textInputAction: TextInputAction.next,
                              focusNode: usernameFocusNode,
                              onChanged: (value) {
                                print("$value");

                                context.read<LoginBloc>().add(UsernameChange(username: value));
                              },
                              onFieldSubmitted: (value) {},
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Enter Username";
                                }

                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20,),

                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: AppColors.white,
                          border: Border.all(color: Colors.black)
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          Icon(Icons.lock_outline),
                          const SizedBox(width: 10,),
                          Expanded(
                            child: TextFormField(
                              decoration: InputDecoration(
                                hintText: "Game Code",
                                border: InputBorder.none,
                              ),
                              keyboardType: TextInputType.name,
                              textInputAction: TextInputAction.next,
                              focusNode: gameCodeFocusnode,
                              onChanged: (value) {
                                print("$value");
                                context.read<LoginBloc>().add(GameCodeChange(gameCode: value));
                              },
                              onFieldSubmitted: (value) {},
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Enter Game Code";
                                }

                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),


                    const SizedBox(height: 20,),

                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: AppColors.white,
                          border: Border.all(color: Colors.black)
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          Icon(Icons.email),
                          const SizedBox(width: 10,),
                          Expanded(
                            child: TextFormField(
                              decoration: InputDecoration(
                                hintText: "Email",
                                border: InputBorder.none,
                              ),
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.done,
                              focusNode: emailFocusnode,
                              onChanged: (value) {
                                context.read<LoginBloc>().add(EmailChange(email: value));
                              },
                              onFieldSubmitted: (value) {},
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Enter Email Address";
                                }

                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20,),

                    InkWell(
                      onTap:(){
                        showImageSource(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: AppColors.white,
                            border: Border.all(color: Colors.black)
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          children: [
                            Icon(Icons.account_circle_sharp),
                            const SizedBox(width: 10,),
                            Expanded(
                              child: TextFormField(
                                decoration: InputDecoration(
                                  hintText: _image?.path != null ? _image!.path.split('/').last : "Upload Photo (Optional)",
                                  border: InputBorder.none,
                                ),
                                textInputAction: TextInputAction.done,
                                enabled: false,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20,),


                    BlocConsumer<LoginBloc, LoginState>(
                      listener: (context,state){
                        if(state.loginApiStatus == LoginApiStatus.success){
                          showToast(state.message);
                          Navigator.pushNamedAndRemoveUntil(context, RoutesName.eventDetailScreen, (route) => false);

                        }
                        if(state.loginApiStatus == LoginApiStatus.error){
                          showToast(state.message);

                        }
                      },
                      builder: (context, state) {
                        print(state);
                        return InkWell(
                      onTap: (){
                        if(state.username.isEmpty){
                          showToast("Please enter username");
                        }else if(state.gameCode.isEmpty){
                          showToast("Please enter Game Code");
                        }else if(state.email.isEmpty || !isValidEmail(state.email)){
                          showToast("Please enter valid email");

                        }else{
                          context.read<LoginBloc>().add(SubmitButton());
                        }

                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white,width: 2)
                        ),
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: state.loginApiStatus == LoginApiStatus.loading
                        ? Center(child: CircularProgressIndicator(color: AppColors.white,))
                        : Text(
                          'SUBMIT',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    );
          },
                )

                  ],
                ),
              )),
        ),
      ),
    );
  }

  void showImageSource(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text("Camera"),
            onTap: () {
              Navigator.pop(context);
              pickImage(ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo),
            title: const Text("Gallery"),
            onTap: () {
              Navigator.pop(context);
              pickImage(ImageSource.gallery);
            },
          ),
        ],
      ),
    );
  }

  Future<void> pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 70, // compress image
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      context.read<LoginBloc>().add(UploadImageEvent(image: _image!));

    }
  }
  bool isValidEmail(String email) {
    return RegExp(r"^[\w\.-]+@[\w\.-]+\.\w{2,}$").hasMatch(email);
  }
}
