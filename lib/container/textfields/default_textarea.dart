import 'package:beauty_fyi/styles/text.dart';
import 'package:beauty_fyi/styles/textfields.dart';
import 'package:flutter/material.dart';

class DefaultTextArea extends StatelessWidget {
  final TextEditingController? defaultTextAreaController;
  final String? invalidMessage;
  final String? hintText;
  final String? labelText;
  final ValueSetter<String?>? onSaved;
  final ValueSetter<String>? onChanged;
  final TextInputType? textInputType;
  final IconData? iconData;
  final bool? disableTextFields;
  final int stylingIndex;
  final int? maxLines;
  final int maxLength;
  DefaultTextArea(
      {this.defaultTextAreaController,
      this.onSaved,
      this.invalidMessage,
      this.hintText,
      this.labelText,
      this.textInputType,
      this.iconData,
      this.disableTextFields,
      this.stylingIndex = 0,
      this.onChanged,
      this.maxLines = 6,
      this.maxLength = 240});

  @override
  Widget build(BuildContext context) {
    List textFieldStylingListHolder = [
      ['blue_textfield', 'tf_label_white', 'tf_hint', 'white_text_decoration'],
      [
        'white_textfield',
        'tf_label_black',
        'tf_hint_black',
        'black_text_decoration'
      ]
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Text(
            labelText!,
            style: textStyles[textFieldStylingListHolder[stylingIndex][1]],
          ),
        ),
        Container(
          alignment: Alignment.centerLeft,
          decoration:
              textfieldStyles[textFieldStylingListHolder[stylingIndex][0]],
          child: TextFormField(
            maxLength: maxLength,
            maxLines: maxLines,
            keyboardType: TextInputType.multiline,
            enabled: !disableTextFields!,
            controller: defaultTextAreaController,
            onSaved: (newValue) {
              onSaved!(newValue);
            },
            onChanged: (value) {
              onChanged!(value);
            },
            validator: (value) {
              return null;
            },
            style: textStyles[textFieldStylingListHolder[stylingIndex][1]],
            decoration: textfieldInputDecoration(
                hintText: hintText,
                iconData: iconData,
                hintTextStyle: textFieldStylingListHolder[stylingIndex]
                    [2])[textFieldStylingListHolder[stylingIndex][3]],
          ),
        ),
      ],
    );
  }
}
