class DeviceInfo {
  final String? deviceName;
  final double? cpuUsage;
  final double? appCPUUsage;
  final int? memoryUsed;
  final int? memoryTotal;
  final int? memoryFree;
  final double? appUsedMemory;
  final int? appSize;
  final int? usedDiskSpace;
  final int? freeDiskSpace;
  final int? totalDiskSpace;

  const DeviceInfo(
      {this.deviceName,
      this.cpuUsage,
      this.appCPUUsage,
      this.memoryUsed,
      this.memoryTotal,
      this.memoryFree,
      this.appUsedMemory,
      this.appSize,
      this.usedDiskSpace,
      this.freeDiskSpace,
      this.totalDiskSpace});

  static DeviceInfo fromMap(Map<String, dynamic> map) {
    return DeviceInfo(
        deviceName: map['deviceName'],
        cpuUsage: map['cpuUsage'],
        appCPUUsage: map['appCPUUsage'],
        memoryUsed: map['memoryUsed'],
        memoryFree: map['memoryFree'],
        memoryTotal: map['memoryTotal'],
        appUsedMemory: map['appUsedMemory'],
        appSize: map['appSize'],
        usedDiskSpace: map['usedDiskSpace'],
        freeDiskSpace: map['freeDiskSpace'],
        totalDiskSpace: map['totalDiskSpace']);
  }

  @override
  String toString() {
    return 'DeviceInfo{deviceName: $deviceName, cpuUsage: $cpuUsage, appCPUUsage: $appCPUUsage, memoryUsed: $memoryUsed, memoryTotal: $memoryTotal, memoryFree: $memoryFree, appUsedMemory: $appUsedMemory, appSize: $appSize, usedDiskSpace: $usedDiskSpace, freeDiskSpace: $freeDiskSpace, totalDiskSpace: $totalDiskSpace}';
  }
}
