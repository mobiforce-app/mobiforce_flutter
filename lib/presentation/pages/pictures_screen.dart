import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_bloc/task_bloc.dart';
import 'package:mobiforce_flutter/presentation/bloc/task_bloc/task_event.dart';
import 'package:mobiforce_flutter/presentation/bloc/tasklist_bloc/tasklist_bloc.dart';
import 'package:mobiforce_flutter/presentation/bloc/tasklist_bloc/tasklist_event.dart';
import 'package:mobiforce_flutter/presentation/widgets/custom_search_delegate.dart';
import 'package:mobiforce_flutter/presentation/widgets/task_list_widget.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:signature/signature.dart';

import '../../data/models/file_model.dart';

class PicturesGaleryPage extends StatelessWidget {
  final List<FileModel> files;
  final FileModel current;
  final String header;
  final String appFilesDirectory;
  final PageController pageController = PageController();

  @override
  Widget build(BuildContext context) {
    //pageController.jumpToPage(index);
    return Scaffold(
      appBar: AppBar(
        title: Text(header),
        centerTitle: true,
      ),
      body: PicuresGalleryInput(files:files, current: current, appFilesDirectory: appFilesDirectory)//PicuresGalleryInput(fieldId:fieldId,oldFileId:oldFileId),
    );
  }

  PicturesGaleryPage({Key? key, required this.files, required this.header, required this.current, required this.appFilesDirectory}) : super(key: key);
}

class PicuresGalleryInput extends StatefulWidget {

  final List<FileModel> files;
  final FileModel current;
  final String appFilesDirectory;
  PageController? pageController;//
  int pageId=0;
  // ;

  PicuresGalleryInput({required this.files, required this.current, required this.appFilesDirectory});

  @override
  State<StatefulWidget> createState() {
    final int index = files.indexOf(current);
    pageId = index;
    pageController = PageController(initialPage: index);

    return _picuresGaleryState();
  }
}
class _picuresGaleryState extends State<PicuresGalleryInput> {
  var _controller = TextEditingController();
 // TextEditingController addressController = TextEditingController();

  var _oldValue;
  //var _needToLoadValue=true;
  Timer? _debounce;
  //_controller.text="20";
  _onChanged(String query) {

    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 1000), () {
      // do something with query
      print("EDIT $query ${widget.files[widget.pageId].parent.id}");
      setState((){
        _oldValue=query;
        //widget.val=query;
      });
      widget.files[widget.pageId].description=query;
      BlocProvider.of<TaskBloc>(context).add(
         FieldFileUpdateDescription(widget.files[widget.pageId]),
      );
    });
  }

  //var _oldValue;
  //var _needToLoadValue=true;
  //Timer? _debounce;
  //_controller.text="20";

  @override
  void deactivate() {
    if(_oldValue!=_controller.text){
      widget.files[widget.pageId].description = _controller.text;
      BlocProvider.of<TaskBloc>(context).add(
        FieldFileUpdateDescription(widget.files[widget.pageId]),
      );
      // widget.val  = _controller.text;
      // BlocProvider.of<TaskBloc>(context).add(
      //   ChangeTextFieldValue(fieldId:widget.fieldId,value:_controller.text),
      // );
    }

    super.deactivate();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    //pageController = PageController(initialPage: index);
    //if(widget.needToLoadValue) {
    _controller.text = widget.files[widget.pageId].description??"";
    _oldValue = _controller.text;

    super.initState();

    // _controller.addListener(() => print('Value changed'));
  }
  @override
  Widget build(BuildContext context) {

    return       Column(
        children: [
          Expanded(
              child:
              Container(
                color: Colors.black,
                child: PhotoViewGallery.builder(
                  scrollPhysics: const BouncingScrollPhysics(),
                  builder: (BuildContext context, int index) {
                    return PhotoViewGalleryPageOptions(
                      minScale: PhotoViewComputedScale.contained,
                      imageProvider: Image.file(File('${widget.appFilesDirectory}/photo_${widget.files[index].id}.jpg')).image,
                      //initialScale: PhotoViewComputedScale.contained * 0.8,
                      //  heroAttributes: PhotoViewHeroAttributes(tag: galleryItems[index].id),
                    );
                  },
                  itemCount: widget.files.length,
                  /*loadingBuilder: (context, event) => Center(
                  child: Container(
                    width: 20.0,
                    height: 20.0,
                    child: CircularProgressIndicator(
                      value: event == null
                          ? 0
                          : event.cumulativeBytesLoaded / event.expectedTotalBytes,
                    ),
                  ),
                ),
                backgroundDecoration: widget.backgroundDecoration,*/
                  pageController: widget.pageController,
                  //onPageChanged: onPageChanged,
                  onPageChanged: (int index) {
                    //setState(() {
                    //  _currentIndex = index;
                    //});
                    if(_oldValue!=_controller.text) {
                      widget.files[widget.pageId].description = _controller.text;
                      BlocProvider.of<TaskBloc>(context).add(
                        FieldFileUpdateDescription(widget.files[widget.pageId]),
                      );
                    }
                    setState(() {
                      _controller.text=widget.files[index].description??"";
                      _oldValue=widget.files[index].description??"";
                    });
                    print("page id: $index");
                    widget.pageId = index;
                  },
                ),
                // child: CarouselSlider(
                //     items: [
                //       InteractiveViewer(
                //       panEnabled: false, // Set it to false
                //       boundaryMargin: EdgeInsets.all(0),
                //       minScale: 1,
                //       maxScale: 4,
                //       child: Image.file(File('${appFilesDirectory}/photo_${fieldId}.jpg'))),
                //       InteractiveViewer(
                //           panEnabled: false, // Set it to false
                //           boundaryMargin: EdgeInsets.all(0),
                //           minScale: 1,
                //           maxScale: 4,
                //           child: Image.file(File('${appFilesDirectory}/photo_${fieldId}.jpg'))),],
                //     options: CarouselOptions(
                //       height: double.infinity,
                //       //aspectRatio: 16/9,
                //       viewportFraction: 1,
                //       initialPage: 0,
                //       //enableInfiniteScroll: true,
                //       reverse: false,
                //       //autoPlay: true,
                //       //autoPlayInterval: Duration(seconds: 3),
                //       //autoPlayAnimationDuration: Duration(milliseconds: 800),
                //       //autoPlayCurve: Curves.fastOutSlowIn,
                //       enlargeCenterPage: true,
                //       //onPageChanged: callbackFunction,
                //       scrollDirection: Axis.horizontal,
                //     )
                // ),
              )
          ),
          //  Container(child: Text('23232'),)
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black12, width: 1),
            ),
            padding: const EdgeInsets.only(left: 8.0),

            child: TextField(
              decoration: InputDecoration(
                hintText: "AppLocalizations.of(context)!.commentInputHint",
                //border: OutlineInputBorder(),
                border: InputBorder.none,
                suffixIcon: _controller.text.length>0?IconButton(
                  icon: Icon(Icons.cancel),
                  onPressed: (){
                    widget.files[widget.pageId].description="";
                    BlocProvider.of<TaskBloc>(context).add(
                      FieldFileUpdateDescription(widget.files[widget.pageId]),
                    );
                    setState(() {
                      _controller.clear();
                    });
                  },
                ):Container(),
              ),
              //expands: true,
              maxLines: null,
              controller: _controller,
              keyboardType: TextInputType.multiline,
              onChanged: _onChanged,
              //.numberWithOptions(),
            ),
          )
        ]);

    //maxLines: 3,
    // onChanged: _onChanged,
    //);
  }
}
