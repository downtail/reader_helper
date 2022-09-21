import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

/// @author yi1993
/// @created at 2022/5/7
/// @description: 本地管理
class ManageFragment extends StatefulWidget {
  const ManageFragment({Key? key}) : super(key: key);

  @override
  State<ManageFragment> createState() => _ManageFragmentState();
}

class _ManageFragmentState extends State<ManageFragment> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: GestureDetector(
        onTap: () async {
          FilePickerResult? result = await FilePicker.platform.pickFiles();
          if (result != null) {
            File file = File(result.files.single.path!);
          } else {
            // User canceled the picker
          }
        },
        child: Text('打开'),
      ),
    );
  }

  @override
  bool get wantKeepAlive {
    return true;
  }
}
