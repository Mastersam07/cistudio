import 'package:flutter/material.dart';

import '../downloader/web_downloader.dart';
import 'models/ci_step.dart';

class Workbench extends StatefulWidget {
  const Workbench({super.key});

  @override
  WorkbenchState createState() => WorkbenchState();
}

class WorkbenchState extends State<Workbench> {
  List<CIStep> availableSteps = [
    CIStep(
      name: 'Runs On',
      isCompulsory: true,
      position: 0,
    ),
    CIStep(
      name: 'Trigger Events',
      isCompulsory: true,
      position: 1,
    ),
    CIStep(name: 'Checkout Repo', position: 1, isCompulsory: true),
    CIStep(name: 'Setup SSH', position: 2),
    CIStep(
      name: 'Setup & Cache Flutter',
      position: 2,
      isCompulsory: true,
    ),
    CIStep(name: 'Get Dependencies', position: 3),
    CIStep(name: 'Dart Format', position: 4),
    CIStep(name: 'Lint Check', position: 5),
    CIStep(name: 'Run Tests', position: 6),
    CIStep(name: 'Build android app', position: 7),
    CIStep(name: 'Upload android binary to firebase distribution', position: 8),
    CIStep(name: 'Upload to playstore', position: 9),
    CIStep(name: 'Build ios app', position: 10),
    CIStep(name: 'Upload ios binary to firebase distribution', position: 11),
    CIStep(name: 'Upload to applestore & testflight', position: 12),
    CIStep(name: 'Notify via email', position: 13),
    CIStep(name: 'Notify via slack', position: 14),
  ];

  List<CIStep> selectedSteps = [];

  CIStep? selectedStep;

