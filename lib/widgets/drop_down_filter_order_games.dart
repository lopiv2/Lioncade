import 'package:flutter/material.dart';

import '../utilities/constants.dart';

class DropdownWidget extends StatefulWidget {
  final ValueChanged<SearchParametersDropDown?>? onChanged;

  DropdownWidget({Key? key, this.onChanged}) : super(key: key);

  @override
  DropDownCategories createState() => DropDownCategories();
}

class DropDownCategories extends State<DropdownWidget> {
  SearchParametersDropDown? currentItem;

  List<SearchParametersDropDown> items = SearchParametersDropDown.values;

  @override
  void initState() {
    currentItem = items[0];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: 10, right: 10), // Margen izquierdo deseado
      child: Container(
        height: 30,
        decoration: BoxDecoration(
          color: const Color.fromARGB(90, 28, 102, 50),
          borderRadius: BorderRadius.circular(2),
          border: Border.all(),
        ),
        child: DropdownButton<SearchParametersDropDown>(
          menuMaxHeight: 200,
          underline: Container(),
          style: const TextStyle(
              fontSize: 16, color: Color.fromARGB(255, 36, 29, 29)),
          isExpanded:
              true, // Hace que el DropdownButton ocupe todo el ancho disponible
          alignment: Alignment.topCenter,
          borderRadius: BorderRadius.circular(8),
          dropdownColor: const Color.fromARGB(255, 45, 114, 72),
          value: currentItem,
          onChanged: (SearchParametersDropDown? newValue) {
            setState(() {
              currentItem = newValue;
              widget.onChanged?.call(newValue);
            });
          },
          items: items.map<DropdownMenuItem<SearchParametersDropDown>>(
            (SearchParametersDropDown value) {
              return DropdownMenuItem<SearchParametersDropDown>(
                value: value,
                child: Text(
                  value.getLocalizedString(context),
                ),
              );
            },
          ).toList()..sort((a, b) =>
          a.child.toString().compareTo(b.child.toString())),
        ),
      ),
    );
  }
}
