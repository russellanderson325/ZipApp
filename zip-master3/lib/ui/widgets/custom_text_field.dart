import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String hint;
  final TextEditingController controller;
  final Color baseColor;
  final Color borderColor;
  final Color errorColor;
  final TextInputType inputType;
  final bool obscureText;
  final Function validator;
  final Function onChanged;
  final Icon customTextIcon;
  CustomTextField(
      {this.hint,
      this.controller,
      this.baseColor,
      this.onChanged,
      this.borderColor,
      this.errorColor,
      this.inputType = TextInputType.text,
      this.obscureText = false,
      this.validator,
      this.customTextIcon
      });

  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  Color currentColor;

  @override
  void initState() {
    super.initState();
    currentColor = widget.borderColor;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.0,
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.0),
          child: TextField(
            obscureText: widget.obscureText,
            onChanged: (text) {
              if (widget.onChanged != null) {
                widget.onChanged(text);
              }
              setState(() {
                if (!widget.validator(text) || text.length == 0) {
                  currentColor = widget.errorColor;
                } else {
                  currentColor = widget.baseColor;
                }
              });
            }, 
            //keyboardType: widget.inputType,
            controller: widget.controller,
            decoration: InputDecoration(
              hintStyle: TextStyle(
                    color: widget.baseColor,
                    fontFamily: "OpenSans",
                    fontWeight: FontWeight.w300,
                    decoration: TextDecoration.none
              ),
              hintText: widget.hint,
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: currentColor, width: 1.0)),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(),
                child: widget.customTextIcon,
              ),
            ),
          ),
          ),
        );
  }
}


class CustomTextField2 extends StatefulWidget {
  final String hint;
  final TextEditingController controller;
  final Color baseColor;
  final Color borderColor;
  final Color errorColor;
  final TextInputType inputType;
  final bool obscureText;
  final Function validator;
  final Function onChanged;
  final Icon customTextIcon;
  bool isEditable;
  CustomTextField2(
      {this.hint,
      this.controller,
      this.baseColor,
      this.onChanged,
      this.borderColor,
      this.errorColor,
      this.inputType = TextInputType.text,
      this.obscureText = false,
      this.validator,
      this.customTextIcon,
      this.isEditable
      });

  _CustomTextFieldState2 createState() => _CustomTextFieldState2();
}

class _CustomTextFieldState2 extends State<CustomTextField2> {
  Color currentColor;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
            elevation: 0.0,
            shape: RoundedRectangleBorder(
              side: BorderSide(
              color: Colors.black,
              width: 0.5,
            ),
          ),
          color: Colors.white,
          child: TextField(
              enabled: widget.isEditable,
              onChanged: (text) {
            },
              style: TextStyle(
                  color: Color.fromRGBO(255, 242, 0, 1.0),
                  fontFamily: "OpenSans",
                  fontWeight: FontWeight.w300,
                  decoration: TextDecoration.none
            ),
            decoration: InputDecoration(
              prefixIcon: Padding(
              padding: const EdgeInsets.only(),
              child: widget.customTextIcon,
              ),
              border: InputBorder.none,
            ),
          ),
      );
  }
}

