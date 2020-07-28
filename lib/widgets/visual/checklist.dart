import 'package:flutter/material.dart';
import 'package:ideas_redux/models/datamodels/checklistmodel.dart';

class Checklist extends StatefulWidget {
  ChecklistModel model;
  Checklist(this.model);

  @override
  State<StatefulWidget> createState() {
    return _Checklist();    
  }
}

class _Checklist extends State<Checklist> {
  @override
  void initState() {
    super.initState();
    //print(widget.model.data);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
            children: List.generate(widget.model.data.length, (index) => Row(
              children: [
                Expanded(
                  flex: 0,
                  child: Checkbox(
                    onChanged: (e) { setState(() => widget.model.data[index].checked = e); },
                    value: widget.model.data[index].checked,
                    visualDensity: VisualDensity.compact,                            
                  ),
                ),
                Expanded(
                  child: TextField(
                    key: UniqueKey(),
                    controller: TextEditingController(text: widget.model.data[index].data),
                    onChanged: (e) => widget.model.data[index].data = e,

                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Note",
                      isDense: true
                    ),
                    style: Theme.of(context).textTheme.subtitle1,
                    maxLines: null,
                  ),
                ),
              ]
            )
          )
        ),

        MaterialButton(
          onPressed: () {
            setState(() {
              widget.model.addEmpty();
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(Icons.add, size: 25,),
              Text(
                'Add item',
                style: Theme.of(context).textTheme.subtitle1
              )
            ],
          ),
        )
      ]
     );
  }
}