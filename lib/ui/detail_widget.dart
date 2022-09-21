import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:reader_helper/entity/book_entity.dart';

/// @author yi1993
/// @created at 2022/5/10
/// @description:
class DetailWidget extends StatefulWidget {
  final BookEntity book;

  const DetailWidget({
    Key? key,
    required this.book,
  }) : super(key: key);

  @override
  State<DetailWidget> createState() => _DetailWidgetState();
}

class _DetailWidgetState extends State<DetailWidget> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(
        100.w,
      ),
      physics: const ClampingScrollPhysics(),
      children: [
        Padding(
          padding: EdgeInsets.only(
            bottom: 60.w,
          ),
          child: Text(
            '书名:${widget.book.name}',
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            bottom: 60.w,
          ),
          child: Text(
            '类型:${widget.book.type}',
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            bottom: 60.w,
          ),
          child: Text(
            '作者:${widget.book.author}',
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            bottom: 60.w,
          ),
          child: Text(
            '状态:${widget.book.status}',
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            bottom: 60.w,
          ),
          child: Text(
            '字数:${widget.book.message}',
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            bottom: 60.w,
          ),
          child: Text(
            '简介:${widget.book.description}',
          ),
        ),
      ],
    );
  }
}
