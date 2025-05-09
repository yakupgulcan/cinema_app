import 'package:cinema_app/services/Auth/auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:html' as html;
import '../../providers/userProvider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordRepeatController = TextEditingController();

  bool iserror = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SizedBox(
          width: MediaQuery.sizeOf(context).width*0.6,
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'YILDIZ SİNEMALARI',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _usernameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Kullanıcı Adı',
                      labelStyle: const TextStyle(color: Colors.grey),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen kullanıcı adınızı girin';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Şifre',
                      labelStyle: const TextStyle(color: Colors.grey),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen şifrenizi girin';
                      }
                      return null;
                    },
                  ),
                  if (!isLogin) ...[
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordRepeatController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Şifre (Tekrar)',
                        labelStyle: const TextStyle(color: Colors.grey),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                        ),
                      ),
                      validator: (value) {
                        if (isLogin) return null;
                        if (value == null || value.isEmpty) {
                          return 'Lütfen şifrenizi tekrar girin';
                        }
                        if (value != _passwordController.text) {
                          return 'Şifreler eşleşmiyor';
                        }
                        return null;
                      },
                    ),
                  ],
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () async{
                      if (_formKey.currentState!.validate()) {
                        int? uid;
                        if(isLogin){
                          List<int>? sonuc = await signIn(name: _usernameController.text, password: _passwordController.text);
                          if(sonuc != null){
                            if(sonuc[0] == 1){
                              uid = sonuc[1];
                            }
                            else if(sonuc[0] == 2){
                              uid = sonuc[1];
                              html.window.open('/sendAdmin', '_blank');
                            }
                          }
                        }
                        else {
                          uid = await signUp(name: _usernameController.text, password: _passwordController.text);
                        }
                        final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
                        if(uid != null){
                          customerProvider.setCustomerID(uid);
                          Navigator.pop(context);
                        }
                        else{
                          setState(() {
                            iserror = true;
                          });
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      isLogin ? 'GİRİŞ YAP' : 'KAYDOL',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if(iserror)
                    Text("Hatalı İsim veya şifre", style: TextStyle(color: Colors.white),),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        isLogin = !isLogin;
                      });
                    },
                    child: Text(
                      isLogin
                          ? 'Hesabınız yok mu? Kaydolun'
                          : 'Zaten hesabınız var mı? Giriş yapın',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}