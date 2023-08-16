import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:synchronyx/widgets/platform_tile_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/platforms.dart';
import '../utilities/generic_functions.dart';

class PlatformTreeView extends StatefulWidget {
  final AppLocalizations appLocalizations;
  const PlatformTreeView({super.key, required this.appLocalizations});

  @override
  State<PlatformTreeView> createState() => _PlatformTreeViewState();
}

class _PlatformTreeViewState extends State<PlatformTreeView> {
  late final TreeController<Platforms> treeController;
  static List<Platforms> roots = [];

  @override
  void initState() {
    super.initState();
    roots = <Platforms>[
      Platforms(
          title: widget.appLocalizations.all,
          icon: const Image(
            image: AssetImage("assets/icons/allPlatforms.png"),
            width: 44,
            height: 44,
            color: null,
            //fit: BoxFit.scaleDown,
            //alignment: Alignment.center,
          )),
      Platforms(
        title: widget.appLocalizations.computers,
        icon: const Image(
          image: AssetImage("assets/icons/Amstrad CPC.png"),
          width: 34,
          height: 34,
          color: null,
          //fit: BoxFit.scaleDown,
          //alignment: Alignment.center,
        ),
        children: <Platforms>[
          Platforms(
            title: 'Node 1.1',
            children: <Platforms>[
              Platforms(
                title: 'Node 1.1.1',
              ),
              Platforms(
                title: 'Node 1.1.2',
              ),
            ],
          ),
          Platforms(
            title: 'Node 1.2',
          ),
        ],
      ),
      Platforms(
        title: 'Root 2',
        children: <Platforms>[
          Platforms(
            title: 'Node 2.1',
            children: <Platforms>[
              Platforms(
                title: 'Node 2.1.1',
              ),
            ],
          ),
          Platforms(
            title: 'Node 2.2',
          )
        ],
      ),
    ];

    treeController = TreeController<Platforms>(
      // Provide the root nodes that will be used as a starting point when
      // traversing your hierarchical data.
      roots: roots,
      // Provide a callback for the controller to get the children of a
      // given node when traversing your hierarchical data. Avoid doing
      // heavy computations in this method, it should behave like a getter.
      childrenProvider: (Platforms node) => node.children,
    );
  }

  @override
  void dispose() {
    // Remember to dispose your tree controller to release resources.
    treeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // This package provides some different tree views to customize how
    // your hierarchical data is incorporated into your app. In this example,
    // a TreeView is used which has no custom behaviors, if you wanted your
    // tree nodes to animate in and out when the parent node is expanded
    // and collapsed, the AnimatedTreeView could be used instead.
    //
    // The tree view widgets also have a Sliver variant to make it easy
    // to incorporate your hierarchical data in sophisticated scrolling
    // experiences.
    return TreeView<Platforms>(
      // This controller is used by tree views to build a flat representation
      // of a tree structure so it can be lazy rendered by a SliverList.
      // It is also used to store and manipulate the different states of the
      // tree nodes.
      treeController: treeController,
      // Provide a widget builder callback to map your tree nodes into widgets.
      nodeBuilder: (BuildContext context, TreeEntry<Platforms> entry) {
        // Provide a widget to display your tree nodes in the tree view.
        //
        // Can be any widget, just make sure to include a [TreeIndentation]
        // within its widget subtree to properly indent your tree nodes.
        return PlatformTreeTile(
          // Add a key to your tiles to avoid syncing descendant animations.
          key: ValueKey(entry.node),
          // Your tree nodes are wrapped in TreeEntry instances when traversing
          // the tree, these objects hold important details about its node
          // relative to the tree, like: expansion state, level, parent, etc.
          //
          // TreeEntrys are short lived, each time TreeController.rebuild is
          // called, a new TreeEntry is created for each node so its properties
          // are always up to date.
          entry: entry,
          // Add a callback to toggle the expansion state of this node.
          onTap: () => treeController.toggleExpansion(entry.node),
        );
      },
    );
  }
}