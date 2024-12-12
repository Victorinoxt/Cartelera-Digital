final fileStateProvider = StateNotifierProvider<FileStateNotifier, FileState>((ref) {
  return FileStateNotifier();
});

class FileState {
  final Map<String, FileStatus> uploadStatus;
  final List<String> recentFiles;
  final int totalUploaded;

  FileState({
    this.uploadStatus = const {},
    this.recentFiles = const [],
    this.totalUploaded = 0,
  });

  FileState copyWith({
    Map<String, FileStatus>? uploadStatus,
    List<String>? recentFiles,
    int? totalUploaded,
  }) {
    return FileState(
      uploadStatus: uploadStatus ?? this.uploadStatus,
      recentFiles: recentFiles ?? this.recentFiles,
      totalUploaded: totalUploaded ?? this.totalUploaded,
    );
  }
}

class FileStateNotifier extends StateNotifier<FileState> {
  FileStateNotifier() : super(FileState());

  Future<void> uploadFile(String path) async {
    try {
      // Actualizar estado de carga
      final currentStatus = {...state.uploadStatus};
      currentStatus[path] = FileStatus.uploading;
      state = state.copyWith(uploadStatus: currentStatus);

      // Lógica de carga aquí
      await Future.delayed(Duration(seconds: 1)); // Simulación

      // Actualizar estado completado
      currentStatus[path] = FileStatus.completed;
      final newRecentFiles = [path, ...state.recentFiles].take(10).toList();
      
      state = state.copyWith(
        uploadStatus: currentStatus,
        recentFiles: newRecentFiles,
        totalUploaded: state.totalUploaded + 1,
      );
    } catch (e) {
      final currentStatus = {...state.uploadStatus};
      currentStatus[path] = FileStatus.error;
      state = state.copyWith(uploadStatus: currentStatus);
    }
  }
}

enum FileStatus { initial, uploading, completed, error }
