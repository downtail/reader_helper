import 'dart:convert';
import 'dart:developer';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as htmlparser;
import 'package:reader_helper/entity/book_entity.dart';
import 'package:reader_helper/entity/method_entity.dart';
import 'package:reader_helper/http/dio_manager.dart';
import 'package:reader_helper/map_entity.dart';
import 'package:reader_helper/ui/chapter_entity.dart';
import 'package:svg_path_parser/svg_path_parser.dart';

/// @author yi1993
/// @created at 2022/4/8
/// @description: DataManager

class DataManager {
  static final DataManager _dataManager = DataManager._();

  DataManager._() {
    init();
  }

  factory DataManager() => _dataManager;

  void init() {}

  Future<List<MethodEntity>> parseMethod(String text) async {
    return toMethodList(json.decode(text));
  }

  Future<MapEntity> parseMap() async {
    var geoText = await rootBundle.loadString('assets/map.json');
    MapEntity entity = MapEntity.fromJson(json.decode(geoText));
    return entity;
    double _initialScale=0.4;
    var text = await rootBundle.loadString('assets/a.svg');
    dom.Document document = htmlparser.parse(
      text,
    );
    var elements = document.querySelectorAll('path');
    var map = <String, dynamic>{};
    map['\"name\"'] = '\"map\"';
    map['\"code\"'] = '\"100000\"';
    var list = List<Map<String, dynamic>>.empty(growable: true);
    var data = List<String>.empty(growable: true);

    for (var index = 0; index < elements.length; index++) {
      var item = <String, dynamic>{};
      item['\"name\"'] = '\"${index}\"';
      item['\"code\"'] = '\"\"';
      var result = '${elements[index].attributes['d']}';
      item['\"path\"']='\"$result\"';
      item['\"children\"'] = [];
      list.add(item);
      data.add('\'${result}\'');
    }
    map['\"path\"'] = '\"\"';
    map['\"children\"'] = list;
    log('${list}');
    MapEntity body = MapEntity.fromJson(map);
    return body;
  }

  Future<List<BookEntity>?> searchBooksByKeyword({
    required String keyword,
    required MethodEntity method,
  }) async {
    if (method.methodCode == 1) {
      return await searchBooksByQiDian(keyword: keyword);
    } else if (method.methodCode == 2) {
      return await searchBooksByBiQuGe(keyword: keyword);
    } else if (method.methodCode == 3) {
      return await searchBooksByKuaiShuKu(keyword: keyword);
    }
    return null;
  }

  Future<List<BookEntity>?> searchBooksByQiDian({
    required String keyword,
  }) async {
    var url = 'https://www.qidian.com/soushu/' + keyword + '.html';
    var data = await DioManager().get<String>(
      url,
      formatted: false,
    );
    if (data == null) {
      return null;
    }
    dom.Document document = htmlparser.parse(
      data,
    );
    var elements = document.querySelectorAll('li.res-book-item');
    var list = elements.map((e) {
      BookEntity child = BookEntity();
      child.original = 1;
      child.path = 'https://book.qidian.com/info/${e.attributes['data-bid']?.trim()}/#Catalog';
      var elementTitle = e.querySelector('h2.book-info-title > a');
      child.name = elementTitle?.text.trim();
      var elementThumb = e.querySelector('div.book-img-box > a > img');
      child.picUrl = 'https:' + (elementThumb?.attributes['src']?.trim() ?? '');
      var elementType = e
          .querySelector('p.author > em')
          ?.nextElementSibling;
      child.type = elementType?.text.trim();
      var elementDesc = e.querySelector('p.intro');
      elementDesc?.querySelector('cite.red-kw')?.remove();
      child.description = elementDesc?.text.trim();
      var elementAuthor = e.querySelector('a.name');
      child.author = elementAuthor?.text.trim();
      var elementStatus = e.querySelector('p.author > span');
      child.status = elementStatus?.text.trim();
      var elementMsg = e.querySelector('div.total > p > span');
      child.message = elementMsg?.text.trim();
      return child;
    }).toList();
    return list;
  }

