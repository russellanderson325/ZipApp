import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:zip/business/auth.dart';
import 'package:zip/ui/widgets/custom_flat_button.dart';

class AddPhoneAuthScreen extends StatefulWidget {
  _AddPhoneAuthScreenState createState() => _AddPhoneAuthScreenState();
}

class _AddPhoneAuthScreenState extends State<AddPhoneAuthScreen> {
  final TextEditingController _phoneNumber = new TextEditingController();

  Country selectedCountry = Country(
    phoneCode: "1",
    countryCode: "US",
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: "United States",
    example: "United States",
    displayName: "United States",
    displayNameNoCountryCode: "US",
    e164Key: "",
  );

  VoidCallback onBackPress;
  final auth = AuthService();

  @override
  void initState() {
    super.initState();
    onBackPress = () {
      Navigator.of(context).pop();
    };
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onBackPress,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: <Widget>[
            Stack(
              alignment: Alignment.topLeft,
              children: <Widget>[
                ListView(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(130),
                      child: Text(
                        "Add Phone",
                        softWrap: true,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color.fromRGBO(252, 242, 0, 1.0),
                          decoration: TextDecoration.none,
                          fontSize: 32.0,
                          fontWeight: FontWeight.w700,
                          fontFamily: "Bebas",
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20, right: 15, left: 15),
                      child: TextFormField(
                        cursorColor: Colors.yellow,
                        controller: _phoneNumber,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        onChanged: (value) {
                          setState(() {});
                        },
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          hintText: "Phone Number",
                          hintStyle: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.black12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.black12),
                          ),
                          prefixIcon: Container(
                            padding: const EdgeInsets.all(12.0),
                            child: InkWell(
                              onTap: () {
                                showCountryPicker(
                                    context: context,
                                    onSelect: (value) {
                                      setState(() {
                                        selectedCountry = value;
                                      });
                                    });
                              },
                              child: Text(
                                selectedCountry.countryCode +
                                    " + ${selectedCountry.phoneCode}",
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          suffixIcon: _phoneNumber.text.length > 9
                              ? Container(
                                  height: 25,
                                  width: 25,
                                  margin: const EdgeInsets.all(10.0),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.green,
                                  ),
                                  child: const Icon(
                                    Icons.done,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 40, right: 30, left: 30),
                      child: CustomTextButton(
                        title: "Get Code",
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        textColor: Colors.black,
                        onPressed: () async {
                          String phoneNumber = _phoneNumber.text.trim();
                          bool userWithNumberExists =
                              await auth.phoneNumberExists(phoneNumber);
                          if (userWithNumberExists) {
                            await auth.phoneAuthentication(
                                "+${selectedCountry.phoneCode}$phoneNumber",
                                context,
                                true);
                          } else {
                            print(phoneNumber +
                                " is not registered to any account.");
                          }
                        },
                        splashColor: Color.fromRGBO(255, 242, 0, 1.0),
                        borderColor: Color.fromRGBO(212, 20, 15, 1.0),
                        borderWidth: 0,
                        color: Color.fromRGBO(255, 242, 0, 1.0),
                      ),
                    ),
                  ],
                ),
                SafeArea(
                  child: IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: onBackPress,
                    color: Color.fromRGBO(255, 242, 0, 1.0),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
