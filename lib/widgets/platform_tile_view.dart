import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:synchronyx/models/platforms.dart';
import 'package:synchronyx/widgets/custom_folder_button.dart';

class PlatformTreeTile extends StatelessWidget {
  const PlatformTreeTile({
    super.key,
    required this.entry,
    required this.onTap,
  });

  final TreeEntry<Platforms> entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      // Wrap your content in a TreeIndentation widget which will properly
      // indent your nodes (and paint guides, if required).
      //
      // If you don't want to display indent guides, you could replace this
      // TreeIndentation with a Padding widget, providing a padding of
      // `EdgeInsetsDirectional.only(start: TreeEntry.level * indentAmount)`
      /*child: Padding(
          padding: EdgeInsetsDirectional.only(start: TreeEntry.level * 2),
        )*/
      child: TreeIndentation(
        entry: entry,
        // Provide an indent guide if desired. Indent guides can be used to
        // add decorations to the indentation of tree nodes.
        // This could also be provided through a DefaultTreeIndentGuide
        // inherited widget placed above the tree view.
        guide: const IndentGuide.connectingLines(indent: 25),
        // The widget to render next to the indentation. TreeIndentation
        // respects the text direction of `Directionality.maybeOf(context)`
        // and defaults to left-to-right.
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              // Add a widget to indicate the expansion state of this node.
              // See also: ExpandIcon.
              Expanded(
                  flex: 1,
                  child: CustomFolderButton(
                    hoverColor: Colors.blue,
                    icon: entry.node.icon,
                    title: Text(entry.node.title),
                    //iconSize: 80,
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    closedIcon: const Icon(
                      Icons.arrow_right,
                    ),
                    openedIcon: const Icon(
                      Icons.arrow_drop_down,
                    ),
                    isOpen: entry.hasChildren ? entry.isExpanded : null,
                    onPressed: entry.hasChildren ? onTap : null,
                  )), // Add spacing between icons
            ],
          ),
        ),
      ),
    );
  }
}
