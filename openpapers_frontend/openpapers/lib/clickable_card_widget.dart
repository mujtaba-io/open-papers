import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'backyard.dart';
import 'theme.dart'; // Import the theme file

import 'dart:html'; // for web only
import 'dart:ui' as ui;
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

class ClickableCard extends StatefulWidget {
  final ui.VoidCallback? onTap;
  final String text;
  ClickableCard({Key? key, required this.onTap, required this.text})
      : super(key: key);
  @override
  _ClickableCardState createState() => _ClickableCardState();
}

class _ClickableCardState extends State<ClickableCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
        });
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            color: _isHovered
                ? RosePineDawnColors.subtle
                : RosePineDawnColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: RosePineDawnColors.overlay),
          ),
          child: Stack(
            children: [
              Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    widget.text,
                    style: TextStyle(
                      fontSize: 18,
                      color: RosePineDawnColors.text,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Tooltip(
                  message: 'Download all',
                  child: IconButton(
                    onPressed: () {},
                    icon: Icon(CupertinoIcons.cloud_download),
                    color: RosePineDawnColors.love,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