  void selectStep(CIStep step) {
    setState(() {
      selectedStep = step;
    });
  }

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
                    key: ValueKey(step.slug),
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
          child: Material(
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
                        .map(
                          (step) => ListTile(
                            key: ValueKey(step.slug),
                            title: Text(step.name),
                            subtitle: step.isCompulsory
                                ? const Text('Compulsory Step')
                                : null,
                            onTap: () => selectStep(step),
                            selected: selectedStep?.name == step.name,
                            selectedTileColor:
                                Colors.lightBlueAccent.withOpacity(0.3),
                          ),
                        )
                        .toList(),
                  ),
                );
              },
            ),
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: selectedStep == null
                    ? const Center(
                        child: Text('Select a step to view/edit its settings'))
                    : _buildStepSettings(selectedStep!),
              ),
              const Divider(height: 2, thickness: 1, color: Colors.grey),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Export Configuration',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        ElevatedButton(
                          onPressed: _exportGitHubActions,
                          child: const Text('GitHub Actions'),
                        ),
                        ElevatedButton(
                          onPressed: _exportGitLabCI,
                          child: const Text('GitLab CI'),
                        ),
                        ElevatedButton(
                          onPressed: _exportAzureDevOps,
                          child: const Text('Azure DevOps'),
                        ),
                        ElevatedButton(
                          onPressed: _exportBitbucketPipeline,
                          child: const Text('Bitbucket Pipeline'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _exportGitHubActions() {
    StringBuffer yaml = StringBuffer();

    // Standard workflow setup
    yaml.writeln('name: CI Workflow');

    // Handling "Trigger Events"
    CIStep triggerEventsStep = selectedSteps.firstWhere(
      (step) => step.name == 'Trigger Events',
      orElse: () => CIStep(
        name: 'Trigger Events',
        isCompulsory: true,
        position: 1,
      ),
    );
    String events = triggerEventsStep.defaultProperties['events'];
    yaml.write('on: [');
    yaml.write(events);
    yaml.writeln(']');

    yaml.writeln('jobs:');
    yaml.writeln('  build:');

    // Handling "Runs On"
    CIStep runsOnStep = selectedSteps.firstWhere(
        (step) => step.name == 'Runs On',
        orElse: () => CIStep(
            name: 'Runs On',
            position: 0,
            properties: {},
            defaultProperties: {'runner': 'ubuntu-latest'}));
    String runner = runsOnStep.defaultProperties['runner'];
    yaml.writeln('    runs-on: $runner');

    // Initial checkout step
    yaml.writeln('    steps:');
    yaml.writeln('      - uses: actions/checkout@v2');

    // Iterate through selected steps to add them to the YAML configuration
    for (CIStep step in selectedSteps) {
      switch (step.name) {
        case 'Setup SSH':
          // Example: Adding a step for setting up SSH
          yaml.writeln('      - name: Setup SSH');
          yaml.writeln('        uses: webfactory/ssh-agent@v0.5.3');
          yaml.writeln('        with:');
          yaml.writeln(
              '          ssh-private-key: \${{ secrets.SSH_PRIVATE_KEY }}');
          break;
        case 'Setup & Cache Flutter':
          yaml.writeln('      - name: Setup Flutter');
          yaml.writeln('        uses: subosito/flutter-action@v1');
          if (step.defaultProperties.containsKey('cache') &&
              step.defaultProperties['cache'] == 'with') {
            yaml.writeln('      - name: Cache Flutter Dependencies');
            yaml.writeln('        uses: actions/cache@v2');
            yaml.writeln('        with:');
            yaml.writeln('          path: ~/.pub-cache');
            yaml.writeln(
                '          key: \${{ runner.os }}-pub-cache-\${{ hashFiles(\'**/pubspec.yaml\') }}');
          }
          break;
        case 'Get Dependencies':
          yaml.writeln('      - name: Get Flutter Dependencies');
          yaml.writeln('        run: flutter pub get');
          break;
        case 'Dart Format':
          yaml.writeln('      - name: Check Dart Formatting');
          yaml.writeln(
              '        run: dart format --output=none --set-exit-if-changed .');
          break;
        case 'Lint Check':
          yaml.writeln('      - name: Run Lint Check');
          yaml.writeln('        run: flutter analyze .');
          break;
        case 'Run Tests':
          yaml.writeln('      - name: Run Flutter Tests');
          yaml.writeln('        run: flutter test --coverage');
          if (step.defaultProperties.containsKey('coverage') &&
              step.defaultProperties['coverage'] == 'with') {
            yaml.writeln('      - name: Upload coverage reports to Codecov');
            yaml.writeln('        uses: codecov/codecov-action@v4.0.1');
            yaml.writeln('        with:');
            yaml.writeln('          token: \${{ secrets.CODECOV_TOKEN }}');
            yaml.writeln('          file: ./coverage/lcov.info');
          }
          break;
        case 'Build android app':
          if (step.defaultProperties['binary'] == 'apk') {
            yaml.writeln('      - name: Build Android APK');
            yaml.writeln('        run: flutter build apk');
          }
          if (step.defaultProperties['binary'] == 'aab') {
            yaml.writeln('      - name: Build Android App Bundle');
            yaml.writeln('        run: flutter build appbundle');
          }
          break;
        case 'Upload android binary to firebase distribution':
          yaml.writeln(
              '      - name: Upload Android binary to Firebase App Distribution');
          yaml.writeln(
              '        uses: wzieba/Firebase-Distribution-Github-Action@v1');
          yaml.writeln('        with:');
          yaml.writeln('          appId: \${{secrets.FIREBASE_APP_ID}}');
          yaml.writeln(
              '          serviceCredentialsFileContent: \${{ secrets.CREDENTIAL_FILE_CONTENT }}');
          yaml.writeln('          groups: testers');
          if (selectedSteps
                  .firstWhere((step) => step.slug == 'build-android-app')
                  .defaultProperties['binary'] ==
              'apk') {
            yaml.writeln(
                '          file: build/app/outputs/flutter-apk/app-release.apk');
          }
          if (selectedSteps
                  .firstWhere((step) => step.slug == 'build-android-app')
                  .defaultProperties['binary'] ==
              'aab') {
            yaml.writeln(
                '          file: build/app/outputs/flutter-apk/app-release.aab');
          }
          break;
        case 'Upload to playstore':
          yaml.writeln('      - name: Upload APK to Google Play');
          yaml.writeln('        uses: r0adkll/upload-google-play@v1');
          yaml.writeln('        with:');
          yaml.writeln(
              '          serviceAccountJsonPlainText: \${{ secrets.SERVICE_ACCOUNT_JSON }}');
          yaml.writeln('          packageName: com.example.app');
          if (selectedSteps
                  .firstWhere((step) => step.slug == 'build-android-app')
                  .defaultProperties['binary'] ==
              'apk') {
            yaml.writeln(
                '          releaseFiles: build/app/outputs/flutter-apk/app-release.apk');
          }
          if (selectedSteps
                  .firstWhere((step) => step.slug == 'build-android-app')
                  .defaultProperties['binary'] ==
              'aab') {
            yaml.writeln(
                '          releaseFiles: build/app/outputs/flutter-apk/app-release.aab');
          }
          yaml.writeln('          track: beta');
          break;
        case 'Build ios app':
          yaml.writeln('      - name: Build iOS and Export IPA');
          yaml.writeln('        uses: yukiarrr/ios-build-action@v0.6.0');
          yaml.writeln('        with:');
          yaml.writeln(
              '          project-path: YourProject.xcodeproj # or .xcworkspace');
          yaml.writeln('          p12-base64: \${{secrets.P12_BASE64}}');
          yaml.writeln(
              '          mobileprovision-base64: \${{ secrets.MOBILEPROVISION_BASE64 }}');
          yaml.writeln(
              '          code-signing-identity: "iPhone Distribution"');
          yaml.writeln('          team-id: \${{secrets.TEAM_ID}}');
          yaml.writeln(
              '          workspace-path: YourWorkspace.xcworkspace # if using a workspace');
          yaml.writeln('          scheme: YourSchemeName');
          yaml.writeln('          configuration: Release');
          break;
        case 'Upload ios binary to firebase distribution':
          yaml.writeln(
              '      - name: Upload iOS binary to Firebase App Distribution');
          yaml.writeln(
              '        uses: wzieba/Firebase-Distribution-Github-Action@v1');
          yaml.writeln('        with:');
          yaml.writeln('          appId: \${{secrets.FIREBASE_APP_ID}}');
          yaml.writeln(
              '          serviceCredentialsFileContent: \${{ secrets.CREDENTIAL_FILE_CONTENT }}');
          yaml.writeln('          groups: testers');
          yaml.writeln('          file: path/to/your/app.ipa');
          break;
        case 'Upload to applestore & testflight':
          yaml.writeln('      - name: Upload IPA to TestFlight');
          yaml.writeln('        uses: apple-actions/upload-testflight@v1');
          yaml.writeln('        with:');
          yaml.writeln('          app-path: path/to/your/app.ipa');
          yaml.writeln(
              '          api-key-id: \${{ secrets.APPSTORE_API_KEY_ID }}');
          yaml.writeln('          issuer-id: \${{secrets.APPLE_ISSUER_ID}}');
          yaml.writeln('          api-key-id: \${{secrets.APPLE_API_KEY_ID}}');
          yaml.writeln(
              '          api-private-key: \${{secrets.APPLE_API_PRIVATE_KEY}}');
          break;
        case 'Notify via email':
          yaml.writeln('      - name: Send Notification Email');
          yaml.writeln('        uses: dawidd6/action-send-mail@v2');
          yaml.writeln('        with:');
          yaml.writeln('          server_address: smtp.example.com');
          yaml.writeln('          server_port: 587');
          yaml.writeln('          username: \${{secrets.EMAIL_USERNAME}}');
          yaml.writeln('          password: \${{secrets.EMAIL_PASSWORD}}');
          yaml.writeln('          subject: CI Build Notification');
          yaml.writeln('          body: Build completed successfully');
          yaml.writeln('          to: user@example.com');
          yaml.writeln('          from: CI Server <ci@example.com>');
          break;
        case 'Notify via slack':
          yaml.writeln('      - name: Notify Slack');
          yaml.writeln('        uses: rtCamp/action-slack-notify@v2');
          yaml.writeln('        env:');
          yaml.writeln('          SLACK_CHANNEL: your_slack_channel');
          yaml.writeln('          SLACK_COLOR: "#FF0000"');
          yaml.writeln('          SLACK_ICON: https://example.com/icon.png');
          yaml.writeln(
              '          SLACK_MESSAGE: "Deployment finished successfully"');
          yaml.writeln('          SLACK_TITLE: "Deployment Notification"');
          yaml.writeln('          SLACK_USERNAME: GitHubAction');
          yaml.writeln(
              '          SLACK_WEBHOOK: \${{ secrets.SLACK_WEBHOOK }}');
          break;
      }
    }

    downloadFile(yaml.toString(), 'ci_workflow.yml');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('CI workflow file has been downloaded.')),
    );
  }

  void _exportGitLabCI() {}

  void _exportAzureDevOps() {}

  void _exportBitbucketPipeline() {}

  Widget _buildStepSettings(CIStep step) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Text('Editing Step: ${step.name}'),
          ...step.properties.keys
              .map((property) => _buildPropertyEditor(step, property))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildPropertyEditor(CIStep step, String property) {
    var propertyValues = step.properties[property]!;
    var defaultValue = step.defaultProperties[property];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
            child: Text(
              property,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Material(
            child: DropdownButton<dynamic>(
              key: ValueKey('dropdown-$property'),
              value: defaultValue,
              onChanged: (newValue) {
                setState(() {
                  step.defaultProperties[property] = newValue;
                });
              },
              items: propertyValues.map<DropdownMenuItem<dynamic>>((value) {
                return DropdownMenuItem<dynamic>(
                  value: value,
                  child: Text(value.toString()),
                );
              }).toList(),
              isExpanded: true,
            ),
          ),
        ],
      ),
    );
  }
}