  Future<List<BookEntity>?> searchBooksByBiQuGe({
    required String keyword,
  }) async {
    var url = 'https://www.biqugesk.org/modules/article/search.php?searchkey=$keyword';
    var data = await DioManager().get<String>(
      url,
      formatted: false,
    );
    if (data == null) {
      return null;
    }
    dom.Document document = htmlparser.parse(
      data,
    );
    var elements = document.querySelectorAll('tr');
    if (elements.isNotEmpty) {
      elements = elements.sublist(1);
    }
    var list = elements.map((e) {
      var items = e.querySelectorAll('td');
      BookEntity child = BookEntity();
      child.original = 2;
      if (items.length == 6) {
        var elementTitle = items[0].querySelector('a');
        child.name = elementTitle?.text.trim();
        child.path = elementTitle?.attributes['href'];
        child.author = items[2].text.trim();
        child.message = items[3].text.trim();
        child.status = items[5].text.trim();
      }
      return child;
    }).toList();
    for (var index = 0; index < list.length; index++) {
      var result = await DioManager().get<String>(
        list[index].path!,
        formatted: false,
      );
      dom.Document detail = htmlparser.parse(
        result,
      );
      var elementThumb = detail.querySelector('div#fmimg > img');
      list[index].picUrl = elementThumb?.attributes['src'];
      var elementType = detail
          .querySelector('a.link')
          ?.parent;
      var typeDesc = elementType?.text.trim();
      if (typeDesc != null && typeDesc.length >= 9) {
        list[index].type = typeDesc.substring(7, 9);
      }
      var elementDesc = detail.querySelector('div#list > p');
      list[index].description = elementDesc?.text.trim();
    }
    return list;
  }

  Future<List<BookEntity>?> searchBooksByKuaiShuKu({
    required String keyword,
  }) async {
    var url = 'http://kuaishuku.com/search.php?searchkey=$keyword';
    var data = await DioManager().get<String>(
      url,
      formatted: false,
    );
    if (data == null) {
      return null;
    }
    dom.Document document = htmlparser.parse(
      data,
    );
    var elements = document.querySelectorAll('tr');
    if (elements.isNotEmpty) {
      elements = elements.sublist(1);
    }
    var list = elements.map((e) {
      var items = e.querySelectorAll('td');
      BookEntity child = BookEntity();
      child.original = 3;
      if (items.length == 6) {
        var elementTitle = items[1].querySelector('div > a');
        child.name = elementTitle?.text.trim();
        child.path = 'http://www.kuaishuku.com/index.php?m=home&s=info.php&aid=${elementTitle?.attributes['href']?.replaceAll('/', '')}';
        child.author = items[2].text.trim();
        child.message = '字数丢失';
        child.status = items[5].text.trim();
      }
      return child;
    }).toList();
    for (var index = 0; index < list.length; index++) {
      var result = await DioManager().get<String>(
        list[index].path!,
        formatted: false,
      );
      dom.Document detail = htmlparser.parse(
        result,
      );
      var elementThumb = detail.querySelector('div.bookinfo-img > img');
      list[index].picUrl = 'http://kuaishuku.com${elementThumb?.attributes['src']}';
      var elementType = detail
          .querySelector('div.intro')
          ?.previousElementSibling
          ?.previousElementSibling
          ?.previousElementSibling;
      var typeDesc = elementType?.text.trim();
      if (typeDesc != null && typeDesc.length >= 7) {
        list[index].type = typeDesc.substring(5, 7);
      }
      var elementDesc = detail.querySelector('div.intro > p');
      list[index].description = elementDesc?.text.trim();
    }
    return list;
  }

  Future<List<ChapterEntity>?> getBookChapters({
    required BookEntity book,
    required MethodEntity method,
  }) async {
    if (method.methodCode == 1) {
      return await getBookChaptersByQiDian(book: book);
    } else if (method.methodCode == 2) {
      return await getBookChaptersByBiQuGe(book: book);
    } else if (method.methodCode == 3) {
      return await getBookChaptersByKuaiShuKu(book: book);
    }
    return null;
  }

