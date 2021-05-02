import 'package:beauty_fyi/styles/text.dart';
import 'package:beauty_fyi/styles/textfields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DefaultTextField extends StatelessWidget {
  final TextEditingController defaultTextFieldController;
  final String invalidMessage;
  final String hintText;
  final String labelText;
  final ValueSetter<String> onSaved;
  final ValueSetter<String> onChanged;
  final TextInputType textInputType;
  final IconData iconData;
  final bool disableTextFields;
  final int stylingIndex;
  final String regex;
  final double height;
  final double labelPadding;
  final String suffixText;
  final int validationStringLength;
  DefaultTextField(
      {this.defaultTextFieldController,
      this.onSaved,
      this.invalidMessage,
      this.hintText,
      this.labelText,
      this.textInputType,
      this.iconData,
      this.disableTextFields,
      this.stylingIndex = 0,
      this.regex = r'^[a-zA-Z]+$',
      this.height = 50,
      this.labelPadding = 10,
      this.suffixText,
      this.onChanged,
      this.validationStringLength = 3});

  @override
  Widget build(BuildContext context) {
    String validationErrorMessage = invalidMessage;
    List textFieldStylingListHolder = [
      [
        'blue_textfield',
        'tf_label_white',
        'tf_hint',
        'white_text_decoration',
        'tf_label_white'
      ],
      [
        'white_textfield',
        'tf_label_black_bold',
        'tf_hint_black',
        'black_text_decoration',
        'tf_label_black_bold', // for label
      ],
      [
        'white_textfield_bottom_border',
        'tf_label_black', // for text field
        'tf_hint_black',
        'black_text_decoration',
        'tf_label_black_bold', // for label
      ],
      [
        'fullwidth_textfield',
        'tf_label_white',
        'tf_hint',
        'white_text_decoration',
        'tf_label_white'
      ],
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: labelPadding),
          child: Text(
            labelText,
            style: textStyles[textFieldStylingListHolder[stylingIndex][4]],
          ),
        ),
        Container(
          alignment: Alignment.centerLeft,
          decoration:
              textfieldStyles[textFieldStylingListHolder[stylingIndex][0]],
          height: height,
          child: TextFormField(
            enabled: !disableTextFields,
            keyboardType: textInputType,
            controller: defaultTextFieldController,
            onSaved: (newValue) {
              onSaved(newValue);
            },
            onChanged: (value) {
              onChanged(value);
            },
            inputFormatters: textInputType == TextInputType.number
                ? <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                  ]
                : null,
            validator: (value) {
              String textFieldValue = value.toString().trim();
              if (!RegExp(regex).hasMatch(textFieldValue) ||
                  textFieldValue.length < validationStringLength) {
                return validationErrorMessage;
              }
              return null;
            },
            style: textStyles[textFieldStylingListHolder[stylingIndex][1]],
            decoration: textfieldInputDecoration(
                hintText: hintText,
                iconData: iconData,
                hintTextStyle: textFieldStylingListHolder[stylingIndex][2],
                suffixText:
                    suffixText)[textFieldStylingListHolder[stylingIndex][3]],
          ),
        ),
      ],
    );
  }
}
