import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import '../downloader/downloader_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _urlCtrl = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _urlCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
  title: const Text('YouTube Music Downloader Pro'),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, cons) {
          final wide = cons.maxWidth > 800;
          final padding = EdgeInsets.symmetric(horizontal: wide ? 48 : 16, vertical: 12);
          return SingleChildScrollView(
            padding: padding,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
        // Header removed (AppBar already shows title)
                    _UrlInput(urlCtrl: _urlCtrl, focusNode: _focusNode),
                    const SizedBox(height: 16),
                    _FolderPicker(),
                    const SizedBox(height: 24),
                    _ProgressCard(),
                    const SizedBox(height: 24),
                    _ActionButtons(),
                    const SizedBox(height: 24),
                    _LogPanel(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _UrlInput extends StatelessWidget {
  final TextEditingController urlCtrl;
  final FocusNode focusNode;
  const _UrlInput({required this.urlCtrl, required this.focusNode});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DownloaderProvider>();
    urlCtrl.value = TextEditingValue(text: provider.url, selection: TextSelection.collapsed(offset: provider.url.length));

  String hint = 'Paste your YouTube URL here';
    String status = '';
    Color statusColor = const Color(0xFF16537E);
    final url = provider.url;
    if (url.isNotEmpty) {
      if (url.startsWith('http')) {
        if (url.contains('playlist') || url.contains('list=')) {
          status = '✅ Playlist URL detected';
          statusColor = const Color(0xFF00FF41);
        } else if (url.contains('youtu')) {
          status = '✅ Video URL detected';
          statusColor = const Color(0xFF00FF41);
        } else {
          status = '⚠️ Please use full YouTube URL (https://...)';
          statusColor = const Color(0xFFFFA502);
        }
      } else {
        status = '❌ Invalid URL - Please enter a YouTube URL';
        statusColor = const Color(0xFFFF4757);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
  const Text('YouTube URL:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E2E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF2C2C54)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: urlCtrl,
                  focusNode: focusNode,
                  onChanged: (v) => context.read<DownloaderProvider>().setUrl(v),
                  decoration: InputDecoration(
                    hintText: hint,
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Paste',
                onPressed: () async {
                  final prov = context.read<DownloaderProvider>();
                  final data = await Clipboard.getData('text/plain');
                  if (data?.text != null) {
                    prov.setUrl(data!.text!);
                  }
                },
                style: IconButton.styleFrom(backgroundColor: const Color(0xFF00FF41)),
                icon: const Icon(Icons.paste, color: Colors.black),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Clear',
                onPressed: () => context.read<DownloaderProvider>().setUrl(''),
                style: IconButton.styleFrom(backgroundColor: const Color(0xFFFF4757)),
                icon: const Icon(Icons.delete_forever, color: Colors.white),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        if (status.isNotEmpty) Text(status, style: TextStyle(color: statusColor, fontStyle: FontStyle.italic)),
      ],
    );
  }
}

class _FolderPicker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final p = context.watch<DownloaderProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('📁 Download Folder:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E2E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF2C2C54)),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  p.outputDir?.path ?? 'Loading...',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () async {
                  final dirPath = await getDirectoryPath();
                  if (dirPath != null) {
                    p.setOutputDir(Directory(dirPath));
                  }
                },
                icon: const Icon(Icons.folder_open),
                label: const Text('Browse'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProgressCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final p = context.watch<DownloaderProvider>();
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F23),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF16537E)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (p.currentTitle.isNotEmpty)
            Text(p.currentTitle, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00FF41))),
          if (p.totalFilesText.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(p.totalFilesText, style: const TextStyle(color: Color(0xFF16537E))),
            ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 200),
              tween: Tween(begin: 0, end: p.progress / 100),
              builder: (context, value, _) => LinearProgressIndicator(
                minHeight: 14,
                value: value,
                color: const Color(0xFF00FF41),
                backgroundColor: const Color(0xFF0A0A14),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${p.progress.toStringAsFixed(1)}%'),
              Row(children: [
                if (p.etaText.isNotEmpty) Text(p.etaText),
                const SizedBox(width: 10),
                if (p.speedText.isNotEmpty) Text(p.speedText, style: const TextStyle(color: Color(0xFF00FF41))),
              ]),
            ],
          ),
          const SizedBox(height: 8),
          Text(p.statusText, style: const TextStyle(color: Color(0xFF00FF41), fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final p = context.watch<DownloaderProvider>();
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 12,
        runSpacing: 12,
        children: [
          ElevatedButton(
            onPressed: p.isBusy ? null : () => p.start(),
            child: Text(p.isBusy ? 'Downloading…' : 'Start Download'),
          ),
          ElevatedButton(
            onPressed: p.isBusy ? () => p.stop() : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF4757),
              foregroundColor: Colors.white,
            ),
            child: const Text('Stop Download'),
          ),
        ],
      ),
    );
  }
}

class _LogPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final p = context.watch<DownloaderProvider>();
    return Container(
      height: 260,
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F23),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF16537E)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              children: [
                const Text('Activity Log:', style: TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                TextButton.icon(
                  onPressed: p.logs.isEmpty ? null : () => p.clearLogs(),
                  icon: const Icon(Icons.delete_forever, size: 18),
                  label: const Text('Clear'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: p.logs.length,
              itemBuilder: (context, i) {
                final e = p.logs[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text('[${p.formatTime(e.time)}] ${e.message}', style: const TextStyle(fontFamily: 'monospace')),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