  Future<List<ChapterEntity>?> getBookChaptersByQiDian({
    required BookEntity book,
  }) async {
    var data = await DioManager().get<String>(
      book.path!,
      formatted: false,
    );
    if (data == null) {
      return null;
    }
    dom.Document document = htmlparser.parse(
      data,
    );
    var elements = document.querySelectorAll('ul.cf');
    List<ChapterEntity> chapters = List.empty(growable: true);
    for (var element in elements) {
      var links = element.querySelectorAll('h2.book_name > a');
      var list = links
          .map((e) =>
          ChapterEntity(
            chapterName: e.text,
            chapterSource: '起点',
            chapterPath: 'https:${e.attributes['href']}',
          ))
          .toList();
      chapters.addAll(list);
    }
    return chapters;
  }

  Future<List<ChapterEntity>?> getBookChaptersByBiQuGe({
    required BookEntity book,
  }) async {
    var data = await DioManager().get<String>(
      book.path!,
      formatted: false,
    );
    if (data == null) {
      return null;
    }
    dom.Document document = htmlparser.parse(
      data,
    );
    var elements = document.querySelectorAll('dd > a');
    List<ChapterEntity> chapters = elements
        .map((e) =>
        ChapterEntity(
          chapterName: e.text,
          chapterSource: '笔趣阁',
          chapterPath: e.attributes['href'],
        ))
        .toList();
    return chapters;
  }

  Future<List<ChapterEntity>?> getBookChaptersByKuaiShuKu({
    required BookEntity book,
  }) async {
    var data = await DioManager().get<String>(
      book.path!,
      formatted: false,
    );
    if (data == null) {
      return null;
    }
    dom.Document document = htmlparser.parse(
      data,
    );
    var elements = document.querySelectorAll('ul.list-group.list-charts#stylechapter > li > a');
    List<ChapterEntity> chapters = elements
        .map((e) =>
        ChapterEntity(
          chapterName: e.text,
          chapterSource: '快书库',
          chapterPath: 'http://kuaishuku.com${e.attributes['href']}',
        ))
        .toList();
    return chapters;
  }

  Future<String?> getChapterContent({
    required ChapterEntity chapter,
    required MethodEntity method,
  }) async {
    if (method.methodCode == 1) {
      return await getChapterContentByQiDian(chapter: chapter);
    } else if (method.methodCode == 2) {
      return await getChapterContentByBiQuGe(chapter: chapter);
    } else if (method.methodCode == 3) {
      return await getChapterContentByKuaiShuKu(chapter: chapter);
    }
    return null;
  }

  Future<String?> getChapterContentByQiDian({
    required ChapterEntity chapter,
  }) async {
    var url = chapter.chapterPath;
    if (url == null) {
      return null;
    }
    var data = await DioManager().get<String>(
      url,
      formatted: false,
    );
    if (data == null) {
      return null;
    }
    dom.Document document = htmlparser.parse(
      data,
    );
    var element = document.querySelector('div.read-content.j_readContent');
    if (element != null) {
      return element.innerHtml.trim().replaceAll('<p>', '').replaceAll("</p>", '\n').trim();
    }
    return null;
  }

  Future<String?> getChapterContentByBiQuGe({
    required ChapterEntity chapter,
  }) async {
    var url = chapter.chapterPath;
    if (url == null) {
      return null;
    }
    var data = await DioManager().get<String>(
      url,
      formatted: false,
    );
    if (data == null) {
      return null;
    }
    dom.Document document = htmlparser.parse(
      data,
    );
    var element = document.querySelector('div.content#booktext');
    if (element != null) {
      element.querySelector('center')?.remove();
      return '    ' + element.innerHtml.replaceAll(RegExp(r'<br>\s*<br>\s*'), '\n    ').replaceAll("&nbsp;", '').trim();
    }
    return null;
  }

  Future<String?> getChapterContentByKuaiShuKu({
    required ChapterEntity chapter,
  }) async {
    var url = chapter.chapterPath;
    if (url == null) {
      return null;
    }
    var data = await DioManager().get<String>(
      url,
      formatted: false,
    );
    if (data == null) {
      return null;
    }
    dom.Document document = htmlparser.parse(
      data,
    );
    var element = document.querySelector('div.book-content');
    if (element != null) {
      return '    ' + element.innerHtml.replaceAll(RegExp(r'<br>\s*<br>\s*'), '\n    ').replaceAll("&nbsp;", '').trim();
    }
    return null;
  }
}
