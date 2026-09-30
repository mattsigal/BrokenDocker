import '../../data/services/ssh_connection_service.dart';

class SystemInfo {
  final String hostname;
  final String uptime;
  final String cpuInfo;
  final String memoryInfo;
  final String diskInfo;
  final String osInfo;
  final String kernelInfo;
  final String loadAverage;

  SystemInfo({
    required this.hostname,
    required this.uptime,
    required this.cpuInfo,
    required this.memoryInfo,
    required this.diskInfo,
    required this.osInfo,
    required this.kernelInfo,
    required this.loadAverage,
  });
}

class SystemInfoService {
  final SSHConnectionService _sshService = SSHConnectionService();

  Future<SystemInfo> getSystemInfo() async {
    if (!_sshService.isConnected) {
      throw Exception('No SSH connection available');
    }

    try {
      // Get hostname
      final hostname = await _sshService.executeCommand('hostname') ?? 'Unknown';

      // Get uptime
      final uptime = await _sshService.executeCommand('uptime') ?? 'Unknown';

      // Get CPU info (checks lscpu, falls back to /proc/cpuinfo)
      final cpuInfo = await _sshService.executeCommand(
        'which lscpu >/dev/null 2>&1 && lscpu | grep "Model name" | cut -d: -f2 | xargs || grep -m1 "model name" /proc/cpuinfo | cut -d: -f2 | sed -e "s/^[[:space:]]*//"'
      ) ?? 'Unknown';

      // Get memory info
      final memoryInfo = await _sshService.executeCommand(
        'free -h | grep "Mem:" | awk \'{print "Used: " \$3 " / Total: " \$2 " (" \$3/\$2*100 "%)"}\'') ?? 'Unknown';

      // Get disk info
      final diskInfo = await _sshService.executeCommand(
        'df -h / | tail -1 | awk \'{print "Used: " \$3 " / Total: " \$2 " (" \$5 ")"}\'') ?? 'Unknown';

      // Get OS info (supports /etc/os-release or Synology /etc/VERSION)
      final osInfo = await _sshService.executeCommand(
        '[ -f /etc/os-release ] && grep "PRETTY_NAME" /etc/os-release | cut -d= -f2 | tr -d \'"\' || ([ -f /etc/VERSION ] && echo "Synology DSM \$(grep productversion /etc/VERSION | cut -d\'"\' -f2)") || uname -s'
      ) ?? 'Unknown';

      // Get kernel info
      final kernelInfo = await _sshService.executeCommand('uname -r') ?? 'Unknown';

      // Get load average
      final loadAverage = await _sshService.executeCommand(
        'cat /proc/loadavg | awk \'{print \$1 " " \$2 " " \$3}\'') ?? 'Unknown';

      return SystemInfo(
        hostname: hostname.trim(),
        uptime: uptime.trim(),
        cpuInfo: cpuInfo.trim(),
        memoryInfo: memoryInfo.trim(),
        diskInfo: diskInfo.trim(),
        osInfo: osInfo.trim(),
        kernelInfo: kernelInfo.trim(),
        loadAverage: loadAverage.trim(),
      );
    } catch (e) {
      throw Exception('Failed to get system info: $e');
    }
  }
}