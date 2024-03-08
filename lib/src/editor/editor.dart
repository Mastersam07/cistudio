import 'package:flutter/material.dart';
import '../models/ci_step.dart';

class Editor extends StatelessWidget {
  final List<CIStep> selectedSteps;
  final void Function(CIStep)? onAccept;
  final Function(int oldIndex, int newIndex) onReorder;
  final void Function(CIStep step)? onTap;
  final CIStep? selectedStep;

  const Editor({
    Key? key,
    required this.selectedSteps,
    required this.onReorder,
    this.onAccept,
    this.onTap,
    this.selectedStep,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DragTarget<CIStep>(
      onAccept: onAccept,
      builder: (context, candidateData, rejectedData) {
        return Container(
          color: Colors.grey[200],
          child: ReorderableListView(
            onReorder: onReorder,
            children: selectedSteps
                .map(
                  (step) => ListTile(
                    key: ValueKey(step.slug),
                    title: Text(step.name),
                    subtitle: step.isCompulsory
                        ? const Text('Compulsory Step')
                        : null,
                    onTap: () {
                      if (onTap != null) onTap!(step);
                    },
                    selected: selectedStep?.name == step.name,
                    selectedTileColor: Colors.lightBlueAccent.withOpacity(0.3),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }
}
