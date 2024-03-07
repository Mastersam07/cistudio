import 'package:flutter/material.dart';

import 'models/ci_step.dart';

class Workbench extends StatefulWidget {
  const Workbench({super.key});

  @override
  WorkbenchState createState() => WorkbenchState();
}

class WorkbenchState extends State<Workbench> {
  List<CIStep> availableSteps = [
    CIStep(name: 'Checkout Repo', position: 1, isCompulsory: true),
    CIStep(name: 'Setup SSH', position: 2),
    CIStep(
        name: 'Setup & Cache Flutter',
        position: 3,
        isCompulsory: true,
        properties: {
          'cache': ['with', 'without']
        },
        defaultProperties: {
          'cache': 'with'
        }),
    CIStep(name: 'Get Dependencies', position: 4),
    CIStep(name: 'Dart Format', position: 5),
    CIStep(name: 'Lint check', position: 6),
    CIStep(name: 'Run Tests', position: 7, properties: {
      'coverage': ['with', 'without']
    }, defaultProperties: {
      'coverage': 'with'
    }),
    CIStep(name: 'Build android app', position: 8, properties: {
      'binary': ['apk', 'aab']
    }, defaultProperties: {
      'binary': 'apk'
    }),
    CIStep(name: 'Upload android binary to firebase distribution', position: 9),
    CIStep(name: 'Upload to playstore', position: 10),
    CIStep(name: 'Build ios app', position: 11),
    CIStep(name: 'Upload ios binary to firebase distribution', position: 12),
    CIStep(name: 'Upload to applestore & testflight', position: 13),
    CIStep(name: 'Notify via email', position: 14),
    CIStep(name: 'Notify via slack', position: 15),
  ];

  List<CIStep> selectedSteps = [];

  @override
  void initState() {
    super.initState();
    _addCompulsorySteps();
  }

  void _addCompulsorySteps() {
    // Automatically add compulsory steps to the selectedSteps list
    for (CIStep step in availableSteps) {
      if (step.isCompulsory) {
        selectedSteps.add(step);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: availableSteps.length,
            itemBuilder: (context, index) {
              final step = availableSteps[index];
              return Draggable<CIStep>(
                data: step,
                feedback: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width *
                        0.9, // Adjust the width as needed
                    minHeight:
                        50, // Minimum height for ListTile, adjust as needed
                  ),
                  child: Material(
                    // Wrapped in Material to ensure visual consistency in the feedback.
                    child: Card(
                      child: ListTile(
                        title: Text(step.name),
                      ),
                    ),
                  ),
                ),
                childWhenDragging: Card(
                  child: ListTile(
                    title: Text(step.name),
                    iconColor: Colors.grey,
                  ),
                ),
                child: Card(
                  child: ListTile(
                    title: Text(step.name),
                  ),
                ),
              );
            },
          ),
        ),
        Expanded(
          flex: 3,
          child: DragTarget<CIStep>(
            onAccept: (data) {
              setState(() {
                if (!selectedSteps.contains(data)) {
                  // Prevent adding duplicate steps
                  selectedSteps.add(data);
                }
              });
            },
            builder: (context, candidateData, rejectedData) {
              return Container(
                color: Colors.grey[200],
                child: ReorderableListView(
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) {
                        newIndex -= 1;
                      }
                      final item = selectedSteps.removeAt(oldIndex);
                      selectedSteps.insert(newIndex, item);
                    });
                  },
                  children: selectedSteps
                      .map((step) => ListTile(
                            key: ValueKey(step),
                            title: Text(step.name),
                            trailing: const Icon(Icons.menu),
                          ))
                      .toList(),
                ),
              );
            },
          ),
        ),
        Expanded(
          // Placeholder for the right column (Step settings)
          child: Container(
            color: Colors.grey[300],
            child: const Center(
              child: Text('Step Settings'),
            ),
          ),
        ),
      ],
    );
  }
}
